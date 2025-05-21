$packages = @(
    "wireshark",               # Wireshark
    "virtualbox",              # VirtualBox
    "docker-desktop",          # Docker
    "filius",                  # Filius 
    "vscode",                  # Visual Studio Code
    "openjdk",                 # Java SDK (Neuestes LTS)
    "maven",                   # Maven
    "git",                     # Git
    "nodejs",                  # Node.js (Spätere Installation von Node-RED via npm )
    "arduino",                 # Arduino IDE
    "xampp",                   # XAMPP
    "mysqL.workbench",         # MySQL Workbench
    "notepadplusplus"          # Notepad++
)

# Falls Chocolatey nicht installiert ist, installiere Chocolatey
IF (-not (Test-Path -Path "$env:programdata\Chocolatey")){
    Write-Host "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force; `
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; `
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) 
    Invoke-Item -Path "$env:programdata\chocolatey\redirects\RefreshEnv.cmd"
}

Invoke-Item -Path "$env:programdata\chocolatey\redirects\RefreshEnv.cmd"
# Installiere Programme falls noch nicht installiert
foreach ($package in $packages) {
    $installed = choco list  | Select-String -Pattern $package
    if (-not $installed) {
        Write-Host "Installing $package..."
        # Bestätige Installation automatisch
        choco install -y $package 
    } else {
        Write-Host "$package is already installed."
    }
}
IF ( Get-Command node-red -ErrorAction SilentlyContinue){
    npm install -g --unsafe-perm node-red
}
# Pfad zu Visual Studio Code
$vscodePath = "$env:ProgramFiles\Microsoft VS Code\bin"

# Überprüfen, ob der Pfad bereits in der PATH-Umgebungsvariablen vorhanden ist
if (-not ($env:Path -split ';' | Where-Object { $_ -eq $vscodePath })) {
    # Fügen Sie den VSCode-Pfad zur PATH-Umgebungsvariablen hinzu
    [System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";$vscodePath", [System.EnvironmentVariableTarget]::Machine)
    
    # Aktualisieren Sie die aktuelle PowerShell-Sitzung
    $env:Path += ";$vscodePath"
}

$javaextensionpack = "vscjava.vscode-java-pack"
code --install-extension $javaextensionpack
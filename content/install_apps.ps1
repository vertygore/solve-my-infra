# Speichere Process ID in einer Variable zur späteren Verwendung.
$hwnd = (Get-Process -Id $PID).MainWindowHandle
# Injiziere ein kurzes C Skript
Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class Win32 {
        [DllImport("user32.dll")]
        public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    }
"@
# Führe Programm im Hintergrund aus.
[Win32]::ShowWindow($hwnd, 0)  

# Liste der zu installierenden Programme
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
    Start-Process cmd.exe -ArgumentList "/c `"$env:ProgramData\chocolatey\redirects\RefreshEnv.cmd`"" -WindowStyle Hidden -NoNewWindow -Wait

}
# Lade env:Variablen neu.
Start-Process cmd.exe -ArgumentList "/c `"$env:ProgramData\chocolatey\redirects\RefreshEnv.cmd`"" -WindowStyle Hidden -NoNewWindow -Wait

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
# Installiere Java Extension oder hole das neueste Update
$javaextensionpack = "vscjava.vscode-java-pack"
code --install-extension $javaextensionpack --force
# Nach Installation aufräumen.
Get-ChildItem -Path $env:TEMP -Filter "chocolatey*" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

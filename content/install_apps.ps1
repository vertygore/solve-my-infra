# Liste der zu installierenden Programme
$packages = @(
    "wireshark", # Wireshark
    "virtualbox", # VirtualBox
    "docker-desktop", # Docker
    "filius", # Filius 
    "vscode", # Visual Studio Code
    "openjdk", # Java SDK (Neuestes LTS)
    "maven", # Maven
    "git", # Git
    "nodejs", # Node.js (Spätere Installation von Node-RED via npm )
    "arduino", # Arduino IDE
    "xampp", # XAMPP
    "mysqL.workbench", # MySQL Workbench
    "notepadplusplus"          # Notepad++
)

IF ($IsWindows) {
    # Falls Chocolatey nicht installiert ist, installiere Chocolatey
    IF (-not (Test-Path -Path "$env:programdata\Chocolatey")) {
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
        }
        else {
            Write-Host "$package is already installed."
        }
    }
    IF ( Get-Command node-red -ErrorAction SilentlyContinue) {
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
}

elseif ($IsLinux) {
    $lpackages = @(
        "wireshark",
        "virtualbox",
        "filius",
        "snapd",
        "notepad-plus-plus",
        "docker.io",
        "openjdk-17-jdk",
        "maven",
        "git",
        "nodejs",
        "npm",
        "arduino",
        "mysql-workbench",
        "code"  # VSCode
    )
    
    # Install basic requirements for the system / update it to the newest compatible version
    sudo apt update; sudo apt full-upgrade -y

    # Ensure basic tools are available
    sudo apt install -y software-properties-common apt-transport-https wget curl gnupg2

    # Add the Microsoft GPG Key and repo for VS Code if not already present
    #GPG: GNU Privacy Guard is responsible for authentification of the received packages
    if (-not (Test-Path /etc/apt/sources.list.d/vscode.list)) {
        curl -sSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
        echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
        sudo apt update
    }

    # Install Node-RED if not present
    #-z checks if string is empty, which returns an empty string if node-red isnt installed
    if (-z $(which node-red)) {
        sudo npm install -g --unsafe-perm node-red
    }

    # Install packages
    sudo apt install -y $lpackages

    # Clean up
    sudo apt autoremove -y
    sudo apt autoclean -y
}
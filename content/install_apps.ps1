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
    "mysql.workbench", # MySQL Workbench
    "notepadplusplus"          # Notepad++
)

IF ($IsWindows) {
# Überprüfen, ob Chocolatey installiert ist und funktioniert
$chocoWorks = $false
try {
    $chocoVersion = choco --version 2>$null
    if ($LASTEXITCODE -eq 0 -and $chocoVersion) {
        $chocoWorks = $true
    }
} catch {
    $chocoWorks = $false
}

if (-not $chocoWorks) {
    Write-Host "Chocolatey is not installed or not working. Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    Start-Process cmd.exe -ArgumentList "/c `"$env:ProgramData\chocolatey\redirects\RefreshEnv.cmd`"" -WindowStyle Hidden -NoNewWindow -Wait
}
    # Lade env:Variablen neu.
    Start-Process cmd.exe -ArgumentList "/c `"$env:ProgramData\chocolatey\redirects\RefreshEnv.cmd`"" -WindowStyle Hidden -NoNewWindow -Wait

    # Installiere Programme falls noch nicht installiert
    foreach ($package in $packages) {
        $installed = choco list --local-only --exact $package | Select-String -Pattern $package
        if (-not $installed) {
            Write-Host "Installing $package..."
            # Bestätige Installation automatisch
            choco install -y $package 
        }
        else {
            Write-Host "$package is already installed."
        }
    }
    IF ( -not (Get-Command node-red -ErrorAction SilentlyContinue)) {
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
       $bashScript = @"
#!/bin/bash
set -e

packages=(
    wireshark virtualbox filius snapd docker.io openjdk-17-jdk
    maven git nodejs npm arduino mysql-workbench code
)

sudo apt update && sudo apt full-upgrade -y
sudo apt install -y software-properties-common apt-transport-https wget curl gnupg2

if [ ! -f /etc/apt/sources.list.d/vscode.list ]; then
    curl -sSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
    echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
    sudo apt update
fi

if ! dpkg -l | grep -q virtualbox; then
    wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/oracle_vbox.gpg > /dev/null
    echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/oracle_vbox.gpg] https://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
    sudo apt update
    sudo apt install -y virtualbox-7.0
fi

for pkg in "${packages[@]}"; do
    if ! dpkg -l | grep -q "$pkg"; then
        echo "Installing $pkg..."
        sudo apt install -y "$pkg"
    else
        echo "$pkg already installed."
    fi
done

if ! command -v node-red &> /dev/null; then
    sudo npm install -g --unsafe-perm node-red
fi

sudo systemctl enable --now snapd
if ! snap list | grep -q notepad-plus-plus; then
    sudo snap install notepad-plus-plus
fi

sudo apt autoremove -y
sudo apt autoclean -y
"@

 # bash-Skript schreiben und ausführen
    $tempFile = "/tmp/install-linux.sh"
    $bashScript | Out-File -FilePath $tempFile -Encoding ASCII
    chmod +x $tempFile
    bash $tempFile
}
else {
    Write-Host "Unsupported operating system. This script only supports Windows and Linux."
    exit 1
}
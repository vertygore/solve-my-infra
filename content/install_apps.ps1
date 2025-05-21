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
    # Falls Chocolatey nicht installiert ist, installiere Chocolatey
    IF (-not (Test-Path -Path "$env:programdata\Chocolatey")) {
        Write-Host "Installing Chocolatey..."
        Set-ExecutionPolicy Bypass -Scope Process -Force; `
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; `
            iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) 
        Start-Process cmd.exe -ArgumentList "/c ⁠ "$env:ProgramData\chocolatey\redirects\RefreshEnv.cmd ⁠"" -WindowStyle Hidden -NoNewWindow -Wait

    }
    # Lade env:Variablen neu.
    Start-Process cmd.exe -ArgumentList "/c ⁠ "$env:ProgramData\chocolatey\redirects\RefreshEnv.cmd ⁠"" -WindowStyle Hidden -NoNewWindow -Wait

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
        "docker.io",
        "openjdk-17-jdk",
        "maven",
        "git",
        "nodejs",
        "npm",
        "arduino",
        "mysql-workbench",
        "code"
    )

    sudo apt update
    sudo apt full-upgrade -y
    sudo apt install -y software-properties-common apt-transport-https wget curl gnupg2

    $vscodeListPath = "/etc/apt/sources.list.d/vscode.list"
    if (-not (Test-Path "/etc/apt/trusted.gpg.d")) {
        sudo mkdir -p /etc/apt/trusted.gpg.d
    }

    if (-not (Test-Path $vscodeListPath)) {
        curl -sSL https://packages.microsoft.com/keys/microso
        ft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > $null
        "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" | sudo tee $vscodeListPath > $null
        sudo apt update
    }

    if (-not (Get-Command node-red -ErrorAction SilentlyContinue)) {
        sudo npm install -g --unsafe-perm node-red
    }

    foreach ($pkg in $lpackages) {
        sudo apt install -y $pkg
    }

    # Ensure snapd is started (some distros require this)
    sudo systemctl enable snapd
    sudo systemctl start snapd

    if (-not (Get-Command notepad-plus-plus -ErrorAction SilentlyContinue)) {
        sudo snap install notepad-plus-plus
    }

    sudo apt autoremove -y
    sudo apt autoclean -y
}
elseif ($IsMacOS) {
    # Liste der zu installierenden Programme
    $mpackages = @(
        "wireshark",
        "virtualbox",
        "filius",
        "docker",
        "notepad-plus-plus",
        "openjdk",
        "maven",
        "git",
        "nodejs",
        "arduino",
        "mysql-workbench"
    )

    # Installiere Homebrew, falls nicht vorhanden
    if (-not (Get-Command brew -ErrorAction SilentlyContinue)) {
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    }

    # Installiere Programme
    foreach ($pkg in $mpackages) {
        brew install $pkg
    }
}
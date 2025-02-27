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
foreach($package in $packages){
    choco uninstall $package -y --remove-dependencies
}
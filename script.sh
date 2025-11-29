#!/bin/bash
# Workflow by aldenpartridge
# Setup for the bug bounty workflow

# Check if OS argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <ubuntu|arch|windows>"
    exit 1
fi

OS=$1

if [ "$OS" == "ubuntu" ]; then
    echo "Updating package lists on Ubuntu..."
    sudo apt-get update
    echo "Installing packages: sublist3r, amass, xsrfprobe..."
    sudo apt-get install sublist3r amass xsrfprobe -y
    echo "Installation complete on Ubuntu."

elif [ "$OS" == "arch" ]; then
    echo "Updating system on Arch Linux..."
    sudo pacman -Syu --noconfirm

    mkdir ~/Tools
    mkdir ~/Wordlists
    mkdir ~/Wordlists/Payloads
    mkdir ~/Bounty
    mkdir ~/.gf
    mkdir ~/.config/puredns
    mkdir ~/nuclei-templates
    mkdir ~/oty-templates

    echo "Installing yay..."
    sudo pacman -S --needed git base-devel --noconfirm
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si

    echo "Installing Go..."
    wget https://go.dev/dl/go1.25.4.linux-amd64.tar.gz
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf go1.25.4.linux-amd64.tar.gz

    yay -S rust
    yay -S rustup

    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc


    echo "Installing Python 3..."
    sudo yay -S python312 --noconfirm

    echo "Installing Pip..."
    python3 -m ensurepip --default-pip
    python3 -m pip install --upgrade pip setuptools wheel

    echo "Installing PipX..."
    sudo pacman -S python-pipx --noconfirm
    pipx ensurepath
    sudo pipx ensurepath --global

    echo "Adding Go binary to PATH..."
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
    # Source the bashrc to update the PATH in the current session
    source ~/.bashrc

    echo "Installing tools..."
    go install github.com/projectdiscovery/katana/cmd/katana@latest
    sudo ln -fs ~/go/bin/katana /usr/bin/katana

    go install github.com/tomnomnom/waybackurls@latest
    sudo ln -fs ~/go/bin/waybackurls /usr/bin/waybackurls

    go install github.com/1hehaq/oty@latest
    sudo ln -fs ~/go/bin/oty /usr/bin/oty
    git clone https://github.com/aldenpartridge/recon.git ~/oty-templates

    go install github.com/tomnomnom/gf@latest
    sudo ln -fs ~/go/bin/gf /usr/bin/gf
    git clone https://github.com/coffinxp/GFpattren.git ~/.gf/

    go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
    sudo ln -fs ~/go/bin/nuclei /usr/bin/nuclei
    git clone https://github.com/coffinxp/nuclei-templates.git ~/nuclei-templates

    pipx install "git+https://github.com/maurosoria/dirsearch.git"

    go install github.com/Chocapikk/wpprobe@latest
    sudo ln -fs ~/go/bin/wpprobe /usr/bin/wpprobe

    go install  github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
    sudo ln -fs ~/go/bin/subfinder /usr/bin/subfinder

    go install  github.com/projectdiscovery/httpx/cmd/httpx@latest
    sudo ln -fs ~/go/bin/httpx /usr/bin/httpx

    go install  github.com/projectdiscovery/dnsx/cmd/dnsx@latest
    sudo ln -fs ~/go/bin/dnsx /usr/bin/dnsx

    go install github.com/ffuf/ffuf/v2@latest
    sudo ln -fs ~/go/bin/ffuf /usr/bin/ffuf

    pipx install "git+https://github.com/aboul3la/Sublist3r.git"

    go install github.com/tomnomnom/assetfinder@latest
    sudo ln -fs ~/go/bin/assetfinder /usr/bin/assetfinder

    go install github.com/d3mondev/puredns/v2@latest
    sudo ln -fs ~/go/bin/puredns /usr/bin/puredns

    go install  github.com/tomnomnom/anew@latest
    sudo ln -fs ~/go/bin/anew /usr/bin/anew

    go install github.com/trickest/mgwls@latest
    sudo ln -fs ~/go/bin/mgwls /usr/bin/mgwls

    sudo yay -S cmake --noconfirm

    git clone https://github.com/ameenmaali/urldedupe.git ~/Tools/urldedupe
    cd ~/Tools/urldedupe
    cmake CMakeLists.txt
    make
    sudo chmod +x urldedupe
    sudo mv urldedupe /usr/bin/urldedupe

    go install github.com/lc/gau/v2/cmd/gau@latest
    sudo ln -fs ~/go/bin/gau /usr/bin/gau

    pipx install "git+https://github.com/xnl-h4ck3r/xnLinkFinder.git"

    pipx install arjun

    pipx install uro

    go install github.com/tomnomnom/qsreplace@latest
    sudo ln -fs ~/go/bin/qsreplace /usr/bin/qsreplace

    go install github.com/PentestPad/subzy@latest
    sudo ln -fs ~/go/bin/subzy /usr/bin/subzy

    go install github.com/ethicalhackingplayground/bxss/v2/cmd/bxss@latest
    sudo ln -fs ~/go/bin/bxss /usr/bin/bxss

    sudo yay -S nmap --noconfirm

    git clone https://github.com/aldenpartridge/lostfuzzer.git ~/Tools/lostfuzzer
    sudo chmod +x ~/Tools/lostfuzzer/lostfuzzer.sh
    sudo ln -fs ~/Tools/lostfuzzer/lostfuzzer.sh /usr/bin/lostfuzzer

    pipx install "git+https://github.com/r0oth3x49/ghauri.git"

    pipx install "git+https://github.com/0xInfection/XSRFProbe.git"

    sudo yay -S burpsuite --noconfirm

    sudo yay -S google-chrome-canary --noconfirm

    curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sudo sh -s -- -b /usr/local/bin

    pipx install bbot

    git clone https://github.com/danielmiessler/SecLists.git ~/Wordlists/SecLists
    wget https://raw.githubusercontent.com/trickest/resolvers/refs/heads/main/resolvers.txt && mv resolvers.txt ~/.config/puredns/
    echo "'\"<script src=https://xss.report/c/manwithafish></script>" > ~/Wordlists/Payloads/bxss.txt
    
    pipx install waymore

    GO111MODULE=on go install github.com/jaeles-project/gospider@latest

    wget https://raw.githubusercontent.com/MrRockettt/Rocket-Crawl/refs/heads/main/rocket-crawl.sh
    chmod +x rocket-crawl.sh
    mv rocket-crawl.sh ~/Tools/

    go install github.com/OJ/gobuster/v3@latest

    go install github.com/hahwul/dalfox/v2@latest

    go install github.com/1hehaq/recx@latest

    go install github.com/1hehaq/shef@latest

    cargo install x8

    wget https://raw.githubusercontent.com/aldenpartridge/scripts/refs/heads/main/chaos-programs.sh
    mv chaos-programs.sh ~/Tools

    git clone https://github.com/zabesec/bb.git
    mv bb ~/Tools

    echo "Installation complete on Arch Linux."

elif [ "$OS" == "windows" ]; then
    echo "Updating and installing packages on Windows..."
    choco upgrade all -y
    choco install sublist3r amass xsrfprobe -y
    echo "Installation complete on Windows."

else
    echo "Unsupported OS: $OS"
    exit 1
fi

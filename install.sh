!# usr/bin/env bash


function install_dependencies(){
	echo "Installing dependencies..."
	# check if brew is installed
	if ! command -v brew >/dev/null 2>&1; then
		echo "Installing brew..."
		NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi
	# check if git is installed
	if ! command -v git >/dev/null 2>&1; then
		echo "Installing git..."
		brew install git
	fi
	# check if python is installed
	if ! command -v python3 >/dev/null 2>&1; then
		echo "Installing python..."
		brew install python@3.10
	fi
}

function install_yt_spammer_purge(){
	echo "Installing yt-spammer-purge..."
	git clone https://github.com/ThioJoe/YT-Spammer-Purge.git
	cd YT-Spammer-Purge
	pip3 install -r requirements.txt
}

options=`echo "Install-Dependencies Install-Yt-Spammer-Purge Quit" | tr ' ' '\n'`

selected=`echo "$options" | fzf`
echo "You selected $selected"
#If the user selects install-dependencies, then run the install-dependencies function
if [ "$selected" = "Install-Dependencies" ]; then
    install_dependencies
#If the user selects install-yt-spammer-purge, then run the install-yt-spammer-purge function
elif [ "$selected" = "Install-Yt-Spammer-Purge" ]; then
    install_yt_spammer_purge
#If the user selects quit, then exit the script
elif [ "$selected" = "Quit" ]; then
    exit 1
fi


#!/bin/bash


install_fail () {
    echo "Install Failed."
    exit 1
}


function install_dependencies_linux(){
	function debian(){
		sudo apt install python3 python3-dev python3-tk python3-pip git || install_fail
	}
	function arch(){
		sudo pacman -S python python-pip git || install_fail
	}
	function centos() {
    	sudo yum install -y python3 || install_fail
    	rpm -q epel-release &> /dev/null || EPEL=0
    	sudo yum install -y python3-tkinter epel-release python3-pip git || install_fail
    	# Honestly not sure why it's installing epel and then uninstalling
    	[[ $EPEL -eq 0 ]] && sudo yum remove -y epel-release
	}

	function fedora() {
    sudo dnf install python3 python3-tkinter python3-pip git python3-devel || install_fail
	}

	function opensuse() {
		sudo zypper install -y python3 python3-pip git || install_fail
	}

	if [[ -f /etc/os-release ]]; then
		source /etc/os-release
		if [[ $ID == "debian" ]]; then
			debian
		elif [[ $ID == "arch" ]]; then
			arch
		elif [[ $ID == "centos" ]]; then
			centos
		elif [[ $ID == "fedora" ]]; then
			fedora
		elif [[ $ID == "opensuse" ]]; then
			opensuse
		else
			echo "Unrecognized Linux distribution. Please install dependencies manually."
			exit 1
		fi
	fi
}

function install_dependencies_macos(){
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
	cd ..
	# check if yt_spammer_purge is installed
	if ! command cd yt_spammer_purge >/dev/null 2>&1; then
		echo "Cloning yt_spammer_purge..."
		git clone https://github.com/ThioJoe/YT-Spammer-Purge.git
		cd YT-Spammer-Purge
		options_install=`echo "Install-Stable Install-Beta Install-Latest" | tr ' ' '\n'`
		selected_install=`echo "$options_install" | fzf`
		echo"You selected $selected_install"
		if [ "$selected_install" = "Install-Stable" ]; then
			echo "Installing stable..."
			git checkout -q -m "$(git describe --abbrev=0 --tags)"
			pip3 install -r requirements.txt
			python3 setup.py install
		elif [ "$selected_install" = "Install-Beta" ]; then
			git tag | egrep Beta
			read -p "Enter the beta version you want to install: " beta_version
			# If the beta version is present in the git tags
			if git tag | grep -q "$beta_version"; then
				echo "Beta version $beta_version found. Installing..."
				git checkout -q tags/"$beta_version"
				pip3 install -r requirements.txt
				cd ..
				echo "YT-Spammer-Purge $beta_version installed successfully in ./y!"
				echo "Run c to start."
			else
				echo "Beta version $beta_version not found. Exiting..."
				exit 1
			fi
		# Install latest master
		elif [ "$selected_install" = "Install-Latest" ]; then
			echo "Installing latest..."
			git pull origin master
			pip3 install -r requirements.txt
			python3 setup.py install
		fi
	fi
	echo "Installing yt-spammer-purge..."
	cd YT-Spammer-Purge
	pip3 install -r requirements.txt
}

options=`echo "Install-Dependencies Install-Yt-Spammer-Purge Quit" | tr ' ' '\n'`

selected=`echo "$options" | fzf`
echo "You selected $selected"
#If the user selects install-dependencies, then run the install-dependencies function
if [ "$selected" = "Install-Dependencies" ]; then
    # check if linux or macos
	if [[ "$OSTYPE" == "linux-gnu" ]]; then
		install_dependencies_linux
	elif [[ "$OSTYPE" == "darwin"* ]]; then
		install_dependencies_macos
	else
		echo "Unrecognized OS. Please install dependencies manually."
		exit 1
	fi
#If the user selects install-yt-spammer-purge, then run the install-yt-spammer-purge function
elif [ "$selected" = "Install-Yt-Spammer-Purge" ]; then
    install_yt_spammer_purge
#If the user selects quit, then exit the script
elif [ "$selected" = "Quit" ]; then
    exit 1
fi


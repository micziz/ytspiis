#!/bin/bash


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
    install_dependencies
#If the user selects install-yt-spammer-purge, then run the install-yt-spammer-purge function
elif [ "$selected" = "Install-Yt-Spammer-Purge" ]; then
    install_yt_spammer_purge
#If the user selects quit, then exit the script
elif [ "$selected" = "Quit" ]; then
    exit 1
fi


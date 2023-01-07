#!/usr/bin/env sh
set -eu

echo "===================================================="
echo "                 ___           ___           ___    "
echo "     ___        /  /\         /__/\         /  /\   "
echo "    /__/|      /  /::\       |  |::\       /  /:/_  "
echo "   |  |:|     /  /:/\:\      |  |:|:\     /  /:/ /\ "
echo "   |  |:|    /  /:/~/::\   __|__|:|\:\   /  /:/ /::\\"
echo " __|__|:|   /__/:/ /:/\:\ /__/::::| \:\ /__/:/ /:/\:\\"
echo "/__/::::\   \  \:\/:/__\/ \  \:\~~\__\/ \  \:\/:/~/:/"
echo "   ~\~~\:\   \  \::/       \  \:\        \  \::/ /:/ "
echo "     \  \:\   \  \:\        \  \:\        \__\/ /:/  "
echo "      \__\/    \  \:\        \  \:\         /__/:/   "
echo "                \__\/         \__\/         \__\/    "
echo "===================================================="
echo "Welcome to YAMS (Yet Another Media Server)"
echo "Instalation process should be really quick"
echo "We just need you to answer some questions"
echo "===================================================="
echo ""

# ============================================================================================
# Check all the prerequisites are installed before continuing
# ============================================================================================
echo "Checking prerequisites..."

check_dependencides() {
    if command -v $1 &> /dev/null; then
        echo "$1 exists ✅ "
    else
        echo "⚠ You need to have $1 installed and in your PATH! EXITING ⚠"
        exit 255
    fi
}

check_dependencides "docker"
check_dependencides "docker-compose"

# ============================================================================================

# ============================================================================================
# Gathering information
# ============================================================================================
read -p "Where do you want to instal the docker-compose file? [/opt/yams] : " install_location

read -p "What's the user that is going to own the media server files? [$USER] : " username

read -p "Please, input your entertainment folder: " ENTERTAINMENT_FOLDER

install_location=${install_location:-/opt/yams}
filename="$install_location/docker-compose.yaml"
username=${username:-$USER}
puid=$(id -u $username)
pgid=$(id -g $username)

echo "Configuring the docker for the user $username on \"$install_location\"..."
# ============================================================================================

# ============================================================================================
# Actually installing everything!
# ============================================================================================
# Checking if the install_location exists
[[ -f $install_location ]] || mkdir -p $install_location || (echo "You need to have permissions on the folder! (Maybe you forgot to run with sudo?)"; false)

# Copy the docker-compose file from the example to the real one
echo "Copying $filename..."

cp docker-compose.example.yaml $filename || (echo "You need to have permissions on the folder! (Maybe you forgot to run with sudo?)"; false)

# Set PUID
sed -i '' -e "s/<your_PUID>/$puid/g" $filename

# Set PGID
sed -i '' -e "s/<your_PGID>/$pgid/g" $filename

# Set entertainment_folder
sed -i '' -e "s;<entertainment_folder>;$ENTERTAINMENT_FOLDER;g" $filename

read -p "Do you want to run the script now? [Y/n]: " run_now
run_now=${run_now:-"y"}

if [ $run_now == "y" ]; then
    echo "Running the server..."
    echo "This is going to take a while..."
    docker-compose -f $filename up -d
else
    echo "Perfect! You can run the server later using the following command:"
    echo ""
    echo "========================================================"
    echo "docker-compose -f $filename up -d"
    echo "========================================================"
    echo ""
fi

echo "========================================================"
echo "     _____          ___           ___           ___     "
echo "    /  /::\        /  /\         /__/\         /  /\    "
echo "   /  /:/\:\      /  /::\        \  \:\       /  /:/_   "
echo "  /  /:/  \:\    /  /:/\:\        \  \:\     /  /:/ /\  "
echo " /__/:/ \__\:|  /  /:/  \:\   _____\__\:\   /  /:/ /:/_ "
echo " \  \:\ /  /:/ /__/:/ \__\:\ /__/::::::::\ /__/:/ /:/ /\\"
echo "  \  \:\  /:/  \  \:\ /  /:/ \  \:\~~\~~\/ \  \:\/:/ /:/"
echo "   \  \:\/:/    \  \:\  /:/   \  \:\  ~~~   \  \::/ /:/ "
echo "    \  \::/      \  \:\/:/     \  \:\        \  \:\/:/  "
echo "     \__\/        \  \::/       \  \:\        \  \::/   "
echo "                   \__\/         \__\/         \__\/    "
echo "========================================================"
echo "All done!✅  Enjoy YAMS!"
echo "========================================================"
exit 0
# ============================================================================================

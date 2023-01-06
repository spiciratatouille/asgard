#!/usr/bin/env sh

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

echo "Checking prerequisites..."

if command -v docker &> /dev/null; then
    echo "Docker exists ✅ "
else
    echo "⚠ You need to have docker installed and in your PATH! EXITING ⚠"
    exit 255
fi

if command -v docker-compose &> /dev/null; then
    echo "docker-compose exists ✅ "
else
    echo "⚠ You need to have docker-compose installed and in your PATH! EXITING ⚠"
    exit 255
fi

read -p "Where do you want to instal the docker-compose file? [/opt/yams] : " install_location

read -p "What's the user that is going to run the media server? [$USER] : " username

read -p "Please, input your entertainment folder: " ENTERTAINMENT_FOLDER

install_location=${install_location:-/opt/yams}
filename="$install_location/docker-compose.yaml"
username=${username:-$USER}
puid=$(id -u $username)
pgid=$(id -g $username)

echo "Configuring the docker for the user $username on \"$install_location\"..."

# Checking if the install_location exists
[[ -f $install_location ]] || mkdir -p $install_location || (echo "You need to have permissions on the folder! EXITING" && exit 255)

# Copy the docker-compose file from the example to the real one
echo "Copying $filename..."

cp docker-compose.example.yaml $filename

# Set PUID
sed -i -e "s/<your_PUID>/$puid/g" $filename

# Set PGID
sed -i -e "s/<your_PGID>/$pgid/g" $filename

# Set entertainment_folder
sed -i -e "s;<entertainment_folder>;$ENTERTAINMENT_FOLDER;g" $filename

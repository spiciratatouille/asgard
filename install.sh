#!/bin/bash
set -eu

printf "\033c"
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
# Functions to ease development
# ============================================================================================

send_success_message() {
    echo -e $(printf "\e[32m$1\e[0m")
}

send_error_message() {
    echo -e $(printf "\e[31m$1\e[0m")
    exit 255
}

check_dependencides() {
    if command -v $1 &> /dev/null; then
        send_success_message "$1 exists ✅ "
    else
        send_error_message "⚠️  You need to have \"$1\" installed and in your PATH! EXITING ⚠️"
    fi
}

running_services_location() {
    host_ip=$(hostname -I | awk '{ print $1 }')
    echo "Sonarr: http://$host_ip:8989/"
    echo "Radarr: http://$host_ip:7878/"
    echo "Bazarr: http://$host_ip:6767/"
    echo "Jackett: http://$host_ip:9117/"
    echo "Emby: http://$host_ip:8096/"
}

# ============================================================================================
# Check all the prerequisites are installed before continuing
# ============================================================================================
echo "Checking prerequisites..."


check_dependencides "docker"
check_dependencides "docker-compose"

# ============================================================================================

# ============================================================================================
# Gathering information
# ============================================================================================
read -p "Where do you want to instal the docker-compose file? [/opt/yams] : " install_location

# Checking if the install_location exists
install_location=${install_location:-/opt/yams}
[[ -f $install_location ]] || mkdir -p $install_location || send_error_message "There was an error with your install location! (Maybe you forgot to run with sudo?)"
install_location=$(realpath $install_location)
filename="$install_location/docker-compose.yaml"

read -p "What's the user that is going to own the media server files? [$USER] : " username

# Checking that the user exists
username=${username:-$USER}

if id -u $username &>/dev/null; then
    puid=$(id -u $username);
    pgid=$(id -g $username);
else
    send_error_message "The user $username doesn't exist!"
fi

read -p "Please, input your media folder: " media_folder

# Checking that the entertainment folder exists

realpath $media_folder &>/dev/null || send_error_message "There was an error with your media folder! The directory \"$media_folder\" does not exist!"

media_folder=$(realpath $media_folder)

read -p "Are you sure your media folder is $media_folder? [y/N]: " media_folder_correct
media_folder_correct=${media_folder_correct:-"n"}

if [ $media_folder_correct == "n" ]; then
    send_error_message "Entertainment folder is not correct. Please, fix it and run the script again"
fi

echo "Configuring the docker-compose file for the user \"$username\" on \"$install_location\"..."
# ============================================================================================

# ============================================================================================
# Actually installing everything!
# ============================================================================================

# Copy the docker-compose file from the example to the real one
echo ""
echo "Copying $filename..."

cp docker-compose.example.yaml $filename || send_error_message "You need to have permissions on the folder! (Maybe you forgot to run with sudo?)"

# Set PUID
sed -i -e "s/<your_PUID>/$puid/g" $filename

# Set PGID
sed -i -e "s/<your_PGID>/$pgid/g" $filename

# Set media_folder
sed -i -e "s;<media_folder>;$media_folder;g" $filename

# Set yams script
sed -i -e "s;<filename>;$filename;g" yams

send_success_message "Everything installed correctly! 🎉"
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
# ============================================================================================

# ============================================================================================
# Cleaning up...
# ============================================================================================

cp setup.sh $install_location
cp yams /usr/local/bin/yams && chmod +x /usr/local/bin/yams


printf "\033c"

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
send_success_message "All done!✅  Enjoy YAMS!"
echo "You can check the installation on $install_location"
if [ $run_now == "y" ]; then
    echo "========================================================"
    echo "Everythins should be running now! To check everything running, go to:"
    running_services_location
    echo "You might need to wait for a couple of minutes while everything gets up and running"
    echo "All the services location are also saved in ~/yams_services.txt"
    running_services_location > ~/yams_services.txt
else
    echo "========================================================"
    echo "Since YAMS is not running yet, to run it just execute:"
    echo "docker-compose -f $filename up -d"
fi
echo "========================================================"
exit 0
# ============================================================================================

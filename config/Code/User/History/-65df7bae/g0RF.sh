#!/bin/bash

# Define variables
GREEN="$(tput setaf 2)[OK]$(tput sgr0)"
RED="$(tput setaf 1)[ERROR]$(tput sgr0)"
YELLOW="$(tput setaf 3)[NOTE]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
LOG="install.log"

# Set the script to exit on error
set -e

printf "$(tput setaf 2) Welcome to the Arch Linux YAY Hyprland installer!\n $(tput sgr0)"

sleep 2

printf "$YELLOW PLEASE BACKUP YOUR FILES BEFORE PROCEEDING!
This script will overwrite some of your configs and files!"

sleep 2

printf "\n
$YELLOW  Some commands requires you to enter your password inorder to execute
If you are worried about entering your password, you can cancel the script now with CTRL Q or CTRL C and review contents of this script. \n"

sleep 3

# Check if yay is installed
ISyay=/sbin/yay

if [ -f "$ISyay" ]; then
    printf "\n%s - yay was located, moving on.\n" "$GREEN"
else 
    printf "\n%s - yay was NOT located\n" "$YELLOW"
    read -n1 -rep "${CAT} Would you like to install yay (y,n)" INST
    if [[ $INST =~ ^[Yy]$ ]]; then
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm 2>&1 | tee -a $LOG
        cd ..
    else
        printf "%s - yay is required for this script, now exiting\n" "$RED"
        exit
    fi
# update system before proceed
    printf "${YELLOW} System Update to avoid issue\n" 
    yay -Syu --noconfirm 2>&1 | tee -a $LOG
fi

# Function to print error messages
print_error() {
    printf " %s%s\n" "$RED" "$1" "$NC" >&2
}

# Function to print success messages
print_success() {
    printf "%s%s%s\n" "$GREEN" "$1" "$NC"
}


### Install packages ####
read -n1 -rep "${CAT} Would you like to install the packages? (y/n)" inst
echo

if [[ $inst =~ ^[Nn]$ ]]; then
    printf "${YELLOW} No packages installed. Goodbye! \n"
            exit 1
        fi

if [[ $inst =~ ^[Yy]$ ]]; then
   git_pkgs="grimblast-git hyprpicker-git waybar-hyprland-git"
   hypr_pkgs="hyprland wl-clipboard wf-recorder rofi-lbonn-wayland-git wlogout swaylock-effects dunst swaybg kitty thunar thunar-archive-plugin tmux zsync unzip tar sudo sed grep wget curl nodejs"
   hypr_pkgs2="wlsunset floorp xdg-desktop-portal-hyprland slurp swappy cliphist swayidle xorg-xwayland xorg-xhost xdg-desktop-portal-gtk npm cargo tree lazygit binutils"
   font_pkgs="ttf-nerd-fonts-symbols-common otf-firamono-nerd inter-font otf-sora ttf-fantasque-nerd noto-fonts noto-fonts-emoji ttf-comfortaa ttf-font-awesome"
   font_pkgs2="ttf-jetbrains-mono-nerd ttf-icomoon-feather ttf-iosevka-nerd adobe-source-code-pro-fonts awesome-terminal-fonts ttf-joypixels ttf-opensans "
   app_pkgs="nwg-look-bin qt5ct qt6ct qt5-wayland qt6-wayland htop jq gvfs ffmpegthumbs mpv playerctl pamixer opendoas rhythmbox qbittorrent bat freedownloadmanager figlet"
   app_pkgs2="polkit-kde-agent ffmpeg neovim viewnior pavucontrol ffmpegthumbnailer tumbler xdg-user-dirs spicetify-cli trash-cli timeshift grub-btrfs coreutils fuse python-pip trizen"
   app_pkgs3="emote syncthing unrar auto-cpufreq tlp network-manager-applet pacman-contrib python-pyamdgpuinfo parallel gparted brightnessctl kvantum neofetch visual-studio-code-bin vim spotify"

#    yay -R --noconfirm swaylock waybar

    if ! yay -S --noconfirm $git_pkgs $hypr_pkgs $hypr_pkgs2 $font_pkgs $font_pkgs2 $app_pkgs $app_pkgs2 $app_pkgs3 2>&1 | tee -a $LOG; then
        print_error " Failed to install additional packages - please check the install.log \n"
        exit 1
    fi
    xdg-user-dirs-update
    echo
    print_success " All necessary packages installed successfully."

else
    echo
    print_error " Packages not installed - please check the install.log"
    sleep 1
fi


### Copy Config Files ###
read -n1 -rep "${CAT} Would you like to copy config files? (y,n)" CFG
if [[ $CFG =~ ^[Yy]$ ]]; then
    printf " Make backup to old config....\n"
#    mv $HOME/.config $/HOME/cfg-bak
    printf " Copying config files...\n"
#    sudo mkdir -p $HOME/.config
    ln -sf config/Code ~/.config/ 2>&1 | tee -a $LOG
    ln -sf config/dunst ~/.config/ 2>&1 | tee -a $LOG
    ln -sf config/gtk-3.0 ~/.config/ 2>&1 | tee -a $LOG
    ln -sf config/kitty ~/.config/ 2>&1 | tee -a $LOG
    ln -sf config/Kvantum ~/.config/ 2>&1 | tee -a $LOG
    ln -sf config/hypr ~/.config/ 2>&1 | tee -a $LOG
    ln -sf config/neofetch ~/.config/ 2>&1 | tee -a $LOG
    ln -sf config/nwg-look ~/.config/ 2>&1 | tee -a $LOG
    ln -sf config/qt5ct ~/.config/ 2>&1 | tee -a $LOG
    ln -sf config/rofi ~/.config/ 2>&1 | tee -a $LOG
    ln -sf config/swaylock ~/.config/ 2>&1 | tee -a $LOG
    ln -sf config/tmux ~/.config/ 2>&1 | tee -a $LOG
    ln -sf config/waybar ~/.config/ 2>&1 | tee -a $LOG
    ln -sf config/wlogout ~/.config/ 2>&1 | tee -a $LOG
    ln -sf config/xsettingsd ~/.config/ 2>&1 | tee -a $LOG

fi

### Add Fonts ###
if [[ ! -d /usr/share/fonts ]]; then
    sudo mkdir -p /usr/share/fonts
fi

if [[ ! -d $HOME/.local/share/fonts ]]; then
    sudo mkdir -p $HOME/.local/share/fonts
fi

sudo cp -R source/fonts/* /usr/share/fonts
sudo cp -R source/fonts/* $HOME/.local/share/fonts

fc-cache -rv  
sudo fc-cache -rv


### Add Icons ###
if [[ ! -d /usr/share/icons ]]; then
    sudo mkdir -p /usr/share/icons
fi

if [[ ! -d $HOME/.icons ]]; then
    sudo mkdir -p $HOME/.icons
fi

sudo cp -R source/icons/* /usr/share/icons
sudo cp -R source/icons/* $HOME/.icons


### Add Themes ###
if [[ ! -d /usr/share/themes ]]; then
    sudo mkdir -p /usr/share/themes
fi

if [[ ! -d $HOME/.themes ]]; then
    sudo mkdir -p $HOME/.themes
fi

sudo cp -R source/icons/* /usr/share/themes
sudo cp -R source/icons/* $HOME/.themes

### for vscode ###
if [[ ! -d $HOME/.vscode ]]; then
    sudo mkdir -p $HOME/.vscode
fi

sudo cp -R source/vscode/* $HOME/.vscode


# pacman
if [ -f /etc/pacman.conf ] && [ ! -f /etc/pacman.conf.t2.bkp ]
    then

    echo "adding extra spice to pacman..."
    sudo cp /etc/pacman.conf /etc/pacman.conf.t2.bkp
    sudo sed -i "/^#Color/c\Color\nILoveCandy
    /^#VerbosePkgLists/c\VerbosePkgLists
    /^#ParallelDownloads/c\ParallelDownloads = 5" /etc/pacman.conf
fi

# BLUETOOTH
read -n1 -rep "${CAT} OPTIONAL - Would you like to install Bluetooth packages? (y/n)" BLUETOOTH
if [[ $BLUETOOTH =~ ^[Yy]$ ]]; then
    printf " Installing Bluetooth Packages...\n"
 blue_pkgs="bluez bluez-utils blueman"
    if ! yay -S --noconfirm $blue_pkgs 2>&1 | tee -a $LOG; then
       	print_error "Failed to install bluetooth packages - please check the install.log"    
    printf " Activating Bluetooth Services...\n"
    sudo systemctl enable --now bluetooth.service
    sleep 2
    fi
else
    printf "${YELLOW} No bluetooth packages installed..\n"
	fi

    
### Script is done ###
printf "\n${GREEN} Installation Completed.\n"
echo -e "${GREEN} You can start Hyprland by typing Hyprland (note the capital H).\n"
read -n1 -rep "${CAT} Would you like to start Hyprland now? (y,n)" HYP
if [[ $HYP =~ ^[Yy]$ ]]; then
    if command -v Hyprland >/dev/null; then
        exec Hyprland
    else
         print_error " Hyprland not found. Please make sure Hyprland is installed by checking install.log.\n"
        exit 1
    fi
else
    exit
fi


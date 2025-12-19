#!/usr/bin/zsh

echo -e "Cloning repo."
git clone https://github.com/killswitchalias/vmsetup-kali.git 1>/dev/null

if [ $? -ne 0 ]; then
  echo -e "ERROR: Could not clone repo" >&2
  exit 1
fi

dir="$(pwd)/vmsetup-kali"

backup_file () {
    if [ -z "$1" ]; then
        return 1
    fi
    local FILE="$1"
    if [ -f "$FILE" ]; then
        echo -e "Creating backup of original $FILE"
        mv "$FILE" "$FILE.bak"
    fi
}

# Fixing zsh with custom files
echo -e "Moving zsh config files into place"
backup_file "$HOME/.zshrc"
sudo ln -s "${dir}/zsh/zshrc" "$HOME/.zshrc"
backup_file "$HOME/.zsh_aliases"
sudo ln -s "${dir}/zsh/zsh_aliases" "$HOME/.zsh_aliases"
backup_file "$HOME/.zsh_functions"
sudo ln -s "${dir}/zsh/zsh_functions" "$HOME/.zsh_functions"
backup_file "$HOME/.zsh_prompt_script"
sudo ln -s "${dir}/zsh/zsh_prompt_script" "$HOME/.zsh_prompt_script"

#echo -e "Setting zsh as default shell"
#chsh -s /bin/zsh # Already is default shell.

# Setting wallpaper for XFCE4
echo -e "Setting up wallpaper"
backup_file "$HOME/Pictures/wp.jpg"
sudo ln -s "${dir}/style/wp.jpg" "$HOME/Pictures/wp.jpg"

xrandr --listmonitors | awk '{print $4}' | tail -n $(( $( xrandr --listmonitors | wc -l ) - 1 )) | while read monitor; do
    xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor"$monitor"/workspace0/last-image -n -t string -s "$HOME/Pictures/wp.jpg"
done

# Turning off screensaver and locking after time
echo -e "Turning off screensaver and locking after timeout"
xfconf-query -c xfce4-screensaver -n -t bool -p /saver/enabled -s false
#xfconf-query -c xfce4-screensaver -n -t bool -p /lock/enabled -s false
xfconf-query -c xfce4-screensaver -p /lock/timeout -s 0 -n -t int

# Default position for rockyou in kali
if [ -f "/usr/share/wordlists/rockyou.txt.gz" ] && [ ! -f "/usr/share/wordlists/rockyou.txt" ]; then
    echo -e "Unzipping rockyou"
    sudo gunzip /usr/share/wordlists/rockyou.txt.gz
else
    if [ ! -f "/usr/share/wordlists/rockyou.txt.gz" ]; then
        echo -e "The file rockyou.txt.gz does not exist"
    fi
    if [ -f "/usr/share/wordlists/rockyou.txt" ]; then
        echo -e "Rockyou was already unzipped"
    fi 
fi

# TMUX settings
if [ ! -f "$HOME/.tmux.conf" ]; then
    echo -e "Setting simple tmux settings"
    echo -e "set -g mouse on\n" >> "$HOME/.tmux.conf"
else
    echo -e "Tmux config detected in $HOME/.tmux.conf"
fi

# SSH keygen
if [ ! -f "$HOME/.ssh/id_rsa" ]; then
    echo -e "Generating ssh-keys"
    ssh-keygen -t rsa -f "$HOME/.ssh/id_rsa" -N ""
else
    echo -e "SSH-keys detected in $HOME/.ssh/id_rsa"
fi

echo -e "Finished"
echo -e "Remember to update and upgrade"
echo -e "[-] Equipping changes"
source "$HOME/.zshrc" && source "$HOME/.zsh_prompt_script" || zsh

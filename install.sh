#!/usr/bin/zsh

echo "Cloning repo."
git clone https://github.com/killswitchalias/vmsetup-kali.git

if [ $? -ne 0 ]; then
  echo "ERROR: Could not clone repo" >&2
  exit 1
fi

dir="$(pwd)/vmsetup-kali"

backup_file () { [ -z "$1" ] && return 1; local FILE="$1"; [ -f "$FILE" ] && mv "$FILE" "$FILE.bak"; }

echo -e "Moving zsh config files into place"
backup_file "$HOME/.zshrc"
sudo ln -s "${dir}/zsh/zshrc" "$HOME/.zshrc"
backup_file "$HOME/.zsh_aliases"
sudo ln -s "${dir}/zsh/zsh_aliases" "$HOME/.zsh_aliases"
backup_file "$HOME/.zsh_functions"
sudo ln -s "${dir}/zsh/zsh_functions" "$HOME/.zsh_functions"
backup_file "$HOME/.zsh_prompt_script"
sudo ln -s "${dir}/zsh/zsh_prompt_script" "$HOME/.zsh_prompt_script"

echo -e "Setting zsh as default shell"
chsh -s /bin/zsh

# Setting wallpaper for XFCE4
echo -e "Setting up wallpaper"
backup_file "$HOME/Pictures/wp.jpg"
sudo ln -s "${dir}/style/wp.jpg" "$HOME/Pictures/wp.jpg"

xrandr --listmonitors | awk '{print $4}' | tail -n $(( $( xrandr --listmonitors | wc -l ) - 1 )) | while read monitor; do
    xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor"$monitor"/workspace0/last-image -n -t string -s "$HOME/Pictures/wp.jpg"
done

# Turning off screensaver and locking after time
echo -e "Turning off screensaver and locking after time"
xfconf-query -c xfce4-screensaver -n -t bool -p /saver/enabled -s false
#xfconf-query -c xfce4-screensaver -n -t bool -p /lock/enabled -s false
xfconf-query -c xfce4-screensaver -p /lock/timeout -s 0 -n -t int

echo -e "Unzipping rockyou"
# Default position for rockyou in kali
[ -f "/usr/share/wordlists/rockyou.txt.gz" ] && [ ! -f "/usr/share/wordlists/rockyou.txt" ] && sudo gunzip /usr/share/wordlists/rockyou.txt.gz

echo -e "Setting simple tmux settings"
# TMUX settings
[ ! -f "$HOME/.tmux.conf" ] echo "set -g mouse on\n" >> "$HOME/.tmux.conf"

echo -e "Finished"
echo -e "Remember to update and upgrade"
echo -e "[-] Equipping changes"
source "$HOME/.zshrc" && source "$HOME/.zsh_prompt_script" || zsh

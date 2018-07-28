sudo pacman -S git
sudo git clone  https://github.com/xenlism/minimalism.git
sudo rm -rf /usr/share/themes/*
sudo cp -r ./minimalism/themes/Xenlism-Minimalism /usr/share/themes
sudo /etc/init.d/gdm restart
#!/bin/bash
# 保证预先安装git
# https://github.com/pangyouzhen/manjaro_setting
exec_location=`pwd`
relative_location=$(cd "$(dirname "$0")"; pwd)

LOG=$relative_location/../log
# print log
print_log() {
    echo -e  "\033[0;31;1m==> $1\033[0m"
    echo $1 >> $LOG
}
# check software
check_software() {
    echo "-> checking app $1..."
    which $1 >> /dev/null
    if [ $? = 0 ]; then
        echo "-> $1 had been installed"
    else
        echo "-> $1 has not been installed, installing now"
        $2 $1
    fi
}
# 更改镜像文件
pacman-mirrors -c China

install_base(){
    check_software wget "pacman -S --noconfirm"
    check_software ibus-rime "pacman -S --noconfirm"
    check_software yaourt "pacman -S --noconfirm"
    check_software base-devel "pacman -S --noconfirm"
    check_software vim "pacman -S --noconfirm"
    check_software pandoc "pacman -S --noconfirm"
    check_software deluge "pacman -S --noconfirm"
    check_software chromium "pacman -S --noconfirm"
}

install_base
# 更换gnome主题
git clone https://github.com/pangyouzhen/manjaro_setting
rm -rf /usr/share/themes/*
cp -r ./gnome/Xenlism-Minimalism /usr/share/themes
/etc/init.d/gdm restart


# 更改python镜像文件
mkdir /opt/pkgs
mkdir /opt/envs

cp ./pypi/* ~

processbar() {
    local current=$1; local total=$2;
    local maxlen=80; local barlen=62; local barlen1=64; local perclen=14;
    local format="%-${barlen1}s]%$((maxlen-barlen))s"
    local perc="[$current/$total]"
    local progress=$((current*barlen/total))
    local prog=$(for i in `seq 0 $progress`; do printf '#'; done)
    printf "\rProgress: $format" [$prog $perc
    echo ''
}
install_software() {

    have_been_installed=0
    not_be_installed=0

    linenu=$(cat $1 | wc -l)
    for app in $(cat $1)
    do
        clear
        processbar `expr $have_been_installed + $not_be_installed` $linenu
        print_log "==> Start to install $app"
        echo "$3 $2 -S --noconfirm $4 $app"
        $3 $2 -S --noconfirm $4 $app
        status=$?
        if [ $status = 0 ]
        then
            print_log "Installed:  $app"
            have_been_installed=`expr $have_been_installed + 1`
        else
            print_log "Error: $app"
            echo $relative_location
            notify-send -i 'error' -a "Error Information For Installing" $app 
            not_be_installed=`expr $not_be_installed + 1`
            sleep 1
        fi
    done

    clear
    processbar `expr $have_been_installed + $not_be_installed` $linenu
    echo "Information for $1"
    echo ""
    print_log "-> $have_been_installed apps had been installed"
    print_log "-> $not_be_installed apps were not installed"
    echo ""
    echo "Error Installed Apps:"
    cat $LOG | grep Error
    echo "wait 3s please..."
    sleep 3
}


# update system
update_system() {
    clear
    print_log "update system..."
    check_software wget "pacman -S --noconfirm"
    pacman -Syyu --noconfirm
    print_log "done"
}
# 安装conda并创建虚拟环境
install_conda(){
    wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
    yes | bash Miniconda3-latest-Linux-x86_64.sh
    conda create -n jupyterpy python=3.6
    source activate jupyterpy
    pip install jupyter notebook
    pip install jupyter_contrib_nbextensions
    jupyter contrib nbextension install --user
    pip install rise
    jupyter-nbextension install rise --py --sys-prefix
    jupyter-nbextension enable rise --py --sys-prefix
    source deactivate
    }

install_conda
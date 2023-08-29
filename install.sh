# Add some colours 
 red='\033[1;31m' 
 green='\033[1;32m' 
 yellow='\033[1;33m' 
 blue='\033[1;34m' 
 light_cyan='\033[1;96m' 
 reset='\033[0m' 
 function checking_architecture () {
case `dpkg --print-architecture` in
                aarch64)
                        archurl="arm64" ;;
                arm)
                        archurl="armhf" ;;
                amd64)
                        archurl="amd64" ;;
                x86_64)
                        archurl="amd64" ;;

                *)
                        echo "unknown architecture"; exit  ;;
                esac
                
                
}                
function install_package () {
apt update
apt upgrade -y
apt install proot wget
}

function download_rootfs () {
wget -O kali.tar.xz https://kali.download/nethunter-images/current/rootfs/kalifs-${archurl}-minimal.tar.xz
}
function extract_rootfs () {
proot --link2symlink tar -xf kali.tar.xz 2> /dev/null || :  
CHROOT=kali-${archurl}
}
function add_kali_launcher () {
cd
kali=$PREFIX/bin/kali
rm -rf $kali
cat > $kali <<- EOM
#/data/data/com.termux/files/usr/bin/bash
unset LD_PRELOAD
proot -k 4.14.81 --link2symlink -0 -r $CHROOT -b /dev -b /dev/null:/proc/sys/kernel/cap_last_cap -b /proc -b /dev/null:/proc/stat -b /sys -b /data/data/com.termux/files/usr/tmp:/tmp -b $CHROOT/tmp:/dev/shm -b /:/host-rootfs -b /sdcard -b /storage -b /mnt -w /home/kali  /usr/bin/env -i HOME=/home/kali PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games TERM=$TERM LANG=C.UTF-8 sudo -u kali /bin/bash
EOM
chmod +x $kali

kali_r=$PREFIX/bin/kali-r
rm -rf $kali-r
cat > $kali_r <<- EOM
#/data/data/com.termux/files/usr/bin/bash
unset LD_PRELOAD
proot -k 4.14.81 --link2symlink -0 -r $CHROOT -b /dev -b /dev/null:/proc/sys/kernel/cap_last_cap -b /proc -b /dev/null:/proc/stat -b /sys -b /data/data/com.termux/files/usr/tmp:/tmp -b $CHROOT/tmp:/dev/shm -b /:/host-rootfs -b /sdcard -b /storage -b /mnt -w /root  /usr/bin/env -i HOME=/root PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games TERM=$TERM LANG=C.UTF-8 /bin/bash --login
EOM
chmod +x $kali_r
}
function fix_sudo () {
## fix sudo and su
chmod +s $CHROOT/usr/bin/sudo
chmod +s $CHROOT/usr/bin/su
echo "kali    ALL=(ALL:ALL) ALL" >> $CHROOT/etc/sudoers.d/kali
}

function kali_logo() {
    clear
    printf "${red}##################################################\n"
    printf "${red}##                                              ##\n"
    printf "${red}##  88      a8P         db        88        88  ##\n"
    printf "${red}##  88    .88'         d88b       88        88  ##\n"
    printf "${red}##  88   88'          d8''8b      88        88  ##\n"
    printf "${red}##  88 d88           d8'  '8b     88        88  ##\n"
    printf "${red}##  8888'88.        d8YaaaaY8b    88        88  ##\n"
    printf "${red}##  88P   Y8b      d8''''''''8b   88        88  ##\n"
    printf "${red}##  88     '88.   d8'        '8b  88        88  ##\n"
    printf "${red}##  88       Y8b d8'          '8b 888888888 88  ##\n"
    printf "${red}##                                              ##\n"
    printf "${red}####  ############# linux ####################${reset}\n\n"
}


##################################
##              Main            ##

kali_logo
printf "${blue}[=]checking architecture ....${reset}\n"
checking_architecture
printf "${blue}[+]install package${reset}\n"
install_package
printf "${blue}[+]download rootfs${reset}\n"
download_rootfs
printf "${blue}extract rootfs${reset}\n"
extract_rootfs
printf "${blue}[+]configure termux for kali${reset}\n"
cd
add_kali_launcher
cd
fix_sudo
kali_logo
printf "${green} kali = start kali${reset}\n"
printf "${green} kali-r = start kali as root${reset}\n"

 
 
 
  

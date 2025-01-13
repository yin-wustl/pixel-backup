#!/bin/sh

usb_mount=$(cat /proc/mounts | grep -i "vfat" | grep "/mnt/media_rw" | awk '{print $2}')
export usb_mount

if [ -n "$usb_mount" ]; then
    echo "USB drive is mounted at: $usb_mount"
    if [ "$(readlink /proc/self/ns/mnt)" != "$(readlink /proc/1/ns/mnt)" ]; then
        echo "switching to global mount namespace and root shell..."

        if [ "$(id -u)" -ne 0 ]; then
            echo "re-running script as root..."
            exec tsu -c "/data/data/com.termux/files/usr/bin/bash $0"
        fi

        nsenter -t 1 -m -- /data/data/com.termux/files/usr/bin/bash -c "
            echo 'Entering global mount namespace 🌐';
            cd /sdcard/Tweaks;
            sh remount_vfat.sh $usb_mount;
            sh;
            echo 'Leaving global mount namespace 👋';
            sh /sdcard/Tweaks/unmount.sh
        "
    else
        echo 'already running in global mount namespace 🤔'
    fi
else
    echo "No USB drive is mounted."
fi

exit 0

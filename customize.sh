#!/bin/bash
SKIPUNZIP=1

BACKUPBOOT(){
    if [ $ifota -eq 1 ] || [ ! -e "/data/adb/stock_boot.img" ]; then
        ui_print "Backup boot..."
        dd if=$BOOTPATH of=/data/adb/stock_boot.img
        ui_print "Done"
    else
        ui_print "Not backup boot"
    fi
}

RESTOREBOOT(){
    if [ ! -e "$TMPDIR/Image" ] && [ -e "/data/adb/stock_boot.img" ];then
        ui_print "Restore boot..."
        dd if=/data/adb/stock_boot.img of=$BOOTPATH
        if [ $? -eq 0 ];then
            ui_print "Done"
            rm -rf $TMPDIR
            exit 0
        else
            abort "Fail to restore boot"
        fi
    elif [ ! -e "$TMPDIR/Image" ] && [ ! -e "/data/adb/stock_boot.img" ];then
        abort "Both Image or stock_boot are not found"
    elif [  -e "$TMPDIR/Image" ]; then
        ui_print "Skip restore boot
    fi
}

PATCHBOOT(){
    case $1 in
    [0])
        SLOT="_a"
    ;;
    [1])
        SLOT="b"
    ;;
    *)
        SLOT=""
    esac
    BOOTPATH=/dev/block/by-name/boot$SLOT
    if [ -e $BOOTPATH ];then
        blockdev --setrw $BOOTPATH 2>/dev/null
        RESTOREBOOT
        BACKUPBOOT
        ui_print "Fetching boot.img"
        dd if=$BOOTPATH of=./boot.img
        ./magiskboot unpack boot.img
        ui_print "Patching boot.img"
        mv ./Image ./kernel
        ./magiskboot repack boot.img new.img
        if [ $? -eq 0 ]; then
            ui_print "Done"
        else
            abort "Fail to patch boot"
    else
        abort "Fail to find device boot"
    fi
}

CHECKOTA(){
    current_slot=`./bootctl get-current-slot`
    target_slot=`./bootctl get-active-boot-slot`
    if [ $current_slot -eq $target_slot ]; then
        ifota=0
    else
        ifota=1
    fi
    ui_print "Your device has OTAed (if you had not change the boot slot by yourself)"
}

FLASHBOOT(){
    ui_print "Flashing new boot to boot$SLOT"
    dd if=./new.img of=/dev/block/by-name/boot$SLOT
    if [ $? -eq 0 ]; then
        ui_print "Succeed"
    else
        abort "Fail to flash boot with dd"
    fi
}

MAIN(){
    ui_print "Setting up environment"
    TMPDIR=/data/local/tmp_ksu_install
    mkdir $TMPDIR 2>/dev/null
    unzip "$ZIPFILE" -d "$TMPDIR"
    cd $TMPDIR
    chmod 755 magiskboot
    chmod 755 bootctl
    ui_print "Done"

    SLOT_COUNT=`./bootctl get-number-slots`
    case $SLOT_COUNT in
    [1])
        PATCHBOOT
        FLASHBOOT
    ;;
    [2])
        CHECKOTA
        PATCHBOOT $target_slot
        FLASHBOOT
    ;;
    *)
        ui_print "unknown device slots"
    esac
}

MAIN
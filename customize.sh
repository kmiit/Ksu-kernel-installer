#!/sbin/bash
SKIPUNZIP=1

BACKUPBOOT(){
    if [ $ifota -eq 1 ] || [ ! -e $BACKUPFILE ]; then
        ui_print "Backup boot..."
        dd if=$BOOTPATH of=$BACKUPFILE
        ui_print "Done"
    else
        ui_print "Not backup boot"
    fi
}

RESTOREBOOT(){
    if [ -e $BACKUPFILE ];then
        ui_print "Restore boot to boot_a"
        dd if=$BACKUPFILE of=${BOOTPATH%_*}_a
        if [ $? -eq 0 ];then
            ui_print "Done"
        else
            abort "Fail to restore boot"
        fi
        ui_print "Restore boot to boot_b"
        dd if=$BACKUPFILE of="${BOOTPATH%_*}_b"
        if [ $? -eq 0 ];then
            ui_print "Done"
            rm -rf $TMPDIR
            exit 0
        else
            abort "Fail to restore boot"
        fi
    else
        abort "Fail to find stock_boot"
    fi
}

PATCHBOOT(){
    if [ -e $BOOTPATH ];then
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
        fi
    else
        abort "Fail to find device boot"
    fi
}

CHECKOTA(){
    current_slot=`./bootctl get-current-slot`
    target_slot=`./bootctl get-active-boot-slot`
    case $target_slot in
    [0])
        SLOT="_a"
    ;;
    [1])
        SLOT="_b"
    ;;
    *)
        SLOT=""
    esac
    BOOTPATH=/dev/block/by-name/boot$SLOT
    if [ $current_slot -eq $target_slot ]; then
        ui_print "Your device is not OTAed"
        ifota=0
    else
        ui_print "Your device has OTAed (if you had not change the boot slot by yourself)"
        ui_print "Set target slot writable"
        blockdev --setrw $BOOTPATH 2>/dev/null
        ui_print "Done"
        ifota=1
    fi
}

FLASHIMAGE(){
    case $SLOT_COUNT in
    [1])
        BACKUPBOOT
        PATCHBOOT
        FLASHBOOT
    ;;
    [2])
        CHECKOTA
        BACKUPBOOT
        PATCHBOOT
        FLASHBOOT
    ;;
    *)
        ui_print "unknown device slots"
    esac
}

FLASHBOOT(){
    ui_print "Flashing new boot to boot$SLOT"
    dd if=./new.img of=$BOOTPATH
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
    BACKUPFILE=/data/adb/stock_boot_backup.img
    
    if [ -e "$TMPDIR/Image" ]; then
        ui_print "Find Image, will flash it later"
        FLASHIMAGE
    elif [ -e "$TMPDIR/boot.img" ]; then
        ui_print "Find boot.img, will flash it later"
        mv boot.img new.img
        CHECKOTA
        FLASHBOOT
    else
        ui_print "Both Image or boot.img are not found, will restore boot"
        CHECKOTA
        RESTOREBOOT
    fi
}

MAIN


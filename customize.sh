#!/sbin/bash
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
    if [ -e "/data/adb/stock_boot.img" ];then
        ui_print "Restore boot to boot_a"
        dd if=/data/adb/stock_boot.img of=${BOOTPATH%_*}_a
        if [ $? -eq 0 ];then
            ui_print "Done"
        else
            abort "Fail to restore boot"
        fi
        ui_print "Restore boot to boot_b"
        dd if="/data/adb/stock_boot.img" of="${BOOTPATH%_*}_b"
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
        fi
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
        ui_print "Your device has OTAed (if you had not change the boot slot by yourself)"
        ui_print "Set target slot writable"
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
        blockdev --setrw $BOOTPATH 2>/dev/null
        ui_print "Done"
    fi
}

FLASHIMAGE(){
    case $SLOT_COUNT in
    [1])
        PATCHBOOT
        FLASHBOOT
    ;;
    [2])
        CHECKOTA
        PATCHBOOT
        FLASHBOOT
    ;;
    *)
        ui_print "unknown device slots"
    esac
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
    
    if [ -e "$TMPDIR/Image" ]; then
        ui_print "Find Image, will flash it"
        FLASHIMAGE
    elif [ -e "$TMPDIR/boot.img" ]; then
        ui_print "Find boot.img, will flash it"
        mv boot.img new.img
        FLASHBOOT
    else
        ui_print "Both Image or boot.img are not found, will restore boot"
        RESTOREBOOT
    fi
}

MAIN


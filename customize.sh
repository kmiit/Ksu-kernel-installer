#!/bin/bash
SKIPUNZIP=1

PATCHBOOT(){
if [ -z $1 ]; then
SLOT=""
else
if [ $1 -eq 0]; then 
SLOT="_a"
else
SLOT="_b"
fi 
fi
ui_print "Fetching boot.img"
dd if=/dev/block/by-name/boot$SLOT of=./boot.img
./magiskboot unpack boot.img
ui_print "Patching boot.img"
mv ./Image ./kernel
./magiskboot repack boot.img new.img
ui_print "Done"
}

FLASHBOOT(){
ui_print "Flashing new boot to boot$SLOT"
dd if=./new.img of=/dev/block/by-name/boot$SLOT
}

TMPDIR=/data/local/tmp_ksu_install
mkdir $TMPDIR 2>/dev/null
ui_print "Extracting fies..."
unzip "$ZIPFILE" -d "$TMPDIR"
cd $TMPDIR
ui_print "Setting up environment"
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
ACTIVESLOT=`./bootctl get-active-boot-slot`
PATCHBOOT $ACTIVESLOT
FLASHBOOT
;;
*)
ui_print "unknown device slots"
esac

rm -rf $TMPDIR

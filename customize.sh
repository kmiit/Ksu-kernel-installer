#!/bin/bash
SKIPUNZIP=1

PATCHBOOT(){
if [ -z $1 ]; then
SLOT=""
ui_print "Your device is A only"
else
if [ $1 -eq 0]; then 
SLOT="_a"
else
SLOT="_b"
fi 
fi
dd if=/dev/block/by-name/boot$SLOT of=./boot.img
./magiskboot unpack boot.img
mv ./Image ./kernel
./magiskboot repack boot.img new.img
}

FLASHBOOT(){
dd if=./new.img of=/dev/block/by-name/boot$SLOT
ui_print "Done."
}

TMPDIR=/data/local/tmp_ksu_install
mkdir $TMPDIR 2>/dev/null
ui_print "extracting fies..."
extract "$ZIPFILE" 'Image'       "$TMPDIR"
extract "$ZIPFILE" 'bootctl'      "$TMPDIR"
extract "$ZIPFILE" 'magiskboot'  "$TMPDIR"
unzip "$ZIPFILE" -d "$TMPDIR"
cd $TMPDIR
A=`ls`
ui_print "$A"
chmod 755 magiskboot
chmod 755 bootctl

SLOT_COUNT=`./bootctl get-number-slots`
ui_print "$SLOT_COUNT"
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

#rm -rf $TMPDIR
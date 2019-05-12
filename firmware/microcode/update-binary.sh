#!/sbin/sh
# Installs Intel CPU microcode for the Android boot configuration

set -eu

MICROCODE_PREFIX="cpu30678_plat02_"
UCODE_FILENAME="intel-ucode.img"
ANDROID_BOOT_CONFIG="/esp/loader/entries/android.conf"

rm -rf /tmp/microcode
mkdir /tmp/microcode
cd /tmp/microcode

# Attempt to find microcode binary: filename "microcode.bin" or "cpu30678_plat02_*.bin"
#  - added to the root directory of this ZIP package
#  - in the same directory as this package

set -- $(unzip -lq "$PACKAGE" | while read -r _ _ _ name; do
    case "$name" in
        microcode.bin|${MICROCODE_PREFIX}*.bin)
            unzip -q "$PACKAGE" "$name" && echo "$name" ;;
    esac
done)

if [ $# -eq 0 ]; then
    dir="$(dirname "$PACKAGE")"
    matches=""
    echo $dir/microcode.bin $(echo "$dir/"${MICROCODE_PREFIX}*.bin)
    for f in $dir/microcode.bin $(echo "$dir/"${MICROCODE_PREFIX}*.bin); do
        [ -f "$f" ] && matches="$matches $f" || :
    done
    set -- $matches
fi

if [ $# -eq 0 ]; then
    ui_print "Cannot find microcode binary. Please download it and:"
    ui_print " - add it to the root directory of this ZIP package, or"
    ui_print " - place it in the same directory as this package."
    ui_print "Check 'README' in this ZIP package for details."
elif [ $# -gt 1 ]; then
    ui_print "Multiple microcode files match: $*"
    exit 1
fi

set_progress 0.1
ui_print "Installing microcode from: $1"

ui_print " -> Building initramfs archive"
mkdir -p kernel/x86/microcode
cp "$1" kernel/x86/microcode/GenuineIntel.bin

chown -R 0:0 kernel
echo kernel/x86/microcode/GenuineIntel.bin | cpio -o -H newc -F "$UCODE_FILENAME"

set_progress 0.5
ui_print " -> Installing new files"

mount_if_necessary /esp
cp "$UCODE_FILENAME" /esp
set_progress 0.75
grep -qF "$UCODE_FILENAME" "$ANDROID_BOOT_CONFIG" \
    || echo "initrd   /$UCODE_FILENAME" >> "$ANDROID_BOOT_CONFIG"

ui_print " -> Done!"
set_progress 1.0
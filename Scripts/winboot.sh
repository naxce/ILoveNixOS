#!/bin/sh
exec 2> /home/naxce/winboot_error.log

printf 'timeout -1\ndefault_selection "Windows 11"\n' | sudo /run/current-system/sw/bin/tee /boot/EFI/refind/manual_boot.conf && sudo /run/current-system/sw/bin/systemctl reboot
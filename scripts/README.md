## ZRAM
The zram script is used to create a compressed portion of RAM to be used as swap.
You need to create a systemd service at `/etc/systemd/system/zram.service`.
Make the `zram` script executable and reboot.
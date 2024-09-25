## ZRAM
The zram script is used to create a compressed portion of RAM to be used as swap.
You need to create a systemd service at `/etc/systemd/system/zram.service`.
Make the `zram` script executable, reload systemd, enable the service and reboot.

```
chmod +x /usr/local/bin/zram
systemctl daemon-reload
systemctl enable zram
```

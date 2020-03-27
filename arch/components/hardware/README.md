# Hardware

This section is split into the following subsections:

- Battery
- GPU
- Trackpad

Each are their own program and can be invoke in a master script.
They are also tailored specifically a Dell XPS 9560.
These utilities should be used as references mostly, not in production.

## Battery

Installs battery saving features that run in the background.
I have been able to get a solid 5 hours of heavy work done on a charge which is decent.
If you have an NVME drive, it also installs a package that will try to make it more power efficient.


```bash
sudo components/hardware/battery
```

## GPU

Enables or disables a secondary GPU installed in a laptop.
**This is a highly experimental feature and is not well tested. Use at your own risk.**
Things are semi hard-coded to work for the Dell XPS 15 9560 and are not guaranteed to work seamlessly for you.

```bash
# run the command without a menu
# options are enable, disable and show

FORCE_="YES" sudo components/hardware/gpu_switch show
```

## Trackpad

Configures the trackpad to be less buggy.
This setup seems to work just fine the only problem is that it needs to be tested on more hardware.

```bash
sudo components/hardware/trackpad
```

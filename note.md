## Adding new drives as lvm

1. Identify new disk
    - `sudo dmesg | grep -i sd` OR `sudo fdisk -l | grep -i /dev/sd`

2. Create PV (Physical Volume)
    - `sudo apt install lvm2`
    - `sudo pvcreate /dev/sd<b/c/e/etc>`
    - Verify with `sudo pvs /dev/sd<b/c/e/etc>` OR `sudo pvdisplay /dev/sd<b/c/e/etc>`

3. Create VG (Volume Group)
    - `sudo vgcreate <vg_name> <pv>` -> Example: `sudo vgcreate volgrp01 /dev/sdb`
    - Verify with `sudo vgs <vg_name>` OR `sudo vgdisplay <vg_name>`

4. Create LV (Logical Volume)
    - `sudo lvcreate -L <Size of LV> -n <lv_name> <vg_name>`
    - Verify with `sudo lvs /dev/<vg_name>/<lv_name>` OR `sudo lvdisplay /dev/<vg_name>/<lv_name>`

5. Format LVM partition
    - As ext4 `sudo mkfs.ext4 /dev/<vg_name>/<lv_name>`
    - As xfs `sudo mkfs.xfs /dev/<vg_name>/<lv_name>`

6. Mount the partition
    - `sudo mkdir <mount_point>`
    - `sudo mount /dev/<vg_name>/<lv_name> <mount_point>`
    - Verify with `df -Th <mount_point>`
    - To permanently mount (tabs not spaces): `echo '/dev/<vg_name>/<lv_name>  <mount_point>   ext4    defaults    0   0' | sudo tee -a /etc/fstab` --> `sudo mount -a`
2.
Так как hardlink это ссылка на тот же самый файл и имеет тот же inode то права будут одни и теже.

3.
root@vagrant:~# lsblk<br>
NAME                 MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT<br>
sda                    8:0    0   64G  0 disk <br>
├─sda1                 8:1    0  512M  0 part /boot/efi<br>
├─sda2                 8:2    0    1K  0 part <br>
└─sda5                 8:5    0 63.5G  0 part <br>
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm  /<br>
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm  [SWAP]<br>
sdb                    8:16   0  2.5G  0 disk <br>
sdc                    8:32   0  2.5G  0 disk<br>

4.
Device     Boot   Start     End Sectors  Size Id Type<br>
/dev/sdb1          2048 4196351 4194304    2G 83 Linux<br>
/dev/sdb2       4196352 5242879 1046528  511M 83 Linux<br>

5.
root@vagrant:~# sfdisk -d /dev/sdb|sfdisk --force /dev/sdc<br>
Checking that no-one is using this disk right now ... OK<br>

Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors<br>
Disk model: VBOX HARDDISK   <br>
Units: sectors of 1 * 512 = 512 bytes<br>
Sector size (logical/physical): 512 bytes / 512 bytes<br>
I/O size (minimum/optimal): 512 bytes / 512 bytes<br>

\>>> Script header accepted.<br>
\>>> Script header accepted.<br>
\>>> Script header accepted.<br>
\>>> Script header accepted.<br>
\>>> Created a new DOS disklabel with disk identifier 0xb289fd48.<br>
/dev/sdc1: Created a new partition 1 of type 'Linux' and of size 2 GiB.<br>
/dev/sdc2: Created a new partition 2 of type 'Linux' and of size 511 MiB.<br>
/dev/sdc3: Done.<br>

New situation:<br>
Disklabel type: dos<br>
Disk identifier: 0xb289fd48<br>

Device     Boot   Start     End Sectors  Size Id Type<br>
/dev/sdc1          2048 4196351 4194304    2G 83 Linux<br>
/dev/sdc2       4196352 5242879 1046528  511M 83 Linux<br>
<br>
The partition table has been altered.<br>
Calling ioctl() to re-read partition table.<br>
Syncing disks.<br>
root@vagrant:\~# <br>

результат:<br>

Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors<br>
Disk model: VBOX HARDDISK   <br>
Units: sectors of 1 * 512 = 512 bytes<br>
Sector size (logical/physical): 512 bytes / 512 bytes<br>
I/O size (minimum/optimal): 512 bytes / 512 bytes<br>
Disklabel type: dos<br>
Disk identifier: 0xb289fd48<br>

Device     Boot   Start     End Sectors  Size Id Type<br>
/dev/sdb1          2048 4196351 4194304    2G 83 Linux<br>
/dev/sdb2       4196352 5242879 1046528  511M 83 Linux<br>
<br><br>

Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors<br>
Disk model: VBOX HARDDISK   <br>
Units: sectors of 1 * 512 = 512 bytes<br>
Sector size (logical/physical): 512 bytes / 512 bytes<br>
I/O size (minimum/optimal): 512 bytes / 512 bytes<br>
Disklabel type: dos<br>
Disk identifier: 0xb289fd48<br>
<br>
Device     Boot   Start     End Sectors  Size Id Type<br>
/dev/sdc1          2048 4196351 4194304    2G 83 Linux<br>
/dev/sdc2       4196352 5242879 1046528  511M 83 Linux<br>

6.
root@vagrant:\~# mdadm --create --verbose /dev/md1 -l 1 -n 2 /dev/sd{b1,c1}<br>
mdadm: Note: this array has metadata at the start and<br>
    may not be suitable as a boot device.  If you plan to<br>
    store '/boot' on this device please ensure that<br>
    your boot-loader understands md/v1.x metadata, or use<br>
    --metadata=0.90<br>
mdadm: size set to 2094080K<br>
Continue creating array? y<br>
mdadm: Defaulting to version 1.2 metadata<br>
mdadm: array /dev/md1 started.<br>

7.
root@vagrant:\~# mdadm --create --verbose /dev/md1 -l 1 -n 2 /dev/sd{b1,c1}<br>
mdadm: Note: this array has metadata at the start and<br>
    may not be suitable as a boot device.  If you plan to<br>
    store '/boot' on this device please ensure that<br>
    your boot-loader understands md/v1.x metadata, or use<br>
    --metadata=0.90<br>
mdadm: size set to 2094080K<br>
Continue creating array? y<br>
mdadm: Defaulting to version 1.2 metadata<br>
mdadm: array /dev/md1 started.<br>
<br>
8.
root@vagrant:~# pvcreate /dev/md1 /dev/md0<br>
  Physical volume "/dev/md1" successfully created.<br>
  Physical volume "/dev/md0" successfully created<br>

9.
root@vagrant:~# vgcreate vg1 /dev/md1 /dev/md0<br>
  Volume group "vg1" successfully created<br>

root@vagrant:~# vgdisplay<br>
  --- Volume group ---<br>
  VG Name               vgvagrant<br>
  System ID             <br>
  Format                lvm2<br>
  Metadata Areas        1<br>
  Metadata Sequence No  3<br>
  VG Access             read/write<br>
  VG Status             resizable<br>
  MAX LV                0<br>
  Cur LV                2<br>
  Open LV               2<br>
  Max PV                0<br>
  Cur PV                1<br>
  Act PV                1<br>
  VG Size               <63.50 GiB<br>
  PE Size               4.00 MiB<br>
  Total PE              16255<br>
  Alloc PE / Size       16255 / <63.50 GiB<br>
  Free  PE / Size       0 / 0   <br>
  VG UUID               5zL1A7-9ldG-J06F-1Pnu-m7we-mAzr-wBnOoF<br>
   
  --- Volume group ---<br>
  VG Name               vg1<br>
  System ID             <br>
  Format                lvm2<br>
  Metadata Areas        2<br>
  Metadata Sequence No  1<br>
  VG Access             read/write<br>
  VG Status             resizable<br>
  MAX LV                0<br>
  Cur LV                0<br>
  Open LV               0<br>
  Max PV                0<br>
  Cur PV                2<br>
  Act PV                2<br>
  VG Size               2.49 GiB<br>
  PE Size               4.00 MiB<br>
  Total PE              638<br>
  Alloc PE / Size       0 / 0  <br> 
  Free  PE / Size       638 / 2.49 GiB<br>
  VG UUID               tojQnc-yOx3-L2uF-35cS-agip-bkwo-5Sz4ol<br>

10.
root@vagrant:\~# lvcreate -L 100M vg1 /dev/md0<br>
  Logical volume "lvol0" created.<br>
root@vagrant:~# vgs<br>
  VG        #PV #LV #SN Attr   VSize   VFree<br>
  vg1         2   1   0 wz--n-   2.49g 2.39g<br>
  vgvagrant   1   2   0 wz--n- <63.50g    0 <br>
root@vagrant:\~# lvs<br>
  LV     VG        Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert<br>
  lvol0  vg1       -wi-a----- 100.00m                                                    <br>
  root   vgvagrant -wi-ao---- <62.54g                                                    <br>
  swap_1 vgvagrant -wi-ao---- 980.00m<br>

11.
root@vagrant:\~# mkfs.ext4 /dev/vg1/lvol0<br>
mke2fs 1.45.5 (07-Jan-2020)<br>
Creating filesystem with 25600 4k blocks and 25600 inodes<br><br>

Allocating group tables: done                         <br>   
Writing inode tables: done                            <br>
Creating journal (1024 blocks): done<br>
Writing superblocks and filesystem accounting information: done<br>

12.
root@vagrant:\~# mkdir /tmp/new<br>
root@vagrant:\~# mount /dev/vg1/lvol0 /tmp/new<br>

13.
root@vagrant:~# wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz<br>
--2021-11-30 12:50:09--  https://mirror.yandex.ru/ubuntu/ls-lR.gz<br>
Resolving mirror.yandex.ru (mirror.yandex.ru)... 213.180.204.183, 2a02:6b8::183<br>
Connecting to mirror.yandex.ru (mirror.yandex.ru)|213.180.204.183|:443... connected.<br>
HTTP request sent, awaiting response... 200 OK<br>
Length: 20488555 (20M) [application/octet-stream]<br>
Saving to: ‘/tmp/new/test.gz’<br>

/tmp/new/test.gz     100%[=====================>]  19.54M  6.65MB/s    in 2.9s    <br>

2021-11-30 12:50:12 (6.65 MB/s) - ‘/tmp/new/test.gz’ saved [20488555/20488555]<br>

root@vagrant:\~# ls -l /tmp/new<br>
total 20012<br>
-rw-r--r-- 1 root root 20488555 Nov 30 12:15 test.gz<br>
root@vagrant:\~#<br>

14.
root@vagrant:\~# lsblk<br>
NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT<br>
sda                    8:0    0   64G  0 disk  <br>
├─sda1                 8:1    0  512M  0 part  /boot/efi<br>
├─sda2                 8:2    0    1K  0 part  <br>
└─sda5                 8:5    0 63.5G  0 part  <br>
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /<br>
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]<br>
sdb                    8:16   0  2.5G  0 disk  <br>
├─sdb1                 8:17   0    2G  0 part  <br>
│ └─md1                9:1    0    2G  0 raid1 <br>
└─sdb2                 8:18   0  511M  0 part  <br>
  └─md0                9:0    0  510M  0 raid1 <br>
    └─vg1-lvol0      253:2    0  100M  0 lvm   /tmp/new<br>
sdc                    8:32   0  2.5G  0 disk  <br>
├─sdc1                 8:33   0    2G  0 part  <br>
│ └─md1                9:1    0    2G  0 raid1 <br>
└─sdc2                 8:34   0  511M  0 part  <br>
  └─md0                9:0    0  510M  0 raid1 <br>
    └─vg1-lvol0      253:2    0  100M  0 lvm   /tmp/new<br>

15.
root@vagrant:~# gzip -t /tmp/new/test.gz && echo $?<br>
0<br>

16.
root@vagrant:\~# pvmove /dev/md0<br>
  /dev/md0: Moved: 12.00%<br>
  /dev/md0: Moved: 100.00%<br>
root@vagrant:~# lsblk<br>
NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT<br>
sda                    8:0    0   64G  0 disk  <br>
├─sda1                 8:1    0  512M  0 part  /boot/efi<br>
├─sda2                 8:2    0    1K  0 part  <br>
└─sda5                 8:5    0 63.5G  0 part  <br>
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /<br>
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]<br>
sdb                    8:16   0  2.5G  0 disk  <br>
├─sdb1                 8:17   0    2G  0 part  <br>
│ └─md1                9:1    0    2G  0 raid1 <br>
│   └─vg1-lvol0      253:2    0  100M  0 lvm   /tmp/new<br>
└─sdb2                 8:18   0  511M  0 part  <br>
  └─md0                9:0    0  510M  0 raid1 <br>
sdc                    8:32   0  2.5G  0 disk  <br>
├─sdc1                 8:33   0    2G  0 part  <br>
│ └─md1                9:1    0    2G  0 raid1 <br>
│   └─vg1-lvol0      253:2    0  100M  0 lvm   /tmp/new<br>
└─sdc2                 8:34   0  511M  0 part  <br>
  └─md0                9:0    0  510M  0 raid1 <br>
root@vagrant:\~#<br>

17.

root@vagrant:\~# mdadm /dev/md1 --fail /dev/sdb1<br>
mdadm: set /dev/sdb1 faulty in /dev/md1<br>

root@vagrant:~# mdadm -D /dev/md1<br>
/dev/md1:<br>
           Version : 1.2<br>
*******<br>
Consistency Policy : resync<br>

              Name : vagrant:1  (local to host vagrant)<br>
              UUID : 1aac0a29:<br>
root@vagrant:\~# mdadm -D /dev/md1<br>
/dev/md1:<br>
           Version : 1.2<br>
0fa0dc73:082e1042:fe00b376<br>
            Events : 19<br>

    Number   Major   Minor   RaidDevice State<br>
       -       0        0        0      removed<br>
       1       8       33        1      active sync   /dev/sdc1<br>

       0       8       17        -      faulty   /dev/sdb1<br>

18.

root@vagrant:\~# dmesg |grep md1<br>
[  480.422928] md/raid1:md1: not clean -- starting background reconstruction<br>
[  480.422930] md/raid1:md1: active with 2 out of 2 mirrors<br>
[  480.422945] md1: detected capacity change from 0 to 2144337920<br>
[  480.425781] md: resync of RAID array md1<br>
[  490.758344] md: md1: resync done.<br>
[ 2325.890719] md/raid1:md1: Disk failure on sdb1, disabling device.<br>
               md/raid1:md1: Operation continuing on 1 devices.<br>

19.
root@vagrant:\~# gzip -t /tmp/new/test.gz && echo $?<br>
0

20.
Выполнено:<br>
15:13:33 alex@upc(0):~/vagrant$ vagrant destroy<br>
    default: Are you sure you want to destroy the 'default' VM? [y/N] y<br>
==> default: Forcing shutdown of VM...<br>
==> default: Destroying VM and associated drives..<br>

# General notes:
There is extensive documentation on ovirt.
Our examples based on gluster, thus gluster experience is needed (Docs available to read online).
The notes refer only to ovirt 4.1, 4.2 and shoudl work at 4.3. oVirt has moved since then but these notes might still have sth useful.

# Basic troubleshooting of ovirt:

## Steps to reset engine:
1. Enable global maintenance: hosted-engine --set-maintenance --mode=global
2. at host (v0 or v1) shutdown engine: hosted-engine --vm-shutdown
3. confirm that engine is shut down
4. at host, start engine: hosted-engine --vm-start
5. Confirm engine is up (ping, web)
6. remove global maintenance: hosted-engine --set-maintenance --mode=none


Check status of gluster:
List volumes:
```
gluster volume list
```

Check status of all volumes:
```
gluster volume status
```

Check status of specific volume:
```
gluster volume status <vol name>
```

Check file heal status:
```
gluster volume heal <vol name> info
```

Check if volume has split-brain:
```
gluster volume heal <vol name> info split-brain
```

Check jumbo frames on the glusters
```
ping -s 8000 <gluster host>
```

In case of timeouts, check if jumbo frames are enabled on the main switch

Check status of hosted engine:
```
hosted-engine --vm-status
```

other useful commands:
```
hosted-engine --help
```

## Ovirt procedure for minor upgrade:

1. Enable global maintenance mode:
```
hosted-engine --set-maintenance --mode=global
```

2. At engine:
```
engine-upgrade-check
yum update "ovirt-*-setup*"
engine-setup
yum update
```

3. Disable global maintenance:
```
hosted-engine --set-maintenance --mode=none
```

4. Update each host by putting it on maintenance mode. You may need to shutdown some VMs if not all of them can be migrated to alternate host. Then click on host -> Installation -> Upgrade. After upgrade is reported as completed from dashboard, confirm all packages are updated with: yum update  After completion of host update reboot host and then activate it from dashboard: reboot, host -> activate


### Notes
- Important: The update process may take some time; allow time for the update process to complete and do not stop the process once initiated.
- If the upgrade fails, the `engine-setup` command attempts to roll your oVirt Engine installation back to its previous state. For this reason, the previous version’s repositories must not be removed until after the upgrade is complete. If the upgrade fails, detailed instructions display that explain how to restore your installation.

### Resolving dependency issues during installation or upgrades:
In case you face package dependency issues, due to missing repos, then you may switch your repos to point to the archived ones, depending on the version of CentOS and oVirt you are currently running. For example, ovirt 4.2 does work with CentOS up until 7.6 as it will not install on centos 7.7 and greater due to dependency issues. In order to resolve it you need to freeze the base repo to point to the specific centos repo at vault.centos.org. Example:
```
cat /etc/yum.repos.d/etc/centos-release
```

CentOS Linux release 7.6.1810 (Core)

The content of the base repo is updated as below:
cat CentOS-Base.repo
```
# CentOS-Base.repo
#
# The mirror system uses the connecting IP address of the client and the
# update status of each mirror to pick mirrors that are updated to and
# geographically close to the client.  You should use this for CentOS updates
# unless you are manually picking other mirrors.
#
# remarked out baseurl= line instead.
#
#
[base]
name=CentOS-7.6.1810 - Base
baseurl=http://vault.centos.org/7.6.1810/os/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#released updates
[updates]
name=CentOS-7.6.1810 - Updates
baseurl=http://vault.centos.org/7.6.1810/updates/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#additional packages that may be useful
[extras]
name=CentOS-7.6.1810 - Extras
baseurl=http://vault.centos.org/7.6.1810/extras/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-7.6.1810 - Plus
baseurl=http://vault.centos.org/7.6.1810/centosplus/$basearch/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
```

The above is easily done with the following sed command:
```
cd /etc/yum.repos.d/
cp CentOS-Base.repo /root/CentOS-Base.repo.bak
sed -e '/mirrorlist=.*/d' \
    -e 's/#baseurl=/baseurl=/' \
    -e "s/\$releasever/7.6.1810/g" \
    -e "s/mirror.centos.org\\/centos/vault.centos.org/g" \
    -i /etc/yum.repos.d/CentOS-Base.repo
```

Then you need to point ovirt-4.2-dependencies.repo to vault.centos.org:
```
cat ovirt-4.2-dependencies.repo


[ovirt-4.2-epel]
name=Extra Packages for Enterprise Linux 7 - $basearch
baseurl=http://download.fedoraproject.org/pub/epel/7/$basearch
#mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-7&arch=$basearch
failovermethod=priority
enabled=1
includepkgs=
 ansible,
 ansible-doc,
 epel-release,
 facter,
 hiera,
 libtomcrypt,
 libtommath,
 nbdkit,
 nbdkit-devel,
 nbdkit-plugin-python2,
 nbdkit-plugin-python-common,
 nbdkit-plugin-vddk,
 ovirt-guest-agent*,
 puppet,
 python2-crypto,
 python2-ecdsa,
 python-ordereddict,
 ruby-augeas,
 rubygem-rgen,
 ruby-shadow

gpgcheck=1
gpgkey=https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7

[ovirt-4.2-centos-gluster312]
name=CentOS-7.6.1810 - Gluster 3.12
baseurl=http://vault.centos.org/centos/7.6.1810/storage/$basearch/gluster-3.12/
gpgcheck=1
enabled=1
gpgkey=https://raw.githubusercontent.com/CentOS-Storage-SIG/centos-release-storage-common/master/RPM-GPG-KEY-CentOS-SIG-Storage

[ovirt-4.2-virtio-win-latest]
name=virtio-win builds roughly matching what will be shipped in upcoming RHEL
baseurl=http://fedorapeople.org/groups/virt/virtio-win/repo/latest
enabled=1
skip_if_unavailable=1
gpgcheck=0

[ovirt-4.2-centos-qemu-ev]
name=CentOS-7.6.1810 - QEMU EV
baseurl=http://vault.centos.org/centos/7.6.1810/virt/$basearch/kvm-common/
gpgcheck=1
enabled=1
gpgkey=https://www.centos.org/keys/RPM-GPG-KEY-CentOS-SIG-Virtualization

[ovirt-4.2-centos-opstools]
name=CentOS-7.6.1810 - OpsTools - release
baseurl=http://vault.centos.org/centos/7.6.1810/opstools/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://www.centos.org/keys/RPM-GPG-KEY-CentOS-SIG-OpsTools

[centos-sclo-rh-release]
name=CentOS-7.6.1810 - SCLo rh
baseurl=http://vault.centos.org/centos/7.6.1810/sclo/$basearch/rh/
gpgcheck=1
enabled=1
gpgkey=https://www.centos.org/keys/RPM-GPG-KEY-CentOS-SIG-SCLo

[ovirt-4.2-centos-ovirt42]
name=CentOS-7.6.1810 - oVirt 4.2
baseurl=http://vault.centos.org/centos/7.6.1810/virt/$basearch/ovirt-4.2/
gpgcheck=1
enabled=1
gpgkey=https://www.centos.org/keys/RPM-GPG-KEY-CentOS-SIG-Virtualization
```

Note. When installing ovirt on 7.6.1810 I had to downgrade ansible to 2.7, as ovirt deploy is not compatible with ansible 2.8 and above. The downgrade is done easily with:
```
yum --showduplicates list ansible
yum downgrade ansible-2.7.10-1.el7
```

## Ovirt procedure for major upgrade
1. update DC to latest minor version (engine + nodes)

2. enable global maintenance: `hosted-engine --set-maintenance --mode=global`

3. at engine: install major version repo: `yum install https://resources.ovirt.org/pub/yum-repo/ovirt-release4x.rpm`

4. at engine:
```
engine-upgrade-check
yum update "ovirt-*-setup*"
engine-setup
```

7. if the upgrade is successful, at engine: remove the old ovirt release from `/etc/yum.repos.d`

8. at engine: `yum update`

9. after completion of engine upgrade disable global maintenance
```
hosted-engine --set-maintenance --mode=none
```

10. verify engine version from GUI

11. update each host/node: update to minor, then install new repo, remove old repo, yum update, reboot, activate

12. after completion of updates: set DC and cluster compatibility level to latest version 4.x.

13. shutdown guest VMs and confirm they start up again. (you may need to disable guest disk leases or re-activate guest disks)

14. check events for any issues and fix accordingly

### Notes
- After updating a cluster’s compatibility version, you must update the cluster compatibility version of all running or suspended virtual machines by rebooting them from the Administration Portal
- During the engine upgrade, if the upgrade fails, the engine-setup command attempts to roll your oVirt Engine installation back to its previous state. For this reason, the previous version’s repositories must not be removed until after the upgrade is complete

ovirt email alerts:
Normally you would set email alerts with a config file, as per IV manual.
In case you have set email alerts in DB during deploy you may change it as below:
get current value by running at host:
```
hosted-engine --get-shared-config destination-emails --type=broker
```

set email by running at host:
```
hosted-engine --set-shared-config destination-emails alerts@examplep.com --type=broker
Then you might need to put to maintenance and reboot each host...
```

Advanced topics:
Resolve heal issues:
First of all check that all bricks are up with gluster volume status
In case you don't have split-brain files but still the volume does not heal, then you will need to delete the file from the servers that report the issue and leave only the healthy copy:

Example:
```
gluster volume heal iso info
Brick gluster1:/gluster/iso/brick
<gfid:1e4cc932-e491-411d-a755-40254d653295>
Status: Connected
Number of entries: 1

Brick gluster2:/gluster/iso/brick
Status: Connected
Number of entries: 0

Brick gluster0:/gluster/iso/brick
Status: Connected
Number of entries: 0
```

delete or move the file that is reported as needing healing:
```
mv .glusterfs/1e/4c/1e4cc932-e491-411d-a755-40254d653295 /root/
```

Resolve split-brain in gluster:

Simple split brain resolution:
```
gluster volume heal <VOLNAME> split-brain latest-mtime <FILE>
example: gluster volume heal vms split-brain latest-mtime gfid:c45d17d9-722a-496a-ac83-96b39e88fb11

gluster volume heal <VOLNAME> split-brain bigger-file <FILE>
gluster volume heal <VOLNAME> split-brain source-brick <HOSTNAME:BRICKNAME>

for i in `gluster volume heal <volume>  info split-brain | awk '/^<gfid:/{print}'`;do gluster volume heal <volume> split-brain latest-mtime "${i:1:${#i}-2}";done
```

Get gfid of file:
```
getfattr -n glusterfs.gfid.string /mnt/testvol/dir/file
```

You may try to stop/start the volume in case you are not getting gfid for some files. Also in case you are getting Operation not permitted on your split resolution attempts no matter what, then your only hope is to go at the .glusterfs directory of the brick and move the offending file/directory to /root/ and check again split-brain status.

For more details to understand type of split-brain, and in case you cannot resolve with above, please refer to Gluster-split-brain-resolution attached.

Useful Links for split-brain resolution:
https://github.com/gluster/glusterfs/blob/master/doc/debugging/split-brain.md

https://support.rackspace.com/how-to/glusterfs-troubleshooting/

The procedure to enable gfapi is below.

1) stop all the vms running
2) Enable gfapi via UI (for 4.2) or using engine-config command:  `engine-config -s LibgfApiSupported=true `
3) Restart ovirt-engine service
4) start the vms.

### Lockspace corrupted recovery procedure

If you end up with corrupted sanlock lockspace due to power outage, hw failure or so, you can fix it using the following procedure:

    Move HE to global maintenance
    Stop all HE agents on all hosts (keep the local broker running)
    Run hosted-engine –reinitialize-lockspace from the host with running broker


# Recover VM from corrupted snapshot with disk in illegal state: (not clean solution as it leaves orphaned snapshots at the storage domains)

1. Login at engine DB
ssh to engine and run:
```
on ovirt 4.1:
su - postgres
psql
\c engine

on ovirt 4.2:
su - postgres -c 'scl enable rh-postgresql95 -- psql'
\c engine
```

2. Get the VM ID (from GUI or DB) and  find the broken snapshot in the snapshots table and delete it.
```
engine=# select snapshot_id,snapshot_type,status,description from snapshots where vm_id='0aff510b-b55a-4986-9d12-8407748fcd8b';
2dd4c31d-7c57-4f87-b863-4fb3de1a5196 | REGULAR       | OK     | smartbox-7.1.2
 6a93187c-2b3f-409f-9831-3c11d36f3efb | ACTIVE        | OK     | Active VM
 818c46ff-4c32-496d-a4ca-12459e4ca917 | REGULAR       | OK     | Backup
```
4. Get the UUID of the affected VM disk (from GUI or DB) and find the image linked to the broken snapshot
```
select image_guid,parentid,imagestatus,vm_snapshot_id,volume_type,volume_format,active from images where image_group_id='0994f9c0-568e-4e4c-b0ea-0370de64d2a7';
 cf8707f2-bf1f-4827-8dc2-d7e6ffcc3d43 | 3f54c98e-07ca-4810-82d8-cbf3964c7ce5 |           1 | 2dd4c31d-7c57-4f87-b863-4fb3de1a5196 |           2 |             4 | f
 1e75898c-9790-4163-ad41-847cfe84db40 | cf8707f2-bf1f-4827-8dc2-d7e6ffcc3d43 |           4 | 818c46ff-4c32-496d-a4ca-12459e4ca917 |           2 |             4 | f
 604d84c3-8d5f-4bb6-a2b5-0aea79104e43 | 1e75898c-9790-4163-ad41-847cfe84db40 |           1 | 6a93187c-2b3f-409f-9831-3c11d36f3efb |           2 |             4 | t
```
5. Delete the broken snapshot from the snapshots table.
```
engine# delete from snapshots where snapshot_id='818c46ff-4c32-496d-a4ca-12459e4ca917';
DELETE 1
```

6. Delete the associated image to the broken snapshots.
```
engine=# delete from images where image_guid='1e75898c-9790-4163-ad41-847cfe84db40';
DELETE 1
```
At this time, the snapshot is no longer shown on the 'Snapshots' tab of the VM.

7. check the status of volumes in the data domain. At SPM run:
```
vdsm-tool -vvv dump-volume-chains 142bbde6-ef9d-4a52-b9da-2de533c1f1bd | grep ILLEGAL
```

8. In case no ILLLEGAL volumes are listed just start the VM.
In case you still get ILLEGAL volumes of the affected VM, then make them legal:

To get the volume ID startup the VM and observe vdsm log:
```
tail -f /var/log/vdsm/vdsm.log |grep prepareImage
```

Example:
```
2018-06-19 12:13:26,832+0100 INFO (vm/5bf9a0bb) [vdsm.api] START prepareImage(sdUUID=u'bc0480e2-85fe-42a4-91ae-f733b23c801f', spUUID=u'75bf8f48-970f-42bc-8596-f8ab6efb2b63', imgUUID=u'870f7e85-d9b6-494a-9541-b419fb0e1b32', leafUUID=u'd7fa8c51-8cad-4695-b90a-a8d1dc146371', allowIllegal=False) from=internal, task_id=89770233-103d-47f3-acc1-45d2e96d9e91 (api:46)
```

Now, go to the SPM and run a command like this:


on ovirt 4.1:
```
vdsClient -s yourhost.com setVolumeLegality bc0480e2-85fe-42a4-91ae-f733b23c801f 75bf8f48-970f-42bc-8596-f8ab6efb2b63 870f7e85-d9b6-494a-9541-b419fb0e1b32 d7fa8c51-8cad-4695-b90a-a8d1dc146371 LEGAL
```

on ovirt 4.2:
```
vdsm-client -a v0.example.com Volume setLegality storagedomainID=bc0480e2-85fe-42a4-91ae-f733b23c801f storagepoolID=75bf8f48-970f-42bc-8596-f8ab6efb2b63 imageID=870f7e85-d9b6-494a-9541-b419fb0e1b32 volumeID=d7fa8c51-8cad-4695-b90a-a8d1dc146371 legality=LEGAL
```

In case you still get ILLEGAL image status, although no ILLEGAL images are reported from SPM and not chain issues are observed at image file, then you may just flag the image as ok in the DB:
Example: update images set imagestatus='1' where image_guid='snapshot id';

Clean chain of backing files:
In case the backing file chain is not reflecting the snapshot chain at engine, then you need to rebase to fix the issue:
```
qemu-img info --backing-chain <active snap ID>

sudo qemu-img rebase -f qcow2 -b $NEW_BACKING_FILE $QCOW2_FILE_TO_CHANGE
```
Then you delete the redundant file at teh ovirt storage domain.



### Engine VM not booting: attempt to repair
```
yum install libguestfs-xfs
```

# Determine location of HostedEngine disk. You need the disk located at the actual gluster mount point and not at /var/run.
```
virsh -r dumpxml HostedEngine
```

# Power off engine
```
hosted-engine --vm-poweroff
```

# run guestfish to repair VM disk
```
LIBGUESTFS_BACKEND=direct guestfish --rw -a <disk>
```

example:
```
LIBGUESTFS_BACKEND=direct guestfish --rw --format=raw -a /rhev/data-center/mnt/glusterSD/10.100.100.1:_engine/6b370875-de94-4590-9cd3-0db870c379d8/images/77396445-5f3a-4abd-a1f8-f9e406fc027e/5d7e37db-d981-43e2-8468-824597b9673c
```

```
><fs> run
><fs> list-filesystems
/dev/sda1: swap
/dev/sda2: xfs
```
# repair disks
```
xfs-repair /dev/sda2
```

In case you are not allowed to repair the disk then you can do it out of guestfish by attaching the partition with losetup and then running xfs_rair on `/dev/mapper/loopp1` respective partition.

example:
```
losetup /dev/loop0 /rhev/data-center/mnt/glusterSD/10.100.100.1:_engine/6b370875-de94-4590-9cd3-0db870c379d8/images/77396445-5f3a-4abd-a1f8-f9e406fc027e/5d7e37db-d981-43e2-8468-824597b9673c
kpartx -a /dev/loop0
xfs_repair /dev/mapper/loop0p2
```
OR you could delete metadata log if needed: `xfs_repair -L /dev/mapper/loop0p2`

# Restart HostedEngine Paused
```
hosted-engine --vm-start-paused
```

# Add VNC password
```
hosted-engine --add-console-password
```

# Connect via Remote Viewer

# Start VM and quickly edit Grub on viewer (move fast)
```
virsh -c qemu://hostname.local/system resume HostedEngine
```

 This will allow to edit grub or select another kernel to boot.

# Enable vdsm debug logs:
```
vdsm-client Host setLogLevel level=DEBUG
```

# Disable vdsm debug logs:
```
vdsm-client Host setLogLevel level=INFO
```

Access from other network or NAT - When receive error

The redirection URI for client is not registered.


ammend `/etc/ovirt-engine/engine.conf.d/99-setup-sso.conf` and add:
```
SSO_CALLBACK_PREFIX_CHECK=false
systemctl  restart ovirt-engine
```

### Commands to define and start a guest VM
```
virsh define <domain>.xml
virsh autostart <domain>
virsh start <domain>.xml
```

### commands to define and start the ovirt guest network
```
virsh net-define vdsm-ovirtmgmt.xml
virsh net-start vdsm-ovirtmgmt
virsh net-autostart vdsm-ovirtmgmt
```

Note that when a VM is started at ovirt, the xml of the VM is logged at vdsm.log. The line contains the wording xml version="1.0".

## Renew engine expired certificate:
1. Enable global maintenance: at one host run:
```
hosted-engine --set-maintenance --mode=global
```
2. At engine run `engine-setup --offline`

and choose Renew certificates? (Yes, No) [No]: Yes

Check engine certificate expiration date:

`openssl x509 -in /etc/pki/ovirt-engine/certs/engine.cer -noout -dates`

Notes that if, at step 2, the engine keep complaining that the cluster is not to global maintenance then trick it by changing the status at the engine DB: Example:
```
SELECT vm_guid, run_on_vds FROM vms  WHERE vm_name ='HostedEngine';
SELECT vds_id, ha_global_maintenance FROM vds_statistics WHERE vds_id = 'e24f0dcc-51f3-4d1a-acf5-2833a9dc584a';
UPDATE vds_statistics SET ha_global_maintenance = true WHERE vds_id = 'e24f0dcc-51f3-4d1a-acf5-2833a9dc584a';
```
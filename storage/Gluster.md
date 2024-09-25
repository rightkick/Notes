# Intro
GlusterFS is an open source distributed file system. The project also has great documentation and Redhat has invested quite al a lot in maturing the solution and its adaption. 

The file system is distributed between the participating nodes which are referred as peers. The peers have a set of bricks which are the building blocks of the glusterfs volumes. Glusterfs supports different distribution models such as replicated, distributed, dispersed and a combination of those which can quickly become complex. 

Generally the gluster bricks can be placed on top any file system that supports extended attributes. It is recommneded that the bricks reside on top of different partition, LVM volumes or separate disk for better performance and resiliency. 

I have had great success using the mirrored approach as a data store for virtualization solutions such as oVirt, KVM and Proxmox, using the high performant libgfapi access mode which is supported from libvirt. I have used also replicated volumes as a DB store in order to provide an alternative MariaDB HA solution through pacemaker/corosync. 

In case you are going into production take note that you need to make sure you meet some requirements, such as at least three nodes so as to meet quorum. This can be a set of three identical servers or 2 high-end servers + 1 low-end one which will act as an arbiter for the quorum requirement. This helps to avoid split brains which can easily occur when you go with a 2 node setup. 

# Install GlusterFS
```
apt install glusterfs-server -y

systemctl enable glusterd.service
systemctl restart glusterd
```

For better performance you need to add the following line at `/etc/glusterfs/glusterd.vol` of each host:
```
option rpc-auth-allow-insecure on
```

Then restart glusterfs: 
```
systemctl restart glusterd
```

## Add glusterfs peers
```
gluster peer probe gluster1
gluster peer probe gluster2
```

## Create bricks
The bricks will be used to create gluster volumes. These bricks should be places at least at different partitions or different disks.

```
mkdir -p /mnt/gluster/{vms,iso}/brick
```

## Create volumes
For 3 replica nodes:
```
gluster volume create vms replica 3 gluster0:/mnt/gluster/vms/brick gluster1:/mnt/gluster/vms/brick gluster2:/mnt/gluster/vms/brick

gluster volume create iso replica 3 gluster0:/mnt/gluster/iso/brick gluster1:/mnt/gluster/iso/brick gluster2:/mnt/gluster/iso/brick
```

## Set gluster volumes attributes
These volume attributes are recommended from the oVirt project so as to run VM workloads on top the glusterfs volumes. Glusterfs supports many attributes which you can investigate at the docs and apply them as needed. 

```
gluster volume set vms group virt
gluster volume set vms network.ping-timeout 30
gluster volume set vms performance.strict-o-direct on
gluster volume set vms server.allow-insecure on
gluster volume set vms features.shard-block-size 512MB
gluster volume start vms
gluster volume heal vms granular-entry-heal enable

gluster volume set iso cluster.quorum-type auto
gluster volume set iso cluster.server-quorum-type server
gluster volume set iso network.ping-timeout 30
gluster volume set iso server.allow-insecure on
gluster volume start iso
gluster volume heal iso granular-entry-heal enable
```

Note that in case you are testing with two nodes only, then you need to disable quorum at the volumes with:
```
gluster volume set VOLNAME cluster.server-quorum-type none
gluster volume set VOLNAME quorum-type none
```

## Check status of gluster
```
gluster volume status
gluster volume status <volume name>
gluster volume status <volume name> detail
gluster volume status <volume name> clients
gluster volume status <volume name> mem
gluster volume heal <volume name> info
```

# Resolve split brain:
Resolve directory/gfid split brain
Example with 3 nodes (2 + 1 arbiter) with split brain:
```
gluster volume heal engine info split-brain
Brick gluster0:/gluster/engine/brick/e1c80750-b880-495e-9609-b8bc7760d101/ha_agent
Status: Connected
Number of entries in split-brain: 1

Brick gluster1:/gluster/engine/brick/e1c80750-b880-495e-9609-b8bc7760d101/ha_agent
Status: Connected
Number of entries in split-brain: 1

Brick gluster2:/gluster/engine/brick/e1c80750-b880-495e-9609-b8bc7760d101/ha_agent
Status: Connected
Number of entries in split-brain: 1
```

The conflicting file (in this case is a directory) is

"/e1c80750-b880-495e-9609-b8bc7760d101/ha_agent"

Get the gfid of file:

`getfattr -m . -d -e hex e1c80750-b880-495e-9609-b8bc7760d101/ha_agent`


That gives the gfid: 0x277c9caa9dce4a17a2a93775357befd5

Then delete file within the bad brick (not gluster mount point):
```
cd /gluster/engine/brick/.glusterfs/27/7c
rm -rf 277c9caa-9dce-4a17-a2a9-3775357befd5 (or move it out of there)
```

Trigger heal:
```
gluster volume heal engine
```

Then all ok:
```
gluster volume heal engine info
Brick gluster0:/gluster/engine/brick
Status: Connected
Number of entries: 0

Brick gluster1:/gluster/engine/brick
Status: Connected
Number of entries: 0

Brick gluster2:/gluster/engine/brick
Status: Connected
Number of entries: 0
```

## Performance tweaks that have may boost your performance of the glusterfs volumes:
```
gluster volume set vms remote-dio enable
gluster volume set vms performance.write-behind-window-size 8MB
gluster volume set vms performance.cache-size 1GB
gluster volume set vms performance.io-thread-count 16
gluster volume set vms performance.readdir-ahead on
gluster volume set vms client.event-threads 8
gluster volume set vms server.event-threads 8
gluster volume set engine features.shard-block-size 512MB
```

Useful link:
https://support.rackspace.com/how-to/glusterfs-troubleshooting/


# Power Management for virtual cluster using fence_xvm

## At physical hypervisor: 
- install packages: 
```
yum install fence-virtd fence-virtd-libvirt fence-virtd-multicast
```

- created a shared key: 
```
mkdir /etc/cluster
dd if=/dev/urandom of=/etc/cluster/fence_xvm.key bs=4k count=1
```

- configure fence XVM: 
```
fence_virtd -c
```

use an interface that is acessible from your VMs (example: ovs-br0)
```
fence_virtd {
	listener = "multicast";
	backend = "libvirt";
	module_path = "/usr/lib64/fence-virt/";
}

listeners {
	multicast {
		key_file = "/etc/cluster/fence_xvm.key";
		address = "225.0.0.12";
		interface = "ovs-br0";
		family = "ipv4";
		port = "1229";
	}

}

backends {
	libvirt {
		uri = "qemu:///system";
	}

}
```

```
systemctl enable fence_virtd
systemctl start fence_virtd
firewall-cmd --permanent --add-port=1229/udp
firewall-cmd --reload
```

- Copy shared secret at each virtual host: 
```
for i in $(seq 0 1);do \
  ssh ovirt-node$i mkdir /etc/cluster; \
  scp /etc/cluster/fence_xvm.key node$i:/etc/cluster/;\
done
```

## At the virtual hosts: 
- configure fence agent: 
```
yum install fence-virt
firewall-cmd --permanent --add-port=1229/tcp
firewall-cmd --reload
```

- check fencing: 
```
fence_xvm -o list
fence_xvm -a 225.0.0.12 -k /etc/cluster/fence_xvm.key -H ovirt-node0 -o status
fence_xvm -a 225.0.0.12 -k /etc/cluster/fence_xvm.key -H ovirt-node1 -o status
```

## Configure fencing in ovirt engine
```
hosted-engine --set-maintenance --mode=global
engine-config -s CustomVdsFenceType="fence_xvm"
engine-config -s CustomFenceAgentMapping="fence_xvm=xvm"
systemctl restart ovirt-engine
```





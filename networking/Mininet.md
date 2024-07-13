## Default mininet VM login: 
```
mininet/mininet
```

Mininet virtualizes only the network. When running `ps -a` all nodes will have the same output and are showing the VM processes.

## Check current topology details

`mn`: login to mininet console (it will start also the default *minimal* topology). You can define different predefined topologies using `--topo`.

`dump`: check topology

`net`: check network topology

`links`: check links and their status

`nodes`: display nodes

`<host> <command>`: run a command at host: example: `h1 ip link`

`sh <command>`: run a host command from mininet console.


## Check interfaces of a host: 
```
h1 ip link
```

## Dump OpenFlow flows of the default controller

with mininet running, switch to the VM console and run

```
ovs-ofctl dump-flows tcp:127.0.0.1:6654
```

If you do not see any flows, you can quickly generate some by running `pingall` within mininet console.


## Changing your topology

The two most simple topologies are `linear` and `single`.

Define a single switch with 2 hosts connected at it: `mn --topo=single,2` (equivalent to minimal)

Define two switches linearly connected with one host per switch: `mn --topo=linear,2`

Define two switches linearly connected with two hosts per switch: `mn --topo=linear,2,2`


## Opening X11 to the mininet nodes

Make sure that the Mininet VM sshd allows X11 forwarding then, start mininet as below:

```
sudo -E mn -X
```

You can open a single XTERM session also without the need to use `-X`, by running `xterm <node>` at the mininet console.

The xterm consoles are just consoles at the VM level and not mininet consoles with the network part virtualized and isolated.


## Give internet access to hosts

Launch mininet with `--nat`. This will create a new interface at the root domain (VM) named `nat0-eth0` and iptables rules to NAT the traffic `-A POSTROUTING -s 10.0.0.0/8 ! -d 10.0.0.0/8 -j MASQUERADE`. This will add also a default route to the hosts such as `default via 10.0.0.3 dev h1-eth0` for h1.

Your VM, where mininet is running, will need to have a path to internet of-course for this to work.


## Change link characteristics

Mininet 2.0 allows you to set link parameters, and these can even be set automatically from the command line:

```
sudo mn --link tc,bw=10,delay=10ms
```

You can also directly use `tc`` to change link characteristics for a specific host or switch interface:

```
h1 tc qdisc add root dev h1-eth0 netem rate 8mbit delay 110ms limit 25
```


## Run Miniedit GUI app to draw your custom topologies

SSH into mininet VM with X forwarding enabled: `ssh -X mininet`

Then launch the **miniedit** app: `sudo -E python2 ~/mininet/examples/miniedit.py`

You can save the topology or export it as a python script. You can also launch terminals at each node and do your fun stuff.


## Running your own scripted topologies

You can write your own python script that define a custom topology. You then instantiate them within the root console by invoking the script with `sudo -E python custom.py`

# Intro

Kubernetes is a container orchestrator engine. It is deployed as a cluster of a single or multiple nodes. The nodes are of two types: master nodes, which run control plane processes, and worker nodes which run workload processes. The workload is a set of pods that are deployed from the user and run on worker nodes.


## Architecture

Following is the architecture with the main components and their interactions. An explanation of each component follows further down.

![image](https://github.com/rightkick/Notes/assets/15179132/b5d553d6-cc6a-4207-9e38-6e36cdff5da0)

*image source: https://kubernetes.io/*

### Control plane components 
- **master nodes**: these are physical or virtual nodes that run the control plane processes. It can be a single node or multiple nodes to provide HA. Master nodes can act also as a worker node, usually when you need to go with a single node cluster. 
- **Kubernetes API server**: The API server is the front end for the Kubernetes control plane. It is a component (pod) that provides all the API needed to run and manage the cluster. The name of this pod is `kube-apiserver`.  
- **Kubernetes scheduler**: this is responsible for scheduling the pods to the nodes. The pod is named `kube-scheduler`. 
- **Kubernetes controller**: this is set of different controllers bundled as a single component named `kube-controller-manager` and is responsible for monitoring nodes and managing endpoints for services and pods. Some types of controllers are: ReplicaSet, Deployment, StatefulSet, Job, CronJob, DaemonSet.
- **KV store**: kubernetes includes a key-value store that keeps the state of the cluster. Usually it is `etcd` but it can be any other supported technology. 
- **cloud controller manager**: optional component to provide integration with cloud APIs so as to manage clusters hosted at cloud providers. 


### Data plane components
- **worker nodes**: these are physical or virtual nodes that run workload processes (pods). 
- **kubelet**: agent that enables the control plane to manage the node where the `kubelet` is running. It makes sure that the containers run in the pods and provides health info at the control plane by interacting with the `kube-apiserver` that runs at the master nodes. 
- **kube-proxy**: is a network proxy that runs on each node in the cluster and is responsible to manage network aspects related to the pods. It usually uses the OS available netfilter functions to apply the iptables rules needed to redirect the traffic. 
- **container runtime**: a fundamental component that makes the nodes able to run containers. Several container runtime options are supported, which implement the Kubernetes CRI, such as containerd, CRIO, rkt, docker, etc. 


### Additional kubernetes components

- **kubectl**: a cluster management command line tool that is used to interact with the Kubernetes cluster. The tool is usually run out of the cluster and can be used to manage multiple clusters by switching context. 
- **Kubernetes dashboard**: one can enable the dashboard to provide simple web based management. 
- **Monitoring and logging**: one can use standard tooling (Prometheus, OTel) to scrape metrics related to the k8s cluster status. 
- **Storage**: CSI plugins to provide persistent storage to the cluster. 
- **Networking**: CNI plugins to provide advanced networking features. 
- **Virtual Machines**: you can install kubevirt so as to manage VMs on top Kubernetes. 


### Basic Types of kubernetes objects

- Pod
- Replicaset
- Deployment
- Service
- StatefulSet
- DaemonSet
- Jobs
- CronJobs
- Ingress
- NetworkPolicy
- ConfigMap
- Secret
- PersistentVolume (PV)
- PersistentVolumeClaim (PVC)
- Namespace
- Annotation

If you are interested to list all the available object types you can do that with `kubectl api-resources` and if you need a description of the resource type you can get that with `kubectl explain <object>`. 


### Kubernetes Networking

Kubernetes addresses four types of network requirements: 
- container-to-container connectivity: containers belonging in the same pod share the same network namespace. connectivity between containers is achieved through the localhost within the pod.
- pod-to-pod connectivity: achieved through veth pairs, local network bridges and overlay networking. 
- pod-to-service connectivity: achieved through Services. Requests to services are proxied to the available Pods. The proxying is implemented by kube-proxy, a Node-level control plane process that runs on each Node.
- external-to-service connectivity: achieved through Services (Ingress, LoadBalancer). 

The kubernetes network model is implemented from the container runtime (CRI) using network pugins or container network interfaces (CNI). The network model assures the following: 
- pods can communicate with all other pods on any other node without NAT
- agents on a node (e.g. system daemons, kubelet) can communicate with all pods on that node

CNI utilizes a plugin architecture to configure the Kubernetes cluster’s networking. The CNI plugin is responsible for creating and configuring the network interface for each container. When a container is created, the Kubernetes kubelet calls the CNI plugin to set up the network interface, assign an IP address, and add it to the Kubernetes network.

The CNI plugin also interacts with the IP Address Management (IPAM) plugin to allocate IP addresses to containers. This involves managing the pool of available IP addresses and assigning them as needed. Once the network interface is established, the kubelet starts the container, enabling it to communicate with other containers on the Kubernetes network.

On multi-node cluster setups kubernetes will use virtual overlay networking (VXLAN, Geneve, BGP, GRE, IP-IP, etc) to provide a flat network where all kubernetes resources will use to reach each other. 

Within the realm of CNI, networks can be instantiated using two primary models: encapsulated and unencapsulated. The encapsulated (overlay) model is based on technologies such as VXLAN, Geneve and IPsec. It encapsulates L2 networking on top L3. The unencapsulated (underlay) model extends a Layer 3 network to facilitate the routing of packets among containers and usually is based on BGP.

Kubernetes will allocate different non-overlapping IP address ranges to pods, services and nodes. IPV4, IPV6 or dual stack (IPV4 and IPV6) are supported. The IP address allocation is split as below:
- The network plugin (CNI) is configured to assign IP addresses to Pods.
- The kube-apiserver is configured to assign IP addresses to Services.
- The kubelet or the cloud-controller-manager is configured to assign IP addresses to Nodes.

Kubernetes includes also DNS funtions (usually through CoreDNS) so as to automatically assign DNS names to pods and services. 

Kubernetes provides also the option to configure network policies for network traffic enforcement. 


# Kubernetes flavors: 

Apart from the vanilla option, there are several other Kubernetes distributions out there that may be more fit for some cases. They come prebuilt with several plugins and tools thus usually are more opinionated. 

- **K3s**: lighweight version provided from Rancher (acquired from SUSE)
- **K0s**: lighweight version provided from Mirantis
- **KubeEdge**: lighweight version with focus on edge and IoT
- **Mikrok8s**: lighweight version provided from Canonical
- **k3d**: lighweight version for learning/dev purposes (k3s in docker)
- **Minikube**: lighweight version for learning/dev purposes. 
- **Kind**: lighweight version for learning/dev purposes. 
- **Openshift**: enterprise version provided from Redhat (OKD is the OSS upstream)


# Useful Kubernetes tools: 

### CI/CD
CI/CD tools that integrate well with Kubernetes:
- ArgoCD
- FluxCD

### Cluster management
Tools that facilitate cluster management:
- k9s
- kubeadm
- Kustomize
- Lens
- Kubeshark
- Kubespray
- Rancher
- Cluster API

### Storage
Some CSI plugins that integrate with Kubernetes:
- Longhorn
- OpenEBS
- Rook
- SeaweedFS

### Virtualization
Plugins that make k8s capable of running VMs:
- Kubevirt
- Kata containers

### CNI
Some famous CNI plugins are the following:

- Flannel
- Calico
- Cilium
- Cargo
- Kube-OVN
- Weave Net


### Playground for practise
In case you need to practice some k8s without deploying your own VMs:
- https://labs.play-with-k8s.com/



# Cheat Sheet

### Cluster

A kubernetes cluster is a set of nodes that coordinate to run the cluster services. It comprises of at least one master node and one worker node. The cluster can be a single node also that runs both master and worker node logic. 

- Get list of clusters: `kubectl config current-context`
- Get cluster status: `kubectl get cs`
- Get list of nodes: `kubectl get nodes -o wide`
- Get namespaces: `kubectl get namespaces`
- Get all objects: `kubectl get all`
- Create an object: `kubectl create -f file.yml`
- Describe an object (pod, deployment, etc): `kubectl describe <object type> <object name>`


### Pods

A pod is a set of one or more containers scheduled on the same physical or virtual machine that acts as a unit. A pod can have one or multiple containers. Every pod has an IP address that belongs to a range assigned to a node. The IP address changes whenever the pod is recreated. The IP address assigned to the pod is accessible from all nodes within the cluster. 

Here is a sample YAML definition for a pod:
```
# Pod definition
apiVersion: v1
kind: Pod
metadata:
  name: my-nginx
  labels:
    env: dev
spec:
  containers:
    - name: nginx
      image: nginx
      env:
        - name: env_var
          value: env_value
```

- Get list of pods: `kubectl get pods`
- Get pod details: `kubectl describe pod <pod>`
- List pods with a specific label: `kubectl get pods -l app=nginx-netshoot`
- Exec into a pod: `kubectl exec -it <pod> -- /bin/sh`
- Generate a yaml file for a pod: `kubectl run redis --image=redis -o yaml --dry-run=client`
- Port forward: `kubectl port-forward POD [LOCAL_PORT:]REMOTE_PORT`

Each pod includes at least one app container and a special *pause* container which is there to provide a shared network stack to the containers of the same pod. 

### Replication Controller

It is a kubernetes controller that can handle the replication of pods to scale the deployed apps and distribute the load. It is being replaced from Replicasets as a more powerful resource type. 

Here is a sample YAML definition for the ReplicationController:
```
# Replication Controller definition
apiVersion: v1
kind: ReplicationController
metadata:
  name: myapp-rc
  labels:
    app: my-app
    type: front-end
spec:
  template:
    metadata:
      name: my-nginx
      labels:
        env: dev
    spec:
      containers:
        - name: nginx
          image: nginx
  replicas: 2
  ```

  The ReplicationController spec has a template section which includes the content of a pod definition (apart from `apiVersion` and `kind`) and a `replicas` section defining the amount of replicas we need for the pod. 

- List replication controllers: `kubectl get replicationController`


### Replicasets

It is a kubernetes controller that can handle the replication of pods to scale the deployed apps and distribute the load. The ReplicaSet provides more advanced selector features then the ReplicationController so as to match pod labels in a more flexible way. 

Here is a sample YAML definition for a ReplicaSet:
```
# ReplicaSet definition
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: myapp-rs
  labels:
    app: my-app
    type: front-end
spec:
  template:
    metadata:
      name: my-nginx
      labels:
        env: dev
    spec:
      containers:
        - name: nginx
          image: nginx
  replicas: 2
  selector:
    matchLabels:
      env: dev
```

The spec of the ReplicaSet has three parts, the pod template, the replicas and the selector. The selector is used to match labels from deployed pods, regardless if they are created from the ReplicaSet or not. The ReplicaSet controller will make sure that the amount of replicas defined is always running and it can create new pods when needed using the template section. If you deploy pods out of the ReplicaSet that use the same label as the one monitored from the ReplicaSet then the ReplicaSet will terminate it since the additional external pod increases the number of replicas declared that have the same label. 

- List created replica-sets: `kubectl get replicaset`
- Replace or update replica-set: `kubectl replace -f file.yml`
- Edit a replica-set: `kubectl edit replicaset <replicaset name>`
- Force replace a replica-set: `kubectl replace -f file.yml --force`
- Scale a replica-set: `kubectl scale replicaset <replicaset name> --replicas=3`


### Deployments

A deployment is an abstraction for the pods and ReplicaSets. It allows you to have extra functionality and control on top of the pods regarding the amount of pod instances to run and their update strategy. 

The deployments can have two deployment strategies: *recreate* and *rolling update* (default). 

Here is a sample deployment file: 
```
# Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
  labels:
    tier: frontend
    app: nginx

spec:
  selector:
    matchLabels:
      app: my-app
  replicas: 3    
  template:
    metadata:
      name: my-nginx
      labels:
        app: my-app
    spec:
      containers:
        - name: nginx
          image: nginx
          ports:
          - containerPort: 80
  ```

- Create a deployment: `kubectl create -f deployment.yml --record `
- To roll-out/update a deployment, update yml file and `kubectl apply -f deployment.yml --record`
- Update image name for a container: `kubectl set image deployment/<deployment_name> <container_name>=<image_name>`
- List created deployments: `kubectl get deployments`
- Check status of roll-outs of a deployment: `kubectl rollout status deployment/<deployment_name>`
- View the history/revisions of a roll-out: `kubectl rollout history deployment/<deployment_name>`
- Roll-back a deployment: `kubectl rollout undo deployment/<deployment_name> --record`


### Kubernetes Services

It is a kubernetes construct that defines how the pods can be accessed within the cluster or outside the cluster. The service uses the pod labels to route the ingress traffic to the appropriate pods. If multiple pods match the labels used from the service selector then the traffic is load balanced between the different pods. 

The creation of the service will generate endpoints in the cluster. 

- View endpoints created from the service: `kubectl get endpoints`. 

If no endpoints are listed under a service then the pods will not be able to access the service. 

Following are the different types of services: 

- **ClusterIP**: exposes the service on an internal cluster IP. This is typically used for services only accessed by other workloads running within the cluster.
- **HeadLess**: this is useful to provide a service name which resolves to the pod IPs for direct pod-pod communications.
- **NodePort**: exposes a service on each worker nodes IP on a static port (default range: 30000-32767). 
- **LoadBalancer**: Exposes the service externally using a cloud provider’s load balancer.
- **ExternalName**: Maps the service to an external name via a DNS provider returning a CNAME record. 

Get list of services: `kubectl get svc -o wide`

### Kubernetes Ingress

Ingress helps to expose internal cluster applications to users that need to access such applications. It acts as a reverse proxy and interacts with an internal service to route traffic based on routing rules that are defined in an ingress resource. It operates at the OSI layer 7 and supports load balancing, TLS termination and named based virtual hosting. 

You may think that you can also expose an app by using a service of type `NodePort` or `LoadBalancer` but such types of services operate at layer 4 and they do not scale well if you need to expose multiple applications to different host names or paths. This is what ingress comes to solve. It can expose applications that are accessible internally through a `ClusterIP` service and it supports multiple host names or paths. For example you could have `app1.example.local` and `app2.example.local` or `app.example.local/path1` and `app.example.local/path2` all exposed through the same ingress controller.

Ingress is comprised of two objects: 
- ingress resources: general kubernetes constructs where the ingress rules are defined
- ingress controllers: third party implementations of ingress that automate and implement the rules defined in the ingress resources. 

Kubernetes does not come with a default ingress controller. You need to install one if you need to deploy such a thing. There are different types of ingress controllers that support software, hardware or cloud load balancers. For example Nginx or Traefik is an ingress controller that can act as a reverse proxy and load balancer in the same time by exposing an application to an IP address that is assigned to a worker node. This node acts as the ingress point to access the application. Alternatively you could deploy a cloud ingress controller which would automate the configuration of a cloud load balancer (for example AWS ELB) that would provide the ingress route to access your apps. 


# Tips
- You can append `-w` at you `kubectl` commands to watch/follow the output. 
- Most commands have a short version for less typing. Example: `kubectl get ns`
- Update your shell aliases to map `k` -> `kubectl`. 
- Append at your .bashrc to enable bash completion for kubectl commands: `source <(kubectl completion bash)`
- Use `netshoot` container to learn/troubleshoot networking. Exec into it as below: 
```
kubectl exec -it <netshoot_pod> -c netshoot -- /bin/sh
```


# Kind

Kind is a useful tool to quickly deploy kubernetes clusters on top Docker nodes. 

- Spin up a single node cluster: `kind create cluster`
- List clusters: `kind get clusters`
- Delete a cluster: `kind delete cluster`


# K3D

K3D is a useful tool to quickly deploy kubernetes clusters for dev use. 

- Create a cluster: `k3d cluster create`
- Stop a cluster: `k3d cluster stop <cluster name>`
- Start cluster: `k3s cluster start <cluster name>`
- List clusters: `k3d cluster list`
- List nodes: `k3d node list`
- Delete a cluster: `k3d cluster delete <cluster name>`


# Minikube

Minikube is a useful tool to quickly deploy kubernetes clusters on top Docker nodes.

- Spin up a 3 node minikube cluster: `minikube start --nodes 3`
- Spin up a cluster with Flannel as CNI: `minikube start --nodes 3 --cni flannel`
- Check cluster status: `minikube status`
- List minikube addons: `minikube addons list`
- Delete a local cluster: `minikube delete`






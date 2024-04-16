# Intro

Kubernetes is a container orchestrator solution. It is deployed as a cluster of a single or multiple nodes. The nodes are of two types: master nodes which run control plane processes and worker nodes which run workload processes. The workload is a set of pods that are deployed from the user.

## Control plane components 
- **master nodes**: these are physical or virtual nodes that run the control plane processes. It can be a single node or multiple nodes to provide HA. Master nodes can act also as a worker node, usually when you need to go with a single node cluster. 
- **Kubernetes API server**: The API server is the front end for the Kubernetes control plane. It is a component (pod) that provides all the API needed to run and manage the cluster. The name of this pod is kube-apiserver.  
- **Kubernetes scheduler**: this is responsible for scheduling the pods to the nodes. The pod is named kube-scheduler. 
- **Kubernetes controller**: this is set of different controllers bundled as a single component named kube-controller-manager and is responsible for monitoring nodes and managing endpoints for services and pods. Some types of controllers are: ReplicaSet, Deployment, StatefulSet, Job, CronJob, DaemonSet.
- **KV store**: kubernetes includes a key-value store that keeps the state of the cluster. Usually it is etcd but it can be any other supported technology. 
- **cloud controller manager**: optional component to provide integration with cloud APIs so as to manage clusters hosted at cloud providers. 

## Data plane components
- **worker nodes**: these are physical or virtual nodes that run workload processes (pods). 
- **kubelet**: agent that enables the control plane to manage the node. It makes sure that the containers run in the pods and provides health info at the control plane by interacting with the kube-apiserver that runs at the master nodes. 
- **kube-proxy**: is a network proxy that runs on each node in the cluster and is responsible to manage network aspects related to the pods. It can use the OS available netfilter functions. 
- **container runtime**: a foundamental component that makes teh nodes able to run containers. Several container runtime options are supported, which implement the Kubernetes CRI, such as containerd, CRIO, rkt, docker, etc. 

## Additional kubernetes components

- **kubectl**: a cluster management tool that is used to interact with the Kubernetes cluster. The tool is usually run out of the cluster and can be used to manage multiple clusters. 
- **Kubernetes dashboard**: one can enable the dashboard to provide simple web based management. 
- **Monitoring and logging**
- **Storage**: CSI plugins to provide persistent storage to the cluster. 
- **Networking**: CNI plugins to provide advanced networking features. 
- **Virtual Machines**: you can install kubevirt so as to manage VMs within Kubernetes. 

# Kubernetes flavors: 

Apart from the vanilla option, there are several other Kubernetes distributions out there that may be more fit for some cases. They come prebuilt with several plugins and tools thus usually are more opinionated. 

- **K3s**: lighweight version provided from Rancher (acquired from SUSE)
- **K0s**: lighweight version provided from Mirantis
- **KubeEdge**: lighweight version with focus on edge and IoT
- **Mikrok8s**: lighweight version provided from Canonical
- **Minikube**: lighweight version for learning/dev purposes. 
- **Kind**: lighweight version for learning/dev purposes. 
- **Openshift**: enterprise version provided form Redhat (OKD is the OSS upstream)


# Cheat Sheet

### Cluster

Get list of clusters: `kubectl config current-context`

Get list of nodes: `kubectl get nodes -o wide`

Get namespaces: `kubectl get namespaces`


## Pods

Get list of pods: `kubectl get pods`

Get pod details: `kubectl describe pod <pod>`

Exec into a pod: `kubectl exec -it <pod> -- /bin/sh`

Generate a yaml file for a pod: `kubectl run redis --image=redis -o yaml --dry-run=client`

Port forward: `kubectl port-forward POD [LOCAL_PORT:]REMOTE_PORT`


### Replication Controller

List replication controllers: `kubectl get replicationController`


### Replicasets

List created replica-sets: `kubectl get replicaset`

Replace or update replica-set: `kubectl replace -f file.yml`

Edit a replica-set: `kubectl edit replicaset <replicaset name>`

Force replace a replica-set: `kubectl replace -f file.yml --force`

Scale a replica-set: `kubectl scale replicaset <replicaset name> --replicas=3`


# Useful Kubernetes tools: 

### CI/CD
- ArgoCD

### Cluster manager
- k9s
- Lens
- Kubeshark
- kubeadm
- kubespray
- Rancher
- CloudStack
- Kosmotron

## Storage
- Longhorn
- OpenEBS
- Rook
- SeaweedFS

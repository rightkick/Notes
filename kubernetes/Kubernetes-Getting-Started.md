# Intro

Kubernetes is a container orchestrator solution. It is deployed as a cluster of a single or multiple nodes. The nodes are of two types: master nodes which run control plane processes and worker nodes which run workload processes. The workload is a set of pods that are deployed from the user.

## Control plane components 
- master nodes: these are physical or virtual nodes that run the control plane processes. It can be a single node or multiple nodes to provide HA. Master nodes can act also as a worker node, usually when you need to go with a single node cluster. 
- Kubernetes API server: it is a pod that provides all the API needed to run and manage the cluster. The name of this pod is kube-apiserver. 
- Kubernetes scheduler: this is responsible for scheduling the pods to the nodes. The pod is named kube-scheduler. 
- Kubernetes controller: this is apod named kube-controller-manager and is responsible for monitoring nodes and managing endpoints for services and pods. 
- KV store: kubernetes includes a key-value store that keeps the state of the cluster. Usually it is etcd but it can be any other supported technlology. 

## Data plane components
- worker nodes: these are physical or virtual nodes that run workload processes (pods). 
- kubelet: agent that enables the control plane to manage the node. 
- kube-proxy: this is a pod that runs at each node and is usefult to expose end-points at the network layer. 

## Additional kubernetes components
- Kubernetes dashboard: one can enable the dashboard to provide simple web based management. 
- Monitoring and logging
- Storage: CSI plugins to provide persistent storage to the cluster. 
- Networking: CNI plugins to provide advanced networking features. 

# Cheat Sheet

Get list of clusters: `kubectl config current-context`

Get list of nodes: `kubectl get nodes -o wide`

Get list of pods: `kubectl get pods`

Get pod details: `kubectl describe pod <pod>`

Get namespaces: `kubectl get namespaces`

Exec into a pod: `kubectl exec -it <pod> -- /bin/sh`

Port forward: `kubectl port-forward POD [LOCAL_PORT:]REMOTE_PORT`

Generate a yaml file for a pod: `kubectl run redis --image=redis123 -o yaml --dry-run=client`
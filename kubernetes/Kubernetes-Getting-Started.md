# Cheat Sheet

Get list of pods: `kubectl get pods`

Get pod details: `kubectl describe pod <pod>`

Get list of nodes: `kubectl get nodes`

Get list of clusters: `kubectl config current-context`

Exec into a pod: `kubectl exec -it <pod> -- /bin/sh`

Port forward: `kubectl port-forward POD [LOCAL_PORT:]REMOTE_PORT`

Get namespaces: `kubectl get namespaces`

Generate a yaml file for a pod: `kubectl run redis --image=redis123 -o yaml --dry-run=client`
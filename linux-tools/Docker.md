# For non running docker, use save:
```
docker save <container name> | gzip > mycontainer.tgz
```

# For running or paused docker, use export:
```
docker export <container name> | gzip > mycontainer.tgz
```

# Load
```
gunzip -c mycontainer.tgz | docker load
```

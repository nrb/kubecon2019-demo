# Prerequisities Not Covered

1. A Kubernetes Cluster 1.14 or above
1. A CSI driver with volume snapshotting capabilities
1. An ingress controller (we used ingress-nginx here)

# Initial Setup

```bash
kubectl apply -k ./setup
LB_ADDRESS="http://"$(kubectl get service/ingress-nginx -n ingress-nginx -o jsonpath="{.status.loadBalancer.ingress[0].hostname}")
open LB_ADDRESS
```

Make the data in your browser


# Create the snapshots

```
kubectl apply -f make-volumesnapshots.yaml
watch -d -n 5 kubectl get volumesnapshot -n wordpress -o jsonpath="{.items[*].status.readyToUse}"
```



# Prep for restore

Get the VolumeSnapshotContents associated with each VolumeSnapshot:

```bash
kubectl get volumesnapshotcontents -o jsonpath='{range .items[*]}{.spec.volumeSnapshotRef.name}{"\t"}{.metadata.name}{"\n"}{end}'
```

# Edit restore/volumesnapshots.yaml to add in the relevant VolumeSnapshotContent names

```
$EDITOR restore/volumesnapshots.yaml
```

# Destroy the namespace

```bash
kubectl delete namespace/wordpress
```


# Edit the VolumeSnapshotContents to omit the PVRef, remove UID from VolumeSnapshotRef

```
kubectl edit volumesnapshotcontents
```

# Recreate Snapshots & PVCs

```bash
kubectl apply -k ./restore
```

# Open the site

```bash
open $LB_ADDRESS
```

# Initial Setup
kubectl apply -k ./
open "http://"$(kubectl get service/wordpress -n wordpress -o jsonpath="{.status.loadBalancer.ingress[0].hostname}")
Make the data


# Create the snapshots
kubectl apply -f volumesnapshots.yaml
WAIT FOR BOTH TO BE READY
kubectl get volumesnapshot -n wordpress -o jsonpath="{.items[*].status.readyToUse}"


# Destroy
kubectl delete namespace/wordpress

# Prep for restore
Edit the VolumeSnapshotContents to omit the PVRef, remove UID from VolumeSnapshotRef

# Recreate Snapshots & PVCs
kubectl apply -f restore.yaml
kubectl apply -f pvcs.yaml     # in order to use the `datasource` field
kubectl apply -k ./   # fails on the PVCs cause they already exist and are immutable.


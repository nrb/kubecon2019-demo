#!/usr/bin/env bash

. demo-magic.sh

function cpe() {
    clear
    pe "$@"
}

function wcl() {
    wait
    clear
}

DEMO_PROMPT="$ "
clear
pe 'kubectl get -n wordpress all'

wcl

pe 'kubectl get -n wordpress persistentvolumeclaims'

wcl

pe 'cat make-volumesnapshots.yaml'

wcl

# Create the snapshots in the cluster
pe 'kubectl apply -f make-volumesnapshots.yaml'

wcl

# Show that the VolumeSnapshot is not ready to use immediately
pe 'kubectl get -n wordpress volumesnapshots/wp-snapshot -o yaml'

wcl

# Show the VolumeSnapshot when it's ready to use
pe 'kubectl get -n wordpress volumesnapshots/wp-snapshot -o yaml'

wcl

# Show off the data in a VolumeSnapshotContents
pe 'kubectl get volumesnapshotcontents -o yaml'

wcl

# Simulate a disaster by deleting the namespace
pe 'kubectl delete ns/wordpress'

# This command will show the mapping between a VolumeSnapshot's name and it's VolumeSnapshotContents's name
CONTENT_MAPS=$(kubectl get volumesnapshotcontents -o jsonpath='{range .items[*]}{.spec.volumeSnapshotRef.name}{"\n  snapshotContentName: "}{.metadata.name}{"\n"}{end}')

echo $CONTENT_MAPS

wcl

# Get the VolumeSnapshotContent name associated with the mysql-snapshot
CONTENT_NAME=$(kubectl get volumesnapshotcontents -o jsonpath='{.items[?(@.spec.volumeSnapshotRef.name == "mysql-snapshot")].metadata.name}')

# Add that Content object's name to the volumesnapshot that will be created on restore.
sed -i "13s/$/$CONTENT_NAME/" restore/volumesnapshots.yaml

# Similarly, get the Content object for the wp-snapshot
CONTENT_NAME=$(kubectl get volumesnapshotcontents -o jsonpath='{.items[?(@.spec.volumeSnapshotRef.name == "wp-snapshot")].metadata.name}')

# Add the Content ID to the volume snapshot for WordPress
sed -i "22s/$/$CONTENT_NAME/" restore/volumesnapshots.yaml

pe 'less restore/volumesnapshots.yaml'

wcl

# Here, remove the UID from the original VolumeSnapshots, since they are now gone and will cause binding errors
pe 'kubectl edit volumesnapshotcontents'

wcl

pe 'less restore/wordpress-deployment.yaml'

wcl

pe 'kubectl apply -k restore'

wcl

pe 'kubectl get -n wordpress volumesnapshot/wp-snapshot -o yaml'

wcl

pe 'kubectl get -n wordpress persistentvolumeclaims/wp-pv-claim -o yaml'

wcl

pe 'kubectl get -n wordpress all'

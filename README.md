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


# The demo

The demo is a script in `demo.sh`, which prints and executes the commands so that it could be recorded more easily.

---
layout : post
title : Containers on k3s continued
image : "/seo/2022-02-06.png"
category : cluster computing
---

## Kubernetes Dashboard

### Command #1

```bash
helm install kubernetes-dashboard/kubernetes-dashboard --set=service.externalPort=8080,resources.limits.cpu=200m --generate-name
```

### Output #1

```bash
NAME: kubernetes-dashboard-1644861254
LAST DEPLOYED: Mon Feb 14 11:54:16 2022
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
*********************************************************************************
*** PLEASE BE PATIENT: kubernetes-dashboard may take a few minutes to install ***
*********************************************************************************

Get the Kubernetes Dashboard URL by running:
  export POD_NAME=$(k3s kubectl get pods -n default -l "app.kubernetes.io/name=kubernetes-dashboard,app.kubernetes.io/instance=kubernetes-dashboard-1644861254" -o jsonpath="{.items[0].metadata.name}")
  echo https://127.0.0.1:8443/
  k3s kubectl -n default port-forward $POD_NAME 8443:8443
```

### Command #2

```bash
  export POD_NAME=$(k3s kubectl get pods -n default -l "app.kubernetes.io/name=kubernetes-dashboard,app.kubernetes.io/instance=kubernetes-dashboard-1644861254" -o jsonpath="{.items[0].metadata.name}")
  echo https://127.0.0.1:8443/
  k3s kubectl -n default port-forward $POD_NAME 8443:8443
```

### Output #2

```bash
Forwarding from 127.0.0.1:8443 -> 8443
Forwarding from [::1]:8443 -> 8443
_
```

kubectl get pods -l run=kubernetes-dashboard-1644861254 -o yaml | grep podIP


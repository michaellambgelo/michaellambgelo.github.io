---
layout : post
title : Containers on k3s
image : "/seo/2022-02-06.png"
category : cluster-computing
---

How does one run containers on k3s? Here are a few things I did to play around with my cluster.

## Syntax

The following syntax describes how to run `kubectl` commands from the terminal:

```sh
kubectl [command] [TYPE] [NAME] [flags]
```

- `command` specifies the operation to be performed
- `TYPE` specifies the resource type (e.g. pod, node, deployment, service)
- `NAME` specifies the name of the resource
- `flags` specifies optional flags

Documentation: [kubectl run](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#run)

## BusyBox

BusyBox is a suite of tools for Linux that provides a shell interface. The image is useful for testing as a running container because the image is lightweight. I used the following command to ephemerally run the container on k3s:

```sh
k3s kubectl run -it --rm --restart=Never busybox-test --image=busybox sh
```

### Breakdown

- `k3s` : CLI for k3s
- `kubectl` : CLI for Kubernetes (wrapped by k3s)
- `run` : kubectl command
- `-it` : make the container interactive
- `-rm` : delete the pod after it exits. Only valid when attaching to the container, e.g. with '--attach' or with '-i/--stdin'
- `--restart=Never` : do not restart the container upon exit
- `busybox-test` : the resource name (used by k8s)
- `--image=busybox` : specifies `busybox` as the image to build the container
- `sh` : requests `sh` access to `busybox` shell in container

## Helm

Did you know there was a package manager for Kubernetes clusters? [Helm](https://helm.sh/) is a tool useful for installing _Charts_ which is a Helm package containing all resource definitions necessary to run some application, tool, or service on a k8s cluster.  In addition to _Charts_, Helm also embodies two other concepts: a _Repository_ is the place where charts can be collected and shared and a _Release_ is an instance of a chart running on a k8s cluster. From [the Helm intro](https://helm.sh/docs/intro/using_helm/): "Helm installs charts into Kubernetes, creating a new release for each installation. And to find new charts, you can search Helm chart repositories."

Using Helm, I can leverage my k3s cluster by making use of existing Helm charts.

## OpenVPN

I want to run a simple VPN server on my network. It won't handle crazy traffic and I'm mostly trying this just for the sake of learning.

First, I installed `Helm` to `node1` so that I could use the [openvpn-as helm chart]( https://artifacthub.io/packages/helm/stenic/openvpn-as). I used the following command to add charts from `stenic` to the Helm package repositories:

```bash
helm repo add stenic https://stenic.github.io/helm-charts
 ```

 The next command deploys the container:

 ```bash
 helm install openvpn-ml --set "service.type=LoadBalancer" stenic/openvpn-as
```

I initally encountered this error after running the `helm install` command:

```raw
Error: INSTALLATION FAILED: Kubernetes cluster unreachable: Get "http://localhost:8080/version": dial tcp [::1]:8080: connect: connection refused
```

The error stems from Helm trying to make use of the same configuration file used by Kubernetes. Since I am running k3s, the following command sets the `KUBECONFIG` environment variable to point to the k3s configuration:

```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```

Now, Helm should be able to install the chart and make use of the k3s cluster.

## Result

I was not able to get OpenVPN properly set up as the pod running OpenVPN Access Server has a status of `CrashLoopBackoff` but it does appear that the chart was able to deploy 12 running pods.

![screenshot of terminal output of k3s kubectl get all](/img/2022-02-06-k3s.png)

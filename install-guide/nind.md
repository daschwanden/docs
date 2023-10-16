# Nephio in Docker (NinD) Installation

*Work-in-Progress*

In this guide, you will set up Nephio running in a Docker container with:
- **Management Cluster**: [kind](https://kind.sigs.k8s.io/)
- **Cluster Provisioner**: [Cluster API](https://cluster-api.sigs.k8s.io/)
- **Workload Clusters**: kind
- **Gitops Tool**: ConfigSync
- **Git Provider**: Gitea running in the Nephio management cluster will be the
  git provider for cluster deployment repositories. Some external repositories
  will be on GitHub.
- **Web UI Auth**: None
- **Ingress/Load Balancer**: [MetalLB](https://metallb.universe.tf/), but only internally to the VM.

## Your Linux Machine

In addition to the general prerequisites, you will need:

* Access to a Linux machine running an OS supported by Nephio (Ubuntu 20.04/22.04, Fedora 34) with a minimum of 8vCPUs and 8 GB in RAM.
* The Linux machine requires to have [Docker](https://docs.docker.com/engine/install/ubuntu/) as well as the gtp5g kernel module installed ([required by free5gc UPF](https://github.com/free5gc/gtp5g)). 

## Provisioning Nephio

You have two options to run Nephio-in-Docker (NinD):
1. Either you follow the manual installation as documented in the Sandbox installation, or
2. You can build a Docker container that automates the installation process following the instructions below.

### Option 1 - Manual installation with Sandbox instructions

#### Bring up the NinD environment
Run the following command on your Linux machine to spin up a Docker container that will provide the NinD environment.  

```
docker run --rm -d --env='DOCKER_OPTS=' --volume=/var/lib/docker --privileged --name nind -p 8080:80 -p 3000:3000 \
           us-central1-docker.pkg.dev/cloud-workstations-images/predefined/code-oss
```

#### Connect to the NinD environment
Connect to the Code OSS IDE by pointing your browser to [http://localhost:8080](http://localhost:8080).  
Then open a Terminal window, create and change into the ```/nephio-installation``` directory to execute the [Sandbox installation commands](sandbox.md#provisioning-your-management-cluster).

### Option 2 - Automated installation with Dockerfile instructions

#### Build the NinD environment Docker image and then run it
We build the Docker image from to the [Dockerfile](./nind/Dockerfile) in the nind directory.  

```
cd nind

docker build -t nind:v0.1 .

docker run --rm -d --env='DOCKER_OPTS=' --volume=/var/lib/docker --privileged \
           --name nind -p 8080:80 -p 3000:3000 nind:v0.1
```

#### Follow the boot/NinD logs
When starting the NinD container image it will set up the NinD environment for you.  

Depending on the spec of your environment this might take a bit of time.

You can tail the logs to follow the progress of the NinD boot/install process.
Run the command below and wait for the log entry reading ```Startup complete```.

```
docker logs -f nind 
...


-----------------
NinD installation done
-----------------
Startup complete
```

## Next Steps
Connect to the Workstation by pointing your browser to [http://localhost:8080](http://localhost:8080).
* Step through the [exercises](https://github.com/nephio-project/docs/blob/main/user-guide/exercises.md)
* Learn more about the [Nephio demo sandbox](https://github.com/nephio-project/docs/blob/main/install-guide/explore-sandbox.md)
* Dig into the [user guide](https://github.com/nephio-project/docs/blob/main/user-guide/README.md)

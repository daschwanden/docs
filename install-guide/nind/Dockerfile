FROM us-central1-docker.pkg.dev/cloud-workstations-images/predefined/code-oss:latest

ENV DEBIAN_FRONTEND=noninteractive

COPY kind-config.yaml /nephio-installation/
COPY 200_install-nind.sh /etc/workstation-startup.d/

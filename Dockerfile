FROM nvidia/cuda:11.8.0-runtime-ubuntu20.04

RUN apt-get update && apt-get install -y \
        apt-utils \
        ca-certificates \
        openssh-client \
        curl \
        iptables \
        git \
        gnupg \
        supervisor && \
    rm -rf /var/lib/apt/list/*

# NVIDIA Container Toolkit & Docker
RUN distribution=$(. /etc/os-release;echo $ID$VERSION_ID) && \
    curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | apt-key add - && \
    curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | tee /etc/apt/sources.list.d/nvidia-docker.list && \
    apt-get update && apt-get install -y nvidia-docker2 docker.io docker-compose && \
    rm -rf /var/lib/apt/list/*

COPY modprobe startup.sh /usr/local/bin/
COPY supervisor/ /etc/supervisor/conf.d/
COPY logger.sh /opt/bash-utils/logger.sh

RUN chmod +x /usr/local/bin/startup.sh /usr/local/bin/modprobe
VOLUME /var/lib/docker

# https://stackoverflow.com/questions/59691207/docker-build-with-nvidia-runtime
RUN mkdir -p /etc/docker &&  printf '{"runtimes": {"nvidia": {"path": "nvidia-container-runtime","runtimeArgs": []}},"default-runtime": "nvidia"}\n' > /etc/docker/daemon.json

# https://github.com/NVIDIA/nvidia-docker/issues/1163
RUN sed -i -- 's/@\/sbin\/ldconfig.real/\/sbin\/ldconfig.real/g' /etc/nvidia-container-runtime/config.toml

ENTRYPOINT ["startup.sh"]
CMD ["sh"]

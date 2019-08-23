FROM ubuntu:18.04

RUN set -eu; \
    apt-get update && apt-get install -y --no-install-recommends \
    axel \
    cpio \
    sudo \
    gdbserver \
    lsb-release \
    libgtk-3-dev \
    openssh-server; \
    rm -rf /var/lib/apt/lists/*

# Enable remote debugging
RUN set -eu; \
    mkdir /var/run/sshd; \
    echo 'root:root' | chpasswd; \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config; \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd;

# 22 for ssh server, 7777 for gdb server
EXPOSE 22 7777

ARG DOWNLOAD_LINK=http://registrationcenter-download.intel.com/akdlm/irc_nas/15693/l_openvino_toolkit_p_2019.2.242.tgz
ARG INSTALL_DIR=/opt/intel/openvino
ARG TMP_DIR=/tmp/openvino_installer

RUN set -eu; \
    mkdir -p $TMP_DIR && cd $TMP_DIR; \
    axel -c $DOWNLOAD_LINK; \
    tar xf l_openvino_toolkit*.tgz; \
    cd l_openvino_toolkit*; \
    sed -i 's/decline/accept/g' silent.cfg; \
    ./install.sh -s silent.cfg; \
    rm -rf $TMP_DIR

RUN set -eu; \
    ${INSTALL_DIR}/install_dependencies/install_openvino_dependencies.sh

RUN set -eu; \
    ${INSTALL_DIR}/deployment_tools/inference_engine/samples/build_samples.sh

RUN apt-get update && apt-get install python3-pip -y && \
    pip3 install pyyaml requests && \
    cd ${INSTALL_DIR}/deployment_tools/tools/model_downloader && \
    python3 downloader.py --name alexnet

RUN set -eu; \
    cd ${INSTALL_DIR}/deployment_tools/model_optimizer; \
    ./install_prerequisites/install_prerequisites.sh; \
    python3 mo.py --input_model ../tools/model_downloader/classification/alexnet/caffe/alexnet.caffemodel

RUN set -eu; \
    axel "https://bit.ly/342QIcW" -o ~/chimp.jpg

RUN set -eu; \
    echo "source ${INSTALL_DIR}/bin/setupvars.sh" >> ~/.bashrc

RUN set -eu; \
    cd ${INSTALL_DIR}/install_dependencies/; \
    sed -i 's/16.04/18.04/g' install_NEO_OCL_driver.sh; \
    ./install_NEO_OCL_driver.sh

RUN set -eu; \
    usermod -aG video root; \
    usermod -aG users root;

COPY test_gpu.sh /root/inference_engine_samples_build/intel64/Release/

WORKDIR /root/inference_engine_samples_build/intel64/Release/

CMD bash test_gpu.sh

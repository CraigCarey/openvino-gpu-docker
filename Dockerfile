FROM ubuntu:16.04

ENV http_proxy $HTTP_PROXY
ENV https_proxy $HTTPS_PROXY
ARG DOWNLOAD_LINK=http://registrationcenter-download.intel.com/akdlm/irc_nas/15461/l_openvino_toolkit_p_2019.1.133.tgz
ARG INSTALL_DIR=/opt/intel/openvino
ARG TEMP_DIR=/tmp/openvino_installer

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    cpio \
    sudo \
    lsb-release \
    libgtk-3-dev && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p $TEMP_DIR && cd $TEMP_DIR && \
    wget -c $DOWNLOAD_LINK && \
    tar xf l_openvino_toolkit*.tgz && \
    cd l_openvino_toolkit* && \
    sed -i 's/decline/accept/g' silent.cfg && \
    ./install.sh -s silent.cfg && \
    rm -rf $TEMP_DIR

RUN $INSTALL_DIR/install_dependencies/install_openvino_dependencies.sh

RUN /opt/intel/openvino/deployment_tools/inference_engine/samples/build_samples.sh

RUN apt-get update && apt-get install python3-pip -y && \
    pip3 install pyyaml requests && \
    cd /opt/intel/openvino/deployment_tools/tools/model_downloader && \
    python3 downloader.py --name alexnet

RUN cd /opt/intel/openvino/deployment_tools/model_optimizer && \
    ./install_prerequisites/install_prerequisites.sh && \
    python3 mo.py --input_model ../tools/model_downloader/classification/alexnet/caffe/alexnet.caffemodel

RUN cd ~ && \
    wget "https://www.thesprucepets.com/thmb/9xZ53v85TGH75XYBZs4Lw_Qwkhg=/450x0/filters:no_upscale():max_bytes(150000):strip_icc()/high-angle-view-of-chimpanzee-in-forest-769784687-5b1e76d63de4230037ce6f9d.jpg" -O ~/chimp.jpg

RUN echo "source /opt/intel/openvino/bin/setupvars.sh" >> ~/.bashrc

# Only works for Ubuntu 16.04
RUN cd /opt/intel/openvino/install_dependencies/ && \
    ./install_NEO_OCL_driver.sh

# TODO: get Ubuntu 18.04 working
#RUN apt-get install -y software-properties-common && \
#    add-apt-repository ppa:intel-opencl/intel-opencl && \
#    apt-get update && \
#    apt-get install -y intel-opencl

# TODO: get Ubuntu 18.04 working
#RUN cd /root && \
#    mkdir neo && \
#    cd neo && \
#    wget https://github.com/intel/compute-runtime/releases/download/19.29.13530/intel-gmmlib_19.2.3_amd64.deb && \
#    wget https://github.com/intel/compute-runtime/releases/download/19.29.13530/intel-igc-core_1.0.10-2306_amd64.deb && \
#    wget https://github.com/intel/compute-runtime/releases/download/19.29.13530/intel-igc-opencl_1.0.10-2306_amd64.deb && \
#    wget https://github.com/intel/compute-runtime/releases/download/19.29.13530/intel-opencl_19.29.13530_amd64.deb && \
#    wget https://github.com/intel/compute-runtime/releases/download/19.29.13530/intel-ocloc_19.29.13530_amd64.deb && \
#    dpkg -i *.deb

RUN usermod -aG video root

WORKDIR /root/inference_engine_samples_build/intel64/Release/

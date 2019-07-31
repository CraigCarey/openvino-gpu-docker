#!/usr/bin/env bash

source /opt/intel/openvino/bin/setupvars.sh
./benchmark_app -i ~/chimp.jpg -m /opt/intel/openvino/deployment_tools/model_optimizer/alexnet.xml -d GPU -api async

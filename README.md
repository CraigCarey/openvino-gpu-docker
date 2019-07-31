# OpenVINO GPU Docker

Allows GPU utilisation inside a docker image

## Ubuntu 16
```bash
docker build -t ov_16 .
docker run --device /dev/dri ov_16

# Interactive shell
docker run -it --device /dev/dri --entrypoint=/bin/bash ov_16
./benchmark_app -i ~/chimp.jpg -m /opt/intel/openvino/deployment_tools/model_optimizer/alexnet.xml -d GPU -api async
```

## Ubuntu 18
```bash
docker build -t ov_18 -f Dockerfile18 .
docker run --device /dev/dri ov_18

# Interactive shell
docker run -it --device /dev/dri --entrypoint=/bin/bash ov_18
./benchmark_app -i ~/chimp.jpg -m /opt/intel/openvino/deployment_tools/model_optimizer/alexnet.xml -d GPU -api async
```

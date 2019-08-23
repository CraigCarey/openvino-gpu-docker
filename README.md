# OpenVINO GPU Docker

Allows GPU utilisation inside a docker image

## Ubuntu 18
```bash
docker build -t ov_18 .
docker run --device /dev/dri ov_18

# Interactive shell
docker run -it --device /dev/dri --entrypoint=/bin/bash ov_18
./benchmark_app -i ~/chimp.jpg -m /opt/intel/openvino/deployment_tools/model_optimizer/alexnet.xml -d GPU -api async

# Using Docker compose
docker-compose up -d
docker-compose up --build -d # For a fresh build
sshpass -p root ssh root@localhost -p 7776
cd inference_engine_samples_build/intel64/Release/
./test_gpu
```

# OpenVINO GPU Docker

Allows GPU utilisation inside a docker image

```bash
docker build -t ov_base .
docker run -it --device /dev/dri ov_base
./benchmark_app -i ~/chimp.jpg -m /opt/intel/openvino/deployment_tools/model_optimizer/alexnet.xml -d GPU -api async
```

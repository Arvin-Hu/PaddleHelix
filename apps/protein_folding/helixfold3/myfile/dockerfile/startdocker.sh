#!/bin/bash
HOST_IP=127.0.0.1

docker run --gpus all -it --name helixfold3_yyh \
	-v /data:/data \
	-v /a100_nas/ai4s:/a100_nas/ai4s \
	-e http_proxy="http://${HOST_IP}:7899" \
	-e https_proxy="http://${HOST_IP}:7899" \
	-e HF_HOME="/data/huggingface/models/huggingface" \
	-e TRANSFORMERS_CACHE="/data/huggingface/models/huggingface" \
	helixfold3:v1
	
#cp /data/perm/workspace/code/PaddleHelix/apps/protein_folding/helixfold3/run_infer.sh .
#bash run_infer.sh

#bash download_all_data.sh /a100_nas/ai4s/data_set_helixfold3


#	-e http_proxy="http://${HOST_IP}:7899" \
#	-e https_proxy="http://${HOST_IP}:7899" \


#!/bin/bash
start=$(date +%s)

# 使用 Docker buildx 的计时功能
docker buildx build --progress=plain \
    -t helixfold3:v1 \
    -f /data/perm/workspace/code/PaddleHelix/apps/protein_folding/helixfold3/myfile/dockerfile/Dockerfile \
    /data/perm/workspace/code/PaddleHelix/apps/protein_folding/helixfold3

end=$(date +%s)
runtime=$((end-start))

echo "Build took: $runtime seconds"
echo "Build took: $((runtime/60)) minutes and $((runtime%60)) seconds"
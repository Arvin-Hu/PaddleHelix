# 第一阶段：构建GCC环境
FROM ubuntu:20.04 AS gcc-builder

# 配置清华源并安装GCC 11
RUN sed -i 's@//.*archive.ubuntu.com@//mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list && \
    sed -i 's@//.*security.ubuntu.com@//mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common && \
    add-apt-repository ppa:ubuntu-toolchain-r/test && \
    apt-get update && \
    apt-get install -y --no-install-recommends gcc-11 g++-11 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN cp /usr/lib/x86_64-linux-gnu/libstdc++.so.6.* libstdc++.so.6

# 第二阶段：构建aria2的libssl依赖
FROM ubuntu:20.04 AS aria2

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive

# 使用单个RUN指令减少层数
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget && \
    wget http://security.ubuntu.com/ubuntu/pool/main/o/openssl1.0/libssl1.0.0_1.0.2n-1ubuntu5_amd64.deb && \
    dpkg -i libssl1.0.0_1.0.2n-1ubuntu5_amd64.deb && \
    rm libssl1.0.0_1.0.2n-1ubuntu5_amd64.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 第三阶段: 构建Maxit
FROM ubuntu:20.04 AS maxit-builder

# 简化源配置
RUN sed -i 's@//.*archive.ubuntu.com@//mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list && \
    sed -i 's@//.*security.ubuntu.com@//mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list && \
    apt-get update && apt-get install -y --no-install-recommends\
    wget \
    build-essential \
    make \
    bison \
    flex \
    && rm -rf /var/lib/apt/lists/*

# 使用原始链接下载
RUN apt-get update && \
    apt-get install -y ca-certificates --no-install-recommends&& \
    wget https://sw-tools.rcsb.org/apps/MAXIT/maxit-v11.100-prod-src.tar.gz \
    && tar -xzf maxit-v11.100-prod-src.tar.gz \
    && cd maxit-v11.100-prod-src \
    && make \
    && make binary \
    && mkdir -p /usr/local/maxit \
    && cp -r bin /usr/local/maxit/ \
    && cp -r data /usr/local/maxit/ \
    && cp -r lib /usr/local/maxit/ \
    && rm -rf /var/lib/apt/lists/*

# 选择安装Conda的基础镜像
FROM nvcr.io/nvidia/cuda:12.0.0-cudnn8-devel-ubuntu20.04 AS base

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    PYTHONUNBUFFERED=1

# 复制GCC和库文件
COPY --from=gcc-builder /usr/bin/gcc-11 /usr/bin/gcc-11
COPY --from=gcc-builder /usr/bin/g++-11 /usr/bin/g++-11
COPY --from=gcc-builder /libstdc++.so.6 /usr/lib/x86_64-linux-gnu/

# 安装miniconda
RUN sed -i 's@//.*archive.ubuntu.com@//mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list && \
    sed -i 's@//.*security.ubuntu.com@//mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends wget bzip2 ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean --all -y

# 设置环境变量
ENV PATH=/opt/conda/bin:$PATH

# 配置conda国内镜像源
RUN conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/ && \
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/ && \
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/ && \
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/bioconda/ && \
    conda config --set show_channel_urls yes && \
    conda config --set ssl_verify false


# 初始化conda并创建环境
RUN conda init bash && \
    . ~/.bashrc && \
    conda create -n helixfold python=3.9 -y && \
    conda install -y aria2 hmmer==3.3.2 kalign2==2.04 hhsuite==3.3.0 -n helixfold && \
    conda install -y openbabel -n helixfold && \
    conda clean --all -y

# 激活helixfold环境并安装paddlepaddle和scipy
COPY requirements.txt /tmp/
RUN echo "conda activate helixfold" >> ~/.bashrc && \
    . ~/.bashrc && \
    conda install -y scipy==1.9.0 -n helixfold && \
    conda clean --all -y && \
    python3 -m pip install --no-cache-dir paddlepaddle-gpu==2.6.1.post120 -f https://www.paddlepaddle.org.cn/whl/linux/mkl/avx/stable.html && \
    python3 -m pip install --no-cache-dir -r /tmp/requirements.txt && \
    rm -rf ~/.cache/pip/*

# 设置工作目录
WORKDIR /app/helixfold3


# 从Maxit阶段复制Maxit
COPY --from=maxit-builder /usr/local/maxit /usr/local/maxit


# 从 aria2 阶段复制 libssl 相关文件
COPY --from=aria2 /usr/lib/x86_64-linux-gnu/libssl.so.1.0.0 /usr/lib/x86_64-linux-gnu/
COPY --from=aria2 /usr/lib/x86_64-linux-gnu/libcrypto.so.1.0.0 /usr/lib/x86_64-linux-gnu/


RUN sed -i 's@//.*archive.ubuntu.com@//mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list && \
    sed -i 's@//.*security.ubuntu.com@//mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


COPY . /app/helixfold3

LABEL maintainer="Arvin-Hu" \
      description="HelixFold3 environment with CUDA 12.0, Python 3.9 and PaddlePaddle 2.6.1"

# 设置Maxit所需的环境变量
ENV RCSBROOT=/usr/local/maxit \
    PATH=/usr/local/maxit/bin:$PATH
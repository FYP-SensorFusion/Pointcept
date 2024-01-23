# Use an official Ubuntu runtime as a parent image
FROM ubuntu:18.04

# Set the working directory in the container to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
ADD . /app

# Install any needed packages specified in requirements.txt
RUN apt-get update && apt-get install -y \
    python3.8 \
    python3-pip

# Install CUDA
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget 
RUN mv cuda-ubuntu1804.pin /etc/apt/preferences.d/cuda-repository-pin-600 
RUN dpkg -i cuda-repo-ubuntu1804-11-3-local_11.3.1-465.19.01-1_amd64.deb
RUN apt-key add /var/cuda-repo-ubuntu1804-11-3-local/7fa2af80.pub
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install cuda

ENV PATH="/root/miniconda3/bin:${PATH}"
ARG PATH="/root/miniconda3/bin:${PATH}"

RUN wget \
    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && mkdir /root/.conda \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && rm -f Miniconda3-latest-Linux-x86_64.sh 
RUN conda --version

# Create Conda Environment
RUN conda create -n pointcept python=3.8 -y
RUN echo "source activate pointcept" > ~/.bashrc
ENV PATH /opt/conda/envs/pointcept/bin:$PATH

# Install PyTorch and other dependencies
RUN conda install ninja -y
# RUN conda install pytorch==1.12.1 torchvision==0.13.1 torchaudio==0.12.1 cudatoolkit=11.3 -c pytorch -y
RUN conda install pytorch torchvision torchaudio cudatoolkit -c pytorch -c conda-forge -y
RUN conda install h5py pyyaml -c anaconda -y
RUN conda install sharedarray tensorboard tensorboardx yapf addict einops scipy plyfile termcolor timm -c conda-forge -y
RUN conda install pytorch-cluster pytorch-scatter pytorch-sparse -c pyg -y
RUN pip install torch-geometric
RUN pip install spconv-cu113
RUN pip install open3d

# Make port 80 available to the world outside this container
EXPOSE 80

# Copy the start script into the container
COPY start.sh /app/start.sh

# Make the start script executable
RUN chmod +x /app/start.sh

CMD ["/app/start.sh"]
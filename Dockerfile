# s: I borrowed this

# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the \"License\");
# you may not use this file except in compliance with the License.\n",
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an \"AS IS\" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Dockerfile-gpu
FROM nvidia/cuda:9.0-cudnn7-runtime

# Installs necessary dependencies.
# s: mine will be different
RUN apt-get update && apt-get install -y --no-install-recommends \
         wget \
         curl \
         python-dev && \
     rm -rf /var/lib/apt/lists/*

# Installs pip.
# s: mine will be different
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python get-pip.py && \
    pip install setuptools && \
    rm get-pip.py

WORKDIR /root

# Installs pytorch and torchvision.
# s: mine will be different
RUN pip install torch==1.0.0 torchvision==0.2.1

# Installs cloudml-hypertune for hyperparameter tuning.
# It’s not needed if you don’t want to do hyperparameter tuning.
# s: not this time
#RUN pip install cloudml-hypertune

# Installs google cloud sdk, this is mostly for using gsutil to export model.
# s: use this as-is
RUN wget -nv \
    https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz && \
    mkdir /root/tools && \
    tar xvzf google-cloud-sdk.tar.gz -C /root/tools && \
    rm google-cloud-sdk.tar.gz && \
    /root/tools/google-cloud-sdk/install.sh --usage-reporting=false \
        --path-update=false --bash-completion=false \
        --disable-installation-options && \
    rm -rf /root/.config/* && \
    ln -s /root/.config /config && \
    # Remove the backup directory that gcloud creates
    rm -rf /root/tools/google-cloud-sdk/.install/.backup

# Path configuration
# s: use this as-is
ENV PATH $PATH:/root/tools/google-cloud-sdk/bin

# Make sure gsutil will use the default service account
# s: figure out how to configure your google default service account
RUN echo '[GoogleCompute]\nservice_account = default' > /etc/boto.cfg

# Copies the trainer code 
# s: mine will be different 
RUN mkdir /root/trainer
COPY trainer/mnist.py /root/trainer/mnist.py

# Sets up the entry point to invoke the trainer.
# s: mine will be different 
ENTRYPOINT ["python", "trainer/mnist.py"]


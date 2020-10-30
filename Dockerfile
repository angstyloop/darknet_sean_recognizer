# s: I borrowed this

# GPU image
FROM nvidia/cuda:9.0-cudnn7-runtime

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends wget curl && \
     rm -rf /var/lib/apt/lists/*

# Install Darknet
# ...

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

# Copy executable (that starts training the network) and its resources into the docker image.
# ...

# Set up the entry point to invoke the trainer.
# ...


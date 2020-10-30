# GPU Docker image
FROM nvidia/cuda:9.0-cudnn7-runtime

# Installs necessary dependencies.
RUN apt-get update && apt-get install -y --no-install-recommends \
         wget \
         curl \
         tar \
         git-all \
         make \
         python-dev && \
     rm -rf /var/lib/apt/lists/*

 # Installs pip.
 # s: mine will be different
 RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
     python get-pip.py && \
     pip install setuptools && \
     rm get-pip.py

WORKDIR /root

# Install Darknet (https://pjreddie.com/darknet/yolo/)
RUN git clone https://github.com/pjreddie/darknet && \
    cd darknet && \
    make

# Get pascal VOC data
RUN wget https://pjreddie.com/media/files/VOCtrainval_11-May-2012.tar && \
    wget https://pjreddie.com/media/files/VOCtrainval_06-Nov-2007.tar && \
    wget https://pjreddie.com/media/files/VOCtest_06-Nov-2007.tar && \
    tar xf VOCtrainval_11-May-2012.tar && \
    tar xf VOCtrainval_06-Nov-2007.tar && \
    tar xf VOCtest_06-Nov-2007.tar

# Generate labels for VOC
RUN wget https://pjreddie.com/media/files/voc_label.py && \
python voc_label.py

# Concatenate training data, except for 2007
RUN cat 2007_train.txt 2007_val.txt 2012_*.txt > train.txt

# Modify cfg for Pascal VOC data
echo "classes = 20\ntrain = ./train.txt\nvalid = ./2007_test.txt\nnames = data/voc.names\nbackup = backup"

# Download pre-trained weights
wget https://pjreddie.com/media/files/darknet53.conv.74

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

# Configure PATH
ENV PATH $PATH:/root/tools/google-cloud-sdk/bin

# Configure boto file for gsutil to use the default service account.
# s: Development only. For production, use a user-managed google service account
RUN echo '[GoogleCompute]\nservice_account = default' > /etc/boto.cfg

# Train the model
RUN ./darknet detector train cfg/voc.data cfg/yolov3-voc.cfg darknet53.conv.7

# fuck ENTRYPOINT and CMD honestly. somebody probably needs that but I don't.

FROM alpine:3.11.3

RUN apk --no-cache add \
    ca-certificates \
    python \
    wget \
    curl \
    tar \
    git \
    bash \
    redis \
    postgresql-client \
    mysql-client \
    kafkacat

WORKDIR /
ENV HOME /

####################
# Google Cloud SDK #
####################
# Download and install Google Cloud SDK
# gcloud, gsutil and kubectl will be available at /google-cloud-sdk/bin/ and added to $PATH
ENV PATH /google-cloud-sdk/bin:$PATH
ENV CLOUDSDK_PYTHON_SITEPACKAGES 1
ENV GCLOUD_VERSION=258.0.0

RUN curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz && \
    tar zxf google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz google-cloud-sdk && \
    rm google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz && \
    google-cloud-sdk/install.sh \
        --usage-reporting=true \
        --path-update=true \
        --bash-completion=true \
        --rc-path=/.bashrc \
        --additional-components app alpha beta

# Disable updater check for the whole installation.
# Users won't be bugged with notifications to update to the latest version of gcloud.
RUN google-cloud-sdk/bin/gcloud config set --installation component_manager/disable_update_check true

###########
# Kubectl #
###########
# Install kubectl manually to get the same version client version as cluster version
ENV KUBECTL_VERSION=v1.14.8

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/bin/kubectl

########
# HELM #
########
ENV HELM_VERSION v3.0.3
ENV FILENAME helm-${HELM_VERSION}-linux-amd64.tar.gz
ENV HELM_URL https://get.helm.sh/${FILENAME}

RUN curl -o /tmp/$FILENAME ${HELM_URL} \
    && tar -zxf /tmp/${FILENAME} -C /tmp \
    && mv /tmp/linux-amd64/helm /usr/bin/helm \
    && rm /tmp/${FILENAME} && rm -rf /tmp/linux-amd64

###################
# HASHICORP VAULT #
###################
ENV VAULT_VERSION 1.0.3
RUN curl -Lo vault.zip https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip --progress-bar --show-error --fail && \
    unzip vault.zip &&  \
    mv vault /bin/vault && \
    rm vault.zip

######################
# mongo cli and dump #
######################
ENV MONGO_VERSION 4.0.10
RUN curl -Lo mongodb-linux-x86_64-${MONGO_VERSION}.tgz https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-${MONGO_VERSION}.tgz --progress-bar --show-error --fail && \
    tar xvfz mongodb-linux-x86_64-${MONGO_VERSION}.tgz && \
    rm mongodb-linux-x86_64-${MONGO_VERSION}.tgz && \
    mv mongodb-linux-x86_64-${MONGO_VERSION}/bin/mongo /bin/mongo && \
    mv mongodb-linux-x86_64-${MONGO_VERSION}/bin/mongodump /bin/mongodump && \
    mv mongodb-linux-x86_64-${MONGO_VERSION}/bin/mongoexport /bin/mongoexport && \
    mv mongodb-linux-x86_64-${MONGO_VERSION}/bin/mongoimport /bin/mongoimport && \
    mv mongodb-linux-x86_64-${MONGO_VERSION}/bin/bsondump /bin/bsondump && \
    rm -rf mongodb-linux-x86_64-${MONGO_VERSION}

CMD ["bash"]
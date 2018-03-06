FROM alpine:3.7

ENV CLOUD_SDK_VERSION 191.0.0
ENV PATH /google-cloud-sdk/bin:$PATH

RUN apk --no-cache add \
        curl \
        python \
        py-crcmod \
        bash \
        libc6-compat \
        openssh-client \
        git \
        && curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
        && tar xzf google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
        && rm google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
        && ln -s /lib /lib64 \
        && gcloud config set core/disable_usage_reporting true \
        && gcloud config set component_manager/disable_update_check true \
        && gcloud config set metrics/environment github_docker_image \
        && gcloud --version

RUN apk add --no-cache \
        openssl \
        tar \
        ca-certificates \
        apache2-utils

RUN gcloud components install \
        alpha beta kubectl

RUN curl -L -o helm.tar.gz \
        https://kubernetes-helm.storage.googleapis.com/helm-v2.8.0-linux-amd64.tar.gz \
        && tar -xvzf helm.tar.gz \
        && rm -rf helm.tar.gz \
        && chmod 0700 linux-amd64/helm \
        && mv linux-amd64/helm /usr/bin

RUN curl -o ./terraform.zip https://releases.hashicorp.com/terraform/0.11.2/terraform_0.11.2_linux_amd64.zip \
        && unzip terraform.zip \
        && mv terraform /usr/bin \
        && rm -rf terraform.zip

RUN curl -L -o ./terragrunt \
        https://github.com/gruntwork-io/terragrunt/releases/download/v0.13.23/terragrunt_linux_amd64 \
        && chmod 0700 terragrunt \
        && mv terragrunt /usr/bin

RUN curl -L -o ./terraform-provider-helm_v0.6.0 \
        https://github.com/burdiyan/terraform-provider-helm/releases/download/v0.6.0/terraform-provider-helm_linux_amd64 \
        && chmod 0700 terraform-provider-helm_v0.6.0 \
        && mkdir -p /root/.terraform.d/plugins/ \
        && mv terraform-provider-helm_v0.6.0 /root/.terraform.d/plugins/


COPY modules /exekube-modules/
COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT [ "docker-entrypoint.sh" ]
FROM google/cloud-sdk:alpine
MAINTAINER "Ludovic Piot <ludovic.piot@thegaragebandofit.com>"

# Install prerequisites
RUN apk add openssl git jq vim

# GCP configuration
WORKDIR /

# GCP extra components install
#RUN gcloud components install beta --quiet
#RUN gcloud components install kubectl --quiet
RUN gcloud components update --quiet && \

# skim down the size of the install
    gcloud components remove bq --quiet && \
    rm -Rf /google-cloud-sdk/.install


# Terraform vars
ENV TERRAFORM_VERSION=0.12.24

# Terraform install
WORKDIR /usr/bin
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip ./terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    rm -f ./terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Add Terraform autocompletion in BASH
RUN touch ~/.bashrc && \
    terraform --install-autocomplete


# Packer vars
# ENV PACKER_VERSION=1.5.5

# Packer install
# WORKDIR /usr/bin
# RUN wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip && \
#     unzip ./packer_${PACKER_VERSION}_linux_amd64.zip && \
#     rm -f ./packer_${PACKER_VERSION}_linux_amd64.zip

# Add Packer autocompletion in BASH
# RUN touch ~/.bashrc && \
#     packer -autocomplete-install

ENTRYPOINT [ "/bin/bash" ]

# -----------------------------------------------------------------------------
# Terraform
# -----------------------------------------------------------------------------
FROM alpine:latest as tf
LABEL maintainer="Ludovic Piot <ludovic.piot@thegaragebandofit.com>"

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

# -----------------------------------------------------------------------------
# Packer
# -----------------------------------------------------------------------------
FROM alpine:latest as pac
LABEL maintainer="Ludovic Piot <ludovic.piot@thegaragebandofit.com>"

# Packer vars
ENV PACKER_VERSION=1.5.5

# Packer install
WORKDIR /usr/bin
RUN wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip && \
    unzip ./packer_${PACKER_VERSION}_linux_amd64.zip && \
    rm -f ./packer_${PACKER_VERSION}_linux_amd64.zip

# Add Packer autocompletion in BASH
RUN touch ~/.bashrc && \
    packer -autocomplete-install

# -----------------------------------------------------------------------------
# Google Cloud SDK
# -----------------------------------------------------------------------------

# ----- IMAGE: gcloud ----- 
FROM google/cloud-sdk:alpine as gcp
LABEL maintainer="Ludovic Piot <ludovic.piot@thegaragebandofit.com>"

# GCP configuration
WORKDIR /

# GCP extra components install
RUN gcloud components update --quiet


# ----- IMAGE: gcloud + skim-down -----
FROM gcp as gcp-lite
LABEL maintainer="Ludovic Piot <ludovic.piot@thegaragebandofit.com>"

# GCP configuration
WORKDIR /

# skim down the size of the install
RUN gcloud components remove bq --quiet && \
    rm -Rf /google-cloud-sdk/.install


# ----- IMAGE: gcloud + beta + kubectl -----
FROM gcp as gcp-full
LABEL maintainer="Ludovic Piot <ludovic.piot@thegaragebandofit.com>"

# GCP configuration
WORKDIR /

# GCP extra components install
RUN gcloud components install beta --quiet
RUN gcloud components install kubectl --quiet


# ----- IMAGE: gcloud + beta + kubectl + skim-down -----
FROM gcp-full as gcp-full-lite
LABEL maintainer="Ludovic Piot <ludovic.piot@thegaragebandofit.com>"

# GCP configuration
WORKDIR /

# skim down the size of the install
RUN gcloud components remove bq --quiet && \
    rm -Rf /google-cloud-sdk/.install

# -----------------------------------------------------------------------------
# Final image
# -----------------------------------------------------------------------------

# ----- IMAGE: gcloud + terraform + packer -----
FROM gcp-lite as gcp-tf-pac
LABEL maintainer="Ludovic Piot <ludovic.piot@thegaragebandofit.com>"

# Install prerequisites
RUN apk add openssl git jq vim

WORKDIR /root/

COPY --from=tf /usr/bin/terraform /usr/bin/terraform
COPY --from=tf /root/.bashrc ./.bashrc_tf

COPY --from=pac /usr/bin/packer /usr/bin/packer
COPY --from=pac /root/.bashrc ./.bashrc_pac

RUN cat ./.bashrc_tf ./.bashrc_pac >> ./.bashrc

ENTRYPOINT [ "/bin/bash" ]


# ----- IMAGE: gcloud + beta + kubectl + terraform + packer -----
FROM gcp-full as gcp-full-tf-pac
LABEL maintainer="Ludovic Piot <ludovic.piot@thegaragebandofit.com>"

# Install prerequisites
RUN apk add openssl git jq vim

WORKDIR /root/

COPY --from=tf /usr/bin/terraform /usr/bin/terraform
COPY --from=tf /root/.bashrc ./.bashrc_tf

COPY --from=pac /usr/bin/packer /usr/bin/packer
COPY --from=pac /root/.bashrc ./.bashrc_pac

RUN cat ./.bashrc_tf ./.bashrc_pac >> ./.bashrc

ENTRYPOINT [ "/bin/bash" ]

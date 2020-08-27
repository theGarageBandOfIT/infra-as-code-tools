FROM google/cloud-sdk:alpine
MAINTAINER "Ludovic Piot <ludovic.piot@thegaragebandofit.com>"

# Install prerequisites
RUN apk add openssl git jq vim

# GCP configuration
WORKDIR /

# GCP extra components install
RUN gcloud components install alpha --quiet
RUN gcloud components install beta --quiet
RUN gcloud components install kubectl --quiet
RUN gcloud components update --quiet 

ENTRYPOINT [ "/bin/bash" ]

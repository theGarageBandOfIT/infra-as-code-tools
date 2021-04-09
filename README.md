# Infra as Code tools

A `Docker` image that is able to use `gcloud`, `terraform`, `packer`, etc.  
:bulb: This `Docker`image is to be used by _CI/CD pipeline_ tools.  

The `Docker` image can be found here: https://hub.docker.com/r/thegaragebandofit/infra-as-code-tools.

To build the image, you may choose a target among the multiple stages.  
ex. `docker build --target gcp-full-tf-pac --tag mytag:myversion .`

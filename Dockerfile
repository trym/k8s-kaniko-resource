FROM google/cloud-sdk

RUN apt-get install -y gettext-base jq

# Upgrade kubectl for 'wait'
RUN curl \
  --silent \
  -L https://storage.googleapis.com/kubernetes-release/release/v1.11.0/bin/linux/amd64/kubectl \
  -o /usr/bin/kubectl

RUN mkdir -p /opt/resource

WORKDIR /opt/resource

COPY assets assets
COPY test test

ENTRYPOINT [ "/bin/bash" ]
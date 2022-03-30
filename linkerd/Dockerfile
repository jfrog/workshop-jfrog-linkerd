FROM alpine/k8s:1.21.5

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories

RUN apk update && apk add \
    openssl \
    step-cli 

RUN step version

RUN curl -sL https://run.linkerd.io/install | sh

ENV PATH=$PATH:/root/.linkerd2/bin

EXPOSE 50750




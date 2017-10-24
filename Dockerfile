FROM node:6-alpine as build-env
MAINTAINER dev@smarttrade.co.jp

ENV LC_ALL C.UTF-8

#RUN apt-get update && \
#    apt-get install -y build-essential libtool-bin autoconf

RUN npm install -g gitbook-cli

WORKDIR /app

COPY src ./


RUN gitbook build

FROM nginx:alpine
MAINTAINER dev@smarttrade.co.jp

ENV LC_ALL C.UTF-8

COPY --from=build-env /app/_book/ /usr/share/nginx/html/

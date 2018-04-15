FROM ubuntu:latest

COPY Environment_Installation.sh /

COPY Preprocess_Data.sh /

RUN /Environment_Installation.sh

RUN /Preprocess_Data.sh
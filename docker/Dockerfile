FROM ubuntu:latest

COPY ./ /root/dotfiles/
WORKDIR /root/dotfiles
RUN chmod +x install.sh && bash install.sh

RUN mkdir /projects
WORKDIR /projects

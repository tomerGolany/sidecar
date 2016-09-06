FROM ubuntu:16.04
MAINTAINER Tomer Golany <tomer.golany@gmail.com>
USER root
#RUN rm -f /usr/sbin/policy-rc.d
#RUN echo #!/bin/sh > /usr/sbin/policy-rc.d
#RUN echo exit 0 >> /usr/sbin/policy-rc.d

RUN apt-get update && apt-get install -y \ 
#network-manager \
dnsmasq \ 
dnsutils

RUN echo log-facility=/dnsmasq.log >> /etc/dnsmasq.conf

RUN echo server=/amalgam8/127.0.0.1#8053 >> /etc/dnsmasq.conf
RUN echo user=root >> /etc/dnsmasq.conf

#configure dnsmasq
#RUN echo "ENABLED=1\nIGNORE_RESOLVCONF=yes" > /etc/default/dnsmasq
#listen on container interface
#RUN echo listen-address=0.0.0.0 >> /etc/dnsmasq.conf 
#RUN echo interface=eth0 >> /etc/dnsmasq.conf

#only use these namesservers
#RUN echo no-resolv >> /etc/dnsmasq.conf
RUN echo server=8.8.4.4 >> /etc/dnsmasq.conf
RUN echo server=8.8.8.4 >> /etc/dnsmasq.conf

#static entries
#RUN echo address=/myhost.company/10.0.0.2 >> /etc/dnsmasq.conf

ADD dns/dns_server .
RUN /etc/init.d/dnsmasq start




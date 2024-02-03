FROM alpine:3.19

LABEL org.opencontainers.image.authors="thomas.mohaupt@gmail.com"

RUN apk add --no-cache bind && mkdir /var/bind/zones

USER named:named

EXPOSE 53
EXPOSE 8053

COPY --chown=root:root --chmod=644 files/* /var/bind

VOLUME [ "/etc/bind/named.conf", "/var/bind/zones" ] 

WORKDIR /var/bind

CMD ["named", "-c", "/etc/bind/named.conf", "-g", "-u", "named"]


Arch Linux image with bind9 service installed.

## Inspect image

```shell
docker run -it --rm -v ./named.conf:/etc/bind/named.conf --entrypoint /bin/sh thomo/dnsbind9:latest
```

Try to run named when in the image

```shell
named -c /etc/bind/named.conf -g -u named
```

## Run with docker compose

Example docker compose file:

```yaml
version: "3.3"

volumes:
  bind9-cache:
    driver: local

services:
  bind9:
    image: thomo/dnsbind9:latest
    container_name: dnsbind9
    restart: always
    ports:
      - "53:53/udp"
      - "53:53/tcp"
      - 8053:8053
    env_file: .env # use .env
    volumes:
      - ./config/named.conf:/etc/bind/named.conf
      - ./zones:/var/bind/zones
```

Example `named.conf` file:

```
acl "trusted" {
    any;
};

options {
    listen-on port 53       { "trusted"; };
    listen-on-v6 port 53    { "trusted"; };
    allow-query             { "trusted"; };

    # all relative paths use this directory as a base
    directory 	            "/var/bind";
    managed-keys-directory  "/var/bind";

    bindkeys-file           "/etc/bind/bind.keys";

    pid-file                "/run/named/named.pid";
    session-keyfile         "/run/named/session.key";

    dump-file 	            "/var/bind/data/cache_dump.db";

    zone-statistics         yes;
    memstatistics           yes;
    memstatistics-file      "/var/bind/data/named_mem_stats.txt";
    statistics-file         "/var/bind/data/named_stats.txt";

    recursing-file          "/var/bind/data/named.recursing";
    secroots-file           "/var/bind/data/named.secroots";

    recursion               yes;
    allow-recursion         { "trusted"; };
    # Note: Both 'allow-query-cache' and 'allow-recursion' statements are allowed
    # - this is a recipe for conflicts and a debuggers dream come true.
    # Use either statement consistently - by preference 'allow-recursion'.

    dnssec-validation       no;

    /* sets the maximum time (in seconds) for which the server will cache positive answers */
    max-cache-ttl           60;

    /* sets the maximum time (in seconds) for which the server will cache negative answers */
    max-ncache-ttl          60;

    forwarders {
                      1.1.1.1;
                      8.8.8.8;
                      2001:4860:4860::8888;
                      2001:4860:4860::8844;
    };

    # But if all forwarders are dead (unlikely), do resolution ourselves
    forward                 first;
};

statistics-channels {
    inet 127.0.0.1 port 8053 allow {127.0.0.1;};
};


include "/var/bind/rfc1912.zones";

#
# relative zone files are based on /var/bind
#
zone "." IN {
    type hint;
    file "named.ca";
};

zone "yourzone.home" {
    type master;
    file "zones/yourzone.home.zone";
};

zone "0.0.192.in-addr.arpa" {
    type master;
    file "zones/192.0.0.zone";
};
```
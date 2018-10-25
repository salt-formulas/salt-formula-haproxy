=====
Usage
=====

The Reliable, High Performance TCP/HTTP Load Balancer.

Sample pillars
==============

Simple admin listener

.. code-block:: yaml

    haproxy:
      proxy:
        enabled: True
        listen:
          admin_page:
            type: admin
            binds:
            - address: 0.0.0.0
              port: 8801
            user: fsdfdsfds
            password: dsfdsf

Simple stats listener

.. code-block:: yaml

    haproxy:
      proxy:
        enabled: True
        listen:
          admin_page:
            type: stats
            binds:
            - address: 0.0.0.0
              port: 8801



Sample pillar with admin

.. code-block:: yaml

    haproxy:
      proxy:
        enabled: True
        mode: http/tcp
        logging: syslog
        maxconn: 1024
        timeout:
          connect: 5000
          client: 50000
          server: 50000
        listen:
          https-in:
            binds:
            - address: 0.0.0.0
              port: 443
            servers:
            - name: server1
              host: 10.0.0.1
              port: 8443
            - name: server2
              host: 10.0.0.2
              port: 8443
              params: 'maxconn 256'


Sample pillar with custom logging

.. code-block:: yaml

    haproxy:
      proxy:
        enabled: True
        mode: http/tcp
        logging: syslog
        maxconn: 1024
        timeout:
          connect: 5000
          client: 50000
          server: 50000
        listen:
          https-in:
            binds:
              address: 0.0.0.0
              port: 443
            servers:
            - name: server1
              host: 10.0.0.1
              port: 8443
            - name: server2
              host: 10.0.0.2
              port: 8443
              params: 'maxconn 256'

.. code-block:: yaml

      haproxy:
        proxy:
          enabled: true
          mode: tcp
          logging: syslog
          max_connections: 1024
          listen:
            mysql:
              type: mysql
              binds:
              - address: 10.0.88.70
                port: 3306
              servers:
              - name: node1
                host: 10.0.88.13
                port: 3306
                params: check inter 15s fastinter 2s downinter 1s rise 5 fall 3
              - name: node2
                host: 10.0.88.14
                port: 3306
                params: check inter 15s fastinter 2s downinter 1s rise 5 fall 3 backup
              - name: node3
                host: 10.0.88.15
                port: 3306
                params: check inter 15s fastinter 2s downinter 1s rise 5 fall 3 backup
            rabbitmq:
              type: rabbitmq
              binds:
              - address: 10.0.88.70
                port: 5672
              servers:
              - name: node1
                host: 10.0.88.13
                port: 5673
                params: check inter 5000 rise 2 fall 3
              - name: node2
                host: 10.0.88.14
                port: 5673
                params: check inter 5000 rise 2 fall 3 backup
              - name: node3
                host: 10.0.88.15
                port: 5673
                params: check inter 5000 rise 2 fall 3 backup
            keystone-1:
              type: general-service
              binds:
              - address: 10.0.106.170
                port: 5000
              servers:
              - name: node1
                host: 10.0.88.13
                port: 5000
                params: check

.. code-block:: yaml

      haproxy:
        proxy:
          enabled: true
          mode: tcp
          logging: syslog
          max_connections: 1024
          listen:
            mysql:
              type: mysql
              binds:
              - address: 10.0.88.70
                port: 3306
              servers:
              - name: node1
                host: 10.0.88.13
                port: 3306
                params: check inter 15s fastinter 2s downinter 1s rise 5 fall 3
              - name: node2
                host: 10.0.88.14
                port: 3306
                params: check inter 15s fastinter 2s downinter 1s rise 5 fall 3 backup
              - name: node3
                host: 10.0.88.15
                port: 3306
                params: check inter 15s fastinter 2s downinter 1s rise 5 fall 3 backup
            rabbitmq:
              type: rabbitmq
              binds:
              - address: 10.0.88.70
                port: 5672
              servers:
              - name: node1
                host: 10.0.88.13
                port: 5673
                params: check inter 5000 rise 2 fall 3
              - name: node2
                host: 10.0.88.14
                port: 5673
                params: check inter 5000 rise 2 fall 3 backup
              - name: node3
                host: 10.0.88.15
                port: 5673
                params: check inter 5000 rise 2 fall 3 backup
            keystone-1:
              type: general-service
              binds:
              - address: 10.0.106.170
                port: 5000
              servers:
              - name: node1
                host: 10.0.88.13
                port: 5000
                params: check

Sample pillar with port range and port offset

This is usefull in listen blocks for definition of multiple servers
that differs only by port number in port range block. This situation
can be result of multiple single-thread servers deployed in multi-core
environment to better utilize the available cores.

For example, five contrail-api workers occupy ports ``9100-9104``.
This can be achieved by using ``port_range_length`` in the pillar,
``port_range_length: 5`` in this case.
For skipping first worker (``worker_id 0``), because it has other
responsibilities and to avoid overloading it by http requests
use the ``port_range_start_offset`` in the pillar,
``port_range_start_offset: 1`` in this case, it will only use ports
9101-9104 (skipping 9100).

- ``port_range_length`` parameter is used to calculate port range end
- ``port_range_start_offset`` will skip first n ports in port range

For backward compatibility, the name of the first server in port range
has no ``pN`` suffix.

The following sample will result in

.. code-block:: text

    listen contrail_api
      bind 172.16.10.252:8082
      option nolinger
      balance leastconn
      server ntw01p1 172.16.10.95:9101 check inter 2000 rise 2 fall 3
      server ntw01p2 172.16.10.95:9102 check inter 2000 rise 2 fall 3
      server ntw01p3 172.16.10.95:9103 check inter 2000 rise 2 fall 3
      server ntw01p4 172.16.10.95:9104 check inter 2000 rise 2 fall 3
      server ntw02 172.16.10.96:9100 check inter 2000 rise 2 fall 3
      server ntw02p1 172.16.10.96:9101 check inter 2000 rise 2 fall 3
      server ntw02p2 172.16.10.96:9102 check inter 2000 rise 2 fall 3
      server ntw02p3 172.16.10.96:9103 check inter 2000 rise 2 fall 3
      server ntw02p4 172.16.10.96:9104 check inter 2000 rise 2 fall 3
      server ntw03 172.16.10.94:9100 check inter 2000 rise 2 fall 3
      server ntw03p1 172.16.10.94:9101 check inter 2000 rise 2 fall 3
      server ntw03p2 172.16.10.94:9102 check inter 2000 rise 2 fall 3
      server ntw03p3 172.16.10.94:9103 check inter 2000 rise 2 fall 3
      server ntw03p4 172.16.10.94:9104 check inter 2000 rise 2 fall 3

.. code-block:: yaml

    haproxy:
      proxy:
        listen:
          contrail_api:
            type: contrail-api
            service_name: contrail
            balance: leastconn
            binds:
            - address: 10.10.10.10
              port: 8082
            servers:
            - name: ntw01
              host: 10.10.10.11
              port: 9100
              port_range_length: 5
              port_range_start_offset: 1
              params: check inter 2000 rise 2 fall 3
            - name: ntw02
              host: 10.10.10.12
              port: 9100
              port_range_length: 5
              port_range_start_offset: 0
              params: check inter 2000 rise 2 fall 3
            - name: ntw03
              host: 10.10.10.13
              port: 9100
              port_range_length: 5
              params: check inter 2000 rise 2 fall 3


Custom more complex listener (for Artifactory and subdomains for docker
registries)

.. code-block:: yaml

    haproxy:
      proxy:
        listen:
          artifactory:
            mode: http
            options:
              - forwardfor
              - forwardfor header X-Real-IP
              - httpchk
              - httpclose
              - httplog
            sticks:
              - stick on src
              - stick-table type ip size 200k expire 2m
            acl:
              is_docker: "path_reg ^/v[12][/.]*"
            http_request:
              - action: "set-path /artifactory/api/docker/%[req.hdr(host),lower,field(1,'.')]%[path]"
                condition: "if is_docker"
            balance: source
            binds:
              - address: ${_param:cluster_vip_address}
                port: 8082
                ssl:
                  enabled: true
                  # This PEM file needs to contain key, cert, CA and possibly
                  # intermediate certificates
                  pem_file: /etc/haproxy/ssl/server.pem
            servers:
              - name: ${_param:cluster_node01_name}
                host: ${_param:cluster_node01_address}
                port: 8082
                params: check
              - name: ${_param:cluster_node02_name}
                host: ${_param:cluster_node02_address}
                port: 8082
                params: backup check

It's also possible to use multiple certificates for one listener (eg. when
it's bind on multiple interfaces):

.. code-block:: yaml

    haproxy:
      proxy:
        listen:
          dummy_site:
            mode: http
            binds:
              - address: 127.0.0.1
                port: 8080
                ssl:
                  enabled: true
                  key: |
                    my super secret key follows
                  cert: |
                    certificate
                  chain: |
                    CA chain (if any)
              - address: 127.0.1.1
                port: 8081
                ssl:
                  enabled: true
                  key: |
                    my super secret key follows
                  cert: |
                    certificate
                  chain: |
                    CA chain (if any)

Definition above will result in creation of ``/etc/haproxy/ssl/dummy_site``
directory with files ``1-all.pem`` and ``2-all.pem`` (per binds).

Custom listener with http-check options specified

.. code-block:: yaml

  haproxy:
    proxy:
      enabled: true
      forwardfor:
        enabled: true
        except: 127.0.0.1
        header: X-Forwarded-For
        if-none: false
      listen:
        glance_api:
          binds:
          - address: 192.168.2.11
            port: 9292
            ssl:
              enabled: true
              pem_file: /etc/haproxy/ssl/all.pem
          http_request:
          - action: set-header X-Forwarded-Proto https
          mode: http
          options:
          - httpchk GET /
          - httplog
          - httpclose
          servers:
          - host: 127.0.0.1
            name: ctl01
            params: check inter 10s fastinter 2s downinter 3s rise 3 fall 3
            port: 9292

Custom listener with tcp-check options specified (for Redis cluster with Sentinel)

.. code-block:: yaml

  haproxy:
    proxy:
      listen:
        redis_cluster:
          service_name: redis
          health-check:
            tcp:
              enabled: True
              options:
                - send PING\r\n
                - expect string +PONG
                - send info\ replication\r\n
                - expect string role:master
                - send QUIT\r\n
                - expect string +OK
          binds:
            - address: ${_param:cluster_address}
              port: 6379
          servers:
            - name: ${_param:cluster_node01_name}
              host: ${_param:cluster_node01_address}
              port: 6379
              params: check inter 1s
            - name: ${_param:cluster_node02_name}
              host: ${_param:cluster_node02_address}
              port: 6379
              params: check inter 1s
            - name: ${_param:cluster_node03_name}
              host: ${_param:cluster_node03_address}
              port: 6379
              params: check inter 1s

Frontend for routing between exists listeners via URL with SSL an redirects.
You can use one backend for several URLs.

.. code-block:: yaml

  haproxy:
    proxy:
      listen:
        service_proxy:
          mode: http
          balance: source
          format: end
          binds:
           - address: ${_param:haproxy_bind_address}
             port: 80
             ssl: ${_param:haproxy_frontend_ssl}
             ssl_port: 443
          redirects:
           - code: 301
             location: domain.com/images
             conditions:
               - type: hdr_dom(host)
                 condition: images.domain.com
          acls:
           - name: gerrit
             conditions:
               - type: hdr_dom(host)
                 condition: gerrit.domain.com
           - name: jenkins
             conditions:
               - type: hdr_dom(host)
                 condition: jenkins.domain.com
           - name: docker
             backend: artifactroy
             conditions:
               - type: hdr_dom(host)
                 condition: docker.domain.com

Enable customisable ``forwardfor`` option in ``defaults`` section.

.. code-block:: yaml

  haproxy:
    proxy:
      enabled: true
      mode: tcp
      logging: syslog
      max_connections: 1024
      forwardfor:
        enabled: true
        except:
        header:
        if-none: false

.. code-block:: yaml

  haproxy:
    proxy:
      enabled: true
      mode: tcp
      logging: syslog
      max_connections: 1024
      forwardfor:
        enabled: true
        except: 127.0.0.1
        header: X-Real-IP
        if-none: false

Sample pillar with multiprocess multicore configuration

.. code-block:: yaml

  haproxy:
    proxy:
      enabled: True
      nbproc: 4
      cpu_map:
        1: 0
        2: 1
        3: 2
        4: 3
      stats_bind_process: "1 2"
      mode: http/tcp
      logging: syslog
      maxconn: 1024
      timeout:
        connect: 5000
        client: 50000
        server: 50000
      listen:
        https-in:
          bind_process: "1 2 3 4"
          binds:
          - address: 0.0.0.0
            port: 443
          servers:
          - name: server1
            host: 10.0.0.1
            port: 8443
          - name: server2
            host: 10.0.0.2
            port: 8443
            params: 'maxconn 256'

Implement rate limiting, to prevent excessive requests
This feature only works if using 'format: end'

.. code-block:: yaml

  haproxy:
    proxy:
      ...
      listen:
        nova_metadata_api:
          ...
          format: end
          options:
          - httpchk
          - httpclose
          - httplog
          rate_limit:
            duration: 900s
            enabled: true
            requests: 125
            track: content
          servers:
            ...
          type: http

Read more
=========

* https://github.com/jesusaurus/hpcs-salt-state/tree/master/haproxy
* http://www.nineproductions.com/saltstack-ossec-state-using-reactor/
* https://gist.github.com/tomeduarte/6340205 - example on how to use peer
  from within a config file (using jinja)
* http://youtu.be/jJJ8cfDjcTc?t=8m58s - from 9:00 on, a good overview
  of peer vs mine
* https://github.com/russki/cluster-agents

Documentation and Bugs
======================

* http://salt-formulas.readthedocs.io/
   Learn how to install and update salt-formulas

* https://github.com/salt-formulas/salt-formula-haproxy/issues
   In the unfortunate event that bugs are discovered, report the issue to the
   appropriate issue tracker. Use the Github issue tracker for a specific salt
   formula

* https://launchpad.net/salt-formulas
   For feature requests, bug reports, or blueprints affecting the entire
   ecosystem, use the Launchpad salt-formulas project

* https://launchpad.net/~salt-formulas-users
   Join the salt-formulas-users team and subscribe to mailing list if required

* https://github.com/salt-formulas/salt-formula-haproxy
   Develop the salt-formulas projects in the master branch and then submit pull
   requests against a specific formula

* #salt-formulas @ irc.freenode.net
   Use this IRC channel in case of any questions or feedback which is always
   welcome


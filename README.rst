=======
HAproxy
=======

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
        listens:
        - name: https-in
          bind:
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
        listens:
        - name: https-in
          bind:
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
          listens:
          - name: mysql
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
          - name: rabbitmq
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
          -name: keystone-1
           type: general-service
           bins:
           - address: 10.0.106.170
             port: 5000
           servers:
           -name: node1
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
          listens:
          - name: mysql
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
          - name: rabbitmq
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
          -name: keystone-1
           type: general-service
           bins:
           - address: 10.0.106.170
             port: 5000
           servers:
           -name: node1
            host: 10.0.88.13
            port: 5000
            params: check

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

Custom listener with tcp-check options specified (for Redis cluster with Sentinel)

.. code-block:: yaml

  haproxy:
    proxy:
      listen:
        redis_cluster:
          service_name: redis
          check:
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

Read more
=========

* https://github.com/jesusaurus/hpcs-salt-state/tree/master/haproxy
* http://www.nineproductions.com/saltstack-ossec-state-using-reactor/ - example reactor usage.
* https://gist.github.com/tomeduarte/6340205 - example on how to use peer from within a config file (using jinja)
* http://youtu.be/jJJ8cfDjcTc?t=8m58s - from 9:00 on, a good overview of peer vs mine
* https://github.com/russki/cluster-agents

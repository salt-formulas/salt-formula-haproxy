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
            check_attr:
              user: clustercheck
              pass: clustercheck
              available_when_donor: 0
              available_when_readonly: 1
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

Read more
=========

* https://github.com/jesusaurus/hpcs-salt-state/tree/master/haproxy
* http://www.nineproductions.com/saltstack-ossec-state-using-reactor/ - example reactor usage.
* https://gist.github.com/tomeduarte/6340205 - example on how to use peer from within a config file (using jinja)
* http://youtu.be/jJJ8cfDjcTc?t=8m58s - from 9:00 on, a good overview of peer vs mine
* https://github.com/russki/cluster-agents

Documentation and Bugs
======================

To learn how to install and update salt-formulas, consult the documentation
available online at:

    http://salt-formulas.readthedocs.io/

In the unfortunate event that bugs are discovered, they should be reported to
the appropriate issue tracker. Use Github issue tracker for specific salt
formula:

    https://github.com/salt-formulas/salt-formula-haproxy/issues

For feature requests, bug reports or blueprints affecting entire ecosystem,
use Launchpad salt-formulas project:

    https://launchpad.net/salt-formulas

You can also join salt-formulas-users team and subscribe to mailing list:

    https://launchpad.net/~salt-formulas-users

Developers wishing to work on the salt-formulas projects should always base
their work on master branch and submit pull request against specific formula.

    https://github.com/salt-formulas/salt-formula-haproxy

Any questions or feedback is always welcome so feel free to join our IRC
channel:

    #salt-formulas @ irc.freenode.net

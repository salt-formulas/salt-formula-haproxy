=======
HAproxy
=======

The Reliable, High Performance TCP/HTTP Load Balancer. 

Sample pillar
=============

.. code-block:: yaml

    haproxy:
      proxy:
        enabled: True
        mode: http/tcp
        max_connections: 1024
        connect_timeout: 5000
        client_timeout: 50000
        server_timeout: 50000
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
=================================

.. code-block:: yaml

    haproxy:
      proxy:
        enabled: True
        mode: http/tcp
        logging: syslog
        max_connections: 1024
        connect_timeout: 5000
        client_timeout: 50000
        server_timeout: 50000
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

Read more
=========

* https://github.com/jesusaurus/hpcs-salt-state/tree/master/haproxy
* http://www.nineproductions.com/saltstack-ossec-state-using-reactor/ - example reactor usage.
* https://gist.github.com/tomeduarte/6340205 - example on how to use peer from within a config file (using jinja)
* http://youtu.be/jJJ8cfDjcTc?t=8m58s - from 9:00 on, a good overview of peer vs mine
* https://github.com/russki/cluster-agents

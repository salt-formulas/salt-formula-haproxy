haproxy:
  proxy:
    enabled: true
    mode: tcp
    logging: syslog
    max_connections: 1024
    nbproc: 4
    cpu_map:
      1: 0
      2: 1
      3: 2
      4: 3
    stats_bind_process: "1 2"
    listen:
      glance_api:
        type: openstack-service
        bind_process: "1 2 3 4"
        binds:
        - address: 127.0.0.1
          port: 9292
        servers:
        - name: ctl01
          host: 127.0.0.1
          port: 9292
          params: check inter 10s fastinter 2s downinter 3s rise 3 fall 3
        - name: ctl02
          host: 127.0.0.1
          port: 9292
          params: check inter 10s fastinter 2s downinter 3s rise 3 fall 3
        - name: ctl03
          host: 127.0.0.1
          port: 9292
          params: check inter 10s fastinter 2s downinter 3s rise 3 fall 3

# For haproxy/meta/sensu.yml
linux:
  network:
    fqdn: linux.ci.local

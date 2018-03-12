haproxy:
  proxy:
    enabled: true
    mode: tcp
    logging: syslog
    max_connections: 1024
    listen:
      nova_metadata_api:
        binds:
        - address: 127.0.0.1
          port: 8775
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
        - host: 127.0.0.1
          name: ctl01
          params: check inter 10s fastinter 2s downinter 3s rise 3 fall 3
          port: 8775
        - host: 127.0.0.1
          name: ctl02
          params: check inter 10s fastinter 2s downinter 3s rise 3 fall 3
          port: 8775
        - host: 127.0.0.1
          name: ctl03
          params: check inter 10s fastinter 2s downinter 3s rise 3 fall 3
          port: 8775
        type: http

# For haproxy/meta/sensu.yml
linux:
  network:
    fqdn: linux.ci.local

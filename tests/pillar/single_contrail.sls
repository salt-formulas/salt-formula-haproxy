haproxy:
  proxy:
    enabled: true
    mode: tcp
    logging: syslog
    max_connections: 1024
    listen:
      contrail_analytics:
        type: contrail-analytics
        binds:
        - address: 127.0.0.1
          port: 8081
        servers:
        - name: ams1posnal01
          host: 127.0.0.1
          port: 9081
          params: check inter 2000 rise 2 fall 3
        - name: ams1posnal02
          host: 127.0.0.1
          port: 9081
          params: check inter 2000 rise 2 fall 3
        - name: ams1posnal03
          host: 127.0.0.1
          port: 9081
          params: check inter 2000 rise 2 fall 3
      contrail_config_stats:
        type: contrail-config
        format: listen
        binds:
        - address: '*'
          port: 5937
        user: haproxy
        password: password
      contrail_api:
        type: contrail-api
        check: false
        binds:
        - address: 127.0.0.1
          port: 8082
        servers:
        - name: ams1posntw01
          host: 127.0.0.1
          port: 9100
          params: check inter 2000 rise 2 fall 3
        - name: ams1posntw02
          host: 127.0.0.1
          port: 9100
          params: check inter 2000 rise 2 fall 3
        - name: ams1posntw03
          host: 127.0.0.1
          port: 9100
          params: check inter 2000 rise 2 fall 3
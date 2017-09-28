haproxy:
  proxy:
    enabled: true
    forwardfor:
      enabled: false
    listen:
      admin_page:
        type: stats
        check: false
        binds:
        - address: '0.0.0.0'
          port: 9600

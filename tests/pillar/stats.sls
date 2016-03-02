haproxy:
  proxy:
    enabled: true
    listen:
      admin_page:
        type: admin
        check: false
        binds:
        - address: '0.0.0.0'
          port: 9600
        user: admin
        password: password
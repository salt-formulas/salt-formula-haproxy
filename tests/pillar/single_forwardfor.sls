haproxy:
  proxy:
    enabled: true
    forwardfor:
      enabled: true
      except: 127.0.0.1
      header: X-Custom-Header
      if-none: true
    mode: tcp
    logging: syslog
    max_connections: 1024

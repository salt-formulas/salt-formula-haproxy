haproxy:
  salt.state:
    - tgt: 'roles:haproxy.proxy'
    - tgt_type: grain
    - sls: haproxy


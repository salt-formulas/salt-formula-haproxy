haproxy:
  proxy:
    enabled: true
    mode: tcp
    max_connections: 10
    listen:
      test_mysql_cluster:
        type: mysql
        checks:
          clustercheck:
            enabled: True
            #user: clustercheck
            password: clustercheck
            available_when_donor: 1
            port: 9200
        binds:
        - address: 127.0.0.1
          port: 3306
        servers:
        - name: dbs01
          host: 127.0.0.1
          port: 33061
          params: check port 9200
        - name: dbs02
          host: 127.0.0.1
          port: 33062
          params: check port 9200
        - name: dbs03
          host: 127.0.0.1
          port: 33063
          params: check port 9200
      test_mysql_cluster2:
        type: mysql
        binds:
        - address: 127.0.10.1
          port: 12701
        servers:
        - name: dbs01
          host: 127.0.11.1
          port: 3306
        - name: dbs02
          host: 127.0.12.1
          port: 3306
galera:
  master:
    enabled: true
    name: kitchen
    maintenance_password: password
    bind:
      address: 127.0.1.1
      port: 33061
    members:
    - host: 127.0.2.1
      port: 33062
    - host: 127.0.3.1
      port: 33063
    admin:
      user: root
      password: pass
    database:
      testdb:
        encoding: 'utf8'
        users:
        - name: 'test'
          password: 'test'
          host: 'localhost'
          rights: 'all privileges'


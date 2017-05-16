linux:
  system:
    enabled: true
    repo:
      galeracluster:
        source: 'deb http://releases.galeracluster.com/ubuntu {{ grains.get('oscodename') }} main'
        key_id: BC19DDBA
        key_server: hkp://p80.pool.sks-keyservers.net:80
      mitaka-staging_PPA:
        source: "deb http://ppa.launchpad.net/ubuntu-cloud-archive/mitaka-staging/ubuntu trusty main"

{%- from "haproxy/map.jinja" import proxy with context %}
{%- if proxy.enabled %}

haproxy_packages:
  pkg.installed:
  - names: {{ proxy.pkgs }}

/etc/default/haproxy:
  file.managed:
  - source: salt://haproxy/files/haproxy.default
  - require:
    - pkg: haproxy_packages

/etc/haproxy/haproxy.cfg:
  file.managed:
  - source: salt://haproxy/files/haproxy.cfg
  - template: jinja
  - require:
    - pkg: haproxy_packages

haproxy_ssl:
  file.directory:
  - name: /etc/haproxy/ssl
  - user: root
  - group: haproxy
  - mode: 750
  - require:
    - pkg: haproxy_packages

{%- if grains.get('virtual_subtype', None) not in ['Docker', 'LXC'] %}

net.ipv4.ip_nonlocal_bind:
  sysctl.present:
    - value: 1

{% endif %}

{% if not grains.get('noservices', False) %}

haproxy_service:
  service.running:
  - name: {{ proxy.service }}
  - enable: true
  - watch:
    - file: /etc/haproxy/haproxy.cfg
    - file: /etc/default/haproxy

{% endif %}


{%- for listen_name, listen in proxy.get('listen', {}).iteritems() %}
  {%- if listen.get('enabled', True) %}
    {%- for bind in listen.binds %}
      {% if bind.get('ssl', {}).enabled|default(False) and bind.ssl.key is defined %}
        {%- set pem_file = bind.ssl.get('pem_file', '/etc/haproxy/ssl/%s/%s-all.pem'|format(listen_name, loop.index)) %}

{{ pem_file }}:
  file.managed:
    - template: jinja
    - source: salt://haproxy/files/ssl_all.pem
    - user: root
    - group: haproxy
    - mode: 640
    - makedirs: true
    - defaults:
        key: {{ bind.ssl.key|yaml }}
        cert: {{ bind.ssl.cert|yaml }}
        chain: {{ bind.ssl.get('chain', '')|yaml }}
    - require:
      - file: haproxy_ssl
    {% if not grains.get('noservices', False) %}
    - watch_in:
      - service: haproxy_service
    {% endif %}

      {%- endif %}
    {%- endfor %}
  {%- endif %}
{%- endfor %}



{%- set _haproxy_xinetd_srv = [] %}

{%- for listen_name, listen in proxy.get('listen', {}).iteritems() %}
{%- if listen.type == 'mysql' and listen.get('checks', {}).get('clustercheck', {}).get('enabled', False) == True %}
{%- for bind in listen.binds %}
{%- set index = '_{0}_{1}'.format(bind.address, bind.port) %}
{%- set _ccheck = listen.checks.clustercheck %}
{%- do _haproxy_xinetd_srv.append('clustercheck') %}
/etc/xinetd.d/mysql_clustercheck{{ index }}_{{ _ccheck.get('clustercheckport', 9200) }}:
  file.managed:
    - source: salt://haproxy/files/xinet.d.conf
    - template: jinja
    - defaults:
        user: nobody
        # FIXME, add optins if check_attr host/port is defined etc..
        server: '/usr/local/bin/clustercheck {{ _ccheck.get('user', 'clustercheck') }} {{ _ccheck.get('password', 'clustercheck') }} {{ _ccheck.get('available_when_donor', 0) }} {{ _ccheck.get('available_when_readonly', 0) }}'
        port: _ccheck.get('port', 9200)
        flags: REUSE
        per_source: UNLIMITED
    - require:
      - file: /usr/local/bin/mysql_clustercheck
    - watch_in:
      - haproxy_xinetd_service

{%- endfor %}
{%- endif %}
{%- endfor %}

{% if 'clustercheck' in _haproxy_xinetd_srv %}
clustercheck_dir:
  file.directory:
  - name: /usr/local/bin/
  - user: root
  - group: root
  - mode: 750

/usr/local/bin/mysql_clustercheck:
  file.managed:
    - source: salt://haproxy/files/clustercheck.sh
    - user: root
    - group: root
    - mode: 755
    - require:
      - file: clustercheck_dir
{%- endif %}

{%- if _haproxy_xinetd_srv|length > 0 %}
haproxy_xinetd_package:
  pkg.installed:
  - name: xinetd

haproxy_xinetd_service:
  service.running:
  - name: xinetd
  - require:
    - pkg: xinetd
{%- endif %}


{%- endif %}

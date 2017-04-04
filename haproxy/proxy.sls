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

{%- endif %}

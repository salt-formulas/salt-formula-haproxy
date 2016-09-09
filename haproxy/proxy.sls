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

net.ipv4.ip_nonlocal_bind:
  sysctl.present:
    - value: 1

haproxy_service:
  service.running:
  - name: {{ proxy.service }}
  - enable: true
  - watch:
    - file: /etc/haproxy/haproxy.cfg
    - file: /etc/default/haproxy

{%- endif %}

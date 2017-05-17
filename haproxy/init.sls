
{% if pillar.haproxy.proxy is defined %}
include:
- haproxy.proxy
{% endif %}
{%- from "openvpn/map.jinja" import openvpn with context %}

{%- set server = openvpn.get('server', {}) %}

include:
  - openvpn.install

openvpn_ip_forward:
  sysctl.present:
    - name: net.ipv4.ip_forward
    - value: 1

/etc/openvpn/server.conf:
  file.managed:
  - source: salt://openvpn/files/server.conf.jinja
  - template: jinja
  - mode: 600
  - require:
    - pkg: openvpn_packages
  - watch_in:
    - service: openvpn_server_service

/etc/openvpn/ipp.txt:
  file.managed:
    - source: salt://openvpn/files/ipp.txt.jinja
    - template: jinja
    - mode: 600
    - require:
      - pkg: openvpn_packages
    - watch_in:
      - service: openvpn_server_service

  {%- if server.ssl.get('key') %}
/etc/openvpn/ssl/server.key:
  file.managed:
  {%- if server.ssl.key.source is defined %}
    - source: {{server.ssl.key.source}}
    {%- if server.ssl.key.get('source_hash', False) %}
    - source_hash: {{server.ssl.key.source_hash}}
    {%- else %}
    - skip_verify: True
    {%- endif %}
  {%- else %}
    - contents_pillar: openvpn:server:ssl:key
  {%- endif %}
    - mode: 600
    - watch_in:
      - service: openvpn_server_service
  {%- endif %}

  {%- if server.ssl.get('cert') %}
/etc/openvpn/ssl/server.crt:
  file.managed:
  {%- if server.ssl.cert.source is defined %}
    - source: {{server.ssl.cert.source}}
    {%- if server.ssl.cert.get('source_hash', False) %}
    - source_hash: {{server.ssl.cert.source_hash}}
    {%- else %}
    - skip_verify: True
    {%- endif %}
  {%- else %}
    - contents_pillar: openvpn:server:ssl:cert
  {%- endif %}
    - watch_in:
      - service: openvpn_server_service
  {%- endif %}

  {%- if server.ssl.get('ca') %}
/etc/openvpn/ssl/ca.crt:
  file.managed:
  {%- if server.ssl.ca.source is defined %}
    - source: {{server.ssl.ca.source}}
    {%- if server.ssl.ca.get('source_hash', False) %}
    - source_hash: {{server.ssl.ca.source_hash}}
    {%- else %}
    - skip_verify: True
    {%- endif %}
  {%- else %}
    - contents_pillar: openvpn:server:ssl:ca
  {%- endif %}
    - watch_in:
      - service: openvpn_server_service
  {%- endif %}

{%- if server.ssl.get('ta') %}
/etc/openvpn/ssl/ta.key:
  file.managed:
  {%- if server.ssl.ta.source is defined %}
    - source: {{server.ssl.ta.source}}
    {%- if server.ssl.ta.get('source_hash', False) %}
    - source_hash: {{server.ssl.ta.source_hash}}
    {%- else %}
    - skip_verify: True
    {%- endif %}
  {%- else %}
    - contents_pillar: openvpn:server:ssl:ta
  {%- endif %}
    - watch_in:
      - service: openvpn_server_service
  {%- endif %}

openvpn_generate_dhparams:
  cmd.run:
    - name: openssl dhparam -out /etc/openvpn/ssl/dh.pem 2048
    - creates: /etc/openvpn/ssl/dh.pem
    - watch_in:
      - service: openvpn_server_service

openvpn_server_service:
  {%- if openvpn.service_running %}
  service.running:
  {%- else %}
  service.dead:
  {%- endif %}
    {%- if grains.get('init', None) == 'systemd' %}
    - name: {{ openvpn.service }}@server
    {%- else %}
    - name: {{ openvpn.service }}
    {%- endif %}

{%- if openvpn.service_enabled %}
openvpn_server_service_enable:
  service.enabled:
    {%- if grains.get('init', None) == 'systemd' %}
    - name: {{ openvpn.service }}@server
    {%- else %}
    - name: {{ openvpn.service }}
    {%- endif %}
{%- else %}
openvpn_server_service_disable:
  service.disabled:
    {%- if grains.get('init', None) == 'systemd' %}
    - name: {{ openvpn.service }}@server
    {%- else %}
    - name: {{ openvpn.service }}
    {%- endif %}
{%- endif %}

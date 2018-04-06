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
    - contents_pillar: openvpn:server:ssl:key
    - mode: 600
    - watch_in:
      - service: openvpn_server_service
  {%- endif %}

  {%- if server.ssl.get('cert') %}
/etc/openvpn/ssl/server.crt:
  file.managed:
    - contents_pillar: openvpn:server:ssl:cert
    - watch_in:
      - service: openvpn_server_service
  {%- endif %}

  {%- if server.ssl.get('ca') %}
/etc/openvpn/ssl/ca.crt:
  file.managed:
    - contents_pillar: openvpn:server:ssl:ca
    - watch_in:
      - service: openvpn_server_service
  {%- endif %}

  {%- if server.ssl.get('ta') %}
/etc/openvpn/ssl/ta.key:
  file.managed:
    - contents_pillar: openvpn:server:ssl:ta
    - mode: 600
    - watch_in:
      - service: openvpn_server_service
  {%- endif %}

openvpn_generate_dhparams:
  cmd.run:
    - name: openssl dhparam -out /etc/openvpn/ssl/dh2048.pem 2048
    - creates: /etc/openvpn/ssl/dh2048.pem
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
    - enable: {{ openvpn.service_enabled }}
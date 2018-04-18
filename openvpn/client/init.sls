{%- from "openvpn/map.jinja" import openvpn with context %}

{%- set client = openvpn.get('client', {}) %}

include:
  - openvpn.install

{%- for tunnel, params in client.get('tunnels', {}).iteritems() %}
/etc/openvpn/{{tunnel}}.conf:
  file.managed:
  - source: salt://openvpn/files/client.conf.jinja
  - template: jinja
  - mode: 600
  - defaults:
      tunnel_name: {{tunnel}}
  - require:
    - pkg: openvpn_packages
  - watch_in:
    - service: openvpn_client_{{tunnel}}_service

  {%- if params.ssl.get('key') %}
/etc/openvpn/ssl/{{tunnel}}.key:
  file.managed:
    - contents_pillar: openvpn:client:tunnels:{{tunnel}}:ssl:key
    - mode: 600
    - watch_in:
      - service: openvpn_client_{{tunnel}}_service
  {%- endif %}

  {%- if params.ssl.get('cert') %}
/etc/openvpn/ssl/{{tunnel}}.crt:
  file.managed:
    - contents_pillar: openvpn:client:tunnels:{{tunnel}}:ssl:cert
    - watch_in:
      - service: openvpn_client_{{tunnel}}_service
  {%- endif %}

  {%- if params.ssl.get('ca') %}
/etc/openvpn/ssl/{{tunnel}}-ca.crt:
  file.managed:
    - contents_pillar: openvpn:client:tunnels:{{tunnel}}:ssl:ca
    - watch_in:
      - service: openvpn_client_{{tunnel}}_service
  {%- endif %}

  {%- if params.ssl.get('ta') %}
/etc/openvpn/ssl/{{tunnel}}-ta.key:
  file.managed:
    - contents_pillar: openvpn:client:tunnels:{{tunnel}}:ssl:ta
    - mode: 600
    - watch_in:
      - service: openvpn_client_{{tunnel}}_service
  {%- endif %}

openvpn_client_{{tunnel}}_service:
  {%- if openvpn.service_running %}
  service.running:
  {%- else %}
  service.dead:
  {%- endif %}
    {%- if grains.get('init', None) == 'systemd' %}
    - name: {{ openvpn.service }}@{{ tunnel }}
    {%- else %}
    - name: {{ openvpn.service }}
    {%- endif %}

  {%- if openvpn.service_enabled %}
openvpn_client_{{tunnel}}_service_enable:
  service.enabled:
    - name: {{ openvpn.service }}
  {%- else %}
openvpn_client_{{tunnel}}_service_disable:
  service.disabled:
    - name: {{ openvpn.service }}
  {%- endif %}
{%- endfor %}

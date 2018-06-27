{%- from "openvpn/map.jinja" import openvpn with context %}

{%- set client = openvpn.get('client', {}) %}
{%- set hostname = salt['grains.get']('host') %}

include:
  - openvpn.install

{%- for tunnel, params in client.get('tunnels', {}).items() %}
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
  {%- if params.ssl.key.source is defined %}
    - source: {{params.ssl.key.source}}
    {%- if params.ssl.key.get('source_hash', False) %}
    - source_hash: {{params.ssl.key.source_hash}}
    {%- else %}
    - skip_verify: True
    {%- endif %}
  {%- else %}
    - contents_pillar: openvpn:client:tunnels:{{tunnel}}:ssl:key
  {%- endif %}
    - mode: 600
    - watch_in:
      - service: openvpn_client_{{tunnel}}_service
  {%- endif %}

  {%- if params.ssl.get('cert') %}
/etc/openvpn/ssl/{{tunnel}}.crt:
  file.managed:
  {%- if params.ssl.cert.source is defined %}
    - source: {{params.ssl.cert.source}}
    {%- if params.ssl.cert.get('source_hash', False) %}
    - source_hash: {{params.ssl.cert.source_hash}}
    {%- else %}
    - skip_verify: True
    {%- endif %}
  {%- else %}
    - contents_pillar: openvpn:client:tunnels:{{tunnel}}:ssl:cert
  {%- endif %}
    - mode: 600
    - watch_in:
      - service: openvpn_client_{{tunnel}}_service
  {%- endif %}

  {%- if params.ssl.get('ca') %}
/etc/openvpn/ssl/{{tunnel}}-ca.crt:
  file.managed:
  {%- if params.ssl.ca.source is defined %}
    - source: {{params.ssl.ca.source}}
    {%- if params.ssl.ca.get('source_hash', False) %}
    - source_hash: {{params.ssl.ca.source_hash}}
    {%- else %}
    - skip_verify: True
    {%- endif %}
  {%- else %}
    - contents_pillar: openvpn:client:tunnels:{{tunnel}}:ssl:ca
  {%- endif %}
    - mode: 600
    - watch_in:
      - service: openvpn_client_{{tunnel}}_service
  {%- endif %}
 
  {%- if params.ssl.get('ta') %}
/etc/openvpn/ssl/{{tunnel}}-ta.key:
  file.managed:
  {%- if params.ssl.ta.source is defined %}
    - source: {{params.ssl.ta.source}}
    {%- if params.ssl.ta.get('source_hash', False) %}
    - source_hash: {{params.ssl.ta.source_hash}}
    {%- else %}
    - skip_verify: True
    {%- endif %}
  {%- else %}
    - contents_pillar: openvpn:client:tunnels:{{tunnel}}:ssl:ta
  {%- endif %}
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

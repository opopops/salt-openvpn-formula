{%- from "openvpn/map.jinja" import openvpn with context %}

include:
  - openvpn.install
  {%- if openvpn.server is defined %}
  - openvpn.server
  {%- endif %}
  {%- if openvpn.client is defined %}
  - openvpn.client
  {%- endif %}
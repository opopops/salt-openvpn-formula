{%- from "openvpn/map.jinja" import openvpn with context %}

{%- set server = openvpn.get('server', {}) %}

include:
  - openvpn.install
  - openvpn.server.config


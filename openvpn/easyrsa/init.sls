{%- from "openvpn/map.jinja" import openvpn with context %}

include:
  - openvpn.easyrsa.install
  - openvpn.easyrsa.config

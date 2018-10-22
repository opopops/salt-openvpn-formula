{%- from "openvpn/map.jinja" import openvpn with context %}

openvpn_easyrsa_archive:
  archive.extracted:
    - name: {{openvpn.config_dir}}
    - source: {{openvpn.easyrsa.base_url}}/v{{openvpn.easyrsa.version}}.tar.gz
    - source_hash: {{openvpn.easyrsa.hash}}
    - options: xvz
    - enforce_toplevel: False

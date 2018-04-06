{%- from "openvpn/map.jinja" import openvpn with context %}

openvpn_packages:
  pkg.installed:
    - pkgs: {{ openvpn.pkgs }}

openvpn_ssl_dir:
  file.directory:
    - name: /etc/openvpn/ssl
    - require:
      - pkg: openvpn_packages


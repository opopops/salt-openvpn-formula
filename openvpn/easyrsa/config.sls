{%- from "openvpn/map.jinja" import openvpn with context %}

include:
  - openvpn.easyrsa.install

openvpn_easyrsa_vars:
  file.managed:
    - name: {{ openvpn.config_dir }}/easy-rsa-{{openvpn.easyrsa.version}}/easyrsa{{openvpn.easyrsa.version.split('.')[0]}}/vars
    - source: salt://openvpn/files/easyrsa-vars.j2
    - template: jinja
    - mode: 755
    - force: True
    - require:
      - sls: openvpn.easyrsa.install

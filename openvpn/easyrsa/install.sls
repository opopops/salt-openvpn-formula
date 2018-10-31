{%- from "openvpn/map.jinja" import openvpn with context %}

openvpn_easyrsa_archive:
  archive.extracted:
    - name: {{openvpn.config_dir}}
    - source: {{openvpn.easyrsa.base_url}}/v{{openvpn.easyrsa.version}}.tar.gz
    - source_hash: {{openvpn.easyrsa.hash}}
    - options: xvz
    - enforce_toplevel: False

openvpn_easyrsa_symlink:
  file.symlink:
    - name: {{openvpn.config_dir}}/easy-rsa
    - target: {{openvpn.config_dir}}/easy-rsa-{{openvpn.easyrsa.version}}/easyrsa{{openvpn.easyrsa.version.split('.')[0]}}
    - mode: 755
    - force: True
    - require:
      - archive: openvpn_easyrsa_archive

openvpn_easyrsa_bin_symlink:
  file.symlink:
    - name: /usr/local/bin/easyrsa
    - target: {{openvpn.config_dir}}/easy-rsa/easyrsa
    - mode: 755
    - force: True
    - require:
      - file: openvpn_easyrsa_symlink


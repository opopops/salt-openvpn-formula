{%- from "openvpn/map.jinja" import openvpn with context %}

{%- for path, params in openvpn.get('easyrsa', {}).items() %}

openvpn_easyrsa_archive_{{path}}:
  archive.extracted:
    - name: {{path}}
    {%- if openvpn.get('easyrsa_source', False) %}
    - source: {{openvpn.easyrsa_source}}
    - source_hash: {{openvpn.easyrsa_source_hash}}
    {%- else %}
    - source: {{openvpn.easyrsa_base_url}}/v{{openvpn.easyrsa_version}}.tar.gz
    - source_hash: {{openvpn.easyrsa_hash}}
    {%- endif %}
    - options: --strip-components=2 easy-rsa-{{openvpn.easyrsa_version}}/easyrsa3
    - enforce_toplevel: False
  file.directory:
    - name: {{path}}
    - user: {{params.get('user', 'root')}}
    - group: {{params.get('group', 'root')}}
    - recurse:
      - user
      - group

openvpn_easyrsa_env_{{path}}:
  file.directory:
    - names:
      - {{path | path_join('pki', 'certs_by_serial')}}
      - {{path | path_join('pki', 'issued')}}
      - {{path | path_join('pki', 'reqs')}}
    - user: {{params.get('user', 'root')}}
    - group: {{params.get('group', 'root')}}
    - mode: 755
    - makedirs: True
    - require:
      - archive: openvpn_easyrsa_archive_{{path}}

openvpn_easyrsa_private_env_{{path}}:
  file.directory:
    - names:
      - {{path | path_join('pki', 'private')}}
    - user: {{params.get('user', 'root')}}
    - group: {{params.get('group', 'root')}}
    - dir_mode: 750
    - file_mode: 640
    - makedirs: True
    - recurse:
      - user
      - group
      - mode
    - require:
      - archive: openvpn_easyrsa_archive_{{path}}

openvpn_easyrsa_files_{{path}}:
  file.managed:
    - names:
      - {{path | path_join('pki', 'index.txt')}}
      - {{path | path_join('pki', 'serial')}}
    - user: {{params.get('user', 'root')}}
    - group: {{params.get('group', 'root')}}
    - mode: 644
    - require:
      - file: openvpn_easyrsa_env_{{path}}
      - file: openvpn_easyrsa_private_env_{{path}}

 {%- if params.get('vars', False) %}
openvpn_easyrsa_vars_{{path}}:
  file.managed:
    - name: {{path | path_join('vars')}}
    - source: salt://openvpn/files/easyrsa-vars.j2
    - template: jinja
    - user: {{params.get('user', 'root')}}
    - group: {{params.get('group', 'root')}}
    - mode: 755
    - force: True
    - defaults:
        vars: {{params.vars}}
    - require:
      - archive: openvpn_easyrsa_archive_{{path}}
  {%- endif %}

  {%- for file, file_params in params.get('files', {}).items() %}
openvpn_easyrsa_{{path}}_{{file}}:
  file.managed:
    - name: {{path | path_join(file)}}
    - contents: |
        {{file_params.contents|indent(8)}}
    - user: {{params.get('user', 'root')}}
    - group: {{params.get('group', 'root')}}
    - mode: {{file_params.get('mode', 644)}}
    - makedirs: True
    - require:
      - archive: openvpn_easyrsa_archive_{{path}}
  {%- endfor %}
{%- endfor %}

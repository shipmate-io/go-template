#!/bin/sh

cd "{{ path('/var/www/', variables.path_to_source_code) }}"

{% for command in variables.deploy_script|trim|split('\n') %}
{{ command }}
{% endfor %}
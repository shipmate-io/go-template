#!/bin/sh

cd "{{ path('/var/www/', variables.path_to_source_code) }}"

{% for command in variables.release_script|trim|split('\n') %}
{{ command }}
{% endfor %}
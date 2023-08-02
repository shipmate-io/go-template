# Set the go base image, based on the specified go version.
{% if variables.go_version == "1.20" %}
FROM europe-west1-docker.pkg.dev/cody-348021/docker-images/go/1.20:1.0 AS production-stage
{% endif %}

# Create the directory to copy the source code to.
RUN mkdir -p {{ path('/var/www/', variables.path_to_source_code) }}

# CD into the directory containing the source code of the service.
WORKDIR {{ path('/var/www/', variables.path_to_source_code) }}

# Run the before build script, if specified.
{% if variables.before_build_script|length > 0 %}
RUN echo "" \
{% for command in variables.before_build_script|split('\n')|filter(command => command) %}
 && ({{ command }}) \
{% endfor %}
 && echo ""
{% endif %}

{% if variables.deploy_script %}
# Copy the deploy.sh entrypoint into the image.
COPY scripts/deploy.sh /entrypoints/deploy.sh
{% endif %}

{% if variables.release_script %}
# Copy the release.sh script into the image.
COPY scripts/release.sh /scripts/release.sh
# Make the scripts executable.
RUN chmod -R 775 /scripts
{% endif %}

{% if variables.install_dependencies %}
COPY {{ path('code-repository/', variables.path_to_source_code, '/go.mod') }} {{ path('/var/www/', variables.path_to_source_code, '/') }}
COPY {{ path('code-repository/', variables.path_to_source_code, '/go.sum') }} {{ path('/var/www/', variables.path_to_source_code, '/') }}
RUN go mod download
{% endif %}

# Copy the source code of the service into the image.
COPY {{ path('code-repository/', variables.path_to_source_code, '/') }} {{ path('/var/www', variables.path_to_source_code, '/') }}

# Run the build script, if specified.
{% if variables.build_script|length > 0 %}
RUN echo "" \
{% for command in variables.build_script|split('\n')|filter(command => command) %}
 && ({{ command }}) \
{% endfor %}
 && echo ""
{% endif %}

# Make sure all files have the correct owners and permissions.
RUN chown -R webuser:webgroup {{ path('/var/www/', variables.path_to_source_code) }} \
 && chmod -R 775 {{ path('/var/www/', variables.path_to_source_code) }}

# Upload assets to Google Cloud Storage
{% if variables.publish_assets %}
FROM google/cloud-sdk:alpine as gcloud

ARG SHIPMATE_ASSET_ACCESS_KEY
ARG SHIPMATE_ASSET_BUCKET

RUN echo $SHIPMATE_ASSET_ACCESS_KEY | cat > /credentials.json \
 && gcloud auth activate-service-account --key-file=/credentials.json

# Create assets directory
RUN mkdir -p /assets
# Copy assets to the assets directory
COPY --from=production-stage {{ path('/var/www/', variables.path_to_source_code, variables.path_to_assets) }} /assets
# Remove all symlinks
RUN find /assets -type l -delete
# Upload the contents of the assets directory
RUN gsutil -m cp -r /assets/. $SHIPMATE_ASSET_BUCKET

# Switch back to production stage
FROM production-stage
{% endif %}
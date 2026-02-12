#
# Ultra-lightweight runner stage, pulls pre-built artifacts
# using a single-stage nginx build
#
FROM nginx:stable-alpine AS runner

# Install curl and unzip to handle artifacts
RUN apk add --no-cache curl unzip

WORKDIR /usr/share/nginx/html

# Download the latest pre-built zip from GitHub
# We use the 'develop' branch artifact as established in install.sh
RUN curl -L https://github.com/PravarHegde/probe-tech-control/raw/develop/probe-tech-control.zip -o ptc.zip && \
    unzip -o ptc.zip && \
    rm ptc.zip

# Copy nginx config from the repo (assumed to be in .docker/)
COPY .docker/nginx.conf /etc/nginx/conf.d/default.conf

# Metadata
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

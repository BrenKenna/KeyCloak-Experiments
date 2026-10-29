# Use latest version of node
FROM node:26.13.0-bookworm-slim


# Plop in code
RUN mkdir -p /opt/simpleServerApp/
COPY dist/simple-servers /opt/simpleServerApp/
COPY supporting/logging/log4j.properties.json /opt/simpleServerApp/supporting/logging/log4j.properties.json
RUN chmod +x /opt/simpleServerApp/simple-servers


# Add app group and user
RUN groupadd --system simple-servers && \
    useradd --system \
        --create-home \
        --home-dir /home/simple-servers \
        --gid simple-servers \
    simple-servers

RUN chown -R simple-servers:simple-servers /home/simple-servers && \
    chown -R simple-servers:simple-servers /opt/simpleServerApp
        

# Set working directory for app
USER simple-servers
WORKDIR /opt/simpleServerApp/
# Use latest version of node
FROM node:20-alpine3.17

# Plop in code
RUN mkdir -p /app/simpleServerApp/
COPY . /app/simpleServerApp/

# Set working directory for app
WORKDIR /app/simpleServerApp/
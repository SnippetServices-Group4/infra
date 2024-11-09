# Start with the official Nginx image
FROM nginx:latest

# Set the build argument for CLOUD_ENVIRONMENT
ARG CLOUD_ENVIRONMENT

# Install dependencies for Lua and Nginx Lua module
RUN apt-get update && \
    apt-get install -y \
    libluajit-5.1-dev \
    lua5.1 \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install the ngx_http_lua_module (if needed)
RUN wget https://github.com/openresty/ngx_http_lua_module/archive/refs/tags/v0.10.19.tar.gz && \
    tar -xzvf v0.10.19.tar.gz && \
    cd ngx_http_lua_module-0.10.19 && \
    wget http://nginx.org/download/nginx-1.22.0.tar.gz && \
    tar -xzvf nginx-1.22.0.tar.gz && \
    cd nginx-1.22.0 && \
    ./configure --add-module=../ngx_http_lua_module-0.10.19 && \
    make && \
    make install

# Copy the correct Nginx config based on the argument
COPY ./nginx/${CLOUD_ENVIRONMENT}-nginx.conf /etc/nginx/nginx.conf

# Copy Lua scripts into the container
COPY ./lua /etc/nginx/lua

# Expose necessary ports
EXPOSE 80 443

# Set the command to run Nginx
CMD ["nginx", "-g", "daemon off;"]

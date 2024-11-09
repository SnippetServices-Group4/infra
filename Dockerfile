# Start from the official Nginx image
FROM nginx:latest

ARG CLOUD_ENVIRONMENT

# Install required dependencies for building Nginx with Lua
RUN apt-get update && \
    apt-get install -y \
    libluajit-5.1-dev \
    lua5.1 \
    wget \
    build-essential \
    libpcre3-dev \
    libssl-dev \
    zlib1g-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install ngx_http_lua_module from OpenResty repository (use stable tag for known working module)
RUN curl -L https://openresty.org/download/ngx_http_lua_module-0.10.19.tar.gz -o ngx_http_lua_module.tar.gz && \
    tar -xzvf ngx_http_lua_module.tar.gz && \
    cd ngx_http_lua_module-0.10.19 && \
    curl -L http://nginx.org/download/nginx-1.22.0.tar.gz -o nginx.tar.gz && \
    tar -xzvf nginx.tar.gz && \
    cd nginx-1.22.0 && \
    ./configure --add-module=../ngx_http_lua_module-0.10.19 && \
    make && \
    make install

# Clean up after installation to reduce image size
RUN rm -rf /ngx_http_lua_module-0.10.19 /nginx-1.22.0

# Copy the Lua files and Nginx configuration into the container
COPY ./nginx/${CLOUD_ENVIRONMENT}-nginx.conf /etc/nginx/nginx.conf
COPY ./lua /etc/nginx/lua

# Expose HTTP and HTTPS ports
EXPOSE 80 443

# Run Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]

# Start with the official Nginx image
FROM nginx:latest

ARG CLOUD_ENVIRONMENT

# Install dependencies for Lua and Nginx Lua module
RUN apt-get update && \
    apt-get install -y \
    libluajit-5.1-dev \
    lua5.1 \
    wget \
    build-essential \
    libpcre3-dev \
    libssl-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Install ngx_http_lua_module from a working version on GitHub
RUN wget https://github.com/openresty/ngx_http_lua_module/archive/refs/tags/v0.10.21.tar.gz && \
    tar -xzvf v0.10.21.tar.gz && \
    cd ngx_http_lua_module-0.10.21 && \
    wget http://nginx.org/download/nginx-1.22.0.tar.gz && \
    tar -xzvf nginx-1.22.0.tar.gz && \
    cd nginx-1.22.0 && \
    ./configure --add-module=../ngx_http_lua_module-0.10.21 && \
    make && \
    make install

# Clean up to reduce image size
RUN rm -rf /ngx_http_lua_module-0.10.21 /nginx-1.22.0

# Copy the Lua files and Nginx config into the container
COPY ./nginx/${CLOUD_ENVIRONMENT}-nginx.conf /etc/nginx/nginx.conf
COPY ./lua /etc/nginx/lua

# Expose necessary ports
EXPOSE 80 443

# Set the command to run Nginx
CMD ["nginx", "-g", "daemon off;"]

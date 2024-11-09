local jwt = require "resty.jwt"
local cjson = require "cjson"

-- Extract token from Authorization header
local token = ngx.var.http_authorization:match("^Bearer%s+(.+)$")
if not token then
    ngx.status = 401
    ngx.say(cjson.encode({ message = "Missing or invalid JWT" }))
    return ngx.exit(ngx.HTTP_UNAUTHORIZED)
end

-- Validate the JWT
local jwt_obj = jwt:verify("your-auth0-public-key", token)
if not jwt_obj.verified then
    ngx.status = 401
    ngx.say(cjson.encode({ message = "Invalid token" }))
    return ngx.exit(ngx.HTTP_UNAUTHORIZED)
end

-- Set headers for User ID and Username
ngx.req.set_header("X-User-ID", jwt_obj.payload.sub)
ngx.req.set_header("X-Username", jwt_obj.payload.nickname)

# mcp.ring - Entry point for the Ring MCP SDK


# Load core dependencies and bootstrap

load "stdlibcore.ring"
load "simplejson.ring"
load "proc.ring"
load "httplib.ring"
load "libcurl.ring"


# Load layers in order
load "schema/schema.ring"
load "protocol/protocol.ring"
load "api/api.ring"
load "transport/transport.ring"
load "middleware/middleware.ring"


fputs(stderr, "Ring MCP SDK Loaded Successfully." + nl)



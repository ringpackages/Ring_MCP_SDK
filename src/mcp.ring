# mcp.ring - Entry point for the Ring MCP SDK

//load "stdlibcore.ring"
# Load core dependencies and bootstrap
load "core/deps.ring"

# Load layers in order
load "schema/schema.ring"
load "protocol/protocol.ring"
load "api/api.ring"
load "transport/transport.ring"
load "middleware/middleware.ring"


fputs(stderr, "Ring MCP SDK Loaded Successfully." + nl)



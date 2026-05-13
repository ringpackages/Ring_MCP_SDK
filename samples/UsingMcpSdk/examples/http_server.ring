load "mcp.ring"

# Create the server
oServer = new MCPServer {
    name    = "http-mcp-server"
    version = "1.0.0"
}

# Register a tool
oServer.tool(new MCPTool {
    name        = "calculate"
    description = "Add two numbers"
    oSchema     = new SchemaBuilder {
        required("a", "number", "First number")
        required("b", "number", "Second number")
    }
    on_call = func(aArgs) {
        result = 0 + aArgs[:a] + aArgs[:b]
        return [[:type = "text", :text = "Result is: " + result]]
    }
})

fputs(stderr, "Starting HTTP MCP Server..." + nl)
fputs(stderr, "Endpoints:" + nl)
fputs(stderr, "  - GET  /        (Info)" + nl)
fputs(stderr, "  - GET  /health  (Status)" + nl)
fputs(stderr, "  - POST /mcp     (JSON-RPC API)" + nl)

# Start the server in HTTP mode (Port 3000)
oServer.start("http")

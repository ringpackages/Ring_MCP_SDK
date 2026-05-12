load "mcp.ring"

# Create server
oServer = new MCPServer {
    name = "Test"
    version = "1.0.0"
}

# Mock request
aReq = [
    :jsonrpc = "2.0",
    :id = 1,
    :method = "initialize",
    :params = [:protocolVersion = "2024-11-05"]
]

# Get router and handle
try
    oRouter = oServer.get_router()
    ? "Router acquired"
    aRes = oRouter.handle_message(oServer, aReq)
    ? "Result: " 
    ? aRes
catch
    ? "Caught error: " + cCatchError
done

load "mcp.ring"

# Create the server
oServer = new MCPServer {
    name    = "hello-server"
    version = "1.0.0"
}

# Register a tool
oServer.tool(new MCPTool {
    name        = "greet"
    description = "Greet a user"
    oSchema     = new SchemaBuilder {
        required("name", "string", "User name")
    }
    on_call = func(aArgs) {
        return [[:type = "text", :text = "Hello, " + aArgs[:name] + "!"]]
    }
})

# Add a simple resource
oServer.resource(new MCPResource {
    uri      = "mcp://hello/config"
    name     = "Configuration"
    mimeType = "application/json"
    reader = func(cUri) {
        return '{ "status": "active" }'
    }
})

# Add a prompt
oServer.prompt(new MCPPrompt {
    name        = "hello_prompt"
    description = "A simple prompt"
    builder = func(aArgs) {
        return [[:type = "text", :text = "Hello, " + aArgs[:name] + "!"]]
    }
})



fputs(stderr, "Hello MCP Server is ready (stdio mode)" + nl)

# Start the server
oServer.start("stdio")

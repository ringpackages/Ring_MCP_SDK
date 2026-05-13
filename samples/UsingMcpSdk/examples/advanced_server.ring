load "mcp.ring"

oServer = new MCPServer {
    name    = "advanced-ring-server"
    version = "2.0.0"
}

# 1. Add a dynamic tool that logs its work
oServer.tool(new MCPTool {
    name        = "process_data"
    description = "A tool that shows off logging and notifications"
    oSchema     = new SchemaBuilder {
        required("input", "string", "Data to process")
    }
    on_call = func(aArgs) {
        # Sending a log to the client
        oServer.log("info", "Starting to process: " + aArgs[:input])
        
        # We can also notify the client about a change
        oServer.notify("notifications/progress", [:progress = 50])
        
        return [[:type = "text", :text = "Processed: " + aArgs[:input]]]
    }
})

# 2. Show the auto-generated documentation
fputs(stderr, "--- AUTO-GENERATED DOCUMENTATION ---" + nl)
fputs(stderr, oServer.docs() + nl)
fputs(stderr, "---------------------------------------" + nl)

# 3. Start the server (using stdio for this example)
fputs(stderr, "Advanced Server is running..." + nl)
oServer.start("stdio")

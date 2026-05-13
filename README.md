# Ring MCP SDK 💍

A high-performance, professional implementation of the **Model Context Protocol (MCP)** for the **Ring Programming Language**. This SDK allows you to build MCP servers that can connect to AI clients like Claude, providing them with tools, resources, and prompts.

## 🚀 Features

- **Multi-Transport Support**: Stdio, HTTP (via Bolt), and SSE.
- **Layered Architecture**: Clean 6-layer design for maximum maintainability.
- **Advanced Capabilities**:
    - **Logging**: Send real-time logs to the client.
    - **Notifications**: Server-initiated updates (e.g., `listChanged`).
    - **Sampling**: Request AI completions from the client.
    - **Auto-Documentation**: Generate Markdown docs for your server with one call.
- **Schema Validation**: Built-in JSON Schema builder and validator for tool arguments.

## 🏗 Architecture

The SDK is built using a professional 6-layer approach:
1. **Developer API**: High-level classes (`MCPServer`, `MCPTool`).
2. **Schema Engine**: Parameter validation and schema generation.
3. **Protocol Engine**: JSON-RPC 2.0 routing and lifecycle management.
4. **Transport Layer**: Stdio, HTTP, and SSE handlers.
5. **Middleware**: Chained logic for logging and error handling.
6. **Core**: Dependency management and bootstrap.

---

## Dependencies

All installed via RingPM:

```ring
ringpm install simplejson from ysdragon       # JSON support
ringpm install bolt       from ysdragon       # HTTP transport
```
---
## 📦 Installation

via RingPM:

```ring
ringpm install Ring_MCP_SDK from Azzeddine2017
```

## 🛠 Quick Start (Stdio)

```ring
load "mcp.ring"

oServer = new MCPServer {
    name    = "my-mcp-server"
    version = "1.0.0"
}

oServer.tool(new MCPTool {
    name        = "hello"
    description = "A simple tool"
    oSchema     = new SchemaBuilder {
        required("name", "string", "User name")
    }
    on_call = func(aArgs) {
        return [[:type = "text", :text = "Hello " + aArgs[:name]]]
    }
})

oServer.start("stdio")
```

## 🌐 Web Support (HTTP & SSE)

Using the high-performance **Bolt** framework:

# Start the server in HTTP mode (Port 3000)
```ring
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
```

# Start as an SSE server
```ring
oServer.start("sse")
```
## 📝 Auto-Generated Documentation

Generate a full documentation of your server's capabilities instantly:

```ring
fputs(stderr, oServer.docs() + nl)
```

## 📂 Project Structure

- `src/`: Core implementation organized by layers.
- `tests/`: Unit tests for each layer.
- `examples/`: Ready-to-run examples:
    - `hello_server.ring`: Basic Stdio server.
    - `http_server.ring`: Web-based MCP server.
    - `advanced_server.ring`: Shows logging and notifications.
    - `ring_expert_server.ring`: A powerful AI assistant for Ring developers.


## 📄 License
This project is licensed under the MIT License.

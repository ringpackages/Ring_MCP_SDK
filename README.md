# 💍 Ring MCP SDK

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ring Version](https://img.shields.io/badge/Ring-1.21-blue.svg)](https://ring-lang.github.io/)
[![MCP Version](https://img.shields.io/badge/MCP-1.0.0-green.svg)](https://modelcontextprotocol.io/)

A high-performance, professional-grade implementation of the **Model Context Protocol (MCP)** for the **Ring Programming Language**. This SDK empowers developers to build sophisticated MCP servers that seamlessly connect AI models (like Claude) with custom tools, resources, and prompts.

---

## ✨ Key Features

- **🚀 Multi-Transport Mastery**: Seamlessly switch between **Stdio**, **HTTP** (powered by Bolt), and **SSE**.
- **🏗️ 6-Layer Architecture**: Engineered for maximum maintainability and scalability.
- **⚡ Advanced Capabilities**:
    - **Real-time Logging**: Stream server logs directly to AI clients.
    - **Smart Notifications**: Server-initiated updates (e.g., `listChanged`).
    - **AI Sampling**: Dynamically request completions from the client.
    - **Instant Documentation**: Generate comprehensive Markdown docs with a single call.
- **🛡️ Schema Safety**: Built-in JSON Schema builder and validator for robust tool interaction.

---

## 🏛️ Architecture & Design

The SDK follows a strict **Professional 6-Layer Design**:

1.  **Developer API**: High-level intuitive classes (`MCPServer`, `MCPTool`).
2.  **Schema Engine**: Intelligent parameter validation and schema generation.
3.  **Protocol Engine**: Full JSON-RPC 2.0 routing and lifecycle management.
4.  **Transport Layer**: High-performance handlers for Stdio, HTTP, and SSE.
5.  **Middleware Layer**: Chained logic for logging, error handling, and security.
6.  **Core Foundation**: Dependency management and system bootstrap.

---

## 📦 Installation

Install the SDK instantly via **RingPM**:

```bash
ringpm install Ring_MCP_SDK from Azzeddine2017
```

### 📋 Dependencies
The SDK leverages these high-quality packages:
- `simplejson`: Ultra-fast JSON processing.
- `bolt`: High-performance HTTP framework for Ring.

---

## 🚀 Quick Start: Stdio Mode

Create a functional MCP server in seconds:

```ring
load "mcp.ring"

oServer = new MCPServer {
    name    = "ring-explorer"
    version = "1.0.0"
}

# Define a professional tool
oServer.tool(new MCPTool {
    name        = "greet"
    description = "Greets a user with a personalized message"
    oSchema     = new SchemaBuilder {
        required("name", "string", "The name of the person to greet")
    }
    on_call = func(aArgs) {
        return [[:type = "text", :text = "Hello, " + aArgs[:name] + "! Welcome to Ring MCP."]]
    }
})

# Launch the server
oServer.start("stdio")
```

---

## 🌐 Enterprise Web Support (HTTP & SSE)

Leverage the power of the **Bolt** framework for web-scale deployments:

### HTTP Implementation
```ring
oServer = new MCPServer { name = "web-mcp", version = "1.0.0" }

# ... define tools ...

# Start on default port 3000
oServer.start("http")
```

### SSE Implementation
```ring
# Low-latency Server-Sent Events support
oServer.start("sse")
```

---

## 📂 Project Structure & Examples

Explore our curated examples to jumpstart your development:

- `src/`: Core implementation organized by architectural layers.
- `samples/`: Real-world implementation references:
    - [**Ring Pro Example**](samples/UsingMcpSdk/examples/ring_pro/): A professional AI assistant with search and code execution.
    - `hello_server.ring`: Minimalist Stdio implementation.
    - `http_server.ring`: Full-featured Web-based MCP server.
    - `advanced_server.ring`: Demonstrates logging and complex notifications.

---

## 📝 Auto-Generated Documentation

Keep your documentation perfectly synced with your code. The SDK can generate a complete manual of your server's capabilities on the fly:

```ring
# Print full markdown documentation to stderr
fputs(stderr, oServer.docs() + nl)
```

---

## 📄 License

This project is licensed under the **MIT License**. Built with ❤️ for the Ring community.

---
**Developed by [Azzeddine2017](https://github.com/Azzeddine2017)**

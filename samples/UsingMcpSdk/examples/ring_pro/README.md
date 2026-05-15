# 🚀 Ring MCP Pro: Advanced AI Developer Assistant

[![Example](https://img.shields.io/badge/Reference-Professional-blue.svg)](https://ring-lang.github.io/)
[![Protocol](https://img.shields.io/badge/MCP-Protocol-orange.svg)](https://modelcontextprotocol.io/)

This is a **Production-Grade** example of an MCP server implemented using the Ring MCP SDK. It serves as a specialized AI assistant designed to help developers navigate, debug, and execute code within the **Ring Programming Language** ecosystem.

---

## 🛠️ Intelligent Toolset

The server exposes four primary tools designed for deep AI integration:

| Tool | Description | Use Case |
| :--- | :--- | :--- |
| `search` | **Universal Search** | Find keywords, functions, or aliases in the Ring documentation. |
| `run_code` | **Safe Execution** | Run Ring code snippets in a sandbox and capture the output. |
| `explain_error` | **Error Diagnostics** | Get detailed explanations and solutions for Ring compiler/runtime errors. |
| `get_grammar` | **Syntax Reference** | Retrieve official grammar rules for specific language constructs. |

---

## ⚙️ Configuration & Installation

To integrate this professional assistant into your MCP environment (like **Claude Desktop** or **Antigravity**), add the following entry to your `mcp_config.json` file:

```json
{
  "mcpServers": {
    "ring-mcp": {
      "command": "ring",
      "args": [
        "C:/ring/samples/UsingMcpSdk/examples/ring_pro/main.ring"
      ],
      "disabledTools": [],
      "disabled": false
    }
  }
}
```

> [!CAUTION]
> **Path Accuracy**: Ensure the path in the `args` array correctly points to the `main.ring` file on your system.

---

## 🏗️ Technical Highlights

- **Logic Separation**: The server uses a clean separation between the entry point (`main.ring`), business logic (`logic.ring`), and data sources (`database.ring`).
- **Dynamic Help System**: Powered by an internal database for instant documentation retrieval.
- **Protocol Compliant**: Fully supports JSON-RPC 2.0 and MCP lifecycle events.

---

## 🌐 Web & Distributed Architecture

Ring Pro isn't just a standard Stdio server; it demonstrates the **distributed capabilities** of the Ring MCP SDK.



### The Bolt-Powered Web Server
`web_server.ring` transforms the Ring Pro logic into a high-performance web service:
- Exposes tools over **HTTP POST** on port `3000`.
- Utilizes the Bolt web framework for routing and JSON parsing.

To run the web server:
```bash
ring web_server.ring
```

### The LibCurl-Powered Web Client

```json
{
    "clientName": "RingProExplorer",
    "version": "1.0.0",
    "transport": {
        "type": "http",
        "url": "http://localhost:3000/mcp"
    }
}
```

`web_client.ring` demonstrates how to consume the web server using a dedicated **MCP Client**:
- Connects to the server using the `HttpClientTransport`.
- Uses `ref()` mechanics to safely track pending requests.
- Maps server responses to class-based `callback` functions asynchronously.

To run the web client (ensure the web server is running first):
```bash
ring web_client.ring
```


---
*Built as part of the Ring MCP SDK Examples.*

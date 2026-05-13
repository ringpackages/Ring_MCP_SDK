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
*Built as part of the Ring MCP SDK Examples.*

load "mcp.ring"
load "g:/Ring_MCP_SDK/examples/ring_pro/logic.ring"

oServer = new MCPServer { name = "Test" version = "1.0.0" }
oServer.get_session().bInitialized = "__BOOL_TRUE__"
oLogic = new RingProLogic

oServer.tool(new MCPTool {
    name = "search"
    on_call = func(aArgs) {
        return [[:type = "text", :text = oLogic.find_help(aArgs[:query])]]
    }
})

aParams = [:name = "search", :arguments = [:query = "for"]]
aMsg = [:jsonrpc = "2.0", :id = 1, :method = "tools/call", :params = aParams]

? "Simulating Tool Call..."
aRes = oServer.get_router().handle_message(oServer, aMsg)
? "Response: " + json_encode(aRes)

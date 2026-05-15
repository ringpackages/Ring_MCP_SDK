# ==========================================================
# Ring Pro - Advanced Web Client (LibCurl Powered)
# ==========================================================

load "mcp.ring"

# 1. Create and Configure the Client
oClient = new MCPClient
if not oClient.load_config("client_config.json")
    see "Error: Failed to load client configuration!" + nl
    return
ok

see "==================================================" + nl
see "   RING PRO WEB CLIENT (LibCurl Powered)" + nl
see "==================================================" + nl

# 3. Initialize Connection
see "Initializing connection to server..." + nl
oClient.initialize()
see "Connection established." + nl + nl
# 4. Action: Call Search Tool
see ">> Searching for 'class' keyword..." + nl
nId = oClient.nNextRequestId
oClient.nNextRequestId++
oClient.add_pending_request(new MCPHandler { id = nId })
aMsg = oClient.get_router().request(nId, "tools/call", [:name = "search", :arguments = [:query = "class"]])
oClient.send_message(aMsg)

# 5. Action: Call Grammar Tool
see nl + ">> Getting grammar for 'for' loop..." + nl
nId = oClient.nNextRequestId
oClient.nNextRequestId++
oClient.add_pending_request(new MCPHandler { id = nId })
aMsg = oClient.get_router().request(nId, "tools/call", [:name = "get_grammar", :arguments = [:subject = "for"]])
oClient.send_message(aMsg)

# 6. Action: Read Resource
see nl + ">> Reading keywords specification..." + nl
nId = oClient.nNextRequestId
oClient.nNextRequestId++
oClient.add_pending_request(new MCPHandler { id = nId, cType = "resource" })
aMsg = oClient.get_router().request(nId, "resources/read", [:uri = "mcp://ring/spec/keywords"])
oClient.send_message(aMsg)

see nl + ">> All requests sent. Awaiting responses..." + nl

# We define a callback handler for the responses
class MCPHandler
    id
    cType = "tool" # "tool" or "resource"
    func callback aRes
        see nl + "========================================" + nl
        see "         RESPONSE RECEIVED (ID=" + id + ")" + nl
        see "========================================" + nl
        try
            if cType = "tool"
                see aRes[:result][:content][1][:text] + nl
            else # resource
                see aRes[:result][:contents][1][:text] + nl
            ok
        catch
            see "Error: Could not parse result." + nl
            see json_encode(aRes) + nl
        done
        see "========================================" + nl
    
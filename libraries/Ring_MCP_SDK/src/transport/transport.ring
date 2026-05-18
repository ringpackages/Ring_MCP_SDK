

$mcp_server = null
$mcp_http = null
$mcp_sse_http = null
$mcp_sse_messages = null
$mcp_stream_http = null
$mcp_stream_outbox = null

func mcp_json_encode aMsg
    cJson = json_encode(aMsg)
    # Global replacement for Booleans
    while substr(cJson, '"__BOOL_TRUE__"') > 0
        cJson = substr(cJson, '"__BOOL_TRUE__"', "true")
    end
    while substr(cJson, '"__BOOL_FALSE__"') > 0
        cJson = substr(cJson, '"__BOOL_FALSE__"', "false")
    end
    # Fix case-sensitivity for MCP keys (SimpleJSON lowercase fix)
    while substr(cJson, '"protocolversion"') > 0
        cJson = substr(cJson, '"protocolversion"', '"protocolVersion"')
    end
    while substr(cJson, '"serverinfo"') > 0
        cJson = substr(cJson, '"serverinfo"', '"serverInfo"')
    end
    while substr(cJson, '"listchanged"') > 0
        cJson = substr(cJson, '"listchanged"', '"listChanged"')
    end
    while substr(cJson, '"mimetype"') > 0
        cJson = substr(cJson, '"mimetype"', '"mimeType"')
    end
    while substr(cJson, '"clientinfo"') > 0
        cJson = substr(cJson, '"clientinfo"', '"clientInfo"')
    end
    while substr(cJson, '"inputschema"') > 0
        cJson = substr(cJson, '"inputschema"', '"inputSchema"')
    end
    return cJson
# HTTP handlers for Ring Server
# When you call oServer.start("http", 3000)
# It will create an HTTP server that listens for:
#   GET  /info - Server information
#   GET  /health - Health check
#   POST /mcp - MCP JSON-RPC endpoint
# 
func _http_cors_preflight
    $mcp_http.response().set_header("Access-Control-Allow-Origin", "*")
    $mcp_http.response().set_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
    $mcp_http.response().set_header("Access-Control-Allow-Headers", "Content-Type, Authorization")
    $mcp_http.setStatus(204)
    $mcp_http.setContent("", "text/plain")

func _http_info
    $mcp_http.response().set_header("Access-Control-Allow-Origin", "*")
    aInfo = [
        :name    = $mcp_server.name,
        :version = $mcp_server.version,
        :mcp     = "2024-11-05"
    ]
    $mcp_http.setContent(mcp_json_encode(aInfo), "application/json")

func _http_health
    $mcp_http.response().set_header("Access-Control-Allow-Origin", "*")
    $mcp_http.setContent('{"status":"ok"}', "application/json")

func _http_mcp_post
    $mcp_http.response().set_header("Access-Control-Allow-Origin", "*")
    # Get the raw JSON body from the POST request
    cBody = $mcp_http.request().body()

    ? "[MCP-HTTP] POST /mcp - Body: " + cBody

    try
        aMsg = json_decode(cBody)
        aRes = $mcp_server.get_router().handle_message($mcp_server, aMsg)
        if not isnull(aRes)
            $mcp_http.setContent(mcp_json_encode(aRes), "application/json")
        else
            $mcp_http.setContent('{"jsonrpc":"2.0","result":"ok"}', "application/json")
        ok
    catch
        ? "[MCP-HTTP] Error: " + cCatchError
        $mcp_http.setStatus(400)
        cErr = '{"jsonrpc":"2.0","error":{"code":-32700,"message":"Parse error"}}'
        $mcp_http.setContent(cErr, "application/json")
    done



# SSE handlers
# 
func _sse_cors_preflight
    $mcp_sse_http.response().set_header("Access-Control-Allow-Origin", "*")
    $mcp_sse_http.response().set_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
    $mcp_sse_http.response().set_header("Access-Control-Allow-Headers", "Content-Type, Authorization, Cache-Control")
    $mcp_sse_http.setStatus(204)
    $mcp_sse_http.setContent("", "text/plain")

func _sse_stream
    # Return queued SSE events and the endpoint URL
    $mcp_sse_http.response().set_header("Access-Control-Allow-Origin", "*")
    $mcp_sse_http.response().set_header("Cache-Control", "no-cache")

    # Build SSE response with endpoint info and any pending messages
    cSseData = "data: " + '{"endpoint":"/mcp"}' + nl + nl

    # Flush any queued messages
    for cMsg in $mcp_sse_messages
        cSseData += "event: message" + nl
        cSseData += "data: " + cMsg + nl + nl
    next

    # Clear sent messages
    while len($mcp_sse_messages) > 0
        del($mcp_sse_messages, 1)
    end

    $mcp_sse_http.setContent(cSseData, "text/event-stream")

func _sse_mcp_post
    $mcp_sse_http.response().set_header("Access-Control-Allow-Origin", "*")
    cBody = $mcp_sse_http.request().body()

    ? "[MCP-SSE] POST /mcp - Body: " + cBody

    try
        aMsg = json_decode(cBody)
        aRes = $mcp_server.get_router().handle_message($mcp_server, aMsg)
        if not isnull(aRes)
            $mcp_sse_http.setContent(mcp_json_encode(aRes), "application/json")
        else
            $mcp_sse_http.setContent('{"jsonrpc":"2.0","result":"ok"}', "application/json")
        ok
    catch
        ? "[MCP-SSE] Error: " + cCatchError
        $mcp_sse_http.setStatus(400)
        cErr = '{"jsonrpc":"2.0","error":{"code":-32700,"message":"Parse error"}}'
        $mcp_sse_http.setContent(cErr, "application/json")
    done

# Stream handlers
func _stream_cors_preflight
    $mcp_stream_http.response().set_header("Access-Control-Allow-Origin", "*")
    $mcp_stream_http.response().set_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
    $mcp_stream_http.response().set_header("Access-Control-Allow-Headers", "Content-Type, Authorization")
    $mcp_stream_http.setStatus(204)
    $mcp_stream_http.setContent("", "text/plain")

func _stream_poll
    $mcp_stream_http.response().set_header("Access-Control-Allow-Origin", "*")

    # Build JSON array of queued messages
    cResult = "["
    for i = 1 to len($mcp_stream_outbox)
        if i > 1 cResult += "," ok
        cResult += $mcp_stream_outbox[i]
    next
    cResult += "]"

    # Clear the outbox after sending
    while len($mcp_stream_outbox) > 0
        del($mcp_stream_outbox, 1)
    end

    $mcp_stream_http.setContent(cResult, "application/json")

func _stream_mcp_post
    $mcp_stream_http.response().set_header("Access-Control-Allow-Origin", "*")
    cBody = $mcp_stream_http.request().body()

    ? "[MCP-Stream] POST /mcp - Body: " + cBody

    try
        aMsg = json_decode(cBody)
        aRes = $mcp_server.get_router().handle_message($mcp_server, aMsg)
        if not isnull(aRes)
            $mcp_stream_http.setContent(mcp_json_encode(aRes), "application/json")
        else
            $mcp_stream_http.setContent('{"jsonrpc":"2.0","result":"ok"}', "application/json")
        ok
    catch
        ? "[MCP-Stream] Error: " + cCatchError
        $mcp_stream_http.setStatus(400)
        cErr = '{"jsonrpc":"2.0","error":{"code":-32700,"message":"Parse error"}}'
        $mcp_stream_http.setContent(cErr, "application/json")
    done

class StdioTransport

    func run oServer
        while true
            cLine = ""
            give cLine
            if len(cLine) = 0 exit ok
            cLine = trim(cLine)
            if cLine = "" loop ok
            
            try
                aMsg = json_decode(cLine)
            catch
                # Skip invalid JSON silently to avoid polluting the stream
                loop
            done
            
            try
                aRes = oServer.get_router().handle_message(oServer, aMsg)
                if not isnull(aRes)
                    fputs(stdout, mcp_json_encode(aRes) + nl)
                    fflush(stdout)
                ok
            catch
                fputs(stderr, "Error handling message: " + cCatchError + nl)
            done
        end

    func send aMsg
        fputs(stdout, mcp_json_encode(aMsg) + nl)
        fflush(stdout)


class HttpTransport
    oHttpServer = null
    nPort = 3000

    func run oServer
        oHttpServer = new Server

        ? "[MCP-HTTP] Starting HTTP transport on port " + nPort
        ? "[MCP-HTTP] Endpoints:"
        ? "  GET  /info   - Server information"
        ? "  GET  /health - Health check"
        ? "  POST /mcp    - MCP JSON-RPC endpoint"

        # --- CORS preflight for /mcp ---
        oHttpServer.route(:Options, "/mcp", :_http_cors_preflight)

        # --- GET /info ---
        oHttpServer.route(:Get, "/info", :_http_info)

        # --- GET /health ---
        oHttpServer.route(:Get, "/health", :_http_health)

        # --- POST /mcp ---
        oHttpServer.route(:Post, "/mcp", :_http_mcp_post)

        # Store server reference globally for route callbacks
        $mcp_server = ref(oServer)
        $mcp_http   = ref(oHttpServer)

        ? "[MCP-HTTP] Listening on 0.0.0.0:" + nPort
        oHttpServer.listen("0.0.0.0", nPort)




class SseTransport
    oHttpServer = null
    nPort = 3001
    aSseMessages = []

    func run oServer
        oHttpServer = new Server

        ? "[MCP-SSE] Starting SSE transport on port " + nPort
        ? "[MCP-SSE] Endpoints:"
        ? "  GET  /sse    - SSE event stream"
        ? "  POST /mcp    - MCP JSON-RPC endpoint"

        # Store references globally for route callbacks
        $mcp_server      = ref(oServer)
        $mcp_sse_http    = ref(oHttpServer)
        $mcp_sse_messages = ref(aSseMessages)

        # --- CORS preflight ---
        oHttpServer.route(:Options, "/mcp", :_sse_cors_preflight)
        oHttpServer.route(:Options, "/sse", :_sse_cors_preflight)

        # --- GET /sse - SSE stream endpoint ---
        # Clients connect here to receive server-sent events
        oHttpServer.route(:Get, "/sse", :_sse_stream)

        # --- POST /mcp - JSON-RPC endpoint ---
        oHttpServer.route(:Post, "/mcp", :_sse_mcp_post)

        ? "[MCP-SSE] Listening on 0.0.0.0:" + nPort
        oHttpServer.listen("0.0.0.0", nPort)

    func send aMsg
        # Queue message for SSE delivery
        cJson = mcp_json_encode(aMsg)
        add(aSseMessages, cJson)





class StreamTransport
    # Long-polling based bidirectional transport (replacement for WebSocket)
    # Clients POST to /mcp for requests, GET /mcp/stream to poll for server-pushed messages
    oHttpServer = null
    nPort = 3002
    aOutbox = []

    func run oServer
        oHttpServer = new Server

        ? "[MCP-Stream] Starting Stream transport on port " + nPort
        ? "[MCP-Stream] Endpoints:"
        ? "  GET  /mcp/stream - Poll for server messages"
        ? "  POST /mcp        - MCP JSON-RPC endpoint"

        # Store references globally for route callbacks
        $mcp_server       = ref(oServer)
        $mcp_stream_http  = ref(oHttpServer)
        $mcp_stream_outbox = ref(aOutbox)

        # --- CORS preflight ---
        oHttpServer.route(:Options, "/mcp", :_stream_cors_preflight)
        oHttpServer.route(:Options, "/mcp/stream", :_stream_cors_preflight)

        # --- GET /mcp/stream - Poll for queued server messages ---
        oHttpServer.route(:Get, "/mcp/stream", :_stream_poll)

        # --- POST /mcp - JSON-RPC endpoint ---
        oHttpServer.route(:Post, "/mcp", :_stream_mcp_post)

        ? "[MCP-Stream] Listening on 0.0.0.0:" + nPort
        oHttpServer.listen("0.0.0.0", nPort)

    func send aMsg
        # Queue message for client to pick up via polling
        cJson = mcp_json_encode(aMsg)
        add(aOutbox, cJson)





class StdioClientTransport
    Command = ""
    Args = NULL
    Client = NULL
    oProcess = null
    cBuffer = ""
    
    func run rClient
        self.Client = ref(rClient)

        # 1. Initialize process
        if isnull(oProcess)
            aCmdLine = [Command]
            if not isnull(Args)
                for arg in Args
                    Add(aCmdLine, arg)
                next
            ok
            # Ring uses + or bitwiseor() for flags, | is logical OR and returns 1
            nOptions = PROC_SEARCH_USER_PATH + PROC_COMBINED_STDOUT_STDERR + PROC_ENABLE_ASYNC
            oProcess = new Process(aCmdLine, nOptions) 
        ok
        return self

    func get_id aList
        if islist(aList)
            for item in aList
                if islist(item) and len(item) >= 2 and item[1] = "id"
                    return item[2]
                ok
            next
        ok
        return NULL

    func send aMsg
        if isnull(oProcess) return ok
        
        # Write to process stdin
        cJson = mcp_json_encode(aMsg)
        oProcess.writeLine(cJson)
        
        nMsgId = get_id(aMsg)
        
        if isnull(nMsgId)
            processPendingOutput()
            return 
        ok
        
        # Wait for response
        nWait = 0
        while nWait < 1000 # 10 seconds max
            cData = oProcess.readStdout(4096)
            if cData != NULL and len(cData) > 0
                cBuffer += cData
            ok
            
            while true
                nLineEnd = substr(cBuffer, nl)
                if nLineEnd = 0 break ok
                
                cLine = left(cBuffer, nLineEnd - 1)
                cBuffer = substr(cBuffer, nLineEnd + len(nl))
                
                cLine = trim(cLine)
                if cLine = "" loop ok
                
                try
                    aRes = json_decode(cLine)
                    Client.get_router().handle_message(Client, aRes)
                    
                    nResId = get_id(aRes)
                    if not isnull(nResId) and not isnull(nMsgId) and string(nResId) = string(nMsgId)
                        return # Found response
                    ok
                catch 
                    # Ignore invalid JSON
                done
            end
            
            sleep(0.01)
            nWait++
        end

    func processPendingOutput
        cData = oProcess.readStdout(4096)
        if cData != NULL and len(cData) > 0
            cBuffer += cData
        ok
        while true
            nLineEnd = substr(cBuffer, nl)
            if nLineEnd = 0 break ok
            cLine = left(cBuffer, nLineEnd - 1)
            cBuffer = substr(cBuffer, nLineEnd + len(nl))
            cLine = trim(cLine)
            if cLine = "" loop ok
            
            try
                aRes = json_decode(cLine)
                Client.get_router().handle_message(Client, aRes)
            catch done
        end

class HttpClientTransport
    Url = "http://localhost:3000/mcp"
    Client 

    func run rClient
        self.Client = ref(rClient)
        return self

    func send aMsg
        load "libcurl.ring"
        curl = curl_easy_init()
        
        cPostData = mcp_json_encode(aMsg)
        
        curl_easy_setopt(curl, CURLOPT_URL, self.Url)
        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, cPostData)
        curl_easy_setopt(curl, CURLOPT_USERAGENT, "RingMCPClient/1.0")
        
        cResponse = curl_easy_perform_silent(curl)
        if cResponse != NULL
            try
                aRes = json_decode(cResponse)
                Client.get_router().handle_message(Client, aRes)
            catch
                # Silently handle invalid JSON or callback errors to avoid disrupting the client flow,
                see "Error handling message: " + cCatchError + nl
            done
        ok
        
        curl_easy_cleanup(curl)

    func set_url Url
        self.Url = Url
    


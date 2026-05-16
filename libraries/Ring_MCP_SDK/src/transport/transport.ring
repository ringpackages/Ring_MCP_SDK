

aRes = null

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
    
    func run oServer
        new Bolt() {
            port = 3000
            enableCors()
            enableLogging()
            homepage() # Automatic homepage with server info
            
            @before(func {
                # Logging middleware using Bolt's logger
                $bolt.log("[MCP-HTTP] " + $bolt.method() + " " + $bolt.path())
            })

            @get("/info", func {
                $bolt.json([
                    :name    = oServer.name,
                    :version = oServer.version,
                    :mcp     = "2024-11-05"
                ])
            })

            @get("/health", func {
                $bolt.json([:status = "ok"])
            })

            @post("/mcp", func {
                aMsg = $bolt.jsonBody()
                aRes = oServer.get_router().handle_message(oServer, aMsg)
                if not isnull(aRes)
                    $bolt.json(aRes)
                else
                    $bolt.json([:jsonrpc = "2.0", :result = "ok"])
                ok
            })
        }

class SseTransport
    oBolt = null

    func run oServer
        oTransport = self
        new Bolt() {
            oTransport.oBolt = self
            port = 3001 
            enableCors()
            
            @sse("/sse")

            @post("/mcp", func {
                aMsg = $bolt.jsonBody()
                aRes = oServer.get_router().handle_message(oServer, aMsg)
                if not isnull(aRes)
                    $bolt.json(aRes)
                else
                    $bolt.json([:jsonrpc = "2.0", :result = "ok"])
                ok
            })
        }

    func send aMsg
        if not isnull(oBolt)
            oBolt.sseBroadcast("/sse", mcp_json_encode(aMsg))
        ok

class WebSocketTransport
    oBolt = null

    func run oServer
        oTransport = self
        new Bolt() {
            oTransport.oBolt = self
            port = 3002
            enableCors()

            @ws("/mcp",
                func { # onConnect
                    $bolt.wsSend("Connected to Ring MCP WebSocket")
                },
                func { # onMessage
                    cMsg = $bolt.wsEventMessage()
                    aMsg = json_decode(cMsg)
                    aRes = oServer.get_router().handle_message(oServer, aMsg)
                    if not isnull(aRes)
                        $bolt.wsSend(mcp_json_encode(aRes))
                    ok
                },
                func { # onDisconnect
                }
            )
        }

    func send aMsg
        if not isnull(oBolt)
            oBolt.wsBroadcast(mcp_json_encode(aMsg))
        ok

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
        
        curl_easy_setopt(curl, CURLOPT_URL, Url)
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


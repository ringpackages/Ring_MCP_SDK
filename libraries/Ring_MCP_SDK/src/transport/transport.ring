load "bolt.ring"
 
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
            
            @get("/", func {
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
    func run oServer
        new Bolt() {
            port = 3001 # Different port for SSE to avoid conflict if both run
            
            @get("/sse", func {
                $bolt.sse(func {
                    # This keeps the connection open for server-to-client notifications
                    # In a full implementation, we would register this client in the session
                })
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

    func send aMsg
       see mcp_json_encode(aMsg) + nl
        




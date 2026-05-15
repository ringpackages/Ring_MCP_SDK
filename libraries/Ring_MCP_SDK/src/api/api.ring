# Layer 1: Developer API
# Defines the main classes for building MCP servers

class MCPServer
    name = "" 
    version = "1.0.0"
    aTools = [] 
    aResources = [] 
    aPrompts = []
    aMiddleware = []
    oTransport = null
    oRouter = null
    oSession = null
    nNextRequestId = 1

    func init
        # Initialized when the server is created
        return self

    func get_router
        if isnull(oRouter)
            get_session()
            oRouter = new MessageRouter
        ok
        return oRouter


    func get_session
        if isnull(oSession)
            oSession = new SessionManager
        ok
        return oSession

    func tool oTool
        add(aTools, oTool)

    func resource oRes
        add(aResources, oRes)

    func prompt oPrompt
        add(aPrompts, oPrompt)

    func use oMiddleware
        add(aMiddleware, oMiddleware)

    func log cLevel, cMessage
        aMsg = oRouter.notify("notifications/message", [:level = cLevel, :message = cMessage])
        send_message(aMsg)

    func notify cMethod, aParams
        aMsg = oRouter.notify(cMethod, aParams)
        send_message(aMsg)

    func sample aParams
        nId = nNextRequestId    
        nNextRequestId += 1
        aMsg = oRouter.request(nId, "sampling/createMessage", aParams)
        send_message(aMsg)

    func send_message aMsg
        if not isnull(self.oTransport)
            if isobject(self.oTransport) and ismethod(self.oTransport, "send")
                self.oTransport.send(aMsg)
            else
               fputs(stdout, json_encode(aMsg) + nl)
            ok
        ok

    func docs
        cDocs = "# MCP Server: " + name + " (v" + version + ")" + nl + nl
        cDocs += "## Tools" + nl
        for oTool in aTools
            cDocs += "* **" + oTool.name + "**: " + oTool.description + nl
        next
        cDocs += nl + "## Resources" + nl
        for oRes in aResources
            cDocs += "* **" + oRes.name + "**: " + oRes.uri + nl
        next
        return cDocs



    func start cMode
        if isnull(cMode) cMode = "stdio" ok
        
        # Select transport based on mode
        # (Transports will be implemented in Layer 4)
        switch cMode
            on "stdio"
                self.oTransport = new StdioTransport
                self.oTransport.run(this)
            on "http"
                self.oTransport = new HttpTransport
                self.oTransport.run(this)
            on "sse"
                self.oTransport = new SseTransport
                self.oTransport.run(this)
            on "ws"
                self.oTransport = new WebSocketTransport
                self.oTransport.run(this)
        off


class MCPClient
    name = "RingMCPClient"
    version = "1.0.0"
    oTransport = null
    oRouter = null
    oSession = null
    nNextRequestId = 1
    aPendingRequests = [] # [id, callback]

    func init
        aPendingRequests = []
        return self

    func load_config cFileName
        if not fexists(cFileName)
            return false
        ok
        
        cContent = read(cFileName)
        try
            aConfig = json_decode(cContent)
            
            try self.name = aConfig[:clientName] catch done
            try self.version = aConfig[:version] catch done
            
            try 
                aTrans = aConfig[:transport]
                if aTrans[:type] = "http"
                    self.oTransport = new HttpClientTransport {
                        Url = aTrans[:url]
                    }
                    self.oTransport.run(self)
                ok
            catch done
            
            return true
        catch
            return false
        done

    func get_router
        if isnull(oRouter)
            oRouter = new MessageRouter
        ok
        return oRouter

    func send_request cMethod, aParams
        nId = nNextRequestId
        nNextRequestId++
        aMsg = get_router().request(nId, cMethod, aParams)
        send_message(aMsg)
        return nId

    func send_message aMsg
        if not isnull(oTransport)
            oTransport.send(aMsg)
        ok

    func add_pending_request oReq
        add(aPendingRequests, oReq)

    func handle_response vId, aMsg
        for i = 1 to len(aPendingRequests)
            oReq = aPendingRequests[i]
            if oReq.id = vId
                if ismethod(oReq, "callback")
                    oReq.callback(aMsg)
                ok
                del(aPendingRequests, i)
                return
            ok
        next
        return null

    func get_session
        if isnull(oSession)
            oSession = new SessionManager
        ok
        return oSession

    # client high level functions
    func initialize
        get_session()
        return send_request("initialize", [
            :protocolVersion = get_session().cProtocolVersion,
            :capabilities = [],
            :clientInfo = [:name = name, :version = version]
        ])

    func list_tools
        return send_request("tools/list", [])

    func call_tool cName, aArgs
        return send_request("tools/call", [:name = cName, :arguments = aArgs])


class MCPTool
    name = ""
    description = ""
    oSchema = null
    on_call = null

class MCPResource
    uri = ""
    name = ""
    mimeType = "text/plain"
    reader = null


class MCPPrompt
    name = ""
    description = ""
    aArguments = []


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
        off




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


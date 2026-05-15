# Layer 3: Protocol Engine
# Handles JSON-RPC routing and MCP lifecycle

# Helper functions
func success_response vId, vResult
    return [
        :jsonrpc = "2.0",
        :id = vId,
        :result = vResult
    ]

func error_response vId, nCode, cMessage
    return [
        :jsonrpc = "2.0",
        :id = vId,
        :error = [:code = nCode, :message = cMessage]
    ]

class MessageRouter
    func handle_message oTarget, aMsg
        if not islist(aMsg) return error_response(null, -32600, "Invalid Request") ok
        
        cMethod = ""
        try 
            cMethod = aMsg[:method] 
        catch 
            cMethod = ""
        done
        
        vId = null
        try 
            vId = aMsg[:id] 
        catch 
            vId = null
        done
        
        # Detect if it's a Response (has result or error but no method)
        if cMethod = "" and not isnull(vId)
            if isobject(oTarget) and ismethod(oTarget, "handle_response")
                return oTarget.handle_response(vId, aMsg)
            ok
        ok

        aParams = []
        try 
            aParams = aMsg[:params] 
        catch 
            aParams = []
        done
        
        if cMethod = "" return error_response(vId, -32600, "Method missing") ok
        
        if isnull(oTarget) return error_response(vId, -32603, "oTarget is null") ok
        if isnull(oTarget.oSession) return error_response(vId, -32603, "oSession is null") ok
        
        # Check initialization (except for initialize and ping)
        if oTarget.oSession.bInitialized = false
            if cMethod != "initialize" and cMethod != "ping"
                return error_response(vId, -32002, "Not initialized")
            ok
        ok

        if isnull(vId)
            return handle_notification(oTarget, cMethod, aParams)
        ok

        switch cMethod
            on "initialize"   return handle_initialize(oTarget, vId, aParams)
            on "initialized"  return handle_initialized(oTarget, aParams)
            on "ping"         return handle_ping(oTarget, vId)
            on "tools/list"   return handle_tools_list(oTarget, vId, aParams)
            on "tools/call"   return handle_tools_call(oTarget, vId, aParams)
            on "resources/list" return handle_resources_list(oTarget, vId, aParams)
            on "resources/read" return handle_resources_read(oTarget, vId, aParams)
            on "prompts/list"  return handle_prompts_list(oTarget, vId, aParams)
            on "prompts/get"   return handle_prompts_get(oTarget, vId, aParams)
            on "logging/setLevel" return handle_logging_set_level(oTarget, vId, aParams)
            other             return error_response(vId, -32601, "Method not found: " + cMethod)
        off


    func handle_initialize oServer, vId, aParams
        oServer.oSession.bInitialized = "__BOOL_TRUE__"
        
        aCapabilities = []
        if len(oServer.aTools) > 0 
            add(aCapabilities, ["tools", [:listChanged = "__BOOL_TRUE__"]])
        ok
        if len(oServer.aResources) > 0 
            add(aCapabilities, ["resources", [:subscribe = "__BOOL_FALSE__", :listChanged = "__BOOL_TRUE__"]])
        ok
        if len(oServer.aPrompts) > 0 
            add(aCapabilities, ["prompts", [:listChanged = "__BOOL_TRUE__"]])
        ok

        res = success_response(vId, [
            :protocolVersion = oServer.oSession.cProtocolVersion,
            :capabilities = aCapabilities,
            :serverInfo = [
                :name = oServer.name,
                :version = oServer.version
            ]
        ])
        return res

    func handle_notification oServer, cMethod, aParams
        switch cMethod
            on "notifications/initialized"
                oServer.oSession.bInitialized = true
            on "notifications/cancelled"
                # Handle cancellation
        off
        return null

    func notify cMethod, aParams
        return [:jsonrpc = "2.0", :method = cMethod, :params = aParams]

    func request vId, cMethod, aParams
        return [:jsonrpc = "2.0", :id = vId, :method = cMethod, :params = aParams]

    func handle_initialized aParams
        oServer.oSession.bInitialized = true
        return null


    func handle_ping oServer, vId
        return success_response(vId, [:pong = "__BOOL_TRUE__"])

    func handle_tools_list oServer, vId, aParams

        aTools = []
        for oTool in oServer.aTools
            add(aTools, [
                :name = oTool.name,
                :description = oTool.description,
                :inputSchema = oTool.oSchema.get_json_schema()
            ])
        next
        return success_response(vId, [:tools = aTools])

    func handle_tools_call oServer, vId, aParams
        cName = ""
        try 
            cName = aParams[:name] 
        catch 
            cName = ""
        done
        
        aArgs = []
        try 
            aArgs = aParams[:arguments] 
        catch 
            aArgs = []
        done
        
        oTargetTool = null
        for oTool in oServer.aTools
            if oTool.name = cName
                oTargetTool = oTool
                exit
            ok
        next
        
        if isnull(oTargetTool)
            return error_response(vId, -32602, "Tool not found: " + cName)
        ok
        
        # Validate args
        if not isnull(oTargetTool.oSchema)
            if not oTargetTool.oSchema.validate(aArgs)
                return error_response(vId, -32602, "Invalid params")
            ok
        ok
        
        # Call handler
        try
            vResult = call oTargetTool.on_call(aArgs)
            return success_response(vId, [:content = vResult])
        catch
            return error_response(vId, -32603, "Internal error: " + cCatchError)
        done


    func handle_resources_list oServer, vId, aParams

        aRes = []
        for oRes in oServer.aResources
            add(aRes, [
                :uri = oRes.uri,
                :name = oRes.name,
                :mimeType = oRes.mimeType
            ])
        next
        return success_response(vId, [:resources = aRes])

    func handle_resources_read oServer, vId, aParams
        cUri = ""
        try 
            cUri = aParams[:uri] 
        catch 
            cUri = ""
        done
        
        for oRes in oServer.aResources
            if oRes.uri = cUri
                try
                    cContent = call oRes.reader(cUri)
                    return success_response(vId, [
                        :contents = [[:uri = cUri, :mimeType = oRes.mimeType, :text = cContent]]
                    ])
                catch
                    return error_response(vId, -32603, "Internal error reading resource")
                done
            ok
        next
        return error_response(vId, -32602, "Resource not found")

    func handle_prompts_list oServer, vId, aParams

        aPrompts = []
        for oPrompt in oServer.aPrompts
            add(aPrompts, [
                :name = oPrompt.name,
                :description = oPrompt.description
            ])
        next
        return success_response(vId, [:prompts = aPrompts])

    func handle_prompts_get oServer, vId, aParams
        cName = ""
        try 
            cName = aParams[:name] 
        catch 
            cName = ""
        done
        
        aArgs = []
        try 
            aArgs = aParams[:arguments] 
        catch 
            aArgs = []
        done
        
        for oPrompt in oServer.aPrompts
            if oPrompt.name = cName
                try
                    aMessages = oPrompt.builder(aArgs)
                    return success_response(vId, [:messages = aMessages])
                catch
                    return error_response(vId, -32603, "Internal error building prompt")
                done
            ok
        next
        return error_response(vId, -32602, "Prompt not found")
    func handle_logging_set_level vId, aParams
        return success_response(vId, [:level = aParams[:level]])


class SessionManager
    bInitialized = false
    cProtocolVersion = "2024-11-05"


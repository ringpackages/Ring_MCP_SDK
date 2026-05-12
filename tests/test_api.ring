load "../src/mcp.ring"

func main
    ? "Running Layer 1 Tests..."
    
    oMyServer = new MCPServer()
    oMyServer.name = "test-api"
    oMyServer.version = "1.0.0"
    
    oTool = new MCPTool
    oTool.name = "hello"
    oTool.description = "says hello"
    oTool.oSchema = new SchemaBuilder
    oTool.oSchema.required("name", "string", "name")
    
    oMyServer.tool(oTool)
    
    if len(oMyServer.aTools) = 1
        ? "  [OK] Tool registration successful"
    else
        ? "  [FAIL] Tool registration failed"
    ok
    
    # Test router connection
    ? "Testing router connection..."
    oRouter = oMyServer.get_router()
    if isnull(oRouter)
        ? "  [FAIL] oRouter is NULL!"
        return
    ok
    
    aReq = [:jsonrpc = "2.0", :id = 1, :method = "initialize", :params = []]
    aRes = oRouter.handle_message(aReq)

    if islist(aRes)
        ? "Response: " + type(aRes)
        if isnull(aRes[:result])
            ? "  [FAIL] Result is NULL!"
            if not isnull(aRes[:error])
                ? "  Error: " + aRes[:error][:message]
            ok
        else
            ? "  Server Name from response: " + aRes[:result][:serverInfo][:name]
            if aRes[:result][:serverInfo][:name] = "test-api"
                ? "  [OK] Router connection successful"
            else
                ? "  [FAIL] Name mismatch"
            ok
        ok
    else
        ? "  [FAIL] aRes is not a list"
    ok

    
    ? "Layer 1 tests completed."

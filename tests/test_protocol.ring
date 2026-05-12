load "mcp.ring"



func main
    ? "Running Layer 3 Tests..."
    
    oServer = new MockServer
    oTool = new MockTool {
        oSchema = new SchemaBuilder
        oSchema.required("name", "string", "Who to say hello to")
    }
    add(oServer.aTools, oTool)
    
    oRouter = new MessageRouter { self.oServer = oServer }
    
    # Test 1: Initialize
    aReq1 = [:jsonrpc = "2.0", :id = 1, :method = "initialize", :params = []]
    aRes1 = oRouter.handle_message(aReq1)
    if islist(aRes1) and aRes1[:id] = 1 and len(aRes1[:result][:capabilities]) > 0
        ? "  [OK] Test 1: Initialize successful"
    else
        ? "  [FAIL] Test 1: Initialize failed"
    ok
    
    # Test 2: Tools list
    aReq2 = [:jsonrpc = "2.0", :id = 2, :method = "tools/list"]
    aRes2 = oRouter.handle_message(aReq2)
    if islist(aRes2) and len(aRes2[:result][:tools]) = 1
        ? "  [OK] Test 2: Tools list successful"
    else
        ? "  [FAIL] Test 2: Tools list failed"
    ok
    
    # Test 3: Tools call (valid)
    aReq3 = [:jsonrpc = "2.0", :id = 3, :method = "tools/call", 
             :params = [:name = "hello", :arguments = [:name = "Ring"]]]
    aRes3 = oRouter.handle_message(aReq3)
   
    if islist(aRes3) and islist(aRes3[:result])
        if aRes3[:result][:content][1][:text] = "Hello Ring"
            ? "  [OK] Test 3: Tools call (valid) successful"
        else
            ? "  [FAIL] Test 3: Tools call (valid) failed - unexpected content"
        ok
    else
        ? "  [FAIL] Test 3: Tools call (valid) failed - no result or invalid format"
    ok
    
    # Test 4: Tools call (invalid params)
    aReq4 = [:jsonrpc = "2.0", :id = 4, :method = "tools/call", 
             :params = [:name = "hello", :arguments = []]]
    aRes4 = oRouter.handle_message(aReq4)
    if islist(aRes4) and not isnull(aRes4[:error])
        ? "  [OK] Test 4: Tools call (invalid params) correctly rejected"
    else
        ? "  [FAIL] Test 4: Tools call (invalid params) not rejected"
    ok

    ? "Layer 3 tests completed."

class MockServer
    name = "test-server"
    version = "1.0.0"
    aTools = []
    aResources = []
    aPrompts = []
    oSession = new SessionManager

class MockTool
    name = "hello"
    description = "says hello"
    oSchema = null
    on_call = func(aArgs) {
        return [[:type = "text", :text = "Hello " + aArgs[:name]]]
    }

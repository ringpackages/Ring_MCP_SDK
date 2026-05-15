# ==========================================================
# Ring Pro - Advanced Web Server
# ==========================================================

load "mcp.ring"
load "logic.ring"

# Create the server
oServer = new MCPServer {
    name    = "Ring-Pro-Web-Service"
    version = "1.0.0"
}

# Load the logic engine
oLogic = new RingProLogic

# 1. Tool: Universal Search
oServer.tool(new MCPTool {
    name        = "search"
    description = "Search for keywords, functions, or aliases in the Ring language."
    oSchema     = new SchemaBuilder {
        required("query", "string", "What to search for (e.g. 'len', 'if', 'Init')")
    }
    on_call = func(aArgs) {
        oServer.log("info", "Searching for: " + aArgs[:query])
        return [[:type = "text", :text = oLogic.find_help(aArgs[:query])]]
    }
})

# 2. Tool: Code Runner (Safe)
oServer.tool(new MCPTool {
    name        = "run_code"
    description = "Safely execute Ring code snippets and return the result."
    oSchema     = new SchemaBuilder {
        required("code", "string", "The Ring source code")
    }
    on_call = func(aArgs) {
        oServer.log("info", "Executing user code...")
        cResult = oLogic.run_code(aArgs[:code])
        return [[:type = "text", :text = "Result:" + nl + cResult]]
    }
})

# 3. Tool: Error Explainer
oServer.tool(new MCPTool {
    name        = "explain_error"
    description = "Get a detailed explanation for any Ring compiler or runtime error code."
    oSchema     = new SchemaBuilder {
        required("code", "string", "The error code (e.g. 'C27', 'R5')")
    }
    on_call = func(aArgs) {
        return [[:type = "text", :text = oLogic.explain_error(aArgs[:code])]]
    }
})

# 4. Tool: Grammar Lookup
oServer.tool(new MCPTool {
    name        = "get_grammar"
    description = "Get the official language grammar rules for a specific construct."
    oSchema     = new SchemaBuilder {
        required("subject", "string", "The construct (e.g. 'class', 'func', 'for')")
    }
    on_call = func(aArgs) {
        return [[:type = "text", :text = oLogic.get_grammar(aArgs[:subject])]]
    }
})

# Resource: Full Keyword List
oServer.resource(new MCPResource {
    uri      = "mcp://ring/spec/keywords"
    name     = "Language Keywords Specification"
    mimeType = "text/plain"
    reader = func(cUri) {
        return "Count: 56" + nl + "List: again, and, but, bye, call, case, catch, class, def, do, done, else, elseif, end, exit, for, foreach, from, func, get, give, if, import, in, load, loop, new, next, not, off, ok, on, or, other, package, private, put, return, see, step, switch, to, try, while, endfunc, endclass, endpackage, endif, endfor, endwhile, endswitch, endtry, function, endfunction, break, continue"
    }
})

# Start the server using Bolt (HTTP + SSE)
see "==================================================" + nl
see "   RING PRO WEB SERVER (Bolt Powered)" + nl
see "==================================================" + nl
see "Status: Running on http://localhost:3000" + nl
see "API Endpoint: http://localhost:3000/mcp" + nl

oServer.start("http")

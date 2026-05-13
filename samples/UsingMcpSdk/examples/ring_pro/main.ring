# ==========================================================
# Ring MCP Server - Main Entry Point
# The ultimate AI-powered Ring Language Server
# ==========================================================

load "mcp.ring"
load "C:/ring/samples/UsingMcpSdk/examples/ring_pro/logic.ring"



# Create the server
oServer = new MCPServer {
    name    = "Ring-MCP-Server"
    version = "3.1.0"
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

# Start the server
fputs(stderr, "==================================================" + nl)
fputs(stderr, "       RING MCP SERVER v1.0.0" + nl)
fputs(stderr, "==================================================" + nl)
fputs(stderr, "Status: Ready to serve AI clients." + nl)
fputs(stderr, "Transports: Stdio (enabled), HTTP (port 3000)" + nl)

# Documentation to stderr
fputs(stderr, oServer.docs() + nl)

# Start (Stdio mode)
oServer.start("stdio")

load "mcp.ring"

# ==========================================================
# Ring Language Expert MCP Server
# A professional server providing Ring tools to AI clients
# ==========================================================

oServer = new MCPServer {
    name    = "ring-expert-server"
    version = "1.0.0"
}

# ----------------------------------------------------------
# Tool 1: Run Ring Code
# ----------------------------------------------------------
oServer.tool(new MCPTool {
    name        = "run_code"
    description = "Execute Ring code and return the output. Use this to verify logic."
    oSchema     = new SchemaBuilder {
        required("code", "string", "The Ring code to execute")
    }
    on_call = func(aArgs) {
        cCode = aArgs[:code]
        oServer.log("info", "Executing Ring code snippet...")
        
        # Save to temp file
        cTempFile = "temp_run.ring"
        cOutFile  = "temp_out.txt"
        write(cTempFile, cCode)
        
        try
            # Run and redirect output to file
            system("ring " + cTempFile + " > " + cOutFile)
            cResult = read(cOutFile)
            
            remove(cTempFile)
            remove(cOutFile)
            return [[:type = "text", :text = "Output:" + nl + cResult]]
        catch
            try remove(cTempFile) catch done
            try remove(cOutFile) catch done
            return [[:type = "text", :text = "Error during execution: " + cCatchError]]
        done

    }
})

# ----------------------------------------------------------
# Tool 2: Search for Functions/Keywords
# ----------------------------------------------------------
oServer.tool(new MCPTool {
    name        = "search_function"
    description = "Search for any Ring function, keyword, or library by name."
    oSchema     = new SchemaBuilder {
        required("name", "string", "Function name (e.g. 'left', 'substr', 'add')")
    }
    on_call = func(aArgs) {
        cName = lower(aArgs[:name])
        
        # Simple knowledge base for the example
        aDocs = [
            ["left", "left(string, count) - Returns the first N characters of a string."],
            ["right", "right(string, count) - Returns the last N characters of a string."],
            ["substr", "substr(string, search, replace) - Search and replace in string."],
            ["add", "add(list, item) - Adds an item to a list."],
            ["new", "new ClassName - Creates a new object from a class."],
            ["see", "see value - Prints a value to the screen."]
        ]
        
        for aDoc in aDocs
            if aDoc[1] = cName
                return [[:type = "text", :text = aDoc[2]]]
            ok
        next
        
        return [[:type = "text", :text = "No documentation found for: " + cName]]
    }
})

# ----------------------------------------------------------
# Tool 3: Explain Error Codes
# ----------------------------------------------------------
oServer.tool(new MCPTool {
    name        = "explain_error"
    description = "Explain Ring error codes (e.g. R12, R5)."
    oSchema     = new SchemaBuilder {
        required("code", "string", "The error code")
    }
    on_call = func(aArgs) {
        cCode = upper(aArgs[:code])
        
        switch cCode
            on "R5"  return [[:type = "text", :text = "R5: Can't access list item. The variable is not a list."]]
            on "R12" return [[:type = "text", :text = "R12: Property not found. The object doesn't have this attribute."]]
            on "R31" return [[:type = "text", :text = "R31: Self reference conflict. Usually happens during cyclic copies."]]
            on "C27" return [[:type = "text", :text = "C27: Syntax error. Check your brackets or keywords."]]
        off
        
        return [[:type = "text", :text = "Unknown error code. Please check the Ring manual."]]
    }
})

# ----------------------------------------------------------
# Resources
# ----------------------------------------------------------
oServer.resource(new MCPResource {
    uri      = "mcp://ring/docs/keywords"
    name     = "Ring Keywords"
    mimeType = "text/plain"
    reader = func(cUri) {
        return "if, ok, but, else, for, to, next, while, end, do, switch, on, other, off, try, catch, done, func, class, package, import, new, give, see, load, return, loop, exit"
    }
})

# ----------------------------------------------------------
# Final Setup
# ----------------------------------------------------------
fputs(stderr, "Ring Language Expert Server is starting..." + nl)
fputs(stderr, "Available tools: run_code, search_function, explain_error" + nl)
fputs(stderr, "Available resources: mcp://ring/docs/keywords" + nl)

# Start the server (Stdio for use with Claude Desktop/Inspector)
oServer.start("stdio")

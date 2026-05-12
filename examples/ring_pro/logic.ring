# ==========================================================
# Ring Pro Server - Logic & Processing
# Expanded with Full Grammar & VM Support
# ==========================================================

load "database.ring"

class RingProLogic
    
    oDB = new RingDB

    func run_code cCode
        cTempFile = "temp_exec.ring"
        cOutFile  = "temp_out.txt"
        write(cTempFile, cCode)
        system("ring " + cTempFile + " > " + cOutFile + " 2>&1")
        cResult = read(cOutFile)
        remove(cTempFile)
        remove(cOutFile)
        if cResult = "" return "Execution completed (No output)." ok
        return cResult

    func find_help cQuery
        cQuery = trim(lower(cQuery))
        
        # 1. Search Keywords
        res = oDB.search_keyword(cQuery)
        if res != "" return res ok
        
        # 2. Search Functions
        res = oDB.search_function(cQuery)
        if res != "" return res ok
        
        # 3. Search Aliases
        for x in oDB.aAliases
            if lower(x[:name]) = cQuery 
                return "Alias: " + x[:name] + nl + "Description: " + x[:desc]
            ok
        next

        # 4. Search VM Instructions
        for x in oDB.aVMInstructions
            if lower(x[:op]) = cQuery
                return "VM Instruction: " + x[:op] + nl + "Operation: " + x[:desc]
            ok
        next

        return "No exact match found for '" + cQuery + "'. Try another keyword."

    func explain_error cCode
        return oDB.explain_error(cCode)

    func get_grammar cSubject
        cSubject = lower(cSubject)
        
        switch cSubject
            on "class"
                return "Grammar: Statement ---> 'class' <Identifier> [ 'from'|':'|'<' <Identifier> ] [ '{' {statement} '}' ][ 'end'|'endclass' ]"
            on "func" or "function" or "def"
                return "Grammar: Statement ---> 'func'|'def'|'function' <Identifier> [ParaList] [ '{' {statement} '}' ][ 'end'|'endfunc'|'endfunction' ]"
            on "package"
                return "Grammar: Statement ---> 'package' <Identifier> { '.' <Identifier> } [ '{' {statement} '}' ] [ 'end'|'endpackage' ]"
            on "if"
                return "Grammar: Statement ---> 'if' <Expr> [ '{' ] {statement} [ { 'but'|'elseif' <Expr> {Statement} } ] [ 'else' {Statement} ] 'ok'|'end'|'}'|'endif'"
            on "for"
                return "Grammar: Statement ---> 'for' <Identifier> '=' <Expr> 'to' <Expr> [ 'step' <Expr> ] [ '{' ] {Statement} 'next'|'end'|'}'|'endfor'"
            on "while"
                return "Grammar: Statement ---> 'while' <Expr> [ '{' ] {statement} 'end'|'}'|'endwhile'"
            on "switch"
                return "Grammar: Statement ---> 'switch' <Expr> [ '{' ] { 'on'|'case' <Expr> {statement} } [ 'other' {Statement} ] 'off'|'end'|'}'|'endswitch'"
            on "try"
                return "Grammar: Statement ---> 'try' {statement} [ '{' ] 'catch' {statement} 'done'|'end'|'}'|'endtry'"
            on "return"
                return "Grammar: Statement ---> 'return' [ '&' ] <Expr>"
            on "import"
                return "Grammar: Statement ---> 'import' <Identifier> { '.' <Identifier> }"
        off
        
        return "Grammar rule not found in the database for '" + cSubject + "'."

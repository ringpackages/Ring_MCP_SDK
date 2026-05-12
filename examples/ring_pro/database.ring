# ==========================================================
# Ring Pro Server - Knowledge Base
# Full Specification: Keywords, Functions, Errors, and VM
# ==========================================================

class RingDB
    
    # 1. Keywords (56)
    aKeywords = [
        "again", "and", "but", "bye", "call", "case", "catch", "class", "def", "do",
        "done", "else", "elseif", "end", "exit", "for", "foreach", "from", "func",
        "get", "give", "if", "import", "in", "load", "loop", "new", "next", "not",
        "off", "ok", "on", "or", "other", "package", "private", "put", "return",
        "see", "step", "switch", "to", "try", "while", "endfunc", "endclass",
        "endpackage", "endif", "endfor", "endwhile", "endswitch", "endtry",
        "function", "endfunction", "break", "continue"
    ]

    # 2. Alias Keywords (14)
    aAliases = [
        [:name="This", :desc="Reference to the current object"],
        [:name="Self", :desc="Reference to the current object (inside braces)"],
        [:name="Super", :desc="Reference to the parent class"],
        [:name="Main", :desc="Main function name"],
        [:name="Init", :desc="Constructor method name"],
        [:name="Operator", :desc="Used for operator overloading"],
        [:name="BraceStart", :desc="Internal identifier for {"],
        [:name="BraceExprEval", :desc="Internal identifier for brace expression evaluation"],
        [:name="BraceNewLine", :desc="Internal identifier for new line inside braces"],
        [:name="BraceError", :desc="Internal identifier for error handling inside braces"],
        [:name="BraceEnd", :desc="Internal identifier for }"],
        [:name="RingVM_See", :desc="Internal See command"],
        [:name="RingVM_Give", :desc="Internal Give command"],
        [:name="RingVM_ErrorHandler", :desc="Internal error handler"]
    ]

    # 3. Compiler Errors (C1 - C31)
    aCompilerErrors = [
        ["C1", "Error in parameters list, expected identifier"],
        ["C2", "Error in class name"],
        ["C3", "Unclosed control structure, 'ok' is missing"],
        ["C4", "Unclosed control structure, 'end' is missing"],
        ["C5", "Unclosed control structure, next is missing"],
        ["C6", "Error in function name"],
        ["C7", "Error in list items"],
        ["C8", "Parentheses ')' is missing"],
        ["C9", "Brackets ']' is missing"],
        ["C10", "Error in parent class name"],
        ["C11", "Error in expression operator"],
        ["C12", "No class definition"],
        ["C13", "Error in variable name"],
        ["C14", "Try/Catch miss the Catch keyword!"],
        ["C15", "Try/Catch miss the Done keyword!"],
        ["C16", "Error in Switch statement expression!"],
        ["C17", "Switch statement without OFF"],
        ["C18", "Missing closing brace for the block opened!"],
        ["C19", "Numeric Overflow!"],
        ["C20", "Error in package name"],
        ["C21", "Unclosed control structure, 'again' is missing"],
        ["C22", "Function redefinition, function is already defined!"],
        ["C23", "Using '(' after number!"],
        ["C24", "The parent class name is identical to the subclass name"],
        ["C25", "Trying to access the self reference after the object name"],
        ["C26", "Class redefinition, class is already defined!"],
        ["C27", "Syntax Error!"],
        ["C28", "Expression is expected!"],
        ["C29", "Braces are missing to define anonymous function!"],
        ["C30", "Argument redefinition, argument is already defined!"],
        ["C31", "Parentheses '(' is expected"]
    ]

    # 4. Runtime Errors (R1 - R54)
    aRuntimeErrors = [
        ["R1", "Can't divide by zero"],
        ["R2", "Array Access (Index out of range)"],
        ["R3", "Calling Function without definition"],
        ["R4", "Stack Overflow"],
        ["R5", "Can't access the list item, Object is not list"],
        ["R6", "Variable is required"],
        ["R11", "Error in class name, class not found"],
        ["R12", "Error in property name, property not found"],
        ["R13", "Object is required"],
        ["R14", "Calling Method without definition"],
        ["R24", "Using uninitialized variable"],
        ["R31", "Trying to destroy the object using the self reference"],
        ["R53", "Function redefinition, function is already defined!"]
        # (قمت باختيار أهمها لضمان الأداء، ويمكن توسيعها حسب الحاجة)
    ]

    # 5. Language Functions (Selected high-priority from the 258 list)
    aFunctions = [
        [:name="acos", :sig="acos(x)", :desc="The principal value of the arc cosine of x"],
        [:name="add", :sig="add(List,Item)", :desc="Adds an item to a list"],
        [:name="addmethod", :sig="addmethod(Object,cNewMethodName,Function)", :desc="Adds a method dynamically"],
        [:name="ascii", :sig="ascii(character)", :desc="ASCII Code"],
        [:name="eval", :sig="eval(cCode)", :desc="Executes Ring code as string"],
        [:name="islist", :sig="islist(value)", :desc="Returns 1 if value is a list"],
        [:name="len", :sig="len(string|list)", :desc="Returns size or length"],
        [:name="read", :sig="read(cFileName)", :desc="Reads file content as string"],
        [:name="write", :sig="write(cFileName,cString)", :desc="Writes string to file"],
        [:name="substr", :sig="substr(string,substring)", :desc="Position of substring"],
        [:name="system", :sig="system(cCommand)", :desc="Executes system command"],
        [:name="trim", :sig="trim(string)", :desc="Removes spaces from right and left"],
        [:name="lower", :sig="lower(string)", :desc="Convert to lower case"],
        [:name="upper", :sig="upper(string)", :desc="Convert to UPPER case"],
        [:name="ringvm_see", :sig="ringvm_see(t)", :desc="Redefines See behavior"],
        [:name="ringvm_passerror", :sig="ringvm_passerror()", :desc="Continue execution after error"]
    ]

    # 6. VM Instructions (Sample)
    aVMInstructions = [
        [:op="ICO_PUSHC", :desc="Push string from the IR to the stack"],
        [:op="ICO_PUSHN", :desc="Push number from the IR to the stack"],
        [:op="ICO_ASSIGNMENT", :desc="Assignment operation"],
        [:op="ICO_LOADADDRESS", :desc="Load variable VP to stack"],
        [:op="ICO_NEWOBJ", :desc="Create new object"]
    ]

    func search_keyword cName
        cName = lower(cName)
        for x in aKeywords if x = cName return "Keyword: " + x ok next
        return ""

    func search_function cName
        cName = lower(cName)
        for x in aFunctions 
            if x[:name] = cName 
                return "Function: " + x[:sig] + nl + "Description: " + x[:desc]
            ok
        next
        return ""

    func explain_error cCode
        cCode = upper(cCode)
        # Search Compiler Errors
        for x in aCompilerErrors if x[1] = cCode return "Compiler Error (" + cCode + "): " + x[2] ok next
        # Search Runtime Errors
        for x in aRuntimeErrors if x[1] = cCode return "Runtime Error (" + cCode + "): " + x[2] ok next
        return "Error code not found."

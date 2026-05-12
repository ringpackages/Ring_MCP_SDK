# Layer 2: Schema Engine
# Handles validation and JSON schema generation

func required_string
    return "string"

func optional_string
    return "string"

func required_number
    return "number"

func optional_number
    return "number"

class SchemaBuilder
    aParams = []

    func required cName, cType, cDesc
        add(aParams, [:name = cName, :type = cType, :description = cDesc, :required = "__BOOL_TRUE__"])

    func optional cName, cType, cDesc, vDefault
        add(aParams, [:name = cName, :type = cType, :description = cDesc, :required = "__BOOL_FALSE__", :default = vDefault])

    func validate aArgs
        if not islist(aArgs) return false ok
        
        for oParam in aParams
            cName = oParam[:name]
            vVal = null
            bFound = false
            
            # Look for the value in the hash map
            # Ring hash maps are lists of [:key = value] which are [":key", value]
            for aPair in aArgs
                if islist(aPair) and len(aPair) = 2
                    if aPair[1] = cName
                        vVal = aPair[2]
                        bFound = true
                        exit
                    ok
                ok
            next
            
            if not bFound
                if oParam[:required]
                    return false
                ok
                loop
            ok
            
            # Basic type validation
            cExpected = lower(oParam[:type])
            cActual = lower(type(vVal))
            
            if cExpected = "string" and cActual != "string" return false ok
            if cExpected = "number" and cActual != "number" return false ok
            if cExpected = "boolean" and cActual != "number" return false ok
            if cExpected = "object" and cActual != "list" return false ok
            if cExpected = "array" and cActual != "list" return false ok
        next
        return true

    func get_json_schema
        aProperties = []
        aRequired = []
        for oParam in aParams
            cName = oParam[:name]
            oProp = [:type = oParam[:type], :description = oParam[:description]]
            add(aProperties, [cName, oProp])
            if oParam[:required]
                add(aRequired, cName)
            ok
        next
        
        return [
            :type = "object",
            :properties = aProperties,
            :required = aRequired
        ]


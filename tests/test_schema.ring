load "../src/schema/schema.ring"

func main
    ? "Running Layer 2 Tests..."
    
    oSchema = new SchemaBuilder
    oSchema.required("query", "string", "Search query")
    oSchema.optional("limit", "number", "Max results", 10)
    
    # Test 1: Valid args
    aArgs1 = [:query = "ring lang", :limit = 5]
    if oSchema.validate(aArgs1)
        ? "  [OK] Test 1: Valid args passed"
    else
        ? "  [FAIL] Test 1: Valid args failed"
    ok
    
    # Test 2: Missing required
    aArgs2 = [:limit = 10]
    if not oSchema.validate(aArgs2)
        ? "  [OK] Test 2: Missing required detected"
    else
        ? "  [FAIL] Test 2: Missing required passed incorrectly"
    ok
    
    # Test 3: Wrong type
    aArgs3 = [:query = 123]
    if not oSchema.validate(aArgs3)
        ? "  [OK] Test 3: Wrong type detected"
    else
        ? "  [FAIL] Test 3: Wrong type passed incorrectly"
    ok

    # Test 4: JSON Schema generation
    oJsonSchema = oSchema.get_json_schema()
    if islist(oJsonSchema) and oJsonSchema[:type] = "object"
        ? "  [OK] Test 4: JSON Schema structure valid"
    else
        ? "  [FAIL] Test 4: JSON Schema structure invalid"
    ok
    
    ? "Layer 2 tests completed."

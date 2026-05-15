# Layer 6: Dependency Bootstrap
# Verifies all required Ring packages are available

# Check if required libraries are present
try
    load "simplejson.ring"
    fputs(stderr, "Checking dependencies..." + nl)
    
    # Test simplejson
    aTest = [:test = "ok"]
    cJson = json_encode(aTest)
    if json_decode(cJson)[:test] = "ok"
        fputs(stderr, "  [OK] simplejson.ring" + nl)
    else
        fputs(stderr, "  [ERROR] simplejson.ring is not working correctly" + nl)
    ok
catch
    fputs(stderr, "  [ERROR] simplejson.ring not found or failed" + nl)
    fputs(stderr, "  Error: " + cCatchError + nl)
done

try
    load "bolt.ring"
    fputs(stderr, "  [OK] bolt.ring" + nl)
    
catch
    fputs(stderr, "  [ERROR] bolt.ring not found or failed" + nl)
    fputs(stderr, "  Error: " + cCatchError + nl)
done

try
    load "libcurl.ring"
    fputs(stderr, "  [OK] libcurl.ring" + nl)
catch
    fputs(stderr, "  [ERROR] libcurl.ring not found" + nl)
done

try
    load "stdlibcore.ring"
    fputs(stderr, "  [OK] stdlibcore.ring" + nl)
catch
    fputs(stderr, "  [ERROR] stdlibcore.ring not found" + nl)
    fputs(stderr, "  Error: " + cCatchError + nl)
done

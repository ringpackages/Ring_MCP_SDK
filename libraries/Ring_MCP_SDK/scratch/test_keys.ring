load "stdlibcore.ring"
load "simplejson.ring"

aMsg = [:name = "test", :inputSchema = [:type = "object"]]
? "MSG: " + json_encode(aMsg)

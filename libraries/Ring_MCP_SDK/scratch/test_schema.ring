load "stdlibcore.ring"
load "simplejson.ring"

aProps = []
add(aProps, ["code", [:type = "string", :description = "test"]])

aSchema = [
    :type = "object",
    :properties = aProps,
    :required = ["code"]
]

cJson = json_encode(aSchema)
? "JSON: " + cJson

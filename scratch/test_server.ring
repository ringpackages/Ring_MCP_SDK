load "stdlibcore.ring"

cInput = '{"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"protocolVersion": "2024-11-05", "capabilities": {}, "clientInfo": {"name": "test", "version": "1.0"}}}' + nl
cInput += '{"jsonrpc": "2.0", "id": 2, "method": "tools/list"}' + nl

write("input.txt", cInput)

# Run the server with input and capture output
# We use a timeout to prevent hanging if the server doesn't exit
system('ring examples\ring_pro\main.ring < input.txt > output.txt 2> error.txt')

cOutput = read("output.txt")
? "Captured Output:"
? cOutput

f = fopen("output.txt", "w")
fputs(f, cOutput)
fclose(f)

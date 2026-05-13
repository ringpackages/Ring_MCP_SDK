aPackageInfo = [
	:name = "The Ring_MCP_SDK Package",
	:description = "Our Ring_MCP_SDK package using the Ring programming language",
	:folder = "Ring_MCP_SDK",
	:developer = "",
	:email = "",
	:license = "MIT License",
	:version = "1.0.0",
	:ringversion = "1.26",
	:versions = 	[
		[
			:version = "1.0.0",
			:branch = "master"
		]
	],
	:libs = 	[
		[
			:name = "simplejson",
			:version = "1.3.0",
			:providerusername = "ysdragon"
		],
		[
			:name = "bolt",
			:version = "1.0.0",
			:providerusername = "ysdragon"
		]
	],
	:files = 	[
		"main.ring",
		"README.md"
	],
	:ringfolderfiles = 	[
		"bin/load/mcp.ring",
		"libraries/Ring_MCP_SDK/scratch/test_keys.ring",
		"libraries/Ring_MCP_SDK/scratch/test_r31.ring",
		"libraries/Ring_MCP_SDK/scratch/test_schema.ring",
		"libraries/Ring_MCP_SDK/scratch/test_server.ring",
		"libraries/Ring_MCP_SDK/scratch/test_success.ring",
		"libraries/Ring_MCP_SDK/scratch/test_tool_call.ring",
		"libraries/Ring_MCP_SDK/src/api/api.ring",
		"libraries/Ring_MCP_SDK/src/core/deps.ring",
		"libraries/Ring_MCP_SDK/src/mcp.ring",
		"libraries/Ring_MCP_SDK/src/middleware/middleware.ring",
		"libraries/Ring_MCP_SDK/src/protocol/protocol.ring",
		"libraries/Ring_MCP_SDK/src/schema/schema.ring",
		"libraries/Ring_MCP_SDK/src/transport/transport.ring",
		"libraries/Ring_MCP_SDK/tests/test_api.ring",
		"libraries/Ring_MCP_SDK/tests/test_protocol.ring",
		"libraries/Ring_MCP_SDK/tests/test_schema.ring",
		"samples/UsingMcpSdk/examples/advanced_server.ring",
		"samples/UsingMcpSdk/examples/hello_server.ring",
		"samples/UsingMcpSdk/examples/http_server.ring",
		"samples/UsingMcpSdk/examples/ring_expert_server.ring",
		"samples/UsingMcpSdk/examples/ring_pro/database.ring",
		"samples/UsingMcpSdk/examples/ring_pro/logic.ring",
		"samples/UsingMcpSdk/examples/ring_pro/main.ring"
	],
	:windowsfiles = 	[

	],
	:linuxfiles = 	[

	],
	:ubuntufiles = 	[

	],
	:fedorafiles = 	[

	],
	:freebsdfiles = 	[

	],
	:macosfiles = 	[

	],
	:windowsringfolderfiles = 	[

	],
	:linuxringfolderfiles = 	[

	],
	:ubunturingfolderfiles = 	[

	],
	:fedoraringfolderfiles = 	[

	],
	:freebsdringfolderfiles = 	[

	],
	:macosringfolderfiles = 	[

	],
	:run = "ring main.ring",
	:windowsrun = "",
	:linuxrun = "",
	:macosrun = "",
	:ubunturun = "",
	:fedorarun = "",
	:setup = "",
	:windowssetup = "",
	:linuxsetup = "",
	:macossetup = "",
	:ubuntusetup = "",
	:fedorasetup = "",
	:remove = "",
	:windowsremove = "",
	:linuxremove = "",
	:macosremove = "",
	:ubunturemove = "",
	:fedoraremove = ""
]
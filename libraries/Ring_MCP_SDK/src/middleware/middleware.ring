# Layer 5: Middleware Pipeline
# Extends server functionality with cross-cutting concerns


# Global error handler as a safety net

func ringvm_errorhandler
    # This is called for any unhandled Ring error
    # In a production SDK, we would format this as JSON-RPC and exit gracefully
    fputs(stderr, "CRITICAL ERROR: " + cCatchError + nl)
    ringvm_passerror()


class LoggerMiddleware
    func run oServer, aReq, oNext
        return oNext.handle_message(oServer, aReq)

class ErrorMiddleware

    func run oServer, aReq, oNext
        try
            return oNext.handle_message(oServer, aReq)
        catch
            # Wrap unexpected errors in JSON-RPC format
            vId = null
            try vId = aReq[:id] catch done
            return [
                :jsonrpc = "2.0",
                :id = vId,
                :error = [:code = -32603, :message = "Internal error: " + cCatchError]
            ]
        done


class HealthCheckTool < MCP::Tool
  tool_name "health-check-tool"
  description "Check the health of the server."

  def self.call(server_context:)
    status = server_context.server_status
    if status == :healthy
      MCP::Tool::Response.new([{ type: "text", text: "Server is healthy." }])
    else
      MCP::Tool::Response.new([{ type: "text", text: "Server is not healthy." }], error: true)
    end
  end
end
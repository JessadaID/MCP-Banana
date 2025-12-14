module AzureDevops
  class GetCurrentUserTool < MCP::Tool
    tool_name "get-current-user-tool"
    description "Get the current user's information from Azure DevOps."

    def self.call(server_context:)
      begin
        org = ApiClient.organization
        url = "https://dev.azure.com/#{org}/_apis/connectionData"
        result = ApiClient.api_request(:get, url)
        ApiClient.success_response("Current User:, name: #{result['authenticatedUser']['providerDisplayName']} , isActive : #{result['authenticatedUser']['isActive']} , properties : #{result['authenticatedUser']['properties']}")
      rescue => e
        return ApiClient.error_response("Error in GetCurrentUserTool: #{e.message}")
      end
    end
  end
end
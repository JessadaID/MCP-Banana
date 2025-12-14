module AzureDevops
  class ListProjectsTool < MCP::Tool
    tool_name "list-projects-tool"
    description "List all projects in the organization."

    def self.call(server_context:)
      org = ApiClient.organization
      url = "https://dev.azure.com/#{org}/_apis/projects?api-version=7.0"
      begin
        result = ApiClient.api_request(:get, url)
        projects = result["value"].map { |p| "- name : #{p['name']} ,state : #{p['state'] || 'Unknown'} ,visibility : #{p['visibility'] || 'Unknown'} ,lastUpdateTime : #{p['lastUpdateTime'] || 'Unknown'}" }.join("\n")
        ApiClient.success_response("Projects:\n\n#{projects}")
      rescue => e
        return ApiClient.error_response("Error in ListProjectsTool: #{e.message}")
      end
    end
  end
end
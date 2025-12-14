module AzureDevops
  class ListRepositoriesTool < MCP::Tool
    tool_name "list-repositories-tool"
    description "List all repositories in the project."

    input_schema(
      properties: {
        project: { type: "string", description: "Project name" }
      },
      required: ["project"]
    )
    
    def self.call(server_context:, project:)

      if project.to_s.strip.empty?
        return ApiClient.error_response("Error: Project parameter is missing or empty.")
      end

      begin
        org = ApiClient.organization
        encoded_project = ApiClient.encode_path(project)
        url = "https://dev.azure.com/#{org}/#{encoded_project}/_apis/git/repositories?api-version=7.0"
        result = ApiClient.api_request(:get, url)
        repos = result["value"].map { |r| "- **#{r['name']}** (#{r['defaultBranch'] || 'No default branch'})" }.join("\n")
        ApiClient.success_response("Repositories in #{project}:\n\n#{repos}")
      rescue => e
        return ApiClient.error_response("Error in ListRepositoriesTool: #{e.message}")
      end
    end
  end 
end
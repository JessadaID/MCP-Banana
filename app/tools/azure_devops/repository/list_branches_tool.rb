module AzureDevops
  class ListBranchesTool < MCP::Tool
    tool_name "list-branches-tool"
    description "List all branches in the repository. required project and repo_name"

    input_schema(
      properties: {
        project: { type: "string", description: "Project name" },
        repo_name: { type: "string", description: "Repository name" }
      },
      required: ["project", "repo_name"]
    )
    
    def self.call(server_context:, project:, repo_name:)
      
      if project.to_s.strip.empty?
        return ApiClient.error_response("Error: Project parameter is missing or empty.")
      end

      if repo_name.to_s.strip.empty?
        return ApiClient.error_response("Error: Repository name parameter is missing or empty.")
      end

      begin
        org = ApiClient.organization
        encoded_project = ApiClient.encode_path(project)
        encoded_repo = ApiClient.encode_path(repo_name)
        url = "https://dev.azure.com/#{org}/#{encoded_project}/_apis/git/repositories/#{encoded_repo}/refs?filter=heads/&api-version=7.0"
        result = ApiClient.api_request(:get, url)
        
        branches = result["value"].map { |b| "- **#{b['name'].gsub('refs/heads/', '')}" }.join("\n")
        ApiClient.success_response("Branches in #{repo_name}:\n\n#{branches}")
      rescue => e
        return ApiClient.error_response("Error in ListBranchesTool: #{e.message}")
      end
    end
  end
end
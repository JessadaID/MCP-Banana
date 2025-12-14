module AzureDevops
    
  class GetPullRequestTool < MCP::Tool
    tool_name "get-pull-request-tool"
    description "Get a specific pull request. required: project, repo_name, pr_id"
    
    input_schema(
      properties: {
        project: { type: "string", description: "Project name" },
        repo_name: { type: "string", description: "Repository name" },
        pr_id: { type: "integer", description: "Pull request ID" }
      },
      required: ["project", "repo_name", "pr_id"]
    )
    
    def self.call(server_context:, project:, repo_name:, pr_id:)

      if project.to_s.strip.empty?
        return ApiClient.error_response("Error: Project parameter is missing or empty.")
      end

      if repo_name.to_s.strip.empty?
        return ApiClient.error_response("Error: Repository name parameter is missing or empty.")
      end

      if pr_id.to_s.strip.empty?
        return ApiClient.error_response("Error: PR ID parameter is missing or empty.")
      end
      
      begin
        org = ApiClient.organization
        encoded_project = ApiClient.encode_path(project)
        encoded_repo = ApiClient.encode_path(repo_name)
        url = "https://dev.azure.com/#{org}/#{encoded_project}/_apis/git/repositories/#{encoded_repo}/pullrequests/#{pr_id}?api-version=7.0"
        result = ApiClient.api_request(:get, url)
        
        info = [
          "**Pull Request ##{result['pullRequestId']}**", "",
          "- **Title:** #{result['title']}",
          "- **Status:** #{result['status']}",
          "- **Description:** #{result['description'] || 'No description'}"
        ].join("\n")
        
        ApiClient.success_response(info)
      rescue => e
        ApiClient.error_response("Error in GetPullRequestTool: #{e.message}")
      end
    end
  end
end
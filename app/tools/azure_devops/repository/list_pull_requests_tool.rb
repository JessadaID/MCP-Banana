module AzureDevops
    class ListPullRequestsTool < MCP::Tool
      tool_name "list-pull-requests-tool"
      description "List pull requests in a repository. required: project, repo_name"
      
      input_schema(
        properties:{
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
          url = "https://dev.azure.com/#{org}/#{encoded_project}/_apis/git/repositories/#{encoded_repo}/pullrequests?api-version=7.0"
          result = ApiClient.api_request(:get, url)
          
          if result["value"].nil? || result["value"].empty?
            return ApiClient.success_response("No pull requests found")
          end
          
          prs = result["value"].map do |pr|
            "- **PR ##{pr['pullRequestId']}**: #{pr['title']}\n #{pr['sourceRefName'].gsub('refs/heads/', '')} → #{pr['targetRefName'].gsub('refs/heads/', '')} | Status: #{pr['status']}"
          end.join("\n\n")
          
          ApiClient.success_response("Pull Requests:\n\n#{prs}")
        rescue => e
          return ApiClient.error_response("Error in ListPullRequestsTool: #{e.message}")
        end
      end
    end
end
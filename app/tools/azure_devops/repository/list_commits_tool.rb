module AzureDevops
  class ListCommitsTool < MCP::Tool
    tool_name "list-commits-tool"
    description "List recent commits in the repository. required: project, repo_name, branch, count"

    input_schema(
      properties: {
        project: { type: "string", description: "Project name" },
        repo_name: { type: "string", description: "Repository name" },
        branch: { type: "string", description: "Branch name" },
        count: { type: "integer", description: "Number of commits to list" }
      },
      required: ["project", "repo_name", "branch", "count"]
    )
    
    def self.call(server_context:, project:, repo_name:, branch:, count:)

      if project.to_s.strip.empty?
        return ApiClient.error_response("Error: Project parameter is missing or empty.")
      end

      if repo_name.to_s.strip.empty?
        return ApiClient.error_response("Error: Repository name parameter is missing or empty.")
      end

      if branch.to_s.strip.empty?
        return ApiClient.error_response("Error: Branch parameter is missing or empty.")
      end

      if count.to_s.strip.empty?
        return ApiClient.error_response("Error: Count parameter is missing or empty.")
      end

      begin
        org = ApiClient.organization
        encoded_project = ApiClient.encode_path(project)
        encoded_repo = ApiClient.encode_path(repo_name)
        encoded_branch = ApiClient.encode_path(branch)
        url = "https://dev.azure.com/#{org}/#{encoded_project}/_apis/git/repositories/#{encoded_repo}/commits?$top=#{count}&api-version=7.0"
        url += "&searchCriteria.itemVersion.version=#{encoded_branch}" if branch
        result = ApiClient.api_request(:get, url)
        commits = result["value"].map do |c|
          "- **#{c['commitId'][0..7]}**: #{c['comment'].lines.first&.strip} (#{c['author']['name']})"
        end.join("\n")
        ApiClient.success_response("Recent Commits in #{repo_name}:\n\n#{commits}")
      rescue => e
        return ApiClient.error_response("Error in ListCommitsTool: #{e.message}")
      end
      
    end
  end
end
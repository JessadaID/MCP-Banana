module AzureDevops
  class ListTeamMembersTool < MCP::Tool
    tool_name "list-team-members-tool"
    description "List all team members in the project."

    input_schema(
      properties: {
        project: { type: "string", description: "Project name" }
      },
      required: ["project"]
    )
    
    def self.call(server_context:, project:)
      begin
        org = ApiClient.organization

        if project.to_s.strip.empty?
          return ApiClient.error_response("Error: Project parameter is missing or empty.")
        end

        encoded_project = ApiClient.encode_path(project)
        url = "https://dev.azure.com/#{org}/_apis/projects/#{encoded_project}/teams?api-version=7.0"
        
        begin
          teams = ApiClient.api_request(:get, url)
        rescue => api_err
          return ApiClient.error_response("Error accessing Azure DevOps API.\nURL: #{url}\nProject Argument: '#{project}'\nError: #{api_err.message}")
        end

        unless teams && teams["value"].is_a?(Array)
          return ApiClient.error_response("Error: Unexpected response format from Azure DevOps when fetching teams. Response: #{teams.inspect}")
        end

        all_members = []
        teams["value"].each do |team|
          next unless team['id']
          
          team_members_url = "https://dev.azure.com/#{org}/_apis/projects/#{encoded_project}/teams/#{team['id']}/members?api-version=7.0"
          begin
            members = ApiClient.api_request(:get, team_members_url)
            if members && members['value'].is_a?(Array)
               # Extract display name from identity object if present, otherwise try top-level (fallback)
               names = members['value'].map do |m| 
                 if m['identity']
                   m['identity']['displayName']
                 elsif m['displayName']
                   m['displayName']
                 else
                   "Unknown Member"
                 end
               end
               all_members.concat(names)
            end
          rescue => inner_e
            all_members << "Could not fetch members for team #{team['name']}: #{inner_e.message}"
          end
        end

        ApiClient.success_response("Teams in #{project}:\n\n#{all_members.uniq.join("\n")}")
      rescue => e
        return ApiClient.error_response("Error in ListTeamMembersTool: #{e.message}")
      end
    end
  end
end
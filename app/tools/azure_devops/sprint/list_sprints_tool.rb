module AzureDevops
  class ListSprintsTool < MCP::Tool
    tool_name "list-sprints-tool"
    description "List sprints in a project, required: project"

    input_schema(
      properties: {
        project: { type: "string" }
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
        teams_url = "https://dev.azure.com/#{org}/_apis/projects/#{encoded_project}/teams?api-version=7.0"
        teams = ApiClient.api_request(:get, teams_url)
        team_id = teams["value"].first["id"]
        
        url = "https://dev.azure.com/#{org}/#{encoded_project}/#{team_id}/_apis/work/teamsettings/iterations?api-version=7.0"
        result = ApiClient.api_request(:get, url)
        
        sprints = result["value"].map do |s|
          dates = s["attributes"]
          start_date = dates["startDate"]&.slice(0, 10) || "Not set"
          end_date = dates["finishDate"]&.slice(0, 10) || "Not set"
          "- **#{s['name']}**: #{start_date} → #{end_date} (#{dates['timeFrame']})"
        end.join("\n")
      
        ApiClient.success_response("Sprints in #{project}:\n\n#{sprints}")
      rescue => e
        return ApiClient.error_response("Error in ListSprintsTool: #{e.message}")
      end
    end
  end
end
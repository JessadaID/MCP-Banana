module AzureDevops
  class GetCurrentSprintTool < MCP::Tool
    tool_name "get-current-sprint-tool"
    description "Get current sprint in a project, required: project"

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
        
        url = "https://dev.azure.com/#{org}/#{encoded_project}/#{team_id}/_apis/work/teamsettings/iterations?$timeframe=current&api-version=7.0"
        result = ApiClient.api_request(:get, url)
        
        if result["value"].empty?
          return ApiClient.success_response("No current sprint found")
        end
        
        s = result["value"].first
        dates = s["attributes"]
        info = [
          "**Current Sprint: #{s['name']}**", "",
          "- **Start:** #{dates['startDate']&.slice(0, 10)}",
          "- **End:** #{dates['finishDate']&.slice(0, 10)}",
          "- **Path:** #{s['path']}"
        ].join("\n")
        
        ApiClient.success_response(info)
      rescue => e
        return ApiClient.error_response("Error in GetCurrentSprintTool: #{e.message}")
      end
    end
  end
end

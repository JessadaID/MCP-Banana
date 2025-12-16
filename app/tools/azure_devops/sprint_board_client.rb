# azure_devops/sprint_board_client.rb
module AzureDevops
  class SprintBoardClient < ApiClient

    # ==================== Sprints & Boards ====================

    # def self.list_sprints(project)
    #   return error_response("Project is required") unless project
    #   encoded_project = encode_path(project)
      
    #   # Get default team ID
    #   teams_url = "https://dev.azure.com/#{organization}/_apis/projects/#{encoded_project}/teams?api-version=7.0"
    #   teams = api_request(:get, teams_url)
    #   team_id = teams["value"].first["id"]
      
    #   url = "https://dev.azure.com/#{organization}/#{encoded_project}/#{team_id}/_apis/work/teamsettings/iterations?api-version=7.0"
    #   result = api_request(:get, url)
      
    #   sprints = result["value"].map do |s|
    #     dates = s["attributes"]
    #     start_date = dates["startDate"]&.slice(0, 10) || "Not set"
    #     end_date = dates["finishDate"]&.slice(0, 10) || "Not set"
    #     "- **#{s['name']}**: #{start_date} → #{end_date} (#{dates['timeFrame']})"
    #   end.join("\n")
      
    #   success_response("Sprints in #{project}:\n\n#{sprints}")
    # end

    def self.get_current_sprint(project)
      return error_response("Project is required") unless project
      encoded_project = encode_path(project)
      
      teams_url = "https://dev.azure.com/#{organization}/_apis/projects/#{encoded_project}/teams?api-version=7.0"
      teams = api_request(:get, teams_url)
      team_id = teams["value"].first["id"]
      
      url = "https://dev.azure.com/#{organization}/#{encoded_project}/#{team_id}/_apis/work/teamsettings/iterations?$timeframe=current&api-version=7.0"
      result = api_request(:get, url)
      
      if result["value"].empty?
        return success_response("No current sprint found")
      end
      
      s = result["value"].first
      dates = s["attributes"]
      info = [
        "**Current Sprint: #{s['name']}**", "",
        "- **Start:** #{dates['startDate']&.slice(0, 10)}",
        "- **End:** #{dates['finishDate']&.slice(0, 10)}",
        "- **Path:** #{s['path']}"
      ].join("\n")
      
      success_response(info)
    end

    def self.list_boards(project)
      return error_response("Project is required") unless project
      encoded_project = encode_path(project)
      
      teams_url = "https://dev.azure.com/#{organization}/_apis/projects/#{encoded_project}/teams?api-version=7.0"
      teams = api_request(:get, teams_url)
      team_id = teams["value"].first["id"]
      
      url = "https://dev.azure.com/#{organization}/#{encoded_project}/#{team_id}/_apis/work/boards?api-version=7.0"
      result = api_request(:get, url)
      
      boards = result["value"].map { |b| "- **#{b['name']}**" }.join("\n")
      success_response("Boards in #{project}:\n\n#{boards}")
    end

    def self.get_board_columns(project)
      return error_response("Project is required") unless project
      encoded_project = encode_path(project)
      
      teams_url = "https://dev.azure.com/#{organization}/_apis/projects/#{encoded_project}/teams?api-version=7.0"
      teams = api_request(:get, teams_url)
      team_id = teams["value"].first["id"]
      
      boards_url = "https://dev.azure.com/#{organization}/#{encoded_project}/#{team_id}/_apis/work/boards?api-version=7.0"
      boards = api_request(:get, boards_url)
      board_id = boards["value"].first["id"]
      
      url = "https://dev.azure.com/#{organization}/#{encoded_project}/#{team_id}/_apis/work/boards/#{board_id}/columns?api-version=7.0"
      result = api_request(:get, url)
      
      columns = result["value"].map { |c| "- **#{c['name']}** (#{c['columnType']})" }.join("\n")
      success_response("Board Columns:\n\n#{columns}")
    end

  end
end
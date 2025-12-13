# azure_devops/project_client.rb
module AzureDevops
  class ProjectClient < ApiClient

    # ==================== Projects & Teams ====================
    
    def self.list_projects
      url = "https://dev.azure.com/#{organization}/_apis/projects?api-version=7.0"
      result = api_request(:get, url)
      projects = result["value"].map { |p| "- name : #{p['name']} ,state : #{p['state'] || 'Unknown'} ,visibility : #{p['visibility'] || 'Unknown'} ,lastUpdateTime : #{p['lastUpdateTime'] || 'Unknown'}" }.join("\n")
      
      success_response("Projects in #{organization}:\n\n#{projects}")
    end

    def self.list_team_members(project)
      return error_response("Project is required") unless project
      encoded_project = encode_path(project)
      teams_url = "https://dev.azure.com/#{organization}/_apis/projects/#{encoded_project}/teams?api-version=7.0"
      teams = api_request(:get, teams_url)
      
      all_members = teams.map do |team|
        team_members_url = "https://dev.azure.com/#{organization}/_apis/projects/#{encoded_project}/teams/#{team['id']}/members?api-version=7.0"
        members = api_request(:get, team_members_url)
        members.map { |m| m['displayName'] }
      end.flatten
      
      success_response("Team Members in #{project}:\n\n#{all_members.uniq.join("\n")}")
    end
    
    def self.get_current_user
      url = "https://dev.azure.com/#{organization}/_apis/connectionData"
      result = api_request(:get, url)
      success_response("Current User: #{result}")
    end
    
  end
end
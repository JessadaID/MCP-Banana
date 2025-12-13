# azure_devops_tool.rb
# frozen_string_literal: true

# Require clients and base
require_relative "azure_devops/api_client"
require_relative "azure_devops/project_client"
require_relative "azure_devops/work_item_client"
require_relative "azure_devops/sprint_board_client"
require_relative "azure_devops/pipeline_client"
require_relative "azure_devops/repo_client"
require_relative "azure_devops/test_plan_client"


class AzureDevopsTool < MCP::Tool
  tool_name "azure-devops-tool"
  description "Complete Azure DevOps integration: Projects, Work Items, Sprints, Boards, Pipelines, Repos, Pull Requests, Test Plans, Get current user, and Team Members."

  input_schema(
    properties: {
      action: {
        type: "string",
        enum: [
          "list_projects", "list_work_items", "get_work_item", "create_work_item", 
          "update_work_item", "delete_work_item", "list_team_members",
          "list_sprints", "get_current_sprint", "list_boards", "get_board_columns",
          "list_pipelines", "get_pipeline_runs", "run_pipeline",
          "list_repositories", "list_pull_requests", "get_pull_request",
          "list_branches", "list_commits",
          "list_test_plans", "list_test_suites", "list_test_cases",
          "add_comment", "list_comments", "get_current_user"
        ],
        description: "The action to perform"
      },
      project: { type: "string", description: "Project name" },
      work_item_id: { type: "integer", description: "Work item ID" },
      work_item_type: { 
        type: "string", 
        enum: ["Bug", "Task", "User Story", "Feature", "Epic", "Issue"],
        description: "Type of work item" 
      },
      title: { type: "string", description: "Title (for create/update)" },
      description: { type: "string", description: "Description (for create/update)" },
      state: { type: "string", description: "State (New, Active, Closed, etc.)" },
      assigned_to: { type: "string", description: "Email to assign" },
      query: { type: "string", description: "WIQL query for filtering" },
      sprint: { type: "string", description: "Sprint/Iteration path" },
      pipeline_id: { type: "integer", description: "Pipeline ID" },
      repo_name: { type: "string", description: "Repository name" },
      pull_request_id: { type: "integer", description: "Pull request ID" },
      branch: { type: "string", description: "Branch name" },
      test_plan_id: { type: "integer", description: "Test plan ID" },
      test_suite_id: { type: "integer", description: "Test suite ID" },
      comment: { type: "string", description: "Comment text" },
      count: { type: "integer", description: "Number of items to return (default 100)" }
    },
    required: ["action"]
  )

  def self.call(action:, project: nil, work_item_id: nil, work_item_type: nil,
                title: nil, description: nil, state: nil, assigned_to: nil, 
                query: nil, sprint: nil, pipeline_id: nil, repo_name: nil,
                pull_request_id: nil, branch: nil, test_plan_id: nil, 
                test_suite_id: nil, comment: nil, count: 100, server_context:)
    
    # Use PAT from Base Client
    if AzureDevops::ApiClient.pat.empty?
      return AzureDevops::ApiClient.error_response("Authentication Token (PAT) is missing. Please set AZURE_DEVOPS_PAT in your .env file and restart the server.")
    end

    begin
      case action
      # Projects & Teams (calls ProjectClient)
      when "list_projects" then AzureDevops::ProjectClient.list_projects
      when "list_team_members" then AzureDevops::ProjectClient.list_team_members(project)
      when "get_current_user" then AzureDevops::ProjectClient.get_current_user
      
      # Work Items (calls WorkItemClient)
      when "list_work_items" then AzureDevops::WorkItemClient.list_work_items(project, query, count)
      when "get_work_item" then AzureDevops::WorkItemClient.get_work_item(work_item_id)
      when "create_work_item" then AzureDevops::WorkItemClient.create_work_item(project, work_item_type, title, description, assigned_to, sprint)
      when "update_work_item" then AzureDevops::WorkItemClient.update_work_item(work_item_id, title, description, state, assigned_to, sprint)
      when "delete_work_item" then AzureDevops::WorkItemClient.delete_work_item(work_item_id)
      when "add_comment" then AzureDevops::WorkItemClient.add_comment(project, work_item_id, comment)
      when "list_comments" then AzureDevops::WorkItemClient.list_comments(project, work_item_id)
      
      # Sprints & Boards (calls SprintBoardClient)
      when "list_sprints" then AzureDevops::SprintBoardClient.list_sprints(project)
      when "get_current_sprint" then AzureDevops::SprintBoardClient.get_current_sprint(project)
      when "list_boards" then AzureDevops::SprintBoardClient.list_boards(project)
      when "get_board_columns" then AzureDevops::SprintBoardClient.get_board_columns(project)
      
      # Pipelines (calls PipelineClient)
      when "list_pipelines" then AzureDevops::PipelineClient.list_pipelines(project)
      when "get_pipeline_runs" then AzureDevops::PipelineClient.get_pipeline_runs(project, pipeline_id, count)
      when "run_pipeline" then AzureDevops::PipelineClient.run_pipeline(project, pipeline_id, branch)
      
      # Repositories & Pull Requests (calls RepoClient)
      when "list_repositories" then AzureDevops::RepoClient.list_repositories(project)
      when "list_branches" then AzureDevops::RepoClient.list_branches(project, repo_name)
      when "list_commits" then AzureDevops::RepoClient.list_commits(project, repo_name, branch, count)
      when "list_pull_requests" then AzureDevops::RepoClient.list_pull_requests(project, repo_name)
      when "get_pull_request" then AzureDevops::RepoClient.get_pull_request(project, repo_name, pull_request_id)
      
      # Test Plans (calls TestPlanClient)
      when "list_test_plans" then AzureDevops::TestPlanClient.list_test_plans(project)
      when "list_test_suites" then AzureDevops::TestPlanClient.list_test_suites(project, test_plan_id)
      when "list_test_cases" then AzureDevops::TestPlanClient.list_test_cases(project, test_plan_id, test_suite_id)
      
      else
        AzureDevops::ApiClient.error_response("Unknown action: #{action}")
      end
    rescue StandardError => e
      AzureDevops::ApiClient.error_response("Error: #{e.message}")
    end
  end
end
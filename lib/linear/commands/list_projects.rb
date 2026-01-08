module Linear
  module Commands
    module ListProjects
      extend self

      def list_projects(client: Client.new)
        result = client.query(Queries::PROJECTS)

        projects = result.dig("data", "projects", "nodes") || []
        if projects.empty?
          puts "No projects found"
        else
          Formatters.display_project_list(projects)
        end
      end
    end
  end
end

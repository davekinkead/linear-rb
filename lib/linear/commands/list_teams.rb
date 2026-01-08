module Linear
  module Commands
    module ListTeams
      extend self

      def list_teams(client: Client.new)
        result = client.query(Queries::TEAMS)

        teams = result.dig("data", "teams", "nodes") || []
        teams.each do |team|
          puts "#{team['key'].ljust(10)} #{team['name']}"
        end
      end
    end
  end
end

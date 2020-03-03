# frozen_string_literal: true

module MeiliSearch
  class Index < HTTPRequest
    module Settings

      # General routes
      def settings
        http_get "/indexes/#{@uid}/settings"
      end
      alias get_settings settings

      def update_settings(settings)
        http_post "/indexes/#{@uid}/settings", settings
      end

      def reset_settings
        http_delete "/indexes/#{@uid}/settings"
      end

      # Sub-routes ranking rules
      def ranking_rules
        http_get "/indexes/#{@uid}/settings/ranking-rules"
      end
      alias get_ranking_rules ranking_rules

      def update_ranking_rules(ranking_rules)
        http_post "/indexes/#{@uid}/settings/ranking-rules", ranking_rules
      end

      def reset_ranking_rules
        http_delete "/indexes/#{@uid}/ranking-rules"
      end


    end
  end
end

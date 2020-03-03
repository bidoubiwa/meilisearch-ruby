# frozen_string_literal: true

module MeiliSearch
  class Index < HTTPRequest
    module StopWords
      def stop_words
        http_get "/indexes/#{@uid}/stop-words"
      end
      alias get_stop_words stop_words

      def udpate_stop_words(stop_words)
        body = stop_words.is_a?(Array) ? stop_words : [stop_words]
        http_patch "/indexes/#{@uid}/stop-words", body
      end

      def reset_stop_words(stop_words)
        body = stop_words.is_a?(Array) ? stop_words : [stop_words]
        http_post "/indexes/#{@uid}/settings/stop-words", body
      end
    end
  end
end

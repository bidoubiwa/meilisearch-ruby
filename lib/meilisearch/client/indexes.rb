# frozen_string_literal: true

module MeiliSearch
  class Client < HTTPRequest
    module Indexes
      def indexes
        http_get '/indexes'
      end

      def show_index(index_uid)
        index_object(index_uid).show
      end

      # Usage:
      # create_index('name')
      # create_index(name: 'name')
      # create_index(name: 'name', uid: 'uid')
      # create_index(name: 'name', schema: {...})
      # create_index(name: 'name', uid: 'uid', schema: {...})
      def create_index(attributes)
        body = if attributes.is_a?(Hash)
                 attributes
               else
                 { name: attributes }
               end
        res = http_post '/indexes', body
        index_object(res['uid'])
      end

      def delete_index(index_uid)
        index_object(index_uid).delete
      end

      # Usage:
      # index('uid')
      # index(uid: 'uid')
      # index(name: 'name') => WARNING: the name of an index is not guaranteed to be unique. This method will return the first occurrence. We recommend using the index uid instead.
      # index(uid: 'uid', name: 'name') => only the uid field will be taken into account.
      def index(identifier)
        uid = index_uid(identifier)
        raise IndexIdentifierError if uid.nil?

        index_object(uid)
      end
      alias get_index index

      private

      def index_object(uid)
        Index.new(uid, @base_url, @api_key)
      end

      def index_uid(identifier)
        if identifier.is_a?(Hash)
          identifier[:uid] || index_uid_from_name(identifier)
        else
          identifier
        end
      end

      def index_uid_from_name(identifier)
        index = indexes.find { |i| i['name'] == identifier[:name] }
        if index.nil?
          nil
        else
          index['uid']
        end
      end
    end
  end
end

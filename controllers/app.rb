# frozen_string_literal: true

require 'roda'
module Edocument
  # Web controller for Edocument API
  class Api < Roda
    plugin :halt
    plugin :multi_route
    plugin :request_headers

    def secure_request?(routing)
      routing.scheme.casecmp(Api.config.SECURE_SCHEME).zero?
    end

     def authenticated_account(headers) #new add
      return nil unless headers['AUTHORIZATION']
      scheme, auth_token = headers['AUTHORIZATION'].split(' ')
      account_payload = AuthToken.payload(auth_token)
      scheme.match?(/^Bearer$/i) ? account_payload : nil
    end

    route do |routing|
      response['Content-Type'] = 'application/json'
      secure_request?(routing) ||
        routing.halt(403, { message: 'TLS/SSL Requested' }.to_json)
         @auth_account = authenticated_account(routing.headers) #new add

      routing.root do
        { message: 'EdocumentAPI up at /api/v1' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          @api_root = 'api/v1'
          routing.multi_route
        end
      end
    end
  end
end

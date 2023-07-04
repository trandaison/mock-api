# frozen_string_literal: true

require 'swagger_helper'

describe 'Api::V2::MesController', swagger_doc: 'v2/swagger.yaml' do
  path '/api/v2/me' do
    get 'Get my profile' do
      tags 'Auhorization'
      security [{ Authorization: [] }]
      consumes 'application/json'
      produces 'application/json'

      response '200', 'Success' do
        schema type: :object,
          properties: {
            data: {
              '$ref': '#/components/schemas/User'
            }
          },
          required: %w[data]

        let!(:user) { User.create(email: 'email@gmail.com', password: 'password', name: 'name' ) }
        let(:Authorization) { 'Bearer ' + user.issue_jwt_token }

        run_test!
      end

      response '401', 'Unauthorized' do
        schema '$ref': '#/components/schemas/Error'
        let(:Authorization) { 'Bearer -' }
        run_test!
      end
    end
  end

  path '/api/v2/me' do
    put 'Update my profile' do
      tags 'Auhorization'
      security [{ Authorization: [] }]
      consumes 'multipart/form-data'
      produces 'application/json'
      parameter name: :me, in: :body, schema: {
        type: :object,
        properties: {
          'me[name]': {
            type: :string,
            description: 'Within 50 characters'
          },
          'me[email]': {
            type: :string,
          },
          'me[password]': {
            type: :string,
            description: 'At least 8 characters'
          },
          'me[avatar]': {
            type: :string,
            format: :binary,
          }
        },
      }

      response '200', 'Success' do
        schema type: :object,
          properties: {
            data: {
              '$ref': '#/components/schemas/User'
            }
          },
          required: %w[data]
        let(:user) { User.create(email: 'email@gmail.com', password: 'password', name: 'name' ) }
        let(:Authorization) { 'Bearer ' + user.issue_jwt_token }
        let(:me) { { me: { name: 'Superman' } } }

        run_test!
      end

      response '422', 'Unprocessable request' do
        schema '$ref': '#/components/schemas/Error'

        let(:user) { User.create(email: 'email@gmail.com', password: 'password', name: 'name' ) }
        let(:Authorization) { 'Bearer ' + user.issue_jwt_token }
        let('me[email]') { 'invalid-email' }

        run_test!
      end

      response '401', 'Unauthorized' do
        schema '$ref': '#/components/schemas/Error'
        let(:Authorization) { 'Bearer -' }

        run_test!
      end
    end
  end
end

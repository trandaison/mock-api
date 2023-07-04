# frozen_string_literal: true

require 'swagger_helper'

describe 'Api::V2::Admin::UsersController', swagger_doc: 'v2/swagger.yaml' do
  path '/api/v2/admin/users' do
    post 'Creates a user' do
      tags 'Admin Users'
      security [{ Authorization: [] }]
      consumes 'multipart/form-data'
      produces 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          'email': {
            type: :string,
            example: 'someone@example.com',
            description: 'The email address'
          },
          'password': {
            type: :string,
            example: 'password',
            description: 'Password should be 8-72 characters'
          },
          'name': {
            type: :string,
            example: 'Tony Stark',
            description: 'Maximum is 50 characters'
          },
          'admin': {
            type: :boolean,
            description: 'Is admin or not. Default is `false`'
          },
          'avatar': {
            type: :string,
            format: :binary,
            description: 'User avatar'
          }
        },
        required: %w[name email password]
      }

      response '201', 'User created' do
        schema type: :object,
          properties: {
            data: {
              '$ref' => '#/components/schemas/User'
            },
          },
          required: %w[data]

        let!(:admin) { User.create(email: 'admin@gmail.com', password: 'password', name: 'name', admin: true ) }
        let(:Authorization) { 'Bearer ' + admin.issue_jwt_token }

        let(:user) { { name: 'foo1', email: 'someone@example.com', password: '12345678' } }
        run_test!
      end

      response '401', 'Unauthorize' do
        schema '$ref' => '#/components/schemas/Error'
        let(:Authorization) { 'Bearer ok' }
        let(:user) { { name: 'foo', email: 'someone@example.com', password: '12345678' } }
        run_test!
      end

      response '403', 'Fobidden' do
        schema '$ref' => '#/components/schemas/Error'
        let!(:normal_user) { User.create(email: 'user@gmail.com', password: 'password', name: 'name', admin: false ) }
        let(:Authorization) { 'Bearer ' + normal_user.issue_jwt_token }

        let(:user) { { name: 'foo', email: 'someone@example.com', password: '12345678' } }
        run_test!
      end

      response '422', 'Unprocessable entity' do
        schema '$ref' => '#/components/schemas/Error'
        let!(:admin) { User.create(email: 'admin@gmail.com', password: 'password', name: 'name', admin: true ) }
        let(:Authorization) { 'Bearer ' + admin.issue_jwt_token }
        let(:user) { { username: 'foo' } }
        run_test!
      end
    end
  end

  path '/api/v2/admin/users/{id}' do
    get 'Retrieves a user by id' do
      tags 'Admin Users'
      security [{ Authorization: [] }]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer

      response '200', 'User found' do
        schema type: :object,
          properties: {
            data: {
              '$ref': '#/components/schemas/User'
            }
          },
          required: %w[data]

        let!(:admin) { User.create(email: 'admin@gmail.com', password: 'password', name: 'name', admin: true ) }
        let(:Authorization) { 'Bearer ' + admin.issue_jwt_token }
        let(:id) { admin.id }
        run_test!
      end

      response '404', 'User not found' do
        schema '$ref': '#/components/schemas/Error'
        let!(:admin) { User.create(email: 'admin@gmail.com', password: 'password', name: 'name', admin: true ) }
        let(:Authorization) { 'Bearer ' + admin.issue_jwt_token }
        let(:id) { 0 }
        run_test!
      end
    end
  end

  path '/api/v2/admin/users' do
    get 'Retrieves users as a list' do
      tags 'Admin Users'
      security [{ Authorization: [] }]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :page, in: :query, type: :number, description: 'Page number. Default is `1`', required: false
      parameter name: :offset, in: :query, type: :number, description: 'Number of items per page. Default is `20`', required: false
      parameter name: :search, in: :query, type: :string, description: 'Search `name` or `email` containing the query', required: false
      parameter name: :sort_by, in: :query, type: :string, description: 'Valid value is one of `[id, name, email, created_at, updated_at, admin]`. Default is `created_at`', required: false
      parameter name: :sort_direction, in: :query, type: :string, description: 'Valid value is `asc` or `desc`. Default is `desc`', required: false

      response '200', 'Users found' do
        schema type: :object,
          properties: {
            data: {
              type: :object,
              properties: {
                items: {
                  type: :array,
                  items: {
                    '$ref': '#/components/schemas/User',
                    required: %w[email name avatar created_at updated_at]
                  }
                },
                pagination: {
                  '$ref': '#/components/schemas/Pagination'
                }
              },
              required: %w[items pagination]
            },
          },
          required: %w[data]

        let!(:admin) { User.create(email: 'admin@gmail.com', password: 'password', name: 'name', admin: true ) }
        let(:Authorization) { 'Bearer ' + admin.issue_jwt_token }
        run_test!
      end
    end
  end

  path '/api/v2/admin/users/{id}' do
    put 'Update a user' do
      tags 'Admin Users'
      security [{ Authorization: [] }]
      consumes 'multipart/form-data'
      produces 'application/json'
      parameter name: :id, in: :path, type: :number
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          'email': {
            type: :string,
            example: 'someone@example.com',
            description: 'The email address'
          },
          'password': {
            type: :string,
            example: 'password',
            description: 'Password should be 8-72 characters'
          },
          'name': {
            type: :string,
            example: 'Tony Stark',
            description: 'Maximum is 50 characters'
          },
          'admin': {
            type: :boolean,
            description: 'Is admin or not. Default is `false`'
          },
          'avatar': {
            type: :string,
            format: :binary,
            description: 'User avatar'
          }
        },
        required: %w[name email password]
      }

      response '200', 'User updated' do
        schema type: :object,
          properties: {
            data: {
              '$ref' => '#/components/schemas/User'
            },
          },
          required: %w[data]

        let!(:admin) { User.create(email: 'admin@gmail.com', password: 'password', name: 'name', admin: true ) }
        let(:Authorization) { 'Bearer ' + admin.issue_jwt_token }

        let(:user) { { name: 'foo', email: 'someone@example.com', password: '12345678' } }
        run_test!
      end

      response '401', 'Unauthorize' do
        schema '$ref' => '#/components/schemas/Error'
        let(:Authorization) { 'Bearer ok' }
        let(:user) { { name: 'foo', email: 'someone@example.com', password: '12345678' } }
        run_test!
      end

      response '403', 'Fobidden' do
        schema '$ref' => '#/components/schemas/Error'
        let!(:normal_user) { User.create(email: 'user@gmail.com', password: 'password', name: 'name', admin: false ) }
        let(:Authorization) { 'Bearer ' + normal_user.issue_jwt_token }

        let(:user) { { name: 'foo', email: 'someone@example.com', password: '12345678' } }
        run_test!
      end

      response '404', 'User not found' do
        schema '$ref': '#/components/schemas/Error'
        let!(:admin) { User.create(email: 'admin@gmail.com', password: 'password', name: 'name', admin: true ) }
        let(:Authorization) { 'Bearer ' + admin.issue_jwt_token }
        let(:id) { 0 }
        run_test!
      end

      response '422', 'Unprocessable entity' do
        schema '$ref' => '#/components/schemas/Error'
        let!(:admin) { User.create(email: 'admin@gmail.com', password: 'password', name: 'name', admin: true ) }
        let(:Authorization) { 'Bearer ' + admin.issue_jwt_token }
        let(:user) { { username: 'foo' } }
        run_test!
      end
    end
  end

  path '/api/v2/admin/users/{id}' do
    delete 'Delete a user' do
      tags 'Admin Users'
      security [{ Authorization: [] }]
      consumes 'application/json'
      parameter name: :id, in: :path, type: :integer

      response '204', 'User deleted' do
        let!(:admin) { User.create(email: 'admin@gmail.com', password: 'password', name: 'name', admin: true ) }
        let(:Authorization) { 'Bearer ' + admin.issue_jwt_token }

        let(:user) { { name: 'foo', email: 'someone@example.com', password: '12345678' } }
        let(:id) { user.id }
        run_test!
      end

      response '401', 'Unauthorize' do
        schema '$ref' => '#/components/schemas/Error'
        let(:Authorization) { 'Bearer ok' }
        let(:user) { { name: 'foo', email: 'someone@example.com', password: '12345678' } }
        run_test!
      end

      response '403', 'Fobidden' do
        schema '$ref' => '#/components/schemas/Error'
        let!(:normal_user) { User.create(email: 'user@gmail.com', password: 'password', name: 'name', admin: false ) }
        let(:Authorization) { 'Bearer ' + normal_user.issue_jwt_token }

        let(:user) { { name: 'foo', email: 'someone@example.com', password: '12345678' } }
        run_test!
      end

      response '404', 'User not found' do
        schema '$ref': '#/components/schemas/Error'
        let!(:admin) { User.create(email: 'admin@gmail.com', password: 'password', name: 'name', admin: true ) }
        let(:Authorization) { 'Bearer ' + admin.issue_jwt_token }
        let(:id) { 0 }
        run_test!
      end
    end
  end
end

# frozen_string_literal: true

require 'swagger_helper'

describe 'Api::V2::CommentsController', swagger_doc: 'v2/swagger.yaml' do
  path '/api/v2/blogs/{blog_id}/comments' do
    post 'Creates a comment' do
      tags 'Comments'
      security [{ Authorization: [] }]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :blog_id, in: :path, type: :number, required: true
      parameter name: :comment, in: :body, schema: {
        type: :object,
        properties: {
          'comment[content]': {
            type: :string,
            example: 'This is an awesome blog',
            description: 'Maximun length is 5000 characters'
          },
        },
        required: %w[comment[content]]
      }

      response '201', 'Comment created' do
        schema type: :object,
          properties: {
            data: {
              '$ref' => '#/components/schemas/Comment'
            },
          },
          required: %w[data]

        let!(:user) { User.create(email: 'email@gmail.com', password: 'password', name: 'name' ) }
        let(:Authorization) { 'Bearer ' + user.issue_jwt_token }

        let(:blog_id) { Blog.create(title: 'foo', content: 'bar', image: '').id }
        let(:comment) { { comment: { content: 'foo' } } }

        run_test!
      end

      response '401', 'Unauthorized' do
        schema '$ref': '#/components/schemas/Error'

        let(:Authorization) { 'Bearer ok' }
        let(:blog_id) { Blog.create(title: 'foo', content: 'bar', image: '').id }
        let(:comment) { { comment: { content: 'foo' } } }

        run_test!
      end

      response '404', 'Blog not found' do
        schema '$ref': '#/components/schemas/Error'

        let!(:user) { User.create(email: 'email@gmail.com', password: 'password', name: 'name' ) }
        let(:Authorization) { 'Bearer ' + user.issue_jwt_token }
        let(:blog_id) { 'foo' }
        let(:comment) { { comment: { content: 'foo' } } }

        run_test!
      end

      response '422', 'Unprocessable entity' do
        schema '$ref' => '#/components/schemas/Error'
        let!(:user) { User.create(email: 'email@gmail.com', password: 'password', name: 'name' ) }
        let(:Authorization) { 'Bearer ' + user.issue_jwt_token }

        let(:blog_id) { Blog.create(title: 'foo', content: 'bar', image: '').id }
        let(:comment) { { comment: { content: '' } } }

        run_test!
      end
    end
  end

  path '/api/v2/blogs/{blog_id}/comments' do
    get 'Retrieves comments as a list' do
      tags 'Comments'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :blog_id, in: :path, type: :number, required: true
      parameter name: :cursor_id, in: :query, type: :number, required: false, description: 'The ID of the last comment'
      parameter name: :sort_direction, in: :query, type: :string, required: false, description: 'Valid value is `asc` or `desc`. Default is `desc`'
      parameter name: :offset, in: :query, type: :number, required: false, description: 'Number of items per page. Default is `20`'

      response '200', 'Comments found' do
        schema type: :object,
          properties: {
            data: {
              type: :object,
              properties: {
                items: {
                  type: :array,
                  items: {
                    '$ref' => '#/components/schemas/Comment'
                  }
                }
              },
              required: %w[items]
            },
            pagination: {
              type: :object,
            },
          },
          required: %w[data pagination]

        let!(:user) { User.create(email: 'email@gmail.com', password: 'password', name: 'name' ) }
        let(:blog_id) { Blog.create(title: 'foo', content: 'bar', image: '').id }
        let!(:comment) { Comment.create(content: 'foo', blog_id: blog_id, user_id: user.id) }

        run_test!
      end
    end
  end

  path '/api/v2/comments/{id}' do
    get 'Retrieves a comment by id' do
      tags 'Comments'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer, required: true

      response '200', 'Comment found' do
        schema type: :object,
          properties: {
            data: {
              type: :object,
              '$ref' => '#/components/schemas/Comment'
            },
          },
          required: %w[data]

        let!(:user) { User.create(email: 'email@gmail.com', password: 'password', name: 'name' ) }
        let(:blog_id) { Blog.create(title: 'foo', content: 'bar', image: '').id }
        let(:comment) { Comment.create(content: 'foo', blog_id: blog_id, user_id: user.id) }
        let(:id) { comment.id }

        run_test!
      end
    end
  end

  path '/api/v2/comments/{id}' do
    put 'Update a comment' do
      tags 'Comments'
      security [{ Authorization: [] }]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :number, required: true
      parameter name: :comment, in: :body, schema: {
        type: :object,
        properties: {
          'comment[content]': {
            type: :string,
            example: 'This is new content for the comment',
            description: 'Maximun length is 5000 characters'
          },
        },
        required: %w[comment[content]]
      }

      response '200', 'Blog updated' do
        schema type: :object,
          properties: {
            data: {
              '$ref' => '#/components/schemas/Comment'
            },
          },
          required: %w[data]

        let!(:user) { User.create(email: 'email@gmail.com', password: 'password', name: 'name' ) }
        let(:Authorization) { 'Bearer ' + user.issue_jwt_token }
        let(:blog_id) { Blog.create(title: 'foo', content: 'bar', image: '').id }
        let!(:original_comment) { Comment.create(content: 'foo', blog_id: blog_id, user_id: user.id) }
        let(:id) { original_comment.id }
        let(:comment) { { comment: { content: 'new content!' } } }

        run_test!
      end

      response '401', 'Unauthorized' do
        schema '$ref': '#/components/schemas/Error'

        let!(:user) { User.create(email: 'email@gmail.com', password: 'password', name: 'name' ) }
        let(:Authorization) { 'Bearer -' }
        let(:blog_id) { Blog.create(title: 'foo', content: 'bar', image: '').id }
        let(:id) { Comment.create(content: 'foo', blog_id: blog_id, user_id: user.id).id }
        let(:comment) { { comment: { content: 'foo' } } }

        run_test!
      end

      response '404', 'Blog not found' do
        schema '$ref': '#/components/schemas/Error'

        let!(:user) { User.create(email: 'email@gmail.com', password: 'password', name: 'name' ) }
        let(:Authorization) { 'Bearer ' + user.issue_jwt_token }
        let(:id) { 'foo' }
        let(:comment) { { comment: { content: 'foo' } } }

        run_test!
      end

      response '422', 'Unprocessable entity' do
        schema '$ref' => '#/components/schemas/Error'
        let!(:user) { User.create(email: 'email@gmail.com', password: 'password', name: 'name' ) }
        let(:Authorization) { 'Bearer ' + user.issue_jwt_token }
        let(:blog_id) { Blog.create(title: 'foo', content: 'bar', image: '').id }
        let(:id) { Comment.create(content: 'foo', blog_id: blog_id, user_id: user.id).id }
        let(:comment) { { comment: { content: "invalid-length" * 400 } } }

        run_test!
      end
    end
  end

  path '/api/v2/comments/{id}' do
    delete 'Delete a comment' do
      tags 'Comments'
      consumes 'application/json'
      produces 'application/json'
      security [{ Authorization: [] }]
      parameter name: :id, in: :path, type: :integer

      response '204', 'Blog deleted' do
        let!(:user) { User.create(email: 'email@gmail.com', password: 'password', name: 'name' ) }
        let(:Authorization) { 'Bearer ' + user.issue_jwt_token }
        let(:blog_id) { Blog.create(title: 'foo', content: 'bar', image: '').id }
        let(:comment) { Comment.create(content: 'foo', blog_id: blog_id, user_id: user.id) }
        let(:id) { comment.id }

        run_test!
      end

      response '401', 'Unauthorized' do
        schema '$ref': '#/components/schemas/Error'

        let(:Authorization) { 'Bearer ok' }
        let(:id) { 1 }

        run_test!
      end

      response '403', 'Forbidden' do
        let!(:user) { User.create(email: 'email@gmail.com', password: 'password', name: 'name' ) }
        let(:Authorization) { 'Bearer ' + user.issue_jwt_token }
        let!(:user2) { User.create(email: 'email2@gmail.com', password: 'password', name: 'name' ) }
        let(:blog_id) { Blog.create(title: 'foo', content: 'bar', image: '').id }
        let(:comment) { Comment.create(content: 'foo', blog_id: blog_id, user_id: user2.id) }
        let(:id) { comment.id }

        run_test!
      end

      response '404', 'Comment not found' do
        schema '$ref': '#/components/schemas/Error'

        let!(:user) { User.create(email: 'email@gmail.com', password: 'password', name: 'name' ) }
        let(:Authorization) { 'Bearer ' + user.issue_jwt_token }
        let(:id) { 'foo' }

        run_test!
      end
    end
  end
end

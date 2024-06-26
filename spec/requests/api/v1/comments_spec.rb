require 'rails_helper'

RSpec.describe 'Comments API', type: :request do
  let!(:user) { create(:user) }
  let!(:post) { create(:post, user: user) }
  let!(:comments) { create_list(:comment, 10, post: post, user: user) }
  let(:post_id) { post.id }
  let(:id) { comments.first.id }
  let(:headers) { valid_headers }

  describe 'GET /posts/:post_id/comments' do
    before { get "/posts/#{post_id}/comments", headers: headers }

    context 'when post exists' do
      it 'returns comments' do
        expect(json).not_to be_empty
        expect(json.size).to eq(10)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when post does not exist' do
      let(:post_id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Post/)
      end
    end
  end

  describe 'GET /posts/:post_id/comments/:id' do
    before { get "/posts/#{post_id}/comments/#{id}", headers: headers }

    context 'when post comment exists' do
      it 'returns the comment' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when post comment does not exist' do
      let(:id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Comment/)
      end
    end
  end

  describe 'POST /posts/:post_id/comments' do
    let(:valid_attributes) { { body: 'Great post!' }.to_json }

    context 'when request attributes are valid' do
      before { post "/posts/#{post_id}/comments", params: valid_attributes, headers: headers }

      it 'creates a comment' do
        expect(json['body']).to eq('Great post!')
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when an invalid request' do
      before { post "/posts/#{post_id}/comments", params: {}, headers: headers }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body).to match(/Validation failed: Body can't be blank/)
      end
    end
  end

  describe 'PUT /posts/:post_id/comments/:id' do
    let(:valid_attributes) { { body: 'Updated comment' }.to_json }

    before { put "/posts/#{post_id}/comments/#{id}", params: valid_attributes, headers: headers }

    context 'when comment exists' do
      it 'updates the comment' do
        expect(response.body).to be_empty
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end

    context 'when the comment does not exist' do
      let(:id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Comment/)
      end
    end
  end

  describe 'DELETE /posts/:post_id/comments/:id' do
    before { delete "/posts/#{post_id}/comments/#{id}", headers: headers }

    it 'returns status code 204' do
      expect(response).to have_http_status(204)
    end
  end
end

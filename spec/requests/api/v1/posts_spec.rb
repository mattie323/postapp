require 'rails_helper'

RSpec.describe 'API::V1::Posts API', type: :request do
  let!(:user) { create(:user) }
  let!(:posts) { create_list(:post, 10, user: user) }
  let(:post_id) { posts.first.id }
  let(:headers) { valid_headers }

  describe 'GET /api/v1/posts' do
    before { get '/api/v1/posts', headers: headers }

    it 'returns posts' do
      expect(json).not_to be_empty
      expect(json.size).to eq(10)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /api/v1/posts/:id' do
    before { get "/api/v1/posts/#{post_id}", headers: headers }

    context 'when the record exists' do
      it 'returns the post' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(post_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:post_id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Post/)
      end
    end
  end

  describe 'POST /api/v1/posts' do
    let(:valid_attributes) { { title: 'Test Title', body: 'Test Body' }.to_json }

    context 'when the request is valid' do
      before { post '/api/v1/posts', params: valid_attributes, headers: headers }

      it 'creates a post' do
        expect(json['title']).to eq('Test Title')
        expect(json['body']).to eq('Test Body')
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is invalid' do
      before { post '/api/v1/posts', params: { title: nil }.to_json, headers: headers }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body).to match(/Validation failed: Title can't be blank/)
      end
    end
  end

  describe 'PUT /api/v1/posts/:id' do
    let(:valid_attributes) { { title: 'Updated Title' }.to_json }

    context 'when the record exists' do
      before { put "/api/v1/posts/#{post_id}", params: valid_attributes, headers: headers }

      it 'updates the record' do
        expect(response.body).to be_empty
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end

    context 'when the record does not exist' do
      let(:post_id) { 0 }

      before { put "/api/v1/posts/#{post_id}", params: valid_attributes, headers: headers }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Post/)
      end
    end
  end

  describe 'DELETE /api/v1/posts/:id' do
    before { delete "/api/v1/posts/#{post_id}", headers: headers }

    it 'returns status code 204' do
      expect(response).to have_http_status(204)
    end
  end
end

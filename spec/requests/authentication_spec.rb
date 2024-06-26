require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  let!(:user) { create(:user) }
  let(:headers) { valid_headers.except('Authorization') }
  let(:valid_credentials) do
    {
      email: user.email,
      password: user.password
    }.to_json
  end
  let(:invalid_credentials) do
    {
      email: 'foo',
      password: 'bar'
    }.to_json
  end

  describe 'POST /signin' do
    context 'when request is valid' do
      before { post '/signin', params: valid_credentials, headers: headers }

      it 'returns an authentication token' do
        expect(json['token']).not_to be_nil
      end
    end

    context 'when request is invalid' do
      before { post '/signin', params: invalid_credentials, headers: headers }

      it 'returns a failure message' do
        expect(json['errors']).to match(/Invalid email or password/)
      end
    end
  end
end

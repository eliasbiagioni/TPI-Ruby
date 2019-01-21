require 'rails_helper'

RSpec.describe 'Create users', :type => :request do
	describe 'POST /users' do
		before do
			headers = {'Content-Type' => 'application/json'}
		end

		it 'returns 422 status, password missing' do
			params = { "user" => {
    			"email": "test@hotmail.com",
    			"username": "test",
    			"screen_name": "tt",
    			 } }
			post("/users", params: params, headers: headers)
			expect(JSON.parse(response.body)["errors"][0]['title']).to eql("Password can't be blank")
			expect(response).to have_http_status(:unprocessable_entity)
		end

		it 'returns 422 status, email is wrong' do
			params = { "user" => {
    			"email": "testhotmail.com",
    			"username": "test",
    			"screen_name": "tt",
    			"password": "1234"} }
			post("/users", params: params, headers: headers)
			expect(JSON.parse(response.body)["errors"][0]['title']).to eql("Email is invalid")
			expect(response).to have_http_status(:unprocessable_entity)
		end

		it 'creates user' do
			params = { "user" => {
    			"email": "test@hotmail.com",
    			"username": "test",
    			"screen_name": "tt",
    			"password": "1234"} }
			post("/users", params: params, headers: headers)
			expect(response).to have_http_status(:created)
		end
	end
end
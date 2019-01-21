require 'rails_helper'

RSpec.describe "Create new session" do
	describe "POST /sessions with invalid credentials" do
		it "returns 401 unauthorized" do
			headers = { "Content-Type" => "application/json" }
			params = { :email => 'elias@hotmail.com', :password => 'contraseña' }
			post "/sessions", params: params.to_json, headers: headers
			expect(JSON.parse(response.body)['error']['user_authentication'][0]).to eql("invalid credentials")
			expect(response).to have_http_status(:unauthorized)
		end
	end

	describe "POST /sessions with valid credentials" do
		it "returns 200 ok" do
			headers = { "Content-Type" => "application/json" }
			params = { :email => 'elias@hotmail.com', :password => 'contra' }
			post "/sessions", params: params.to_json, headers: headers
			expect(response).to have_http_status(:ok)
			expect(JSON.parse(response.body)['data']['attributes']['token']).not_to be(nil)
		end
	end
end
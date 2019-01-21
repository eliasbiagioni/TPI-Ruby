require 'rails_helper'

RSpec.describe 'PUT and DELETE question requests', :type => :request do
	before :all do
		#New session with two diferents users
		headers = {"Content-Type" => "application/json"}
		params = { :email => 'elias@hotmail.com', :password => 'contra' }
		post "/sessions", params: params.to_json, headers: headers
		@auth_token_elias = JSON.parse(response.body)['data']['attributes']['token']
		params = { :email => 'otro@hotmail.com', :password => 'alsina' }
		post "/sessions", params: params.to_json, headers: headers
		@auth_token_otro = JSON.parse(response.body)['data']['attributes']['token']

		#GET a question id to update/delete
		get("/questions?sort=needing_help")
		@question_id = ((JSON.parse(response.body))['data'].first)['id']
	end


	describe 'PUT /questions/:id' do
		it 'returns 200 status code' do
			headers = {"Content-Type" => "application/json", "X-QA-Key" => @auth_token_elias}
			put "/questions/#{@question_id}", params: {description: 'Descripcion actualizada test'}.to_json, headers: headers
			expect(JSON.parse(response.body)['data']['attributes']['description']).to eql("Descripcion actualizada test")
		end

		it 'returns 401 status code because the user who wants to update the question is not the one who created it' do
			headers = {"Content-Type" => "application/json", "X-QA-Key" => @auth_token_otro}
			put "/questions/#{@question_id}", params: {description: 'Descripcion actualizada test'}.to_json, headers: headers
			expect(response).to have_http_status(:unauthorized)
		end
	end

	describe 'DELETE /questions/:id' do
		it 'returns 401 status code because the user who wants to update the question is not the one who created it' do
			headers = {"Content-Type" => "application/json", "X-QA-Key" => @auth_token_otro}
			delete "/questions/#{@question_id}", headers: headers
			expect(response).to have_http_status(:unauthorized)
		end

		it 'returns 403 status code because the question has, at least, one answer' do
			headers = {"Content-Type" => "application/json", "X-QA-Key" => @auth_token_elias}
			delete "/questions/#{@question_id}", headers: headers
			expect(response).to have_http_status(:forbidden)
		end

		it 'delete the question' do
			headers = {"Content-Type" => "application/json", "X-QA-Key" => @auth_token_elias}
			get("/questions")
			delete_question_id = ((JSON.parse(response.body))['data'].first)['id']

			get("/questions")
			expect(JSON.parse(response.body)['data'].length).to eql(3)
			delete "/questions/#{delete_question_id}", headers: headers
			get("/questions")
			expect(JSON.parse(response.body)['data'].length).to eql(2)
		end
	end

end
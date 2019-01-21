require 'rails_helper'

RSpec.describe 'Resolve question' do
	before :all do
		#New session with two diferents users
		headers = {"Content-Type" => "application/json"}
		params = { :email => 'elias@hotmail.com', :password => 'contra' }
		post "/sessions", params: params.to_json, headers: headers
		@auth_token_elias = JSON.parse(response.body)['data']['attributes']['token']
		params = { :email => 'otro@hotmail.com', :password => 'alsina' }
		post "/sessions", params: params.to_json, headers: headers
		@auth_token_otro = JSON.parse(response.body)['data']['attributes']['token']

		#GET a question id, this question is not resolved
		get("/questions?sort=needing_help")
		@first_question_id = ((JSON.parse(response.body))['data'].first)['id']
		@last_question_id = ((JSON.parse(response.body))['data'].last)['id']

		#GET an answer id, this becomes to the question obtained previously
		get("/questions/#{@first_question_id}?answers")
		@first_answer_id = JSON.parse(response.body)['data']['relationships']['answers']['data'][0]['id']
		get("/questions/#{@last_question_id}?answers")
		@last_answer_id = JSON.parse(response.body)['data']['relationships']['answers']['data'][0]['id']
	end

	describe 'PUT /questions/:id/resolve' do
		it 'returns 401 status code because the user who wants to update the question is not the one who created it' do
			headers = {"Content-Type" => "application/json", "X-QA-Key" => @auth_token_otro}
			put "/questions/#{@first_question_id}/resolve", params: {"answer_id" => @first_answer_id}.to_json, headers: headers
			expect(response).to have_http_status(:unauthorized)
		end

		it 'returns 403 status code because the answer id is not related with that question' do
			headers = {"Content-Type" => "application/json", "X-QA-Key" => @auth_token_elias}
			put "/questions/#{@first_question_id}/resolve", params: {"answer_id" => @last_answer_id}.to_json, headers: headers
			expect(response).to have_http_status(:forbidden)
		end

		it 'resolve a question' do
			get("/questions/#{@first_question_id}")
			expect((JSON.parse(response.body))['data']['attributes']['status']).to eql(false)
			headers = {"Content-Type" => "application/json", "X-QA-Key" => @auth_token_elias}
			put "/questions/#{@first_question_id}/resolve", params: {"answer_id" => @first_answer_id}.to_json, headers: headers
			expect(JSON.parse(response.body)['data']['relationships']['answer']['data']['id']).to eql(@first_answer_id)
			expect((JSON.parse(response.body))['data']['attributes']['status']).to eql(true)
		end
	end
end
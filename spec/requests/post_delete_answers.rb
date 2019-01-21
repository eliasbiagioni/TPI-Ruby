require 'rails_helper'

RSpec.describe 'POST/DELETE answers' do
	before :all do
		#New session with two diferents users
		@headers = {"Content-Type" => "application/json"}
		params = { :email => 'elias@hotmail.com', :password => 'contra' }
		post "/sessions", params: params.to_json, headers: @headers
		@auth_token_elias = JSON.parse(response.body)['data']['attributes']['token']
		params = { :email => 'otro@hotmail.com', :password => 'alsina' }
		post "/sessions", params: params.to_json, headers: @headers
		@auth_token_otro = JSON.parse(response.body)['data']['attributes']['token']
	end

	describe 'POST /questions/:question_id/answers' do
		it 'returns 422 status because the question is resolved' do
			#GET a resolved question id
			get("/questions")
			resolved_question_id = (JSON.parse(response.body)['data'].first)['id']
			
			@headers.merge!({"X-QA-Key" => @auth_token_otro})
			post "/questions/#{resolved_question_id}/answers", params: {"content" => "Nueva respuesta test"}.to_json, headers: @headers
			expect(response).to have_http_status(:unprocessable_entity)
		end

		it 'save the answer' do
			#GET a question id
			get("/questions")
			question_id = (JSON.parse(response.body)['data'].last)['id']
			expect((JSON.parse(response.body)['data'].last)['attributes']['number_of_answers']).to eql(1)
			post "/questions/#{question_id}/answers", params: {"content" => "Nueva respuesta test"}.to_json, headers: @headers

			expect((JSON.parse(response.body)['data'])['attributes']['content']).to eql('Nueva respuesta test')
			expect(((JSON.parse(response.body)['data'])['relationships']['user']['data']['id']).to_i).to eql(JsonWebToken.decode(@auth_token_otro)['user_id'])
			get("/questions")
			expect((JSON.parse(response.body)['data'].last)['attributes']['number_of_answers']).to eql(2)
		end
	end

	describe 'DELETE /questions/:question_id/answers/:id' do
		it 'returns unauthorized status because de user who wants to delete the answers is not the owner of it' do
			#GET a question id
			get("/questions")
			question_id = (JSON.parse(response.body)['data'].last)['id']
			get("/questions/#{question_id}/answers")
			
			answer_id = (JSON.parse(response.body)['data'].first)['id']
			@headers['X-QA-Key'] = @auth_token_elias
			delete "/questions/#{question_id}/answers/#{answer_id}", headers: @headers
			expect(response).to have_http_status(:unauthorized)
		end

		it 'returns forbidden status because the question is resolved' do
			#First, set a question as resolved
			#GET a question id
			get("/questions")
			question_id = (JSON.parse(response.body)['data'].last)['id']
			get("/questions/#{question_id}/answers")
			answer_id = JSON.parse(response.body)['data'][0]['id']
			@headers.merge!({"X-QA-Key" => @auth_token_elias})
			put "/questions/#{question_id}/resolve", params: {"answer_id" => answer_id}.to_json, headers: @headers
			
			#Try to delete the question
			@headers['X-QA-Key'] = @auth_token_otro
			delete "/questions/#{question_id}/answers/#{answer_id}", headers: @headers
			expect(response).to have_http_status(:forbidden)
		end

		it 'delete an answer' do
			#GET a question id
			get("/questions")
			question_id = (JSON.parse(response.body)['data'].last)['id']
			expect((JSON.parse(response.body)['data'].last)['attributes']['number_of_answers']).to eql(1)

			get("/questions/#{question_id}/answers")
			answer_id = JSON.parse(response.body)['data'][0]['id']
			delete "/questions/#{question_id}/answers/#{answer_id}", headers: @headers
			get("/questions")
			expect((JSON.parse(response.body)['data'].last)['attributes']['number_of_answers']).to eql(0)
		end
	end
end
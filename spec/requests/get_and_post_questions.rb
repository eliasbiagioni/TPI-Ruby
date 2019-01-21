require 'rails_helper'

RSpec.describe 'Question list', :type => :request do
	describe 'GET /questions' do
		before :all do
			Answer.destroy_all
			Question.destroy_all
		end

		it 'returns an empty questions list' do
			get('/questions')
			json = JSON.parse(response.body)
			expect(json['data'].length).to eql(0)
			expect(response).to have_http_status(:success)
		end

	end

	describe 'GET /questions after posting a question' do		
		it 'returns a 401 status as no token authentication is sent' do
			headers = { "Content-Type" => "application/json" }
			params = { :question => { :title => 'Test...', :description => 'Pregunta test'}}
			post "/questions", params: params.to_json, headers: headers
			expect(response).to have_http_status(:unauthorized)
		end

		it 'creates a new question' do
			#Authentication
			headers = {"Content-Type" => "application/json"}
			params = { :email => 'elias@hotmail.com', :password => 'contra' }
			post "/sessions", params: params.to_json, headers: headers
			json_response = JSON.parse(response.body)

			#Post a question
			headers = {"Content-Type" => "application/json", "X-QA-Key" => json_response['data']['attributes']['token']}
			params = { :question => { :title => 'Test...', :description => 'Pregunta test'}}
			post "/questions", params: params.to_json, headers: headers
			current_user = JsonWebToken.decode(json_response['data']['attributes']['token'])['user_id']
			expect(response).to have_http_status(:created)
			expect(current_user).to eql(JSON.parse(response.body)['data']['relationships']['user']['data']['id'].to_i)

			#Test that now the questions list has 1 question.
			get('/questions')
			json = JSON.parse(response.body)
			expect(json['data'].length).to eql(1)
			expect(response).to have_http_status(:success)
		end
	end

	describe 'GET /questions and GET /questions/:id with created questions'  do
		#POST some questions
		before :all  do			
			#Authentication
			headers = {"Content-Type" => "application/json"}
			params = { :email => 'elias@hotmail.com', :password => 'contra' }
			post "/sessions", params: params.to_json, headers: headers
			@elias_auth_token = JSON.parse(response.body)['data']['attributes']['token']
			
			#Post some questions
			headers = {"Content-Type" => "application/json", "X-QA-Key" => @elias_auth_token}
			post "/questions", params: { :question => { :title => 'Pregunta 1', :description => 'Pregunta test 1', :created_at => '2019-01-18 10:45:02', :status => 0}}.to_json, headers: headers
			post "/questions", params: { :question => { :title => 'Pregunta 2', :description => 'Pregunta test 2', :created_at => '2019-01-16 10:45:02', :status => 1}}.to_json, headers: headers
			post "/questions", params: { :question => { :title => 'Pregunta 3', :description => 'Pregunta test 3', :created_at => '2019-01-17 10:45:02', :status => 0}}.to_json, headers: headers
		end

		#POST an answer to some questions
		before :all do
			#GET question id
			get("/questions")
			first_question_id = ((JSON.parse(response.body))['data'].last)['id']
			last_question_id = ((JSON.parse(response.body))['data'][1])['id']
			#second_question_id = ((JSON.parse(response.body))['data'].first)['id']

			#POST an answer to that question id
			headers = {"Content-Type" => "application/json"}
			params = { :email => 'otro@hotmail.com', :password => 'alsina' }
			post "/sessions", params: params.to_json, headers: headers
			otro_auth_token = JSON.parse(response.body)['data']['attributes']['token']
			headers.merge!({"X-QA-Key" => otro_auth_token})
			post "/questions/#{first_question_id}/answers", params: { :content => 'Respuesta pregunta 1'}.to_json, headers: headers
			post "/questions/#{last_question_id}/answers", params: { :content => 'Respuesta pregunta 3'}.to_json, headers: headers
			#post "/questions/#{second_question_id}/answers", params: { :content => 'Respuesta pregunta 2'}.to_json, headers: headers
		end

		it 'get questions ordered by creation date, from the newest to the oldest' do
			get('/questions?sort=latest')
			json = JSON.parse(response.body)
			expect(((json)['data'].first)['attributes']['title']).to eql("Pregunta 2")
			expect(((json)['data'].last)['attributes']['title']).to eql("Pregunta 1")
		end		

		it 'get questions prioritizing resolved questions' do
			get('/questions?sort=pending_first')
			expect(((JSON.parse(response.body))['data'].last)['attributes']['title']).to eql("Pregunta 2")
		end

		it 'get only questions that are not been resolved' do
			get('/questions?sort=needing_help')
			json = JSON.parse(response.body)
			expect(((json)['data'].first)['attributes']['title']).to eql("Pregunta 1")
			expect(((json)['data'].last)['attributes']['title']).to eql("Pregunta 3")
			expect(((json)['data']).length).to eql(2)
		end

		it 'returns an error because question does not exist' do
			get('/questions/546')
			expect(response).to have_http_status(:not_found) 
		end 

		it 'returns the question without answers' do
			#GET a question id
			get("/questions?sort=needing_help")
			question_id = ((JSON.parse(response.body))['data'].first)['id']

			#GET the question
			get("/questions/#{question_id}")
			json = JSON.parse(response.body)
			expect(json['data']['attributes']['number_of_answers']).to eql(1)
			expect(json['included']).to eql(nil)
		end

		it 'returns the question with answers' do
			#GET a question id
			get("/questions?sort=needing_help")
			question_id = ((JSON.parse(response.body))['data'].first)['id']

			#GET the question
			get("/questions/#{question_id}?answers")
			json = JSON.parse(response.body)
			expect(json['data']['attributes']['number_of_answers']).to eql(1)
			expect(json['included']).not_to eql(nil)
			expect(json['included'][0]['type']).to eql('answer')
			expect(json['included'][0]['attributes']['content']).to eql('Respuesta pregunta 1')
		end

		it 'returns the answers of a question' do
			#GET a question id
			get("/questions?sort=needing_help")
			question_id = ((JSON.parse(response.body))['data'].first)['id']

			#GET the answers
			get("/questions/#{question_id}/answers")
			expect(response).to have_http_status(:ok)
			expect(JSON.parse(response.body)['data'][0]['attributes']['content']).to eql('Respuesta pregunta 1')			
		end
	end
end
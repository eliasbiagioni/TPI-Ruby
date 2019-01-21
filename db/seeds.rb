# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
User.create!(email: "elias@hotmail.com", password: "contra", username: "eliasb", screen_name: "eb7")
User.create!(email: "otro@hotmail.com", password: "alsina", username: "otroguacho", screen_name: "og")
#Question.create!(title: "Como estas?", description: "Responde u2", user_id: (User.find_by_email("elias@hotmail.com")).id)
#Question.create!(title: "Vamos a ver a Boca?", description: "Responde u1", user_id: (User.find_by_email("otro@hotmail.com")).id)
#Answer.create!(content: "Bien bien", user_id: (User.find_by_email("otro@hotmail.com")).id, question_id: 1)
#Answer.create!(content: "Si de una", user_id: (User.find_by_email("elias@hotmail.com")).id, question_id: 2)
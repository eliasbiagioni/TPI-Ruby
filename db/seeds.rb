# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
u1 = User.create!(email: "elias@hotmail.com", password: "contra", username: "eliasb", screen_name: "eb7")
u2 = User.create!(email: "otro@hotmail.com", password: "alsina", username: "otroguacho", screen_name: "og")
q1 = Question.create!(title: "Como estas?", description: "Responde u2", user_id: 1)
q2 = Question.create!(title: "Vamos a ver a Boca?", description: "Responde u1", user_id: 2)
a1 = Answer.create!(content: "Bien atrrr", user_id: 2, question_id: 1)
a2 = Answer.create!(content: "Si de una guacho", user_id: 1, question_id: 2)
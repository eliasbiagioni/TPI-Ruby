# TRABAJO INTEGRADOR 

1. Se utiliza mysql2 para persistencia.
2. Correr bundle install para instalar las gemas necesarias.
3. Correr bundle exec figaro install para crear el archivo config/application.yml
4. En el archivo config/application.yml escribir:
```
	development:
	    BD_USERNAME: nombre_de_usuario_de_su_bd
	    BD_PASSWORD: contraseña_de_su_bd
	    SECRET_KEY: ejecutar rake secret y pegar aca el token generado. Se utiliza para la secret_key_base.
```
5. La base de datos se llama TPI_Ruby_development, debe ser creada.
6. Los endpoints creados son:
```
	POST /users
	POST /sessions
	GET /questions	
	GET /questions/:id
	POST /questions
	PUT /questions/:id
	DELETE /questions/:id
```
restan los demas endpoints y los tests.
ACLARACIóN: el token expira 30 min después que se inicia sesión.
# TRABAJO INTEGRADOR 

1. Se utiliza postgresql para persistencia. Ejecutar el siguiente comando para instalar las dependencias de postgresql:
```
	sudo apt-get install libpq-dev
```
2. Correr ``` bundle install``` para instalar las gemas necesarias.
3. Correr ``` bundle exec figaro``` install para crear el archivo config/application.yml
4. En el archivo config/application.yml escribir:
```
	development:
	    BD_USERNAME: nombre_de_usuario_de_su_bd
	    BD_PASSWORD: contraseña_de_su_bd
	    SECRET_KEY: ejecutar rake secret y pegar aca el token generado. Se utiliza para la secret_key_base.

	test:
		BD_USERNAME: nombre_de_usuario_de_su_bd
	    BD_PASSWORD: contraseña_de_su_bd
	    SECRET_KEY: ejecutar rake secret y pegar aca el token generado. Se utiliza para la secret_key_base.
```
5. Para crear la base de datos correr:
```
rails db:create db:migrate db:seed
```
db:seed crea 2 usuarios en la base de datos. En el archivo db/seeds.rb se encuentran los usuarios para loguearse.
6. Los tests fueron hechos con rspec, los mismos estan ubicados en spec/requests. Para correr los tests, ejecutar:
```
	rspec spec/requests/*.rb
```
ACLARACION: el token expira 30 min después que se inicia sesión.
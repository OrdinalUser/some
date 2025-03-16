app: app.c some.c
	gcc app.c some.c -o app -O2

run: app
	./app -p "$(shell pwd)/././././some.c"
clean:
	rm app
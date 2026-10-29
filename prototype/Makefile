.PHONY: all run clean

bin/app: src/app.c src/some.c
	mkdir -p bin
	gcc src/app.c src/some.c -o bin/app -I include/some -O2

run: bin/app
	./bin/app -p $(ARGS)

clean:
	rm -r bin

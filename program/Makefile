.PHONY: all run clean

bin/app: bin/app.o bin/some.o
	gcc -m64 -no-pie bin/app.o bin/some.o -o bin/app -O2

bin/app.o: src/app.asm | bin
	nasm -f elf64 src/app.asm -o bin/app.o

bin/some.o: src/some.asm | bin
	nasm -f elf64 src/some.asm -o bin/some.o

run: bin/app
	./bin/app -p $(ARGS)

bin:
	mkdir -p bin

clean:
	rm -rf bin

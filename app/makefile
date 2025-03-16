app: app.o some.o
	gcc -m64 -no-pie app.o some.o -o app

app.o: app.asm
	nasm -f elf64 app.asm

some.o: some.asm
	nasm -f elf64 some.asm

run: app
	./app -p "$(shell pwd)/./././././././some.asm"

clean:
	rm *.o
	rm app
asm-ws: main.o request.o io.o utils.o
	ld main.o request.o io.o utils.o -o asm-ws
main.o: main.asm
	nasm -f elf64 main.asm -o main.o
request.o: request.asm
	nasm -f elf64 request.asm -o request.o
io.o: io.asm
	nasm -f elf64 io.asm -o io.o
utils.o: utils.asm
	nasm -f elf64 utils.asm -o utils.o
clean:
	rm -f *.o
	rm -f asm-ws

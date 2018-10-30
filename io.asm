[BITS 64]

extern CLIENT_DESCRIPTOR
extern PATH
extern print_string
extern int_to_str

section .rdata
	INDEX_html DB "index.html", 0

	OK_RESP1 DB "HTTP/1.1 200 OK", 13, 10, 0
	OK_RESP2 DB "Content-Length: ", 0
	OK_RESP3 DB 13, 10, 13, 10, 0

	ERR_RESP DB "HTTP/1.1 404 Not Found", 13, 10, 13, 10, 0
	
	DONE_MSG DB "File Served!", 13, 10, 0
	ERR_MSG DB "File ERROR!", 13, 10, 0

section .data
	TO_SERVE DQ 0
	MIME_TYPE DQ 0
	CONTENT_LENGTH DQ 0
	CONTENT_LENGTH_SIZE DQ 0
	THE_FILE_SIZE DQ 0

section .bss
	THE_FILE RESB 10000000

section .text

global serve_file
serve_file:
	index_check:
		cmp byte [PATH], '/'
		je index_check2

		index_check2:
			cmp byte [PATH+1], 0
			je set_index_html
		
		inc rdi
		
	really_serve:
		mov [TO_SERVE], rdi
		
		mov rax, 2 ; open()

		mov rdi, [TO_SERVE]
		mov rsi, 0
		
		syscall
		
		cmp rax, 0
		jl error_404

		mov rdi, rax

		mov rax, 0 ; read()
	
		mov rsi, THE_FILE
		mov rdx, 10000000

		syscall

		mov [THE_FILE_SIZE], rax

		mov rax, 3 ; close()
		syscall

		mov rdi, [THE_FILE_SIZE]
		call int_to_str

		mov [CONTENT_LENGTH], rax
		mov [CONTENT_LENGTH_SIZE], rbx


		mov rax, 1 ; write()

		mov rdi, [CLIENT_DESCRIPTOR]
		mov rsi, OK_RESP1
		mov rdx, 17
	
		syscall

		mov rax, 1 ; write()

		mov rdi, [CLIENT_DESCRIPTOR]
		mov rsi, OK_RESP2
		mov rdx, 16

		syscall

		mov rax, 1 ; write()

		mov rdi, [CLIENT_DESCRIPTOR]
		mov rsi, [CONTENT_LENGTH]
		mov rdx, [CONTENT_LENGTH_SIZE]

		syscall

		mov rax, 1 ; write()
	
		mov rdi, [CLIENT_DESCRIPTOR]
		mov rsi, OK_RESP3
		mov rdx, 4

		syscall

		mov rax, 1 ; write()

		mov rdi, [CLIENT_DESCRIPTOR]
		mov rsi, THE_FILE
		mov rdx, [THE_FILE_SIZE]

		syscall

		mov rdi, DONE_MSG
		call print_string

	serve_end:
		mov rax, 0
		ret

	set_index_html:
		mov rdi, INDEX_html
		jmp really_serve

	error_404:
		mov rax, 1

		mov rdi, [CLIENT_DESCRIPTOR]
		mov rsi, ERR_RESP
		mov rdx, 26

		syscall

		mov rdi, ERR_MSG
		call print_string

		jmp serve_end


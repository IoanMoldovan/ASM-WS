[BITS 64]

extern CLIENT_STRUCT
extern REQUEST
extern print_string
extern int_to_str

extern serve_file

section .rdata
	msg_connection_from db "Got a connection from: ", 0
	parsing_msg db "Parsing ", 0
	parsing_err db "A request parsing error has occoured", 13, 10, 0

	path_msg db "Serving: ", 0
	path_err db "Failed to decode path", 13, 10, 0

	dot db ".", 0
	newline db 13, 10, 0	

section .bss
	METHOD RESB 20
	global PATH
	PATH RESB 256
	
section .text
global process_request
process_request:
	mov rdi, msg_connection_from
	call print_string
	
	print_out_ip:
		mov rdx, 0
		mov byte dl, [CLIENT_STRUCT + 4]
		mov rdi, rdx
		call int_to_str

		mov rdi, rax
		call print_string

		mov rdi, dot
		call print_string

		mov rdx, 0
        	mov byte dl, [CLIENT_STRUCT + 5]
		mov rdi, rdx
        	call int_to_str

	        mov rdi, rax
	        call print_string

		mov rdi, dot
		call print_string

		mov rdx, 0
	        mov byte dl, [CLIENT_STRUCT + 6]
	        mov rdi, rdx
	        call int_to_str

		mov rdi, rax
		call print_string

	        mov rdi, dot
	        call print_string

		mov rdx, 0
	        mov byte dl, [CLIENT_STRUCT + 7]
	        mov rdi, rdx
	        call int_to_str

	        mov rdi, rax
	        call print_string
	
		mov rdi, newline
		call print_string

	parse_request:
		call clear_stuff

		mov rsi, 0
		mov rax, 0

		get_method:
			mov byte al, [REQUEST + rsi]
			cmp al, ' '
			je term_method
			mov byte [METHOD + rsi], al
			inc rsi

			cmp rsi, 15
			jge parsing_error

			jmp get_method

		term_method:
			mov byte [METHOD + rsi], 0
			inc rsi

			mov rbx, rsi

			mov rdi, parsing_msg
			call print_string

			mov rdi, METHOD
			call print_string

			mov rdi, newline
			call print_string

			mov rsi, rbx
			mov rdi, 0

		get_path:
                        mov byte al, [REQUEST + rsi]
                        cmp al, ' '
                        je term_path
                        mov byte [PATH + rdi], al
                        inc rsi
			inc rdi

                        cmp rdi, 256
                        jge path_error

                        jmp get_path

		term_path:
			mov byte [PATH + rsi], 0
			inc rsi

			cmp byte [PATH], '/'
			jne path_err

			mov rdi, path_msg
			call print_string

			mov rdi, PATH
			call print_string

			mov rdi, newline
			call print_string

			mov rdi, PATH	
			call serve_file 

	; The End
	the_end:
		mov rax, 0
		ret	

	parsing_error:
		mov rdi, parsing_err
		call print_string
		jmp the_end

	path_error:
		mov rdi, path_err
		call print_string
		jmp the_end

	clear_stuff:
		mov rsi, 0
		clear_method:
			mov byte [METHOD+rsi], 0
			cmp rsi, 20
			je prep_clear_path
			inc rsi
			jmp clear_method

		prep_clear_path:
			mov rsi, 0
		clear_path:
			mov byte [PATH+rsi], 0
			cmp rsi, 256
			je return_clear
			inc rsi
			jmp clear_path

		return_clear:
			ret 
			

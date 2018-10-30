[BITS 64]

section .rdata
	sockaddr_in:
		DW 2
		DW 0x672B ; port 11111
		DQ 0
section .data
	global CLIENT_STRUCT
	CLIENT_STRUCT RESB 16
	global CLIENT_STRUCT_SIZE
	CLIENT_STRUCT_SIZE DQ 16

section .bss
	SOCKET_DESCRIPTOR RESQ 1
	global CLIENT_DESCRIPTOR
	CLIENT_DESCRIPTOR RESQ 1
	global REQUEST	
	REQUEST RESB 2000

section .text

global _start
_start:
	mov rax, 41 ; socket()

	mov rdi, 2 ; AF_INET
	mov rsi, 1 ; SOCK_STREAM
	mov rdx, 0 ; IPv4

	syscall

	mov qword [SOCKET_DESCRIPTOR], rax

	mov rax, 49 ; bind()

	mov qword rdi, [SOCKET_DESCRIPTOR]
	mov qword rsi, sockaddr_in
	mov qword rdx, 16

	syscall	
	
	mov rax, 50 ; listen()

	mov qword rdi, [SOCKET_DESCRIPTOR]
	mov qword rsi, 3
	
	syscall

	handle_connections:

		mov rax, 43 ; accept()

		mov qword rdi, [SOCKET_DESCRIPTOR]
		mov qword rsi, CLIENT_STRUCT
		mov qword rdx, CLIENT_STRUCT_SIZE

		syscall

		mov qword [CLIENT_DESCRIPTOR], rax

		; Read request
		mov rax, 0 ; read()

		mov qword rdi, [CLIENT_DESCRIPTOR]
		mov qword rsi, REQUEST
		mov qword rdx, 2000
		syscall

		; Process request
		call process_request
		
		mov rax, 3 ; close()

		mov qword rdi, [CLIENT_DESCRIPTOR]

		syscall

		jmp handle_connections

	;exit()
	mov rax, 60
	mov rdi, 0
	syscall

extern process_request

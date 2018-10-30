[BITS 64]

section .bss
tempstr  RESB 8
tempstr2 RESB 8

section .text
global print_string
print_string:
	mov rsi, 0
	find_end:
		cmp byte [rdi+rsi], 0
		je actually_print
		inc rsi
		jmp find_end
	actually_print:
		mov rdx, rsi
		mov rsi, rdi
		mov rdi, 0

		mov rax, 1
		syscall

		mov rax, 0
		ret

global int_to_str
int_to_str:
	call clear_temp

	mov rax, rdi
	mov rsi, 0

	divandmod:
		mov rdx, 0
		mov rbx, 10
		idiv rbx

		add rdx, '0'
		mov byte [tempstr + rsi], dl

		inc rsi

		cmp rax, 0
		jne divandmod

	dec rsi

	mov rdi, 0

	cmp rsi, 0
	je last_byte

	reverse_string:
		mov byte al, [tempstr + rsi]
		mov byte [tempstr2 + rdi], al
		inc rdi
		dec rsi

		cmp rsi, 0
		jnz reverse_string

	last_byte:
		mov byte al, [tempstr]
		mov byte [tempstr2 + rdi], al
		inc rdi

	mov rax, tempstr2
	mov rbx, rdi
	ret

clear_temp:
	mov rsi, 0
	clear_loop:
		mov byte [tempstr + rsi], 0
		mov byte [tempstr2 + rsi], 0

		inc rsi

		cmp rsi, 8
		jne clear_loop
	ret


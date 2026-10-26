section .data
    opt dd 1
    addrlen dd 16

section .bss
    secret_key resb 64
    dynamic_ports resd 3
    address resb 16

section .text
    global _start

_start:
    ; 1. Read Secret Key (sys_read)
    mov rax, 0          ; sys_read
    mov rdi, 0          ; stdin
    mov rsi, secret_key
    mov rdx, 64
    syscall
    
    ; Strip newline if exists
    mov rcx, rax        ; length read
    xor rsi, rsi
.strip_nl:
    cmp rsi, rcx
    jge .calc_hash
    cmp byte [secret_key + rsi], 10 ; '\n'
    jne .next_char
    mov byte [secret_key + rsi], 0
    mov rcx, rsi        ; new length
    jmp .calc_hash
.next_char:
    inc rsi
    jmp .strip_nl

.calc_hash:
    xor r9, r9          ; hash = 0
    xor rsi, rsi
.hash_loop:
    cmp rsi, rcx
    jge .gen_ports
    movzx rbx, byte [secret_key + rsi]
    cmp rbx, 0
    je .gen_ports
    add r9, rbx
    inc rsi
    jmp .hash_loop

.gen_ports:
    ; Port 1 = 10000 + (hash * 1) % 40000
    mov rax, r9
    mov rbx, 1
    mul rbx
    mov rbx, 40000
    xor rdx, rdx
    div rbx
    add rdx, 10000
    mov [dynamic_ports], edx

    ; Port 2 = 10000 + (hash * 2) % 40000
    mov rax, r9
    mov rbx, 2
    mul rbx
    mov rbx, 40000
    xor rdx, rdx
    div rbx
    add rdx, 10000
    mov [dynamic_ports + 4], edx

    ; Port 3 = 10000 + (hash * 3) % 40000
    mov rax, r9
    mov rbx, 3
    mul rbx
    mov rbx, 40000
    xor rdx, rdx
    div rbx
    add rdx, 10000
    mov [dynamic_ports + 8], edx

    xor r12, r12        ; state = 0

.main_loop:
    ; Get current target port
    mov eax, [dynamic_ports + r12*4]
    
    ; htons simulation (swap bytes for Big-Endian port)
    xchg al, ah
    mov [address + 2], ax ; sin_port

    ; 2. Create Socket (sys_socket)
    mov rax, 41         ; sys_socket
    mov rdi, 2          ; AF_INET
    mov rsi, 1          ; SOCK_STREAM
    mov rdx, 0
    syscall
    cmp rax, 0
    jl .main_loop
    mov r13, rax        ; r13 = server_fd

    ; 3. Setsockopt (sys_setsockopt)
    mov rax, 54         ; sys_setsockopt
    mov rdi, r13
    mov rsi, 1          ; SOL_SOCKET
    mov rdx, 2          ; SO_REUSEADDR
    mov r10, opt
    mov r8, 4
    syscall

    ; Prepare sockaddr_in struct
    mov word [address], 2   ; sin_family = AF_INET
    mov dword [address + 4], 0 ; sin_addr = INADDR_ANY (0.0.0.0)

    ; 4. Bind (sys_bind)
    mov rax, 49         ; sys_bind
    mov rdi, r13
    mov rsi, address
    mov rdx, 16
    syscall
    cmp rax, 0
    jl .close_and_continue

    ; 5. Listen (sys_listen)
    mov rax, 50         ; sys_listen
    mov rdi, r13
    mov rsi, 1          ; backlog
    syscall

    ; 6. Accept (sys_accept)
    mov rax, 43         ; sys_accept
    mov rdi, r13
    mov rsi, 0
    mov rdx, 0
    syscall
    cmp rax, 0
    jl .close_and_continue

    ; Valid Knock Detected
    mov r14, rax        ; client_fd
    inc r12             ; state++

    ; Close client_fd
    mov rax, 3          ; sys_close
    mov rdi, r14
    syscall

.close_and_continue:
    ; Close server_fd
    mov rax, 3          ; sys_close
    mov rdi, r13
    syscall

    ; Check if state == 3
    cmp r12, 3
    jne .main_loop

    ; 7. Success Action: Sleep 10 seconds (sys_nanosleep)
    ; we use sys_nanosleep with 10 seconds structure
    push qword 0        ; tv_nsec = 0
    push qword 10       ; tv_sec = 10
    mov rax, 35         ; sys_nanosleep
    mov rdi, rsp
    mov rsi, 0
    syscall
    add rsp, 16         ; restore stack

    ; Reset state
    xor r12, r12
    jmp .main_loop

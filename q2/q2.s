.section .rodata
fmt: .string "%d "
fmt_last: .string "%d"
newline: .string "\n"

.section .text
.globl main
.extern printf
.extern malloc

string_to_int:
    li   t0, 0
    li   t3, 0
    lb   t1, 0(a0)
    li   t2, 45
    bne  t1, t2, stoi_loop_start
    li   t3, 1
    addi a0, a0, 1
stoi_loop_start:
    lb   t1, 0(a0)
    beqz t1, stoi_done
    addi t1, t1, -48
    li   t2, 10
    mul  t0, t0, t2
    add  t0, t0, t1
    addi a0, a0, 1
    j    stoi_loop_start
stoi_done:
    beqz t3, stoi_ret
    neg  t0, t0
stoi_ret:
    mv   a0, t0
    ret

main:
    addi sp, sp, -80
    sd   ra, 72(sp)
    sd   s0, 64(sp)
    sd   s1, 56(sp)
    sd   s2, 48(sp)
    sd   s3, 40(sp)
    sd   s4, 32(sp)
    sd   s5, 24(sp)
    sd   s6, 16(sp)

    addi s0, a0, -1
    mv   s6, a1
    blez s0, exit_main

    slli a0, s0, 2
    call malloc
    mv   s1, a0
    slli a0, s0, 2
    call malloc
    mv   s2, a0
    slli a0, s0, 2
    call malloc
    mv   s3, a0
    li   s4, -1

    li   s5, 0
parse_args:
    bge  s5, s0, nge_init
    addi t0, s5, 1
    slli t0, t0, 3
    add  t0, s6, t0
    ld   a0, 0(t0)
    call string_to_int
    slli t1, s5, 2
    add  t1, s1, t1
    sw   a0, 0(t1)
    addi s5, s5, 1
    j    parse_args

nge_init:
    addi s5, s0, -1
nge_loop:
    bltz s5, print_init
    slli t0, s5, 2
    add  t0, s1, t0
    lw   t0, 0(t0)
stack_while:
    bltz s4, stack_is_empty
    slli t1, s4, 2
    add  t1, s3, t1
    lw   t1, 0(t1)
    bgt  t1, t0, nge_found
    addi s4, s4, -1
    j    stack_while
nge_found:
    slli t2, s5, 2
    add  t2, s2, t2
    sw   t1, 0(t2)
    j    push_val
stack_is_empty:
    slli t2, s5, 2
    add  t2, s2, t2
    li   t1, -1
    sw   t1, 0(t2)
push_val:
    addi s4, s4, 1
    slli t2, s4, 2
    add  t2, s3, t2
    sw   t0, 0(t2)
    addi s5, s5, -1
    j    nge_loop

print_init:
    li   s5, 0
print_loop:
    bge  s5, s0, print_done
    slli t0, s5, 2
    add  t0, s2, t0
    lw   a1, 0(t0)
    addi t1, s0, -1
    beq  s5, t1, print_last
    la   a0, fmt
    call printf
    addi s5, s5, 1
    j    print_loop
print_last:
    la   a0, fmt_last
    call printf
print_done:
    la   a0, newline
    call printf

exit_main:
    ld   ra, 72(sp)
    ld   s0, 64(sp)
    ld   s1, 56(sp)
    ld   s2, 48(sp)
    ld   s3, 40(sp)
    ld   s4, 32(sp)
    ld   s5, 24(sp)
    ld   s6, 16(sp)
    addi sp, sp, 80
    li   a0, 0
    ret

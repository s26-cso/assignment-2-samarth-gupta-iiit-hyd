.section .rodata
fmt: .string "%d "
fmt_last: .string "%d"
newline: .string "\n"
.section .data
.balign 8
head: .dword 0
.section .text
.globl main
.extern printf
.extern malloc

string_to_int:
    add  t0, x0, x0
    add  t3, x0, x0
    lb   t1, 0(a0)
    addi t2, x0, 45
    bne  t1, t2, stoi_loop
    addi t3, x0, 1
    addi a0, a0, 1
stoi_loop:
    lb   t1, 0(a0)
    beq  t1, x0, stoi_end
    addi t1, t1, -48
    addi t2, x0, 10
    mul  t0, t0, t2
    add  t0, t0, t1
    addi a0, a0, 1
    jal  x0, stoi_loop
stoi_end:
    beq  t3, x0, stoi_ret
    sub  t0, x0, t0
stoi_ret:
    add  a0, t0, x0
    jalr x0, ra, 0

push:
    addi sp, sp, -16
    sd   ra, 8(sp)
    sd   s0, 0(sp)
    add  s0, a0, x0

    addi a0, x0, 16
    jal  ra, malloc

    sw   s0, 0(a0)

1:  auipc t1, %pcrel_hi(head)
    ld   t2, %pcrel_lo(1b)(t1)
    sd   t2, 8(a0)
    sd   a0, %pcrel_lo(1b)(t1)

    ld   s0, 0(sp)
    ld   ra, 8(sp)
    addi sp, sp, 16
    jalr x0, ra, 0

pop:
1:  auipc t0, %pcrel_hi(head)
    addi  t0, t0, %pcrel_lo(1b)
    ld   t1, 0(t0)
    beq  t1, x0, pop_ret
    ld   t2, 8(t1)
    sd   t2, 0(t0)
pop_ret:
    jalr x0, ra, 0

top:
1:  auipc t0, %pcrel_hi(head)
    addi  t0, t0, %pcrel_lo(1b)
    ld   t1, 0(t0)
    lw   a0, 0(t1)
    jalr x0, ra, 0

main:
    addi sp, sp, -80
    sd   ra, 72(sp)
    sd   s0, 64(sp)
    sd   s1, 56(sp)
    sd   s2, 48(sp)
    sd   s3, 40(sp)
    sd   s4, 32(sp)

    addi s0, a0, -1
    add  s3, a1, x0
    beq  s0, x0, exit

    slli a0, s0, 2
    jal  ra, malloc
    add  s1, a0, x0

    slli a0, s0, 2
    jal  ra, malloc
    add  s2, a0, x0

1:  auipc t0, %pcrel_hi(head)
    sd   x0, %pcrel_lo(1b)(t0)

    addi s4, x0, 1
argtoint:
    blt  s0, s4, nge
    slli t1, s4, 3
    add  t1, s3, t1
    ld   a0, 0(t1)
    jal  ra, string_to_int
    addi t1, s4, -1
    slli t1, t1, 2
    add  t1, s1, t1
    sw   a0, 0(t1)
    addi s4, s4, 1
    jal  x0, argtoint

nge:
    addi s4, s0, -1
loop_main:
    blt  s4, x0, print
loop_while:
1:  auipc t0, %pcrel_hi(head)
    addi  t0, t0, %pcrel_lo(1b)
    ld   t1, 0(t0)
    beq  t1, x0, noelem
    jal  ra, top
    slli t1, a0, 2
    add  t1, s1, t1
    lw   t1, 0(t1)
    slli t2, s4, 2
    add  t2, s1, t2
    lw   t2, 0(t2)
    blt  t2, t1, found
    jal  ra, pop
    jal  x0, loop_while
noelem:
    slli t1, s4, 2
    add  t1, s2, t1
    addi t2, x0, -1
    sw   t2, 0(t1)
    jal  x0, push_i
found:
    jal  ra, top
    slli t1, s4, 2
    add  t1, s2, t1
    sw   a0, 0(t1)
push_i:
    add  a0, s4, x0
    jal  ra, push
    addi s4, s4, -1
    jal  x0, loop_main

print:
    add  s4, x0, x0
print_loop:
    beq  s4, s0, exit
    slli t0, s4, 2
    add  t0, s2, t0
    lw   a1, 0(t0)
    addi t1, s0, -1
    beq  s4, t1, last_val
1:  auipc a0, %pcrel_hi(fmt)
    addi  a0, a0, %pcrel_lo(1b)
    jal  ra, printf
    addi s4, s4, 1
    jal  x0, print_loop
last_val:
1:  auipc a0, %pcrel_hi(fmt_last)
    addi  a0, a0, %pcrel_lo(1b)
    jal  ra, printf

exit:
1:  auipc a0, %pcrel_hi(newline)
    addi  a0, a0, %pcrel_lo(1b)
    jal  ra, printf
    ld   ra, 72(sp)
    ld   s0, 64(sp)
    ld   s1, 56(sp)
    ld   s2, 48(sp)
    ld   s3, 40(sp)
    ld   s4, 32(sp)
    addi sp, sp, 80
    add  a0, x0, x0
    addi a7, x0, 93
    ecall

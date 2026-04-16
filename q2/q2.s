.section .rodata
fmt:      .string "%d "
fmt_last: .string "%d"
newline:  .string "\n"

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
    # 16-byte alignment
    addi sp, sp, -16
    sd   ra, 8(sp)
    sd   s0, 0(sp)
    
    add  s0, a0, x0      # save index to push
    addi a0, x0, 16      # space for (int index, padding, void* next)
    jal  ra, malloc
    
    sw   s0, 0(a0)       # node->val = index
    
    auipc t0, %pcrel_hi(head)
    ld    t1, %pcrel_lo(push)(t0)
    sd    t1, 8(a0)       # node->next = head
    sd    a0, %pcrel_lo(push)(t0) # head = node
    
    ld   ra, 8(sp)
    ld   s0, 0(sp)
    addi sp, sp, 16
    jalr x0, ra, 0

pop:
    auipc t0, %pcrel_hi(head)
    ld    t1, %pcrel_lo(pop)(t0)
    beq   t1, x0, pop_ret
    ld    t2, 8(t1)       # next = head->next
    sd    t2, %pcrel_lo(pop)(t0)
pop_ret:
    jalr x0, ra, 0

top:
    auipc t0, %pcrel_hi(head)
    ld    t1, %pcrel_lo(top)(t0)
    lw    a0, 0(t1)       # return index
    jalr x0, ra, 0

main:
    # Maintain 16-byte alignment
    addi sp, sp, -80
    sd   ra, 72(sp)
    sd   s0, 64(sp)
    sd   s1, 56(sp)
    sd   s2, 48(sp)
    sd   s3, 40(sp)
    sd   s4, 32(sp)

    addi s0, a0, -1      # s0 = count of numbers
    add  s3, a1, x0      # s3 = argv
    beq  s0, x0, cleanup

    # Allocate input array
    slli a0, s0, 2
    jal  ra, malloc
    add  s1, a0, x0

    # Allocate result array
    slli a0, s0, 2
    jal  ra, malloc
    add  s2, a0, x0

    # Parse argv to int array
    addi s4, x0, 0
parse_args:
    beq  s4, s0, solve
    addi t0, s4, 1
    slli t0, t0, 3
    add  t0, s3, t0
    ld   a0, 0(t0)
    jal  ra, string_to_int
    slli t1, s4, 2
    add  t1, s1, t1
    sw   a0, 0(t1)
    addi s4, s4, 1
    jal  x0, parse_args

solve:
    addi s4, s0, -1      # i = count - 1
loop_main:
    blt  s4, x0, print
loop_while:
    auipc t0, %pcrel_hi(head)
    ld    t1, %pcrel_lo(loop_while)(t0)
    beq   t1, x0, no_greater
    
    jal   ra, top
    add   t3, a0, x0     # t3 = index from stack
    slli  t3, t3, 2
    add   t3, s1, t3
    lw    t3, 0(t3)      # t3 = input[stack_top]
    
    slli  t4, s4, 2
    add   t4, s1, t4
    lw    t4, 0(t4)      # t4 = input[i]
    
    blt   t4, t3, found
    jal   ra, pop
    jal   x0, loop_while

no_greater:
    slli t1, s4, 2
    add  t1, s2, t1
    addi t2, x0, -1
    sw   t2, 0(t1)
    jal  x0, push_curr

found:
    slli t1, s4, 2
    add  t1, s2, t1
    sw   a0, 0(t1)       # store the index found by top

push_curr:
    add  a0, s4, x0
    jal  ra, push
    addi s4, s4, -1
    jal  x0, loop_main

print:
    add  s4, x0, x0
print_loop:
    beq  s4, s0, cleanup
    slli t0, s4, 2
    add  t0, s2, t0
    lw   a1, 0(t0)
    
    addi t1, s0, -1
    beq  s4, t1, print_last
    
    auipc a0, %pcrel_hi(fmt)
    addi a0, a0, %pcrel_lo(print_loop)
    jal  ra, printf
    addi s4, s4, 1
    jal  x0, print_loop

print_last:
    auipc a0, %pcrel_hi(fmt_last)
    addi a0, a0, %pcrel_lo(print_last)
    jal  ra, printf

cleanup:
    auipc a0, %pcrel_hi(newline)
    addi a0, a0, %pcrel_lo(cleanup)
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

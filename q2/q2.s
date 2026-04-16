.section .rodata
fmt_ld:      .string "%ld"
fmt_space:   .string " "
fmt_newline: .string "\n"

    .section .text
    .global main
    .type   main, @function

main:
    addi    sp,  sp,  -80
    sd      ra,  64(sp)
    sd      s0,  56(sp)
    sd      s1,  48(sp)
    sd      s2,  40(sp)
    sd      s3,  32(sp)
    sd      s4,  24(sp)
    sd      s5,  16(sp)
    sd      s6,   8(sp)
    sd      s7,   0(sp)

    addi    s0,  sp,  80

    addi    s1,  a0,  -1
    addi    s2,  a1,   8

    mv      s7,  s1
    mv      s1,  s2

    slli    a0,  s7,   3
    call    malloc
    mv      s2,  a0

    slli    a0,  s7,   3
    call    malloc
    mv      s3,  a0

    slli    a0,  s7,   3
    call    malloc
    mv      s4,  a0

    li      s6,   0
.Lparse_loop:
    bge     s6,  s7,  .Lparse_done
    slli    t0,  s6,   3
    add     t0,  s1,  t0
    ld      a0,  0(t0)
    call    atoi
    slli    a0,  a0,  32
    srai    a0,  a0,  32
    slli    t0,  s6,   3
    add     t0,  s2,  t0
    sd      a0,  0(t0)
    addi    s6,  s6,   1
    j       .Lparse_loop
.Lparse_done:

    li      s6,   0
.Linit_loop:
    bge     s6,  s7,  .Linit_done
    slli    t0,  s6,   3
    add     t0,  s3,  t0
    li      t1,  -1
    sd      t1,  0(t0)
    addi    s6,  s6,   1
    j       .Linit_loop
.Linit_done:

    li      s5,  -1
    addi    s6,  s7,  -1

.Lnge_loop:
    bltz    s6,  .Lnge_done

    slli    t0,  s6,   3
    add     t0,  s2,  t0
    ld      t4,  0(t0)

.Lpop_loop:
    bltz    s5,  .Lpop_done
    slli    t0,  s5,   3
    add     t0,  s4,  t0
    ld      t1,  0(t0)
    slli    t2,  t1,   3
    add     t2,  s2,  t2
    ld      t3,  0(t2)
    bgt     t3,  t4,  .Lpop_done
    addi    s5,  s5,  -1
    j       .Lpop_loop
.Lpop_done:

    bltz    s5,  .Lpush
    slli    t0,  s5,   3
    add     t0,  s4,  t0
    ld      t1,  0(t0)
    slli    t2,  s6,   3
    add     t2,  s3,  t2
    sd      t1,  0(t2)

.Lpush:
    addi    s5,  s5,   1
    slli    t0,  s5,   3
    add     t0,  s4,  t0
    sd      s6,  0(t0)

    addi    s6,  s6,  -1
    j       .Lnge_loop
.Lnge_done:

    li      s6,   0
.Lprint_loop:
    bge     s6,  s7,  .Lprint_done

    beqz    s6,  .Lno_space
    la      a0,  fmt_space
    call    printf
.Lno_space:
    slli    t0,  s6,   3
    add     t0,  s3,  t0
    ld      a1,  0(t0)
    la      a0,  fmt_ld
    call    printf

    addi    s6,  s6,   1
    j       .Lprint_loop
.Lprint_done:

    la      a0,  fmt_newline
    call    printf

    mv      a0,  s2
    call    free
    mv      a0,  s3
    call    free
    mv      a0,  s4
    call    free

    ld      ra,  64(sp)
    ld      s0,  56(sp)
    ld      s1,  48(sp)
    ld      s2,  40(sp)
    ld      s3,  32(sp)
    ld      s4,  24(sp)
    ld      s5,  16(sp)
    ld      s6,   8(sp)
    ld      s7,   0(sp)
    addi    sp,  sp,   80
    li      a0,  0
    ret

    .size   main, .-main

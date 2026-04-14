.section .text
.globl make_node
.globl insert
.globl get
.globl getAtMost
.extern malloc


make_node:
    addi sp, sp, -16
    sd   ra, 8(sp)
    sd   s0, 0(sp)          

    add  s0, a0, x0         # s0 = val
    addi a0, x0, 24         # 4(val) + 4(pad) + 8(left) + 8(right) = 24 bytes
    jal  ra, malloc

    beq  a0, x0, make_done  
    sw   s0, 0(a0)          # Store 4-byte int at offset 0
    # Offset 4 is skipped (padding)
    sd   x0, 8(a0)          # Store 8-byte pointer at offset 8
    sd   x0, 16(a0)         # Store 8-byte pointer at offset 16

make_done:
    ld   s0, 0(sp)
    ld   ra, 8(sp)
    addi sp, sp, 16
    jalr x0, ra, 0

# struct Node* insert(struct Node* root, int val)
insert:
    addi sp, sp, -32
    sd   ra, 24(sp)
    sd   s0, 16(sp)         # s0 = current root
    sd   s1, 8(sp)          # s1 = val to insert

    add  s0, a0, x0
    add  s1, a1, x0

    bne  s0, x0, insert_rec
    add  a0, s1, x0         
    jal  ra, make_node
    jal  x0, insert_finish

insert_rec:
    lw   t0, 0(s0)          # Load 4-byte val
    blt  s1, t0, ins_left
    
ins_right:
    ld   a0, 16(s0)         # Load right pointer from offset 16
    add  a1, s1, x0
    jal  ra, insert
    sd   a0, 16(s0)         # Store new right pointer
    add  a0, s0, x0         
    jal  x0, insert_finish

ins_left:
    ld   a0, 8(s0)          # Load left pointer from offset 8
    add  a1, s1, x0
    jal  ra, insert
    sd   a0, 8(s0)          # Store new left pointer
    add  a0, s0, x0

insert_finish:
    ld   s1, 8(sp)
    ld   s0, 16(sp)
    ld   ra, 24(sp)
    addi sp, sp, 32
    jalr x0, ra, 0

# struct Node* get(struct Node* root, int val)
get:
    beq  a0, x0, get_exit   
    lw   t0, 0(a0)          # Load 4-byte val
    beq  t0, a1, get_exit   
    blt  a1, t0, get_go_left

get_go_right:
    ld   a0, 16(a0)
    jal  x0, get

get_go_left:
    ld   a0, 8(a0)
    jal  x0, get

get_exit:
    jalr x0, ra, 0

# int getAtMost(int val, struct Node* root)
getAtMost:
    addi t0, x0, -1         # result = -1

at_most_loop:
    beq  a1, x0, at_most_done
    lw   t1, 0(a1)          # Load 4-byte val
    
    beq  t1, a0, at_most_exact
    blt  a0, t1, at_most_left

    add  t0, t1, x0         # Current val is <= target, save as candidate
    ld   a1, 16(a1)         # Go right
    jal  x0, at_most_loop

at_most_left:
    ld   a1, 8(a1)          # Go left
    jal  x0, at_most_loop

at_most_exact:
    add  t0, t1, x0

at_most_done:
    add  a0, t0, x0
    jalr x0, ra, 0
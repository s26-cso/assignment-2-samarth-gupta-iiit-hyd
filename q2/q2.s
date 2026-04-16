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
    mv   t0, x0          
    mv   t3, x0          
    lb   t1, 0(a0)
    li   t2, 45          
    bne  t1, t2, stoi_loop
    li   t3, 1           
    addi a0, a0, 1
stoi_loop:
    lb   t1, 0(a0)
    beq  t1, x0, stoi_end
    addi t1, t1, -48
    li   t2, 10          
    mul  t0, t0, t2
    add  t0, t0, t1
    addi a0, a0, 1
    j    stoi_loop       
stoi_end:
    beq  t3, x0, stoi_ret
    neg  t0, t0          
stoi_ret:
    mv   a0, t0          
    ret                  

push:
    addi sp, sp, -16
    sd   ra, 8(sp)
    sd   s0, 0(sp)
    mv   s0, a0          

    li   a0, 16          
    call malloc          

    sw   s0, 0(a0)       
    la   t1, head        
    ld   t2, 0(t1)
    sd   t2, 8(a0)       
    sd   a0, 0(t1)       

    ld   s0, 0(sp)
    ld   ra, 8(sp)
    addi sp, sp, 16
    ret                  

pop:
    la   t0, head        
    ld   t1, 0(t0)
    beq  t1, x0, pop_ret
    ld   t2, 8(t1)       
    sd   t2, 0(t0)       
pop_ret:
    ret                  

top:
    la   t0, head        
    ld   t1, 0(t0)
    beq  t1, x0, top_err
    lw   a0, 0(t1)       
    ret
top_err:
    li   a0, -1
    ret

main:
    addi sp, sp, -80
    sd   ra, 72(sp)
    sd   s0, 64(sp)      
    sd   s1, 56(sp)      
    sd   s2, 48(sp)      
    sd   s3, 40(sp)      
    sd   s4, 32(sp)      

    addi s0, a0, -1      
    mv   s3, a1          
    blez s0, exit_no_nl  

    slli a0, s0, 2
    call malloc          
    mv   s1, a0          

    slli a0, s0, 2
    call malloc          
    mv   s2, a0          

    la   t0, head        
    sd   x0, 0(t0)       

    li   s4, 1           
argtoint:
    bgt  s4, s0, nge
    slli t1, s4, 3
    add  t1, s3, t1
    ld   a0, 0(t1)
    call string_to_int   
    addi t1, s4, -1
    slli t1, t1, 2
    add  t1, s1, t1
    sw   a0, 0(t1)
    addi s4, s4, 1
    j    argtoint        

nge:
    addi s4, s0, -1      
loop_main:
    blt  s4, x0, print
loop_while:
    la   t0, head        
    ld   t1, 0(t0)
    beq  t1, x0, noelem  
    
    call top             
    slli t1, a0, 2       
    add  t1, s1, t1
    lw   t1, 0(t1)       
    
    slli t2, s4, 2
    add  t2, s1, t2
    lw   t2, 0(t2)       
    
    bgt  t1, t2, found   
    call pop             
    j    loop_while      

noelem:
    slli t1, s4, 2
    add  t1, s2, t1
    li   t2, -1          
    sw   t2, 0(t1)
    j    push_i          

found:
    call top             
    slli t1, s4, 2
    add  t1, s2, t1
    sw   a0, 0(t1)       

push_i:
    mv   a0, s4          
    call push            
    addi s4, s4, -1
    j    loop_main       

print:
    mv   s4, x0          
print_loop:
    beq  s4, s0, exit
    slli t0, s4, 2
    add  t0, s2, t0
    lw   a1, 0(t0)
    
    addi t1, s0, -1
    beq  s4, t1, last_val 

    la   a0, fmt         
    call printf          
    addi s4, s4, 1
    j    print_loop      

last_val:
    la   a0, fmt_last    
    call printf          

exit:
    la   a0, newline     
    call printf          
exit_no_nl:
    ld   ra, 72(sp)
    ld   s0, 64(sp)
    ld   s1, 56(sp)
    ld   s2, 48(sp)
    ld   s3, 40(sp)
    ld   s4, 32(sp)
    addi sp, sp, 80
    li   a0, 0           
    li   a7, 93          
    ecall

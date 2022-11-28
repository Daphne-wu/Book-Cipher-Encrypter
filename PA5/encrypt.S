//uncomment the next line when you want to use your routine
#define MYCODE
#ifdef MYCODE
// version 1.0 05/22/2022
    .arch armv6
    .arm
    .fpu vfp
    .syntax unified

    #include "encrypter.h"

    .text     // start of text segment

    //////////////////////////////////////////////////
    // int encrypt(char *IOBUF, char *BOOKBUF, int cnt)
    // encrypts  IOBUF with BOOKBUF; updating IOBUF
    //////////////////////////////////////////////////
    .global encrypt
    .type   encrypt, %function
    .equ    FP_OFF, 12

encrypt:
    push    {r4, r5, fp, lr}
    add     fp, sp, FP_OFF

    // notes for you remove this from your code
    // passed two buffer with the same number of characters in them
    // for (i = 0; i < cnt; i++) {
    //  x = IOBUF[i]
    //  x = swap_nibbles (in the byte using shifts, or rotates, or masks)
    //  y = BOOKBUF[i]
    //  IOBUF[i] = x EOR y
    // }
    // return cnt
   
// your code here 
    mov     r3, 0         //r3 is used to increment to walk the char array
.Lfor:
    cmp     r3, r2      //check to see if reached cnt
    bge     .Ldone  

    ldrb    r5, [r0, r3] //x = IPBUF[i]

    lsl     r4, r5, 4   //shift bits left 4
    lsr     r5, r5, 4   //shift bits right 4
    orr     r5, r4, r5  //combine them

    ldrb    r4, [r1, r3]    //y = BOOKBUF[i]    
    eor     r5, r5, r4      //x = x EOR y

    strb    r5, [r0, r3]    // IOBUF[i] = x
    add     r3, r3, 1       //increment to next char
    b       .Lfor
    
.Ldone:
    mov r0, r2          //return cnt
    sub     sp, fp, FP_OFF
    pop     {r4, r5, fp, lr}
    bx      lr
    .size encrypt, (. - encrypt)
    .section .note.GNU-stack,"",%progbits
.end
#endif

//uncomment the next line when you want to use your routine
//#define MYCODE
#ifdef MYCODE
// version 1.0 05/22/2022
    .arch armv6
    .arm
    .fpu vfp
    .syntax unified

    #include "encrypter.h"

    .text     // start of text segment

    //////////////////////////////////////////////////
    // int decrypt(char *IOBUF, char *BOOKBUF, int cnt) 
    // decrypts  IOBUF using BOOKBUF; result in IOBUF
    //////////////////////////////////////////////////
    .global decrypt
    .type   decrypt, %function
    .equ    FP_OFF, 12

decrypt:
    push    {r4, r5, fp, lr}
    add     fp, sp, FP_OFF
    
    mov     r3, 0               //r3 will be used to increment (like an i)

.Lfor:
    cmp     r3, r2              //if iterator is < cnt then decrypt the message
    bge     .Ldone              

    ldrb    r5, [r0, r3]        //x = IPBUF[i]
    ldrb    r4, [r1, r3]        //y = BOOKBUF[i]
    eor     r5, r5, r4          //x = x EOR y

    lsl     r4, r5, 4           //shift bits left 4
    lsr     r5, r5, 4           //shift bits right 4
    orr     r5, r4, r5          //combine them 

    strb    r5, [r0, r3]        // IOBUF[i] = x
    add     r3, r3, 1           //increment to next char   
    b       .Lfor
    
.Ldone:
    mov r0, r2                  //return cnt

    sub     sp, fp, FP_OFF
    pop     {r4, r5, fp, lr}
    bx      lr

    .size decrypt, (. - decrypt)
    .section .note.GNU-stack,"",%progbits
.end
#endif

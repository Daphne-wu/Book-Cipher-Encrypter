//uncomment the next line when you want to use your routine
//#define MYCODE
#ifdef MYCODE
// version 1.0 05/27/2022
    .arch   armv6
    .arm
    .fpu    vfp
    .syntax unified
    
    // import constants
    #include "encrypter.h"

    .section .rodata
.Lmsg: .string "wrbuf: Write failed on output\n"
.Lmsg2: .string "wrbuf: Buffer size error\n"

    .text

    ///////////////////////////////////////////////////
    // int wrbuf(char *IOBUF, int cnt, FILE *FPOUT); //
    // return cnt on success EXIT_FAIL otherwise     //
    ///////////////////////////////////////////////////
    .type   wrbuf, %function
    .global wrbuf
    .equ    FP_OFF, 12
 
wrbuf:
    //funciton epilogue
    push    {r4, r5, fp, lr}
    add     fp, sp, FP_OFF

    cmp     r1, 0           //is cnt <= 0
    bge     .Lfwrite    
    ldr     r0, =.Lmsg2     //if count is not less than to 0 the print errmsg
    bl      errmsg
    mov     r0, EXIT_FAIL   //return EXIT_FAIL (in r0)
    b       .Ldone


.Lfwrite:
    //r0 is already holding the IOBUF
    mov     r5, r1          //hold cnt in r5
    mov     r3, r2 
    mov     r2, r1          //r2 holds cnt (param)
    mov     r1, 1           //r1 holds 1  (param)
  
    bl      fwrite
    mov     r1, r0          //mov return into r1
    mov     r0, r5          //mov cnt into r0 to return
    cmp     r1, r0
    beq     .Ldone
    ldr     r0, =.Lmsg      //if not equal to cnt the print errmsg
    bl      errmsg
    mov     r0, EXIT_FAIL   //return EXIT_FAIL (in r0)
    b       .Ldone

.Ldone:
    //function prologue
    sub     sp, fp, FP_OFF
    pop     {r4, r5, fp, lr}
    bx      lr

    .size   wrbuf, (. - wrbuf)
    .section .note.GNU-stack,"",%progbits
.end
#endif

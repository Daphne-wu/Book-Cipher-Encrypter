//uncomment the next line when you want to use your routine
//#define MYCODE
#ifdef MYCODE
// version 1.1 05/22/2022
    .arch   armv6
    .arm
    .fpu    vfp
    .syntax unified

    // global constants
    #include "encrypter.h"

    .section .rodata
.Lmsg:  .string "rdbuf: Bookfile is too short for message\n"
.Lmsg2: .string "rdbuf: Buffer size error\n"
    .text

    //////////////////////////////////////////////////////
    // int rdbuf(char *IOBUF, char *BOOKBUF, FILE *FPIN
    //              FILE *FPBOOK, int BUFSZ);
    // returns number of bytes read EXIT_FAIL otherwise
    //////////////////////////////////////////////////////

    .type   rdbuf, %function
    .global rdbuf
    .equ    IARG5,  4 
    .equ    FP_OFF, 12
 
    ////////////////////////////////////////
    // preserved register use             //
    // r4 pointer to book buffer          //
    // r5 FILE *FPBOOK  & cnt read saved  //
    ////////////////////////////////////////

//rdbuf(IOBUF, BOOKBUF, FPIN, FPBOOK, BUFSZ)
//      r0,        r4     r7    r5      r3   cnt stored in r2
//      r0         r1     r2   r3      in stack
rdbuf:
    // function prologue
    push    {r4, r5, fp, lr}
    add     fp, sp, FP_OFF 


    mov     r4, r3          //save FPBOOK to r4
    mov     r5, r1          //save the BOOKBUF to r5


    mov     r3, r2          //FPIN to r3 to pass into fread
    
    ldr     r2, [fp, IARG5] //get BUFSZ from OARG5
    cmp     r2, 0                            
    bge     .Lfread
    ldr     r0, =.Lmsg2     //pseudo ldr the msg into ldr
    bl      errmsg          //call func to output errmsg    
    mov     r0, EXIT_FAIL
    b       .Lexit

.Lfread:

    mov     r1, 1           //mov 1 into r1 (param)
    bl      fread
    cmp     r0, 0   
    bne    .LfreadTwo
    b       .Lexit

.LfreadTwo:
    
    mov     r2, r0          //move cnt into r2 (parameter)
    mov     r0, r5          //BOOKBUF into r0b(parameter)
    mov     r1, 1           //size inro r1 (parameter)
    mov     r3, r4          //FPBOOK into r3 (parameter)

    mov     r5, r2          //mov cnt into r5 and call funciton

    bl      fread 
    mov     r1, r0          //mov return value of fread into r1
    mov     r0, r5          //mov cnt into r0 to return 
    cmp     r0, r1          //compare return value to cnt
    beq     .Lexit          
    ldr     r0, =.Lmsg      //pseudo ldr the msg into ldr
    bl      errmsg          
    mov     r0, EXIT_FAIL   //move into return value
    b       .Lexit

.Lexit:
    // function epilogue
    sub     sp, fp, FP_OFF
    pop     {r4, r5, fp, lr}
    bx      lr

    .size   rdbuf, (. - rdbuf)
    .section .note.GNU-stack,"",%progbits
.end
#endif

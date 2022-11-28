//uncomment the next line when you want to use your routine
//#define MYCODE
#ifdef MYCODE
// version 1.01 05/27/2022
    .arch armv6
    .arm
    .fpu vfp
    .syntax unified

    // imports
    .extern stderr
    .extern fprintf

    .text

    ////////////////////////////////////////////
    // void errmsg(char *errormsg)            //
    // writes error messages to stderr        //
    ////////////////////////////////////////////
    .type   errmsg, %function          //defined to be a function     
    .global errmsg                     
    .equ    FP_OFF,  4                  //fp offset in stack frame

errmsg:
    //function epilogue
    push    {fp, lr}                    //stack frame register save
    add     fp, sp, FP_OFF              //set the frame pointer


    mov     r1, r0                      
    ldr     r0, =stderr                 // pseudo ldr into r0
    ldr     r0, [r0]                    // r0 = stderr
    bl      fprintf

    //function prologue
    sub     sp, fp, FP_OFF              //restore stack frame top
    pop     {fp, lr}                    // remove frame and restore
    bx      lr                          //return to caller 

    .size errmsg, (. - errmsg)          //set size for function
    .section .note.GNU-stack,"",%progbits
.end
#endif

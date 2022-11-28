//uncomment the next line when you want to use your routine
//#define MYCODE
#ifdef MYCODE
// version 1.1 05/27/2022
    .arch   armv6
    .arm
    .fpu    vfp
    .syntax unified

    // function import
    .extern encrypt
    .extern decrypt
    .extern setup
    .extern rdbuf
    .extern cleanup
    .extern wrbuf

    // global constants
    #include "encrypter.h"

    .text

    //////////////////////////////////////////////////////
    // int main(int argc, char **argv)                  //
    // encrypter [-d | -e] -b bookfile encryption_file  //
    //////////////////////////////////////////////////////

    // finish the stack frame first
    .global main
    .type   main, %function
    .equ    BUFSZ,      1024        // buffer size
    .equ    FP_OFF,     28          // fp offset in main stack frame
    .equ    FPBOOK,     4 + FP_OFF    // FILE * to book file
    .equ    FPIN,       4 + FPBOOK    // FILE * to input file
    .equ    FPOUT,      4 + FPIN      // FILE * to output file
    .equ    MODE,       4 + FPOUT     // decrypt or encrypt mode
    .equ    IOBUF,      BUFSZ + MODE  // buffer for input file
    .equ    BOOKBUF,    BUFSZ + IOBUF // buffer for book file
    // add local variables here: adjust PAD size
    .equ    PAD,        0 + BOOKBUF   // Stack frame PAD  to make divisible by 8
    .equ    OARG6,      4 + PAD       // output arg6
    .equ    OARG5,      4 + OARG6     // output arg5 must be at bottom
    .equ    FRAMESZ,    OARG5-FP_OFF// total space for frame
    ////////////////////////////////////////////////////////////////
    // make sure that FRAMESZ + FP_OFF + 4 divides by 8 EVENLY!
    ////////////////////////////////////////////////////////////////
 
    ////////////////////////////////////////
    // preserved register use             //
    // r4 pointer to input/output buffer  //
    // r5 pointer to book buffer          //
    // r6 mode flag                       //
    // r7 input FILE *                    //
    // r8 book FILE *                     //
    // r9 output FILE *                  //
    ////////////////////////////////////////

main:
    push    {r4-r9, fp, lr}
    add     fp, sp, FP_OFF          // set frame pointer to frame base
    ldr     r3, =FRAMESZ            // frame size is big, use pseudo ldr
    sub     sp, sp, r3              // allocate space for locals and passed args 
     
    // call int setup(argc, argv, *mode, *FPBOOK, *FPIN, *FPOUT)
    //  argc and argv are already in r0 and r1 respectively
   
    ldr     r3, =IOBUF              //set up IOBUF
    sub     r4, fp, r3              
    ldr     r6, =BOOKBUF            //set up IOBUF
    sub     r5, fp, r6              
    add     r9, fp, -FPOUT          //set offests of the FPOUT, FPIN, etc.
    add     r8, fp, -FPBOOK
    add     r7, fp, -FPIN
    add     r6, fp, -MODE  

    str r9, [fp, -OARG6]            //store -FPOUT to OARG6 to pass into setup
    str r7, [fp, -OARG5]            //store -FPIN to OARG5 to pass into setup
  
    mov     r3, r8                  //pass in &FPBOOk to setup 
    mov     r2, r6                  //pass in &MODE  to setup
    bl      setup                   // call int setup(argc, argv, *mode, *FPBOOK, *FPIN, *FPOUT)
    cmp     r0, EXIT_FAIL
    bne     .Lloop                  //if not failure then branch to while loop 
    mov     r0, EXIT_FAILURE        
    b       .Lexit                  //return exit failture and exit 

    // set up for main while loop

.Lloop:
    // int rdbuf(char *IOBUF, char *BOOKBUF, FILE *FPIN
    //              FILE *FPBOOK, int BUFSZ);
    // returns number of bytes read EXIT_FAIL otherwise

    //set up passed in parameters to rdbuf called fucntion

    ldr     r0, =BUFSZ              //load bufsz
    str 	r0, [fp, -OARG5]        //store bufsz into OARG5 to use
    mov     r0, r4                  //pass in IOBUF to r0
    mov     r1, r5                  //pass in BOOKBUF to r1
    ldr     r2, [r7]                //pass in FPIN to r2
    ldr     r3, [r8]                //pas in FPBOOK to r3
    bl      rdbuf                                  
    cmp     r0, 0                   //compare return value stored to cnt to 0    
    ble     .Ldone                  //leave while loop when at zero
   
    //inside while loop

.Lprocinput:
    // int XXcrypt(char *IOBUF, char *BOOKBUF, int cnt)
    // encrypt or decrypt updating the buffer c 
    // returns the number of chars processed or EXIT_FAIL
    
    ldr     r1, [r6]                //deference mode
    cmp     r1, ENCRYPT_MODE        //otherwise enter MODE if statment
    bne     .Ldecrypt

    mov     r2, r0                  //pass in cnt to encrypt
    mov     r1, r5                  //pass in IOBUF 
    mov     r0, r4                  //pass in IOBUF
    bl      encrypt         
    b       .Lwriteout  //break to next if statement

.Ldecrypt: 
    // decrypt the input

    mov     r2, r0                  // pass cnt into r2
    mov     r1, r5                  //pass BOOKBUF into r1
    mov     r0, r4                  //pass IOBUF into r0
    bl      decrypt

.Lwriteout:
    // XXcrypted the buffer, write it out

    // int wrbuf(char *IOBUF, int cnt, FILE *FPOUT);
    // return cnt on success EXIT_FAIL otherwise 

    cmp     r0, EXIT_FAIL           //compaare cnt to exit
    beq     .Ldone                  //break to next iteration in while loop
    ldr     r2, [r9]                //FPOUT into reg2 (param)
    mov     r1, r0                  //cnt into r1     (param)
    mov     r0, r4                  //IOBUT into r0   (param)
    bl      wrbuf               
    cmp     r0, EXIT_FAIL           //return value of wrbuf compared to EXIT_FAIL
    bne     .Lloop                  //break into next iteration in while loop
    
.Ldone:
    // int cleanup(int status)
    // r0 should have exit status in it
    bl      cleanup                     


.Lexit:
    
    //function prologue
    sub     sp, fp, FP_OFF
    pop     {r4-r9, fp, lr}
    bx      lr

    .size   main, (. - main)
    .section .note.GNU-stack,"",%progbits
.end
#endif

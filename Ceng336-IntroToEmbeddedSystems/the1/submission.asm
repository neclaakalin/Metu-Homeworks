; Necla Nur Akalin
; 2171148
    
list    P=18F8722
#include    <p18f8722.inc>

CONFIG OSC=HSPLL, FCMEN=OFF, IESO=OFF,PWRT=OFF,BOREN=OFF, WDT=OFF, MCLRE=ON, LPT1OSC=OFF, LVP=OFF, XINST=OFF, DEBUG=OFF

timer1  udata   0x20
timer1

timer2  udata   0x21
timer2

timer3  udata   0x22
timer3

count_b   udata   0x23
count_b

count_c   udata   0x24
count_c
   
state_selector   udata   0x25
state_selector
    
org 0
goto    main

setup
    movlw   h'00'
    movwf   TRISB
    clrf    LATB
    movwf   TRISC
    clrf    LATC
    movwf   TRISD
    clrf    LATD
    movlw   h'00'
    movwf   count_b
    movwf   count_c
    movwf   state_selector

    movlw   b'00011000' ; Setting RE3 and RE4 as digital inputs
    movwf   TRISE       ; TRISx, used to set a digital I/O pin
    clrf    LATE        ; LATx, used to set outputs
    clrf    PORTE       ; PORTx, used to read the value

    movlw   b'00010000' ; Setting RA4 as a digital input
    movwf   TRISA
    clrf    LATA
    clrf    PORTA

    return
    
turn_all_on
    movlw   h'0f'
    movwf   LATB
    movwf   LATC
    movlw   h'ff'
    movwf   LATD
    call    wait1sn
    movlw   h'00'
    movwf   LATB
    movwf   LATC
    movwf   LATD

    return
    
wait1sn
    movlw   0xcb        ; PIC18F8722 works as 40MHz
    movwf   timer1      ; so, timer's total should be 
    movlw   0xec        ; as there're 6 instructions + a loop
    movwf   timer2
    movlw   0x84
    movwf   timer3
loop1       
    decfsz  timer3
    goto    loop1
    decfsz  timer2
    goto    loop1
    decfsz  timer1
    goto    loop1

    return

state_select
press               ; Condition to make sure
    btfss   PORTA, 4    ; RA4 is pressed and released
    goto    press       ; before RE3
release
    btfsc   PORTA, 4
    goto    release
pressSub
    btfsc   PORTE, 3    ; If RE3 is pressed, then
    goto    e_release_add   ; send it to wait to be released
    btfss   PORTA, 4
    goto    pressSub
releaseSub
    btfsc   PORTA, 4
    goto    releaseSub
pressAdd
    btfsc   PORTE, 3
    goto    e_release_sub
    btfss   PORTA, 4
    goto    pressAdd
releaseAdd
    btfsc   PORTA, 4
    goto    releaseAdd
    goto    pressSub
    
    return
   
e_release_add
    btfsc   PORTE, 3
    goto    e_release_add
    goto    addition_stage1
    
    return
  
e_release_sub
    btfsc   PORTE, 3
    goto    e_release_sub
    movlw   h'01'
    movwf   state_selector
    goto    addition_stage1
    
    return

addition_stage1
    btfsc   PORTE, 3
    goto    release_porte3_addition_stage1
    btfsc   PORTE, 4
    goto    release_porte4_addition_stage1
    goto    addition_stage1

    return

release_porte3_addition_stage1
    btfss   PORTE, 3
    goto    addition_stage2
    goto    release_porte3_addition_stage1

    return

release_porte4_addition_stage1
    btfss   PORTE, 4
    goto    b_led1
    goto    release_porte4_addition_stage1
    
    return

b_led1
    movlw   h'01'
    movwf   count_b
    movlw   b'00000001'
    movwf   LATB
    btfsc   PORTE, 3
    goto    release_porte3_addition_stage1
    btfsc   PORTE, 4
    goto    release_b_led1
    goto    b_led1

    return

release_b_led1
    btfss   PORTE, 4
    goto    b_led2
    goto    release_b_led1

    return

b_led2
    movlw   b'00000011'
    movwf   LATB
    movlw   h'02'
    movwf   count_b
    btfsc   PORTE, 3
    goto    release_porte3_addition_stage1
    btfsc   PORTE, 4
    goto    release_b_led2
    goto    b_led2

    return

release_b_led2
    btfss   PORTE, 4
    goto    b_led3
    goto    release_b_led2

    return

b_led3
    movlw   b'00000111'
    movwf   LATB
    movlw   h'03'
    movwf   count_b
    btfsc   PORTE, 3
    goto    release_porte3_addition_stage1
    btfsc   PORTE, 4
    goto    release_b_led3
    goto    b_led3

    return

release_b_led3
    btfss   PORTE, 4
    goto    b_led4
    goto    release_b_led3

    return

b_led4
    movlw   b'00001111'
    movwf   LATB
    movlw   h'04'
    movwf   count_b
    btfsc   PORTE, 3
    goto    release_porte3_addition_stage1
    btfsc   PORTE, 4
    goto    release_b_ledreset
    goto    b_led4

    return

release_b_ledreset
    btfss   PORTE, 4
    goto    b_ledreset
    goto    release_b_ledreset

    return

b_ledreset
    movlw   b'00000000'
    movwf   LATB
    movlw   h'00'
    movwf   count_b
    btfsc   PORTE, 3
    goto    release_porte3_addition_stage1
    btfsc   PORTE, 4
    goto    release_porte4_addition_stage1
    goto    b_ledreset

    return

addition_stage2
    btfsc   PORTE, 3
    goto    release_re3_addition_stage2
    btfsc   PORTE, 4
    goto    release_c_led1
    goto    addition_stage2

    return

release_c_led1
    btfss   PORTE, 4
    goto    c_led1
    goto    release_c_led1

    return

release_re3_addition_stage2
    btfss   PORTE, 3
    goto    operation_state_select
    goto    release_re3_addition_stage2

    return

operation_state_select
    tstfsz  state_selector
    goto    subtraction
    goto    add

    return

c_led1
    movlw   b'00000001'
    movwf   LATC
    movlw   h'01'
    movwf   count_c
    btfsc   PORTE, 3
    goto    release_re3_addition_stage2
    btfsc   PORTE, 4
    goto    release_c_led2
    goto    c_led1

    return

release_c_led2
    btfss   PORTE, 4
    goto    c_led2
    goto    release_c_led2

    return

c_led2
    movlw   b'00000011'
    movwf   LATC
    movlw   h'02'
    movwf   count_c
    btfsc   PORTE, 3
    goto    release_re3_addition_stage2
    btfsc   PORTE, 4
    goto    release_c_led3
    goto    c_led2

    return

release_c_led3
    btfss   PORTE, 4
    goto    c_led3
    goto    release_c_led3

    return

c_led3
    movlw   b'00000111'
    movwf   LATC
    movlw   h'03'
    movwf   count_c
    btfsc   PORTE, 3
    goto    release_re3_addition_stage2
    btfsc   PORTE, 4
    goto    release_c_led4
    goto    c_led3

    return

release_c_led4
    btfss   PORTE, 4
    goto    c_led4
    goto    release_c_led4

    return

c_led4
    movlw   b'00001111'
    movwf   LATC
    movlw   h'04'
    movwf   count_c
    btfsc   PORTE, 3
    goto    release_re3_addition_stage2
    btfsc   PORTE, 4
    goto    release_c_ledreset
    goto    c_led4

    return

release_c_ledreset
    btfss   PORTE, 4
    goto    c_ledreset
    goto    release_c_ledreset

    return

c_ledreset
    movlw   b'00000000'
    movwf   LATC
    movlw   h'00'
    movwf   count_c
    btfsc   PORTE, 3
    goto    release_re3_addition_stage2
    btfsc   PORTE, 4
    goto    release_c_led1
    goto    c_ledreset


add
    movf    count_c, 0, 0
    addwf   count_b
    tstfsz  count_b
    goto    add_d_led1
    call    wait1sn
    goto    main_helper

    return

add_d_led1
    movlw   b'00000001'
    movwf   LATD
    decfsz  count_b
    goto    add_d_led2
    call    wait1sn
    goto    main_helper

    return

add_d_led2
    movlw   b'00000011'
    movwf   LATD
    decfsz  count_b
    goto    add_d_led3
    call    wait1sn
    goto    main_helper

    return

add_d_led3
    movlw   b'00000111'
    movwf   LATD
    decfsz  count_b
    goto    add_d_led4
    call    wait1sn
    goto    main_helper

    return

add_d_led4
    movlw   b'00001111'
    movwf   LATD
    decfsz  count_b
    goto    add_d_led5
    call    wait1sn
    goto    main_helper

    return

add_d_led5
    movlw   b'00011111'
    movwf   LATD
    decfsz  count_b
    goto    add_d_led6
    call    wait1sn
    goto    main_helper

    return

add_d_led6
    movlw   b'00111111'
    movwf   LATD
    decfsz  count_b
    goto    add_d_led7
    call    wait1sn
    goto    main_helper

    return

add_d_led7
    movlw   b'01111111'
    movwf   LATD
    decfsz  count_b
    goto    add_d_led8
    call    wait1sn
    goto    main_helper

    return

add_d_led8
    movlw   b'11111111'
    movwf   LATD
    decfsz  count_b
    goto    add_d_led1
    call    wait1sn
    goto    main_helper

    return
    
subtraction
    movf    count_c, 0, 0
    cpfsgt  count_b     ; skips if count_b is greater than count_c
    goto    subtraction_helper
    subwf   count_b, 0, 0
    movwf   count_b
    tstfsz  count_b
    goto    add_d_led1
    call    wait1sn
    goto    main_helper

    return

subtraction_helper
    movf    count_b, 0, 0
    subwf   count_c, 0, 0  ; w should be less than reg
    movwf   count_b
    tstfsz  count_b
    goto    add_d_led1
    call    wait1sn
    goto    main_helper
    
    return

main
    call    setup
    call    turn_all_on
    call    state_select
main_helper
    call    setup
    goto    state_select
    end
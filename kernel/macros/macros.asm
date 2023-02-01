;---------------------------------------;
; Copyright 2023 Maximilian Wittmer     ;
;---------------------------------------;
                                        ;
;---------------------------------------;
; parameters                            ;
;---------------------------------------;
    PARAM_KERNEL_VERSION EQU -10        ;
                                        ;
;---------------------------------------;
; preserves all four common registers   ;
;---------------------------------------;
MAC_PUSH_COMMON_REGS MACRO              ;
    PUSH ax                             ;
    PUSH bx                             ;
    PUSH cx                             ;
    PUSH dx                             ;
ENDM                                    ;
                                        ;
;---------------------------------------;
; pops all four common registers        ;
;---------------------------------------;
MAC_POP_COMMON_REGS MACRO               ;
    POP dx                              ;
    POP cx                              ;
    POP bx                              ;
    POP ax                              ;
ENDM                                    ;

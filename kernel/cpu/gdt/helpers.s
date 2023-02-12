;-------------------------------------------------;
; Copyright 2023 Maximilian Wittmer               ;
;-( synopsis )------------------------------------;
; GDT_encode_entry                                ;
;-( synopsis )------------------------------------;
; GDT_encode_entry                                ; encode a single entry
; GDT_set                                         ; loads the GDT to the processor
;-------------------------------------------------;
.386P                                             ;
                                                  ;
;-------------------------------------------------;
; GDT_encode_entry                                ;
;-------------------------------------------------;
; creates a GDT at the required position          ;
;-( inputs )--------------------------------------;
; BP + 2 = pointer to GDT                         ; W
; BP + 4 = limit                                  ; DW - first byte will effectively be empty - and ignored by code!
; BP + 8 = flags                                  ; W (first byte unused)
; BP + 10 = base                                  ; DW
; BP + 14 = unused                                ;
; BP + 15 = access byte                           ; B
;-( output )--------------------------------------;
; [AX] = the newly created GDT                    ;
;-------------------------------------------------;
GDT_encodeEntry PROC                              ;
    ENTER 0, 0                                    ;
    ;- params                                     ;
    GDT_GDTptr EQU BP + 2                         ;
    GDT_limit EQU BP + 4                          ;
    GDT_flags EQU BP + 9                          ;
    GDT_base EQU BP + 10                          ;
    GDT_accessByte EQU BP + 15                    ;
    ;-                                            ;
    MAC_PUSH_COMMON_REGS                          ;
                                                  ;
    ;- is the limit without bounds?               ;
    MOV bx, WORD PTR SS:[GDT_limit + 2]           ;
    CMP bx, 0FFH                                  ;
    JLE @@limitOk                                 ;
    MOV ax, 50                                    ; Error code: GDT problem
    CALL RM_panic                                 ;
                                                  ;
@@limitOk:                                        ;
    ;- encode entry                               ;
    ASSUME CX: PTR GDT_entry                      ;
    MOV cx, WORD PTR [GDT_GDTptr]                 ;
    ;-- encode limit                              ; BX is still GDT_limit
    ;--- low limit                                ;
    MOV WORD PTR [cx].GDT_entry.limitLow, bx      ;
    ;--- high limit                               ;
    MOV bl, BYTE PTR SS:[GDT_limit + 1]           ;
    AND bl, 00001111B                             ; don't make assumptions, we might get garbage passed
    MOV dl, BYTE PTR [cx].GDT_entry.granularity   ;
    AND dl, 11110000B                             ;
    OR dl, bl                                     ;
    MOV BYTE PTR [cx].GDT_entry.granularity, dl   ;
    ;-- encode flag                               ;
    MOV bl, BYTE PTR [GDT_flags]                  ;
    SHL bl, 4                                     ;
    MOV dl, BYTE PTR [cx].GDT_entry.granularity   ;
    AND dl, 00001111B                             ;
    OR dl, bl                                     ;
    MOV BYTE PTR [cx].GDT_entry.granularity, dl   ;
    ;-- encode base                               ;
    ;--- low base                                 ;
    MOV bx, WORD PTR [GDT_base + 2]               ;
    MOV WORD PTR [cx].GDT_entry.baseLow, bx       ;
    ;--- mid base                                 ;
    MOV bl, BYTE PTR [GDT_base + 1]               ;
    MOV BYTE PTR [cx].GDT_entry.baseMid, bl       ;
    ;--- high base                                ;
    MOV bl, BYTE PTR [GDT_base]                   ;
    MOV BYTE PTR [cx].GDT_entry.baseHighest, bl   ;
    ;-- encode access byte                        ;
    MOV bl, BYTE PTR [GDT_accessByte]             ;
    MOV BYTE PTR [cx].GDT_entry.accessByte, bl    ;
                                                  ;
    ;- all done!                                  ;
    MAC_POP_COMMON_REGS                           ;
    LEAVE                                         ;
    RET 16                                        ; free the 16 bytes of stack params
GDT_encodeEntry ENDP                              ;
                                                  ;
;-------------------------------------------------;
; GDT_set                                         ;
;-( inputs )--------------------------------------;
; BP + 2 = pointer to GDTR PTR (FWORD)            ;
;-------------------------------------------------;
GDT_set PROC                                      ;
    GDTR_ptr EQU BP + 2                           ;
    ;- get GDTR                                   ;
    MOV ax, WORD PTR [GDTR_ptr]                   ;
    ASSUME AX: PTR GDTR                           ;
    ;- LGDT                                       ;
    LGDT FWORD PTR [ax]                           ;
    ;- load the DS                                ;
    MOV ax, PARAM_KERNEL_DATA_SEG                 ;
    MOV ds, ax                                    ;
    MOV es, ax                                    ;
    MOV fs, ax                                    ;
    MOV gs, ax                                    ;
    MOV ss, ax                                    ;
    DB 0EAH                                       ;
    DW PARAM_KERNEL_CODE_SEG                      ;
    ;- gdt is in place! recover and return to old function
@@recover:                                        ;
    RET                                           ;
GDT_set ENDP                                      ;
                                                  ;
include structure.s                               ;
                                                  ;

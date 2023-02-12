;-------------------------------------------------;
; Copyright 2023 Maximilian Wittmer               ;
;-------------------------------------------------; Namespace GDT
                                                  ;
;-------------------------------------------------;
; GDT_entry                                       ;
;-------------------------------------------------;
; structure for one GDT entry. very weird encoding;
; bc of compat.                                   ;
; https://wiki.osdev.org/Global_Descriptor_Table  ;
;-------------------------------------------------;
GDT_entry STRUCT                                  ;
    limitLow DW ?                                 ;
    baseLow DW ?                                  ;
    baseMid DB ?                                  ;
    accessByte DB ?                               ;
    granularity DB ?                              ;
    baseHighest DB ?                              ;
GDT_entry ENDS                                    ;
                                                  ;
;-------------------------------------------------;
; GDTR                                            ;
;-------------------------------------------------;
; only for 32 bit systems                         ;
;-------------------------------------------------;
GDTR STRUCT                                       ;
    SZ DW ?                                       ; subtract by 1 for real size!!
    GDTptr32 DD ?                                 ;
GDTR ENDS                                         ;

ORG 0
BITS 16

_start:
    jmp short start
    nop
 
 times 33 db 0

start:
jmp 0x7c0:step2 ; makes our code segment 0x7c0

; INT 13h, AH = 02h
; BIOS Disk Services - Read Sectors

; Input:
;   AH    = 02h        ; Read sectors
;   AL    = sectors to read
;   CH    = cylinder
;   CL    = sector number (1-based)
;   DH    = head
;   DL    = drive number (00h floppy, 80h HDD)
;   ES:BX = destination memory address
;
; Output:
;   CF = 0             ; Success
;   CF = 1             ; Error
;   AH = error code
;
; Notes:
;   - Sector numbers start at 1, not 0
;   - ES:BX points to where the data is loaded
;   - DL should normally contain the boot drive number
;     saved from BIOS on boot
;
; Example:
;   Read 1 sector from sector 2 into 0000:7E00

step2:
    cli  ; Clear Interrupts
    mov ax, 0x7c0
    mov ds, ax
    mov es, ax
    mov ax, 0x00
    mov ss, ax
    mov sp, 0x7c00
    sti ; Enables Interrupts 

    mov ah, 2 ; Read Sector Command
    mov al, 1 ; One Sector to Read
    mov ch, 0 ; Cylinder Low Eight Bits
    mov cl, 2 ; Read Sector 2
    mov dh, 0 ; Head number
    mov bx, buffer
    int 0x13
    jc error

    mov si, buffer
    call print
    jmp $

error:
    mov si, error_message
    call print
    jmp $
  
print:
    mov bx, 0

.loop:
    lodsb
    cmp al, 0
    je .done
    call print_char
    jmp .loop
.done:
    ret

print_char:
    mov ah, 0eh
    int 0x10
    ret

error_message: db 'Failed to load sector', 0

times 510 - ($ - $$) db 0
dw 0xAA55

buffer:

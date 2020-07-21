; Header segment is needed for emulators only
.segment "HEADER"
	.byte "NES"
	.byte $1a
	.byte $02		; 2 * 16 KB PRG ROM
	.byte $01		; 1 * 8 KB CHR ROM
	.byte %00000000	; mapper and mirroring
	.byte $00
	.byte $00
	.byte $00
	.byte $00
	.byte $00, $00, $00, $00, $00

; Enable zeropage
.segment "ZEROPAGE"	; LSB 0x00 - 0xFF

; Startup code
.segment "STARTUP"
Reset:
	SEI				; Disables all interrupts
	CLD				; Disables decimal mode - NES doesn't support it
	; Disables sound IRQ
	LDX #$40
	STX $4017
	; Initializes stack register
	LDX #$FF
	TXS
	; Leaving LDX clear
	INX
	; Clear PPU registers
	STX $2000
	STX $2001
	STX $4010

	; Wait for VBlank
:
	BIT $2002
	BPL :-
	; Leaving A clear
	TXA

	; Clear memory
ClearMem:
	STA $0000, X	; $0000 => $00FF
	STA $0100, X	; $0100 => $01FF
	STA $0300, X	; $0300 => $03FF
	STA $0400, X	; $0400 => $04FF
	STA $0500, X	; $0500 => $05FF
	STA $0600, X	; $0600 => $06FF
	STA $0700, X	; $0700 => $07FF
	LDA #$FF		; FF will clear sprite data memory region ($0200-$02FF)
	STA $0200, X	; $0200 => $02FF
	LDA #$00
	INX
	BNE ClearMem
	; Wait for VBlank
:
	BIT $2002
	BPL :-
	; Set video memory region (PPU)
	LDA #$02
	STA $4014
	NOP
	; Write $3F00 to PPU - Prepare to write data
	LDA #$3F
	STA $2006
	LDA #$00
	STA $2006

	; Load pallete values
	LDX #$00
LoadPalletes:
	LDA PalleteData, X
	STA $2007		; Autoincrements the PPU memory address ($3F00 - $3F1F)
	INX
	CPX #$20		; Increment through memory
	BNE LoadPalletes

	; Load Sprite values
	LDX #$00
LoadSprites:
	LDA SpriteData, X
	STA $0200, X
	INX
	CPX #$20
	BNE LoadSprites

; Enables interrupts
	CLI
	; Enables NMI and change background to use second CHR set of tiles ($1000)
	LDA #%10010000
	STA $2000
	; Enabling sprites and background for left-most 8 pixels
	LDA #%00011110
	STA $2001

Loop:
	JMP Loop

NMI:
	LDA #$02		; Copy sprite data from $0200 => PPU memory for display
	STA $4014
	RTI				; Return from interrupt subroutine

PalleteData:
	.byte $22,$29,$1A,$0F,$22,$36,$17,$0f,$22,$30,$21,$0f,$22,$27,$17,$0F  ;background palette data
	.byte $22,$16,$27,$18,$22,$1A,$30,$27,$22,$16,$30,$27,$22,$0F,$36,$17  ;sprite palette data

SpriteData:
	.byte $08, $00, $00, $08
  	.byte $08, $01, $00, $10
  	.byte $10, $02, $00, $08
	.byte $10, $03, $00, $10
	.byte $18, $04, $00, $08
	.byte $18, $05, $00, $10
	.byte $20, $06, $00, $08
	.byte $20, $07, $00, $10

; Interrupt vectors
.segment "VECTORS"
	.word NMI
	.word Reset
	; Used for specialized HW that triggers interrupts

; Include character bitmaps and tiles mapping
.segment "CHARS"
	.incbin "hellomario.chr"

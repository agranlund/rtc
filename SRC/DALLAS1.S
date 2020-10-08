;--------------------------------------------------------------
; dallas1.s
;	Dallas Phantom Time Chip (ROM configuration)
;
;	DS1216E, DS1216F
;	DS1315 in ROM mode
;
;
; Thanks to Troed of SYNC for example DS1216 code
;
;--------------------------------------------------------------
;
; This file is distributed under the GPL v2 or at your
; option any later version.	See LICENSE.TXT for details.
;
; (c) Anders Granlund, 2020
;
;--------------------------------------------------------------
DEV_BASE_ADDR		EQU	$00000000	; autodetect
DEV_WRITE_ADDR		EQU	$00000001	; A1	-->	D
DEV_READ_ADDR		EQU	$0000000C	; A2 or A3 --> /CE
DEV_NVRAM_SIZE		EQU	$00000000	;
DEV_CONF4			EQU	$00000000	;
DEV_CONF5			EQU	$00000000	;
DEV_CONF6			EQU	$00000005	; autodetect delay
DEV_CONF7			EQU	$00000000	; last found addr

CONF_DETECT_DELAY	EQU	6*4
CONF_PREF_ADDR		EQU	7*4


	include "CORE.S"


section data
dsAutoDetectPref:
	dc.l	$0
dsAutoDetectAddr:
	dc.l	$00FB0000, $00FB0001	; Cartridge ROM3
	dc.l	$00FA0000, $00FA0001	; Cartridge ROM4
	dc.l	$00E00000, $00E00001	; TOS2 Lo/Hi-0
	dc.l	$00FC0000, $00FC0001	; TOS1 Lo/Hi-0
	dc.l	$00FD0000, $00FD0001	; TOS1 Lo/Hi-1
	dc.l	$00FE0000, $00FE0001	; TOS1 Lo/Hi-2
	dc.l	0


section bss
gBusError	ds.l	1
gReadAddr	ds.l	1
gWriteAddr	ds.l	1
gDataPin	ds.l	1



section text
;--------------------------------------------------------------
devInit:		; a0 = config, d0 = return status
;--------------------------------------------------------------
	move.l	(a0),a0
	bsr		dsDetect	; detect chip
	cmp.l	#0,d0
	bne		.found
	moveq.l	#0,d0
	rts
.found
	rts

;--------------------------------------------------------------
devGetTime:	 ; d0 = return
;--------------------------------------------------------------
	bsr	dsOpen
	bsr	dsReadRegs
	
	moveq	#0,d7	; year
	rol.l	#4,d1
	move.l	d1,d2
	and.l	#$F,d2
	mulu.w	#10,d2
	rol.l	#4,d1
	move.l	d1,d3
	and.l	#$F,d3
	add.l	d2,d3
	and.l	#$7F,d3
	ror.l	#7,d3
	or.l	d3,d7

	rol.l	#4,d1	; month
	move.l	d1,d2
	and.l	#1,d2
	mulu.w	#10,d2
	rol.l	#4,d1
	move.l	d1,d3
	and.l	#$F,d3
	add.l	d2,d3
	and.l	#$F,d3
	ror.l	#8,d3
	ror.l	#3,d3
	or.l	d3,d7

	rol.l	#4,d1	; day
	move.l	d1,d2
	and.l	#3,d2
	mulu.w	#10,d2
	rol.l	#4,d1
	move.l	d1,d3
	and.l	#$F,d3
	add.l	d2,d3
	and.l	#$1F,d3
	swap	d3
	or.l	d3,d7

	rol.l	#4,d0	; hour
	move.l	d0,d2
	and.l	#3,d2
	mulu.w	#10,d2
	rol.l	#4,d0
	move.l	d0,d3
	and.l	#$F,d3
	add.l	d2,d3
	and.l	#$1F,d3
	lsl.l	#8,d3
	lsl.l	#3,d3
	or.l	d3,d7


	rol.l	#4,d0	; minute
	move.l	d0,d2
	and.l	#7,d2
	mulu.w	#10,d2
	rol.l	#4,d0
	move.l	d0,d3
	and.l	#$F,d3
	add.l	d2,d3
	and.l	#$3F,d3
	lsl.l	#5,d3
	or.l	d3,d7

	rol.l	#4,d0	; second/2
	move.l	d0,d2
	and.l	#7,d2
	mulu.w	#10,d2
	rol.l	#4,d0
	move.l	d0,d3
	and.l	#$F,d3
	add.l	d2,d3
	lsr.l	#1,d3
	and.l	#$1F,d3
	or.l	d3,d7

	move.l	d7,d0
	rts

;--------------------------------------------------------------
devSetTime:	 ; d0 = input
;--------------------------------------------------------------
	moveq	#0,d7

	move.l	d0,d1	; seconds
	and.l	#$1F,d1
	lsl.l	#1,d1
	divu.w	#10,d1
	swap	d1
	move.l	d1,d2
	and.l	#$F,d1
	or.l	d1,d7
	ror.l	#4,d7
	swap	d2
	and.l	#$7,d2
	or.l	d2,d7
	ror.l	#4,d7
	lsr.l	#5,d0

	move.l	d0,d1	; minutes
	and.l	#$3F,d1
	divu	#10,d1
	swap	d1
	move.l	d1,d2
	and.l	#$F,d1
	or.l	d1,d7
	ror.l	#4,d7
	swap	d2
	and	#$7,d2
	or.l	d2,d7
	ror.l	#4,d7
	lsr.l	#6,d0

	move.l	d0,d1	; hours
	and.l	#$1F,d1
	divu.w	#10,d1
	swap	d1
	move.l	d1,d2
	and.l	#$F,d1
	or.l	d1,d7
	ror.l	#4,d7
	swap	d2
	and.l	#$3,d2
	or.l	d2,d7
	ror.l	#4,d7
	and.l	#$FFFFFF00,d7
	lsr.l	#5,d0

	move.l	d7,d6
	moveq	#0,d7

	move.l	#$11,d1	; day + ctrl
	or.l	d1,d7
	ror.l	#8,d7

	move.l	d0,d1	; date
	and.l	#$1F,d1
	divu.w	#10,d1
	swap	d1
	move.l	d1,d2
	and.l	#$F,d1
	or.l	d1,d7
	ror.l	#4,d7
	swap	d2
	and.l	#$3,d2
	or.l	d2,d7
	ror.l	#4,d7
	lsr.l	#5,d0
	
	move.l	d0,d1	; month
	and.l	#$F,d1
	divu.w	#10,d1
	swap	d1
	move.l	d1,d2
	and.l	#$F,d1
	or.l	d1,d7
	ror.l	#4,d7
	swap	d2
	and.l	#$1,d2
	or.l	d2,d7
	ror.l	#4,d7
	lsr.l	#4,d0

	move.l	d0,d1	; year
	and.l	#$7F,d1
	divu.w	#10,d1
	swap	d1
	move.l	d1,d2
	and.l	#$F,d1
	or.l	d1,d7
	ror.l	#4,d7
	swap	d2
	and.l	#$F,d2
	or.l	d2,d7
	ror.l	#4,d7
	lsr.l	#5,d0


	move.l	d6,d0
	move.l	d7,d1
	bsr		dsOpen
	bsr		dsWriteRegs
	rts


;--------------------------------------------------------------
devReadNVram:	; a0 = buffer, d0 = start, d1 = length
;--------------------------------------------------------------
	rts

;--------------------------------------------------------------
devWriteNVram:	 ; a0 = buffer, d0 = start, d1 = length
;--------------------------------------------------------------
	rts

;--------------------------------------------------------------
dsSetAddr:		; d0 = base addr
;--------------------------------------------------------------
	movem.l	d0-d1,-(sp)
	move.l	d0,gWriteAddr
	or.l	config+8,d0
	move.l	d0,gReadAddr
	move.l	config+4,d0
	move.l	d0,gDataPin
	movem.l	(sp)+,d0-d1
	rts

;--------------------------------------------------------------
dsDetect:		; d0 = base address in/out
;--------------------------------------------------------------
	cmp.l	#0,d0
	beq		dsAutoDetect
	bsr		dsCheckDevice
	bne		.found
	bsr		dsInitDevice
	bsr		dsCheckDevice
	bne		.found	
	moveq	#0,d0
	rts
.found
	move.l	gWriteAddr,d0
	rts

dsAutoDetect:
	move.l	config+CONF_PREF_ADDR,d0
	movea.l	#dsAutoDetectPref,a1
	move.l	d0,(a1)
	cmp.l	#0,d0
	bne		.l1
	add.l	#4,a1
.l1 move.l	(a1)+,d0
	cmp.l	#0,d0
	beq		.l2
	bsr		dsCheckDevice
	bne		.l7
	bra		.l1
.l2 movea.l	#dsAutoDetectAddr,a1	; found nothing
.l3 move.l	(a1)+,d0				; it may be switched off so
	cmp.l	#0,d0					; reinitialize and try again
	beq		.l4
	bsr		dsInitDevice
	bra		.l3
.l4 movea.l	#dsAutoDetectAddr,a1	; again now
.l5 move.l	(a1)+,d0
	cmp.l	#0,d0
	beq		.l6
	bsr		dsCheckDevice
	bne		.l7
	bra		.l5
.l6 moveq	#0,d0
	rts
.l7 move.l	-(a1),d0
	move.l	dsAutoDetectPref,d1
	cmp.l	d0,d1
	bne		dsUpdateAutoDetectPref
	rts

dsUpdateAutoDetectPref:
	move.l	d0,-(sp)
	move.l	d0,dsAutoDetectPref
	move.l	d0,config+CONF_PREF_ADDR
	bsr		saveConfig
	move.l	(sp)+,d0
	rts

dsCheckDevice:
	move.l	sp,a6
	move.l	$8,gBusError
	move.l	#.except,$8
	bsr		dsSetAddr
	bsr		dsOpen
	bsr		dsReadRegs
	move.l	d0,d2
	move.l	$4ba,d1
	add.l	config+CONF_DETECT_DELAY,d1
.l1 move.l	$4ba,d0
	cmp.l	d0,d1
	bhi		.l1
	bsr		dsOpen
	bsr		dsReadRegs
.done:
	cmp.l	d0,d2
	rts
.except
	move.l	a6,sp
	moveq	#0,d0
	moveq	#0,d1
	move.l	gBusError,$8
	bra		.done

dsInitDevice:
	bsr		dsSetAddr
	bsr		dsOpen
	move.l	#$00000000,d0
	move.l	#$01010111,d1
	bsr		dsWriteRegs
	rts



;--------------------------------------------------------------
dsOpen:
;--------------------------------------------------------------
	movem.l	d0-d1,-(sp)
	bsr		dsReadRegs			; flush open transmissions
	move.l	#$5CA33AC5,d0		; write magic to reopen
	move.l	d0,d1
	bsr		dsWriteRegs
	movem.l (sp)+,d0-d1
	rts

;--------------------------------------------------------------
dsReadRegs:		; d1=7-4, d0=3-0
;--------------------------------------------------------------
	movem.l d2-d3/a0,-(sp)
	movea.l (gReadAddr),a0	 	; a0 = read address
	moveq	#0,d0
	moveq	#0,d1
	moveq	#63,d2		 		; d2 = bit counter
.l1 move.b	(a0),d3				; d3 = temp data
	roxr.b	#1,d3
	roxr.l	#1,d1
	roxr.l	#1,d0
	dbf		d2,.l1
	movem.l (sp)+,d2-d3/a0
	rts

;--------------------------------------------------------------
dsWriteRegs:	 ; d1=7-4, d0=3-0
;--------------------------------------------------------------
	movem.l d0-d5/a0,-(sp)
	movea.l (gWriteAddr),a0		; a0 = write address
	move.l	gDataPin,d2	 		; d2 = data pin
	moveq	#31,d5		 		; d5 = bit counter
.l1 move.w	d0,d3				; d3 = temp data
	ror.l	#1,d0
	and.w	#1,d3				; bit to write
	lsl.w	d2,d3				; shift into position
	move.b	(a0,d3),d4			; read to write
	dbf		d5,.l1
	moveq	#31,d5		 		; d5 = bit counter
.l2 move.w	d1,d3
	ror.l	#1,d1
	and.w	#1,d3				; bit to write
	lsl.w	d2,d3				; shift into position
	move.b	(a0,d3),d4			; read to write
	dbf		d5,.l2
	movem.l (sp)+,d0-d5/a0
	rts





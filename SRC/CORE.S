;--------------------------------------------------------------
; core.s
;	Atari RTC driver core
;
;	Driver is expected to supply the following defines:
;		DEV_BASE_ADDR
;		DEV_READ_ADDR
;		DEV_WRITE_ADDR
;		DEV_NVRAM_SIZE
;		DEV_CONF4
;		DEV_CONF5
;		DEV_CONF6
;		DEV_CONF7
;
;	Driver is expected to supply the following functions:
;		devInit		(d0 = return status, 0 = fail)
;		devGetTime		(d0 = time in TOS format)
;		devSetTime		(d0 = time in TOS format)
;		devReadNVram	(a0 = buffer, d0 = start, d1 = count)
;		devWriteNVram	(a0 = buffer, d0 = start, d1 = count)
;
;--------------------------------------------------------------
;
; Todo:
;	- config save
;
;--------------------------------------------------------------
;
; This file is distributed under the GPL v2 or at your
; option any later version.	See LICENSE.TXT for details.
;
; (c) Anders Granlund, 2020
;
;--------------------------------------------------------------
COOKIE_RTC	EQU	'RTCx'


;--------------------------------------------------------------
section bss
gStackTop	ds.l 256		; 1024 byte stack
gStack		ds.l 2
gTsrSize	ds.l 1			; program size for TSR
gPrevTrap14	ds.l 1			; original xbios trap

section text
_entrypoint
	bra	startup
config:
	dc.l	DEV_BASE_ADDR	; base address
	dc.l	DEV_WRITE_ADDR	; write address
	dc.l	DEV_READ_ADDR	; read address
	dc.l	DEV_NVRAM_SIZE	; nvram
	dc.l	DEV_CONF4		; reserved
	dc.l	DEV_CONF5		; reserved
	dc.l	DEV_CONF6		; reserved
	dc.l	DEV_CONF7		; reserved


;--------------------------------------------------------------



;--------------------------------------------------------------
startup:
;--------------------------------------------------------------
	move.l	4(sp),a0		; a0 = basepage
	lea		gStack(pc),sp	; initalize stack
	move.l	#100,d0			; basepage size
	add.l	#$1000,d0		; 
	add.l	$c(a0),d0		; text size
	add.l	$14(a0),d0		; data size
	add.l	$1c(a0),d0		; bss size
	lea		gTsrSize(pc),a1
	move.l	d0,(a1)
	move.l	d0,-(sp)		; Mshrink()
	move.l	a0,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#12,sp

	lea		main(pc),a0		; call main as supervisor
	pea		(a0)
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp		
	tst.w	d0				; check return code from main
	beq		.fail			; 0 = exit normally

	move.w	#0,-(sp)		; 1 = stay resident
	lea		gTsrSize(pc),a0
	move.l	(a0),-(sp)
	move.w	#49,-(sp)
	trap	#1
	addq.l	#8,sp
.fail:
	move.w	#0,-(sp)
	move.w	#76,-(sp) 
	trap	#1
	addq.l	#4,sp



;--------------------------------------------------------------
main:
;--------------------------------------------------------------
	move.l	#COOKIE_RTC,d0		; check cookie
	bsr		getCookie
	cmp.w	#0,d0
	bne		.fail

	movea.l #config,a0
	bsr		devInit				; init device
	beq		.fail

	move.l	d0,-(sp)

	bsr		devGetTime				; get date/time

	move.l	d0,-(sp)
	move.w	#43,-(sp)			; set gemdos date
	trap	#1
	addq.l	#4,sp
	move.w	#45,-(sp)			; set gemdos time
	trap	#1
	addq.l	#4,sp

	pea		xbiosHandler(pc)	; install new xbios set/get time
	move.w	#$2E,-(sp)
	move.w	#5,-(sp)
	trap	#13
	addq.l	#8,sp
	move.l	d0,gPrevTrap14

	move.l	#COOKIE_RTC,d0		; set cookie
	move.l	(sp)+,d1
	bsr		setCookie
	moveq.w #1,d0				; return value 1
	rts
.fail:
	moveq.w #0,d0				; return value 0
	rts


;--------------------------------------------------------------
xbiosHandler:
;--------------------------------------------------------------
	move	usp,a0
	btst	#5,(sp)				; already super?
	beq.s	.l1
	lea		6(sp),a0
	tst.w	$59E.w				; long stackframe?
	beq.s	.l1
	addq.l	#2,a0
.l1 move.w	(a0)+,d0			; d0 = xbios function
	cmp.w	#22,d0
	beq		xbios_setTime
	cmp.w	#23,d0
	beq		xbios_getTime
.l2 movea.l gPrevTrap14(pc),a0	; original trap14
	jmp		(a0)

xbios_getTime:
	movem.l	d1-d7/a0-a1,-(sp)
	bsr		devGetTime
	movem.l	(sp)+,d1-d7/a0-a1
	rte

xbios_setTime:
	movem.l d0-d7/a0-a5,-(sp)
	move.l	(a0),d0
	bsr		devSetTime
	movem.l (sp)+,d0-d7/a0-a5
	movea.l gPrevTrap14(pc),a0	; call original xbios in order for
	jmp		(a0)				; internal TOS variables to update


;--------------------------------------------------------------
xbios_NVMaccess:
;--------------------------------------------------------------
	rte

;--------------------------------------------------------------
saveConfig:
;--------------------------------------------------------------
	rts



;--------------------------------------------------------------
getCookie:
; input:
;	d0.l: cookie
; returns:
;	d0.w: exists? 0 or 1
;	d1.l: value
;--------------------------------------------------------------
	move.l	$5a0,d2				; has cookies?
	beq		.l3
	move.l	d2,a0
.l1	tst.l	(a0)				; end of cookies?
	beq		.l3
	cmp.l	(a0),d0				; compare cookie name
	beq		.l2
	addq.l	#8,a0
	bra		.l1
.l2 move.l	4(a0),d1			; found
	move.w	#1,d0
	rts
.l3	moveq.l #0,d1				; not found
	moveq.l #0,d0
	rts

;--------------------------------------------------------------
setCookie:
; input:
;	d0.l: cookie
;	d1.l: value
;--------------------------------------------------------------
	move.l	$5a0,d2				; has cookies?
	beq	.l3
	move.l	d2,a0
	moveq	#1,d3
.l1 tst.l	(a0)				; end of cookies?
	beq	.l2
	addq.l	#1,d3
	addq.l	#8,a0
	bra	.l1
.l2 move.l	4(a0),d2
	cmp.l	d2,d3				; full?
	bcc.s	.l3
	move.l	d0,0(a0)			; add our cookie
	move.l	d1,4(a0)
	move.l	#0,8(a0)			; add end cookie
	move.l	d2,12(a0)
.l3 rts


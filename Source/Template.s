;--------------------------------------------------------------
; template.s
;	 Dummy RTC driver template
;
;--------------------------------------------------------------
;
; This file is distributed under the GPL v2 or at your
; option any later version. See LICENSE.TXT for details.
;
; (c) Anders Granlund, 2020
;
;--------------------------------------------------------------
DEV_BASE_ADDR	EQU	$00000000
DEV_WRITE_ADDR	EQU	$00000000
DEV_READ_ADDR	EQU	$00000000
DEV_NVRAM_SIZE	EQU	$00000000
DEV_CONF4	EQU	$00000000
DEV_CONF5	EQU	$00000000
DEV_CONF6	EQU	$00000000
DEV_CONF7	EQU	$00000000

	include "Core.s"

section text

;--------------------------------------------------------------
devInit:			; d0 = return status, 0 = failed
;--------------------------------------------------------------
	moveq.l #0,d0
	rts

;--------------------------------------------------------------
devGetTime:			; d0 = return in TOS format
;--------------------------------------------------------------
	moveq.l #0,d0
	rts

;--------------------------------------------------------------
devSetTime:			; d0 = input in TOS format
;--------------------------------------------------------------
	rts

;--------------------------------------------------------------
devReadNVram:		; a0 = buffer, d0 = start, d1 = length
;--------------------------------------------------------------
	rts

;--------------------------------------------------------------
devWriteNVram:		; a0 = buffer, d0 = start, d1 = length
;--------------------------------------------------------------
	rts

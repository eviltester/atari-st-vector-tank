*	format	0-,1-
*	list +
*******************************
* joystick routines           *
*                             *
* joystick.s                  *
*                             *
*   04/06/94                  *
*******************************
*	list -


*
*	CSECT section defines all the asm routines which are exported
*
	CSECT		text,0

	XDEF		_initialise_joystick
	XDEF		_revector_joystick
	

*
* initialise_joystick sets up our joystick handler
* the old routine is placed into old_joy_vector
*
* set up the joystick routine
*
* smashes a0,d0
*

_initialise_joystick

	movem.l	d2-d7/a2-a6,-(sp)		* store old registers

*
* first off tell the IKBD to set the
* joystick into event reporting mode.
* This causes a joystick report to be generated
* whenever the state of either joystick
* changes.
*
* do this by Bconout(ing) command 0x14 to 
* the keyboard
*

	move.w	#$14,-(a7)	;IKBD command 0x14
	move.w	#4,-(a7)	;device 4(keyboard)
	move.w	#3,-(a7)	;Bconout
	trap	#13
	addq.l	#6,a7		;tidy

*
* get the address of the IKBD system vectors
* returned in d0.L
*

	move.w	#34,-(a7)	;kbdvbase
	trap	#14
	addq.l	#2,a7		;tidy

*
* store the old vector and patch in the new
*

	movea.l	d0,a0			;stick the address in a0
	lea	24(a0),a0		;the joystick vector
	move.l	(a0),old_joy_vector	;store old vector address
	move.l	#als_joy_handler,(a0)	;patch in the new one

	movem.l	(sp)+,d2-d7/a2-a6		* restore old registers

	rts






*
* revector_joystick puts the old joystick
* handler back in and sets the keyboard to 
* power up status
*
* smashes a0
*
* set joystick back to what it was

_revector_joystick

	movem.l	d2-d7/a2-a6,-(sp)		* store old registers

*
* get the address of the IKBD system vectors
* returned in d0.L
*
	move.w	#34,-(a7)
	trap	#14
	addq.l	#2,a7

*
* put back the old vector
*
	movea.l	d0,a0			;stick the address in a0
	lea	24(a0),a0		;the joystick vector
	move.l	old_joy_vector,(a0)	;put back the old one

*
* reset the keyboard to power up status
* this is done by Bconout(ing) to the keyboard
* command 0x80
* this is a two byte command so 0x80 must 
* be followed by 0x01
*
	move.w	#$80,-(a7)	;reset command byte 1
	move.w	#4,-(a7)	;to keyboard
	move.w	#3,-(a7)	;via Bconout
	trap	#13		;do it
	addq.l	#6,a7		;tidy

	move.w	#$1,-(a7)	;reset command byte 2
	move.w	#4,-(a7)	;to keyboard
	move.w	#3,-(a7)	;via Bconout
	trap	#13		;do it
	addq.l	#6,a7		;tidy

	movem.l	(sp)+,d2-d7/a2-a6		* restore old registers

	rts





* 
* als_joy_handler is the new joystick vector
* it reads both joystick ports and parses the
* joystick packets.
*
* it checks for firebutton state and places
* that in fire_button1 and fire_button2
*
* it uses a table lookup (which smashes d0)
* to make an easily processed way of using the info
* in the main prog. This puts a change value in
* joystick1_x & joystick1_y (also joystick2)
* -1 in x means left, 1 means right, 0 means nothing
* -1 in y means up, 1 means down, 0 means nothing
* ^^^ remember top left is (0,0)
*
* the routine the o/s now uses for joysticks
*
* smashes d0
*

als_joy_handler

*
* we use d0 as an offset into a table so we need
* to save it first (since we are called from an
* interrupt)
*

	move.l	d0,-(a7)	;d0 needs to be saved, so save it
	clr.l	d0		;clear it

*
* the routine is entered with a0 pointing to the 
* joystick data, this is 1 byte, with bits set as follows
* F...RLDU
* (a0) is the header byte and contains 0xFE if joystick0
* has changed state, and 0xFF if joystick1 has changed state
* essentially we don't care which has changed state since
* we process both of them :->
* 1(a0) contains joystick1 data
* 2(a0) contains joystick2 data
*
* see page 5.12 in Atari Compedium for more info
*

* process joystick 1

	move.b	1(a0),d0	;joystick port data   		F...RLDU
	add.b	d0,d0		;cause an overflow		...RLDU.
	scs	_fire_button1	;did fire flag overflow if so 0xFF else 0x00
	add.b	d0,d0		;make it into a table offset	..RLDU..

	move.l	joy_tab(pc,d0.w),joystick1_xy	;store the x&y change

* process joystick 2

	clr.l	d0

	move.b	2(a0),d0	;joystick port data   		F...RLDU
	add.b	d0,d0		;cause an overflow		...RLDU.
	scs	_fire_button2	;did fire flag overflow
	add.b	d0,d0		;make it into a table offset	..RLDU..

	move.l	joy_tab(pc,d0.w),joystick2_xy

* reset d0 back to what it was at the start of the routine

	move.l	(a7)+,d0


	rts

*
*	table of easily read joystick directional changes
*
joy_tab
*		x,y
	dc.w	0,0		;..0000..
	dc.w	0,-1		;..000U..
	dc.w	0,1		;..00D0..
	dc.w	0,0		;..00DU..	Impossible
	dc.w	-1,0		;..0L00..
	dc.w	-1,-1		;..0L0U..
	dc.w	-1,1		;..0LD0..
	dc.w	0,0		;..0LDU..	Impossible
	dc.w	1,0		;..R000..
	dc.w	1,-1		;..R00U..
	dc.w	1,1		;..R0D0..
	dc.w	0,0		;..R0DU..	Impossible
	dc.w	0,0		;..RL00..	Impossible
	dc.w	0,0		;..RL0U..	Impossible
	dc.w	0,0		;..RLD0..	Impossible
	dc.w	0,0		;..RLDU..	Impossible


old_joy_vector		ds.l	1

	CSECT		__MERGED,1

	XDEF	_fire_button1,_fire_button2,_joystick1_x,_joystick1_y,_joystick2_x,_joystick2_y

_fire_button1	ds.b 1
_fire_button2	ds.b 1
joystick1_xy			;used to move.l the values into x & y	
_joystick1_x	ds.w 1
_joystick1_y	ds.w 1
joystick2_xy			;used to move.l the values into x & y	
_joystick2_x	ds.w 1
_joystick2_y	ds.w 1

	END
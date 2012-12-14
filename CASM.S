*
*
*


*
*	CSECT section defines all the asm routines which are exported
*
	CSECT		text,0

*
* FastCLS clears the screen		FastCLS( screen_address ) 
*
	XDEF 		_FastCLS	
*
* PAUSE0 waits for a key 
*
	XDEF		_PAUSE0
*
* VSYNC waits for screen swapping 
*
	XDEF		_VSYNC 

	XDEF		_HIPLOT











* Functions

*
*	The arguments are passed on the stack in long word lengths
*	first is the return address, then the args
*	return values should be saved to d0
*
*	d2-d7 and a2-a6 must NOT be trashed	
*

*Skeleton
*
*	Get stuff off the stack before we add anything new to the stack
*	move.l	4(sp),value1	* get the passed parameters off the stack
*	move.l	8(sp),value2	* they are stored 32bits each in order. 
*
*	save the values on the stack
*	movem.l	d2-d7/a2-a6,-(sp)		* store old registers
*
*
*	movem.l	(sp)+,d2-d7/a2-a6		* restore old registers
*	rts

*
*	FastCLS(screen_address)
* 	FCLS -clears fast but smashes all data registers and a0-a3
*
_FastCLS	
	move.l	4(sp),a0		* get the screen address

	movem.l	d2-d7/a2-a6,-(sp)		* store old registers

	add.l	#$7d00,a0		; end of screen

	moveq.l	#0,d0
	move.l	d0,d1
	move.l	d1,d2
	move.l	d2,d3
	move.l	d3,d4
	move.l	d4,d5
	move.l	d5,d6
	move.l	d6,a1
	move.l	a1,a2
	move.l	a2,a3
	move.w	#24,d7			
clrLoop
	movem.l	d0-d6/a1-a3,-(a0)	
	movem.l	d0-d6/a1-a3,-(a0)
	movem.l	d0-d6/a1-a3,-(a0)
	movem.l	d0-d6/a1-a3,-(a0)
	movem.l	d0-d6/a1-a3,-(a0)
	movem.l	d0-d6/a1-a3,-(a0)
	movem.l	d0-d6/a1-a3,-(a0)
	movem.l	d0-d6/a1-a3,-(a0)
	movem.l	d0-d6/a1-a3,-(a0)
	movem.l	d0-d6/a1-a3,-(a0)
	movem.l	d0-d6/a1-a3,-(a0)
	movem.l	d0-d6/a1-a3,-(a0)
	movem.l	d0-d6/a1-a3,-(a0)
	movem.l	d0-d6/a1-a3,-(a0)
	movem.l	d0-d6/a1-a3,-(a0)
	movem.l	d0-d6/a1-a3,-(a0)
	movem.l	d0-d6/a1-a3,-(a0)
	movem.l	d0-d6/a1-a3,-(a0)
	movem.l	d0-d6/a1-a3,-(a0)
	movem.l	d0-d6/a1-a3,-(a0)
	movem.l	d0-d6/a1-a3,-(a0)
	movem.l	d0-d6/a1-a3,-(a0)
	movem.l	d0-d6/a1-a3,-(a0)
	movem.l	d0-d6/a1-a3,-(a0)
	movem.l	d0-d6/a1-a3,-(a0)
	movem.l	d0-d6/a1-a3,-(a0)
	movem.l	d0-d6/a1-a3,-(a0)
	movem.l	d0-d6/a1-a3,-(a0)
	movem.l	d0-d6/a1-a3,-(a0)
	movem.l	d0-d6/a1-a3,-(a0)
	movem.l	d0-d6/a1-a3,-(a0)
	movem.l	d0-d6/a1-a3,-(a0)
	dbra		d7,clrLoop

	movem.l	(sp)+,d2-d7/a2-a6		* restore old registers
	rts

*
*	PAUSE0 void function simulates speccy pause0
*
_PAUSE0
	move.w	#1,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

*
* VSYNC waits for screen swapping 
*
_VSYNC 
	move	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	rts

_HIPLOT	
	move.l	4(sp),d0		* x co-ord
	move.l	8(sp),d1		* y co-ord
	move.l	12(sp),a0	* get the screen address

	movem.l	d2-d7/a2-a6,-(sp)		* store old registers

*	move.l	#hi_res_y,a1
*	adda		d1,a1
*	move.w	(a1),d1			* vertical offset

	mulu.w	#80,d1
	move.w	d0,d2

	lsr		#4,d2				* /16 word offset on row
	add.w		d2,d2				* byte offset on row
	add.w		d2,d1
	adda.w	d1,a0				*	a0 points to correct word
	and		#$F,d0			*	d0 now holds correct pixel
	neg		d0
	add.w		#15,d0			* correct bit
	move		(a0),d1
	bchg		d0,d1
	move		d1,(a0)
	
	movem.l	(sp)+,d2-d7/a2-a6		* restore old registers
	rts


* instead of calculating the y addition factor just
* read it from this table instead 
hi_res_y
                dc.w 0,80,160,240,320,400,480,560,640,720
                dc.w 800,880,960,1040,1120,1200,1280,1360,1440,1520
                dc.w 1600,1680,1760,1840,1920,2000,2080,2160,2240,2320
                dc.w 2400,2480,2560,2640,2720,2800,2880,2960,3040,3120
                dc.w 3200,3280,3360,3440,3520,3600,3680,3760,3840,3920
                dc.w 4000,4080,4160,4240,4320,4400,4480,4560,4640,4720
                dc.w 4800,4880,4960,5040,5120,5200,5280,5360,5440,5520
                dc.w 5600,5680,5760,5840,5920,6000,6080,6160,6240,6320
                dc.w 6400,6480,6560,6640,6720,6800,6880,6960,7040,7120
                dc.w 7200,7280,7360,7440,7520,7600,7680,7760,7840,7920
                dc.w 8000,8080,8160,8240,8320,8400,8480,8560,8640,8720
                dc.w 8800,8880,8960,9040,9120,9200,9280,9360,9440,9520
                dc.w 9600,9680,9760,9840,9920,10000,10080,10160,10240,10320
                dc.w 10400,10480,10560,10640,10720,10800,10880,10960,11040,11120
                dc.w 11200,11280,11360,11440,11520,11600,11680,11760,11840,11920
                dc.w 12000,12080,12160,12240,12320,12400,12480,12560,12640,12720
                dc.w 12800,12880,12960,13040,13120,13200,13280,13360,13440,13520
                dc.w 13600,13680,13760,13840,13920,14000,14080,14160,14240,14320
                dc.w 14400,14480,14560,14640,14720,14800,14880,14960,15040,15120
                dc.w 15200,15280,15360,15440,15520,15600,15680,15760,15840,15920
                dc.w 16000,16080,16160,16240,16320,16400,16480,16560,16640,16720
                dc.w 16800,16880,16960,17040,17120,17200,17280,17360,17440,17520
                dc.w 17600,17680,17760,17840,17920,18000,18080,18160,18240,18320
                dc.w 18400,18480,18560,18640,18720,18800,18880,18960,19040,19120
                dc.w 19200,19280,19360,19440,19520,19600,19680,19760,19840,19920
                dc.w 20000,20080,20160,20240,20320,20400,20480,20560,20640,20720
                dc.w 20800,20880,20960,21040,21120,21200,21280,21360,21440,21520
                dc.w 21600,21680,21760,21840,21920,22000,22080,22160,22240,22320
                dc.w 22400,22480,22560,22640,22720,22800,22880,22960,23040,23120
                dc.w 23200,23280,23360,23440,23520,23600,23680,23760,23840,23920
                dc.w 24000,24080,24160,24240,24320,24400,24480,24560,24640,24720
                dc.w 24800,24880,24960,25040,25120,25200,25280,25360,25440,25520
                dc.w 25600,25680,25760,25840,25920,26000,26080,26160,26240,26320
                dc.w 26400,26480,26560,26640,26720,26800,26880,26960,27040,27120
                dc.w 27200,27280,27360,27440,27520,27600,27680,27760,27840,27920
                dc.w 28000,28080,28160,28240,28320,28400,28480,28560,28640,28720
                dc.w 28800,28880,28960,29040,29120,29200,29280,29360,29440,29520
                dc.w 29600,29680,29760,29840,29920,30000,30080,30160,30240,30320
                dc.w 30400,30480,30560,30640,30720,30800,30880,30960,31040,31120
                dc.w 31200,31280,31360,31440,31520,31600,31680,31760,31840,31920

	end
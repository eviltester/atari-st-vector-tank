 
#include <stdio.h>
/*#include <vdi.h>
#include <aes.h>*/
#include <osbind.h>
#include "casm.h"
#include	"cgraphic.h"
#include "joystick.h"

void draw_line(int x1, int y1, int x2, int y2, void *screen)
{
	short x,y,t,e,dx,dy,denom,xinc=1,yinc=1,vertlonger=0,aux;

	dx=x2-x1;
	dy=y2-y1;

	if(dx<0)
	{
		xinc=-1;
		dx=-dx;
	}

	if(dy<0)
	{
		yinc=-1;
		dy=-dy;
	}

	if(dy>dx)
	{
		vertlonger=1;
		aux=dx;
		dx=dy;
		dy=aux;
	}

	denom=dx<<1;
	t=dy<<1;
	e=-dx;
	x=x1;
	y=y1;

	while(dx-- >= 0)
	{
		HIPLOT(x,y,screen);
		if((e+=t)>0)
		{
			if(vertlonger)
				x+=xinc;
			else
				y+=yinc;
			
			e-=denom;
		}

		if(vertlonger)
			y+=yinc;
		else
			x+=xinc;
	}
}
                                           

void main( void )
{
	long	plot_loop;
	void *phys_screen;
	short palette[16];
	short palette2[]={
								0x000,0x777,0x000,0x000,
								0x000,0x000,0x000,0x000,
								0x000,0x000,0x000,0x000,
								0x000,0x000,0x000,0x000
							};
	short loop;

	initialise_joystick();
	Getpalette(palette);
 /*	PAUSE0();*/

	Setpalette(palette2);
	phys_screen=Physbase();
	FastCLS(phys_screen);

	for(plot_loop=1;plot_loop<200;plot_loop=plot_loop+2)
/*		HIPLOT(plot_loop,plot_loop,phys_screen);*/
		draw_line(1,1,plot_loop,300,phys_screen);
	PAUSE0();

/*	while(!fire_button1)
		printf("+");


	PAUSE0();*/
	Setpalette(palette);
	FastCLS(phys_screen);
	revector_joystick();

} 



/*
#define 	SCREEN_WIDTH	0
#define	SCREEN_HEIGHT	1
#define	SCREEN_COLOURS	13


short work_in[11]={1,1,1,1,1,1,1,1,1,1,2};
short work_out[57],work_out2[57];
short junk,handle;

int test_squarex=10;
int test_squarey=10;

int main(void)
{
	int xfactor,yfactor;
	int max_x,max_y;
	short square[10];
	short pts[]={100,200,300,400};

	appl_init();
	handle=graf_handle(&junk,&junk,&junk,&junk);
	v_opnvwk(work_in,&handle,work_out);
	vq_extnd(handle,1,work_out2);

	if(handle)
	{

	/* we can do shit */

		v_clsvwk(handle);
		v_clswk(handle);
		

		xfactor=(work_out[SCREEN_WIDTH]+1)/320;
		yfactor=(work_out[SCREEN_HEIGHT]+1)/200;

		max_x=(xfactor*320)-1;
		max_y=(yfactor*200)-1;

		printf("x %d y %d\n", xfactor,yfactor);

		/* lets scale the line width too */
/*		if(xfactor>0 && yfactor >0)
		{
			if(xfactor>yfactor)
				vsl_width(handle,yfactor);
			else
				vsl_width(handle,xfactor);
		}
*/
		if(xfactor>0)
			test_squarex=test_squarex*xfactor;

		if(yfactor>0)
			test_squarey=test_squarey*yfactor;

		printf("x %d y %d\n", test_squarex,test_squarey);

		square[0]=20;
		square[1]=20;
		square[2]=square[0]+test_squarex;
		square[3]=square[1];
		square[4]=square[0]+test_squarex;
		square[5]=square[1]+test_squarey;
		square[6]=square[0];
		square[7]=square[1]+test_squarey;
		square[8]=square[0];
		square[9]=square[1];

		v_pline(handle,4,square);
		v_pline(handle,2,pts);
		evnt_keybd();
		v_clsvwk(handle);

	}

	return appl_exit();

}


*/
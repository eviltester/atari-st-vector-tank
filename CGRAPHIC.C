#include "cgraphic.h"
#include <stdio.h>

void Getpalette(short *palette)
{
	short loop;

	for(loop=0;loop<15;loop++)
	{
		palette[loop]=Setcolor(loop,-1);	
	}
}

/*
void Setpalette(short *palette)
{
	Setpallete(palette);	
}
*/

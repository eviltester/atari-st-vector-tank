#include <stdio.h>

/* definitions */

void **create_line_index_array(int array_size);
void **delete_line_index_and_details(void **index, int index_size);

typedef struct{
		int x1;
		int y1; 
		int x2;
		int y2;
		int attribs;
		int current_attribs;
		}line_details;

line_details *create_line_details( void );
void **add_line_to_index(       int line_number,
				int x1, int y1, int x2, int y2, int attribs,
				void **index, int index_size
			);
void optomise_line_details( line_details *line_p );

typedef struct{
		struct int_list *left;
		int line_number;
		struct int_list *right;
		}int_list;

int_list *create_int_list( void );
int_list *append_int_to_list( int the_int, int_list *the_list);
int_list *delete_int_list(int_list *the_list);

#define MAX_WORD_VALUE          32768
#define PIXEL_BLOCK_SIZE        256
#define ARRAY_DIMENSION         MAX_WORD_VALUE/PIXEL_BLOCK_SIZE
void *world_array[ARRAY_DIMENSION][ARRAY_DIMENSION];

void nullify_empty_world_array( void );
void nullify_full_world_array( void );
void fill_world_array( void **line_index , int index_length);
void plot_world_array(int line_number, line_details *line_p);
void add_line_to_world_at(int line_number,int index_x, int index_y);

/* functions */

void **create_line_index_array(int array_size)
{
	void **return_p;

	return_p=(void **)malloc(sizeof(line_details *)*array_size);

	if(return_p)
	{
		for(;array_size>1;array_size--)
			return_p[array_size-1]=NULL;
	}
	
	return(return_p);
}

void **delete_line_index_and_details(void **index, int index_size)
{
	if(index)
	{
		for(;index_size>0;index_size--)
			if(index[index_size-1]!=NULL)
				free((line_details *)index[index_size-1]);

		free(index);
	}

	return NULL;
	
}

line_details *create_line_details( void )
{
	line_details *return_p;

	return_p=(line_details *)malloc(sizeof(line_details));

	if(return_p)
	{
		return_p->x1=0;
		return_p->y1=0;
		return_p->x2=0;
		return_p->y2=0;
		return_p->attribs=0;    
		return_p->current_attribs=0;
	}

	return(return_p);
}

void **add_line_to_index(       int line_number, 
				int x1, int y1, int x2, int y2, int attribs, 
				void **index, int index_size
			)
{
	line_details *line_p;

	if(index==NULL)
		return index;

	if(((line_details *)index[line_number])!=NULL)
	{
		printf("WARNING: Line %d already exists, overwriting details!\n",line_number);
		((line_details *)index[line_number])->x1=x1;
		((line_details *)index[line_number])->y1=y1;
		((line_details *)index[line_number])->x2=x2;
		((line_details *)index[line_number])->y2=y2;
		((line_details *)index[line_number])->attribs=attribs;
	}
	else
	{
		line_p=create_line_details();
		if(line_p)
		{
			line_p->x1=x1;
			line_p->y1=y1;
			line_p->x2=x2;
			line_p->y2=y2;
			line_p->attribs=attribs;
			index[line_number]=line_p;
		}
		else
		{
			printf("ERROR: OUT OF MEMORY creating line %d\n",line_number);
			/* free current level details */
			index=delete_line_index_and_details(index,index_size);
		}
	}

	return(index);
}

void optomise_line_details( line_details *line_p )
{
	int intermediate;

	/* this function just swaps the points if the x1 is greater than
	   x2. This way all lines move from left to right */

	if(line_p->x2 > line_p->x1)
	{
		intermediate=line_p->x1;
		line_p->x1=line_p->x2;
		line_p->x2=intermediate;

		intermediate=line_p->y1;                     
		line_p->y1=line_p->y2;
		line_p->y2=intermediate;
	}
}

/*
#define MAX_WORD_VALUE          32768
#define PIXEL_BLOCK_SIZE        256
#define ARRAY_DIMENSION         MAX_WORD_VALUE/PIXEL_BLOCK_SIZE
void *world_array[ARRAY_DIMENSION][ARRAY_DIMENSION];       
*/

void nullify_empty_world_array( void )
{
	int loop,loop2;

	loop = ARRAY_DIMENSION-1;

	for(;loop>=0;loop--)
	{
		for(loop2=ARRAY_DIMENSION-1; loop2>=0; loop2--)
			world_array[loop][loop2]=NULL;
	}
}

void nullify_full_world_array( void )
{
	int loop,loop2;

	loop = ARRAY_DIMENSION-1;

	for(;loop>=0;loop--)
	{
		for(loop2=ARRAY_DIMENSION-1; loop2>=0; loop2--)
			world_array[loop][loop2]=delete_int_list(world_array[loop][loop2]);                          
	}
}

void fill_world_array( void **line_index, int index_length )
{
	int loop;

	for(loop=0;loop<index_length;loop++)
	{
		if(line_index[loop]!=NULL)
		{
			printf("  plot the line for %d\n",loop);
			plot_world_array(loop,line_index[loop]);
		}
	}
	printf("end fill world array\n");
}

void plot_world_array(int line_number, line_details *line_p)
{
	int x,y,t,e,dx,dy,denom,xinc=1,yinc=1,vertlonger=0,aux;
	int last_world_index_x=-1, last_world_index_y=-1;

	dx=line_p->x2-line_p->x1;
	dy=line_p->y2-line_p->y1;

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
	x=line_p->x1;
	y=line_p->y1;

	while(dx-- >= 0)
	{
		if(last_world_index_x!=(int)x/PIXEL_BLOCK_SIZE ||
		   last_world_index_y!=(int)y/PIXEL_BLOCK_SIZE)
		{
			printf("    add line %d at %d,%d\n",line_number,
					x/PIXEL_BLOCK_SIZE,
					y/PIXEL_BLOCK_SIZE);
		
			add_line_to_world_at(   line_number,
						(int)x/PIXEL_BLOCK_SIZE,
						(int)y/PIXEL_BLOCK_SIZE);
			last_world_index_x=x/PIXEL_BLOCK_SIZE;
			last_world_index_y=y/PIXEL_BLOCK_SIZE;
		}
	/*      HIPLOT(x,y,screen);*/
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

void add_line_to_world_at(int line_number,int index_x, int index_y)
{
	int_list *temp;

	if(world_array[index_x][index_y]==NULL)
	{
		temp=create_int_list();
		temp->line_number=line_number;
		world_array[index_x][index_y]=temp;
	}
	else
	{
		world_array[index_x][index_y]=append_int_to_list(line_number,world_array[index_x][index_y]);
	}
}
	 
int_list *create_int_list( void )
{
	int_list *created;

	created=(int_list *)malloc(sizeof(int_list));
	if(created)
	{
		created->left=NULL;
		created->line_number=0;
		created->right=NULL;
	}

	return(created);
}

int_list *append_int_to_list( int the_int, int_list *the_list)
{
	int_list *created,*listp;

	if(the_list)
	{
		listp=the_list;
		while(listp->right!=NULL)
			listp=(int_list *)listp->right;

		created=create_int_list();
		if(created)
		{
			(int_list *)created->left=(int_list *)listp;
			created->line_number=the_int;
		}
	}
	else
	{
		created=create_int_list();
		if(created)
		{
			(int_list *)created->left=(int_list *)listp;
			created->line_number=the_int;
		}        
		the_list=created;
	}

	return(the_list);
}

int_list *delete_int_list(int_list *the_list)
{
	int_list *temp_list;

	while(the_list!=NULL)
	{
		temp_list=the_list;
		free(the_list);
		the_list=(int_list *)temp_list->right;
	}

	return NULL;
}

void main( void )
{
	void **line_index;

printf("nullify empty world array\n");
	nullify_empty_world_array();

printf("create the line index\n");

	line_index=create_line_index_array(4);

printf("nullify full world array\n");
	nullify_full_world_array();

printf(" add line 0\n");
	line_index=add_line_to_index(0,0,0,639,0,0,line_index,4);
printf(" add line 1\n");
	line_index=add_line_to_index(1,639,0,639,399,0,line_index,4);
printf(" add line 2\n");
	line_index=add_line_to_index(2,639,399,0,399,0,line_index,4);
printf(" add line 3\n");
	line_index=add_line_to_index(3,0,399,0,0,0,line_index,4);

printf(" fill that world array \n");
	fill_world_array(line_index, 4);

printf(" delete the line array \n");
	delete_line_index_and_details(line_index, 4);

printf(" delete the world array (nullify full)\n");
	nullify_full_world_array();

}

#ifdef BOLLOCKS_THIS_WILL_NEVER_HAPPEN
void clip_line(int x1, int y1, int x2, int y2, int *window, int xtransform, int ytransform)
{
	/* check jeff lawson code cause the book I have is naff */
	/* and 3d graphics book too */

	int vertical_slope_flag;
	int edge_loop;
	float slope;

	vertical_slope_flag=0

	/* check for vertical line */

	if(x2-x1==0)
	{
		vertical_clope_flag=-1;
	}
	else
	{
		/* calculate_slope */
		slope = (y2-y1)/(x2-x1);
	}

	for(edge_loop=0;edge_loop<4;edge_loop++)
	{

	}
}
#endif


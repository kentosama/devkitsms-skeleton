/*******************************************
 * Filename: types.h
 * Created: Sun Nov 22 2020 
 * Author: Jacques Belosoukinski <kentosama>
 * Github: https://github.com/kentosama
 *******************************************/

#ifndef TYPES_H_INCLUDED
#define TYPES_H_INCLUDED

#define FALSE 0
#define TRUE 1

typedef unsigned char u8;
typedef unsigned short u16;
typedef signed char s8;
typedef signed short s16;

typedef struct
{
    u8 x,y;
} Vect2D_u8;

typedef struct
{
    u16 x,y;
} Vect2D_u16;

typedef struct
{
    s8 x,y;
} Vect2D_s8;

typedef struct
{
    s16 x,y;
} Vect2D_s16;


#endif
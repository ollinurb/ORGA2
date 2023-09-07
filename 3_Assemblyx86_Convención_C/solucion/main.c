#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>

#include "checkpoints.h"

int main (void){
	/* Acá pueden realizar sus propias pruebas */

	/*  alternate_sum_4  */
	assert(alternate_sum_4(8,2,5,1) == 10);	
	assert(alternate_sum_4(1,1,1,1) == 0);	
	assert(alternate_sum_4(10,5,20,3) == 22);	
	assert(alternate_sum_4(-2,-1,-1,-2) == 0);

	/*  alternate_sum_4_using_c  */
	assert(alternate_sum_4_using_c(8,2,5,1) == 10);
	assert(alternate_sum_4_using_c(1,1,1,1) == 0);	
	assert(alternate_sum_4_using_c(10,5,20,3) == 22);	
	assert(alternate_sum_4_using_c(-2,-1,-1,-2) == 0);

	/*  alternate_sum_4_simplified  */
	assert(alternate_sum_4_simplified(8,2,5,1) == 10);	
	assert(alternate_sum_4_simplified(1,1,1,1) == 0);	
	assert(alternate_sum_4_simplified(10,5,20,3) == 22);	
	assert(alternate_sum_4_simplified(-2,-1,-1,-2) == 0);

	/*  alternate_sum_8  */
	assert(alternate_sum_8(8,2,5,1,1,1,1,1) == 10);	
	assert(alternate_sum_8(1,1,1,1,8,2,5,1) == 10);	
	assert(alternate_sum_8(8,2,5,1,8,2,5,1) == 20);
	assert(alternate_sum_8(1,1,1,1,1,1,1,1) == 0);
	assert(alternate_sum_8(10,5,20,3,8,2,5,1) == 32);	
	assert(alternate_sum_8(-2,-1,-1,-2,10,5,20,3) == 22);

	
}
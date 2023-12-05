#include "task_lib.h"

#define WIDTH TASK_VIEWPORT_WIDTH
#define HEIGHT TASK_VIEWPORT_HEIGHT

#define SHARED_SCORE_BASE_VADDR (PAGE_ON_DEMAND_BASE_VADDR + 0xF00)
#define CANT_PONGS 3


void task(void) {
	screen pantalla;
	// ¿Una tarea debe terminar en nuestro sistema?
	while (true)
	{
	int8_t task_id = 0;
	uint32_t* current_task_record_task_0 = (uint32_t*) SHARED_SCORE_BASE_VADDR + ((uint32_t) task_id * sizeof(uint32_t)*2);
	uint32_t task_0_player_1 = current_task_record_task_0[0];
	uint32_t task_0_player_2 = current_task_record_task_0[1];

	task_id++;
	uint32_t* current_task_record_task_1 = (uint32_t*) SHARED_SCORE_BASE_VADDR + ((uint32_t) task_id * sizeof(uint32_t)*2);
	uint32_t task_1_player_1 = current_task_record_task_1[0];
	uint32_t task_1_player_2 = current_task_record_task_1[1];

	task_id++;
	uint32_t* current_task_record_task_2 = (uint32_t*) SHARED_SCORE_BASE_VADDR + ((uint32_t) task_id * sizeof(uint32_t)*2);
	uint32_t task_2_player_1 = current_task_record_task_2[0];
	uint32_t task_2_player_2 = current_task_record_task_2[1];

	task_print_dec(pantalla, task_0_player_1, 2, WIDTH / 2 - 3, 0, C_FG_CYAN);
	task_print_dec(pantalla, task_0_player_2, 2, WIDTH / 2, 0, C_FG_CYAN);

	task_print_dec(pantalla, task_1_player_1, 2, WIDTH / 2 - 3, 2, C_FG_CYAN);
	task_print_dec(pantalla, task_1_player_2, 2, WIDTH / 2, 2, C_FG_CYAN);

	task_print_dec(pantalla, task_2_player_1, 2, WIDTH / 2 - 3, 4, C_FG_CYAN);
	task_print_dec(pantalla, task_2_player_2, 2, WIDTH / 2, 4, C_FG_CYAN);
	// Completar:
	// - Pueden definir funciones auxiliares para imprimir en pantalla
	// - Pueden usar `task_print`, `task_print_dec`, etc. 
		syscall_draw(pantalla);
	}
}

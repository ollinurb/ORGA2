#include "lista_enlazada.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>


lista_t* nueva_lista(void) {
	lista_t * res = malloc(sizeof(nodo_t));
	res->head = NULL;
	return res;
}

uint32_t longitud(lista_t* lista) {
	nodo_t *it_lista = lista->head;
	uint32_t res = 0;
	while(it_lista->next != NULL){
		res++;
		it_lista++;
	}
	return res;
}

void agregar_al_final(lista_t* lista, uint32_t* arreglo, uint64_t longitud) {
	uint32_t * dir_cp_arreglo = malloc(longitud * sizeof(uint32_t));
	memcpy(dir_cp_arreglo, arreglo, longitud * sizeof(uint32_t)); 

	nodo_t * nuevo_nodo = malloc(sizeof(nodo_t));
	nuevo_nodo->next = NULL;
	nuevo_nodo->longitud = longitud;
	nuevo_nodo->arreglo = dir_cp_arreglo;
	if(lista->head == NULL){
		lista->head = nuevo_nodo;
	}else{
		nodo_t * it_lista = lista->head;
		while(it_lista->next != NULL){
			it_lista = it_lista->next;
		}
		it_lista->next = nuevo_nodo;
	}
}

nodo_t* iesimo(lista_t* lista, uint32_t i) {
	nodo_t * it = lista->head;
	for(uint32_t j = 0; j < i; j++){
		it = it->next;
	}
	return it;
}

uint64_t cantidad_total_de_elementos(lista_t* lista) {
	uint64_t res = 0;
	nodo_t * ptr = lista->head;
	while(ptr != NULL){
		res = res + ptr->longitud;
		ptr = ptr->next;
	}
	return res;
}

void imprimir_lista(lista_t* lista) {
		nodo_t * ptr = lista->head;
	while(ptr != NULL){
		printf("| %ld | ->",ptr->longitud);
	}
	printf(" null\n");
}

// Función auxiliar para lista_contiene_elemento
int array_contiene_elemento(uint32_t* array, uint64_t size_of_array, uint32_t elemento_a_buscar) {
	int res = 0;
	uint32_t * it = array;
	for(uint32_t i = 0; i < size_of_array && !res; i++){
		if(*it == elemento_a_buscar){
			res = 1;
		}
		it++;
	}
	return res;
}

int lista_contiene_elemento(lista_t *lista, uint32_t elemento_a_buscar)
{
	nodo_t *ptr = lista->head;
	int res = 0;
	while (ptr != NULL && !res){
		if (array_contiene_elemento(ptr->arreglo, ptr->longitud, elemento_a_buscar) == 1){
			res = 1;
		}
		ptr = ptr->next;
	}
	return res;
}

// Devuelve la memoria otorgada para construir la lista indicada por el primer argumento.
// Tener en cuenta que ademas, se debe liberar la memoria correspondiente a cada array de cada elemento de la lista.
void destruir_lista(lista_t* lista) {
	nodo_t * ptr = lista->head;
	while(ptr != NULL){
		free(ptr->arreglo);
		//deberia iterar por el arreglo y borrar cada dirección?
		nodo_t * sig = ptr->next;
		free(ptr);
		ptr = sig;
	}
	free(lista);
}

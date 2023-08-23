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
}

void agregar_al_final(lista_t* lista, uint32_t* arreglo, uint64_t longitud) {
	uint32t* dir_cp_arreglo = malloc(sizeof(uint32t));
	uint32t* it = arreglo;
	while()
	
	uint32t* copia_dir_arreglo = arreglo;

	if(lista_head == NULL){
		nodo_t * nuevo_nodo = malloc(sizeof(nodo_t));
		*nuevo_nodo = {NULL; longitud; arreglo};
		lista_head = nuevo_nodo;
	}else{
		nodo_t * it_lista = lista->head;
		while(it_lista->next != NULL){
			it_lista++;
		}

		nodo_t * nuevo_nodo = malloc(sizeof(nodo_t));
		*nuevo_nodo = {NULL; longitud; arreglo};
		lista_head = nuevo_nodo;
		it_lista->next = nuevo_nodo;
	}
}

nodo_t* iesimo(lista_t* lista, uint32_t i) {
}

uint64_t cantidad_total_de_elementos(lista_t* lista) {
}

void imprimir_lista(lista_t* lista) {
}

// Función auxiliar para lista_contiene_elemento
int array_contiene_elemento(uint32_t* array, uint64_t size_of_array, uint32_t elemento_a_buscar) {
}

int lista_contiene_elemento(lista_t* lista, uint32_t elemento_a_buscar) {

}


// Devuelve la memoria otorgada para construir la lista indicada por el primer argumento.
// Tener en cuenta que ademas, se debe liberar la memoria correspondiente a cada array de cada elemento de la lista.
void destruir_lista(lista_t* lista) {
}

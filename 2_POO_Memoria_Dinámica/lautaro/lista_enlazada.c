#include "lista_enlazada.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

lista_t *nueva_lista(void)
{
    lista_t *nlista = malloc(sizeof(lista_t));
    nlista->head = NULL;
    return nlista;
}

uint32_t longitud(lista_t *lista)
{
    uint32_t res = 0;
    nodo_t *iterador = lista->head;
    while (iterador != NULL)
    {
        res++;
        iterador = iterador->next;
    }

    return res;
}

/*
Para poder agregar un nuevo nodo al final de la lista, primero debo llegar hasta el último nodo
de la misma. Para ello debo iterar a partir de un iterador que tenga el misvo valor que lista->head
hasta que el mismo apunte a NULL, lo que representa que este es el nodo final de la lista.
Para hacer esto va tomando el iterador el valor iterador->next, porque ya que apunta al próximo nodo
puede apuntar al valor next del nodo, lo que le permite llegar al siguiente.
una vez llegue al último nodo, pide memoria para poder guardar al nuevo nodo, y hace que el valor next
del último nodo apunte al inicio de este nuevo nodo, que será el puntero otorgado por la función malloc,
el valor next del nuevo nodo apunta a NULL, longitud vale longitudArr y se usa la funcion memcpy para copiar
al vector del cual se obtiene el puntero por parámetro en donde malloc reservó lugar para el mismo.
*/
void agregar_al_final(lista_t *lista, uint32_t *arreglo, uint64_t longitudArr)
{

    nodo_t *iterador = lista->head;
    while (iterador->next != NULL)
    {
        iterador = iterador->next;
    }
    nodo_t *nuevoNodo = malloc(sizeof(nodo_t));
    iterador->next = nuevoNodo;
    nuevoNodo->next = NULL;
    nuevoNodo->arreglo = malloc(longitudArr);
    nuevoNodo->longitud = longitudArr;
    memcpy(nuevoNodo->arreglo, arreglo, longitudArr);
}

nodo_t *iesimo(lista_t *lista, uint32_t i)
{
    nodo_t *nodo = lista->head;
    for (size_t j = 0; j < i; j++)
    {
        nodo = nodo->next;
    }
    return nodo;
}

uint64_t cantidad_total_de_elementos(lista_t *lista)
{
    nodo_t *nodo = lista->head;
    uint64_t res = 0;
    while (nodo->next != NULL)
    {
        res += nodo->longitud;
        nodo = nodo->next;
    }
    res += nodo->longitud;
    return res;
}

void imprimir_lista(lista_t *lista)
{
    nodo_t *nodo = lista->head;
    uint64_t res = 0;
    while (nodo->next != NULL)
    {
        printf(" | %ld | ->", nodo->longitud);
        nodo = nodo->next;
    }
    printf("null");
}

// Función auxiliar para lista_contiene_elemento
int array_contiene_elemento(uint32_t *array, uint64_t size_of_array, uint32_t elemento_a_buscar)
{
    uint32_t *elemento = array;
    int res = 0;

    for (uint64_t i = 0; i < size_of_array; i++)
    {
        if (*elemento == elemento_a_buscar)
        {
            res = 1;
        }
        elemento++;
    }
    return res;
}

int lista_contiene_elemento(lista_t *lista, uint32_t elemento_a_buscar)
{
    nodo_t *nodo = lista->head;
    int res = 0;
    while (nodo != NULL)
    {
        if(array_contiene_elemento(nodo->arreglo, nodo->longitud, elemento_a_buscar) == 1){
            res = 1;
        }
        nodo = nodo->next;
    }

    return res;
}

// Devuelve la memoria otorgada para construir la lista indicada por el primer argumento.
// Tener en cuenta que ademas, se debe liberar la memoria correspondiente a cada array de cada elemento de la lista.
void destruir_lista(lista_t *lista)
{

    while (lista->head != NULL)
    {
        nodo_t *nextNode = lista->head->next;
        free(lista->head->arreglo);
        free(lista->head);
        lista->head = nextNode;
    }
}
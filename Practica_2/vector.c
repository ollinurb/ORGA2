#include "vector.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


vector_t* nuevo_vector(void) {
    vector_t* res = malloc(sizeof(vector_t));
    uint32_t* arr[2] = malloc(2*sizeof(uint32_t));
    res->array = arr;
    res->capacity = 2;
    res->size = 0;
}

uint64_t get_size(vector_t* vector) {
    return vector->size;
}

void push_back(vector_t* vector, uint32_t elemento) {
    if(vector->size < vector->capacity){
        uint32_t * ptr_array = vector->array;
        uint64_t i = 0;
        while(i < vector->size){
            ptr_array++;
            i++;
        }
        ptr_array = elemento;
    } else{
        
    }
}

int son_iguales(vector_t* v1, vector_t* v2) {
}

uint32_t iesimo(vector_t* vector, size_t index) {
}

void copiar_iesimo(vector_t* vector, size_t index, uint32_t* out)
{
}


// Dado un array de vectores, devuelve un puntero a aquel con mayor longitud.
vector_t* vector_mas_grande(vector_t** array_de_vectores, size_t longitud_del_array) {
}

#include "vector.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


vector_t* nuevo_vector(void) {
    vector_t* res = malloc(sizeof(vector_t));
    uint32_t* arr = malloc(2*sizeof(uint32_t));
    res->array = arr;
    res->capacity = 2;
    res->size = 0;
    return res;
}

uint64_t get_size(vector_t* vector) {
    return vector->size;
}

void push_back(vector_t* vector, uint32_t elemento) {
    if(vector->size == vector->capacity){
        reallocarray(vector->array, vector->capacity, 2);
    }
    uint32_t * ptr_array = vector->array;
    uint64_t i = 0;
    while(i < vector->size){
        ptr_array++;
        i++;
    }
    *ptr_array = elemento;
}

int son_iguales(vector_t* v1, vector_t* v2) {
    if(v1->size != v2->size){
        return 0;
    }
    uint32_t * ptr1 = v1->array;
    uint32_t * ptr2 = v2->array;
    while(ptr1 != NULL && ptr2 != NULL){
        if(&ptr1 != &ptr2){
            return 0;
        }
        ptr1++;
        ptr2++;
    }
    return 1;
}

uint32_t iesimo(vector_t* vector, size_t index) {
    if(vector->size < index){
        return 0;
    }
    uint32_t * ptr = vector->array;
    uint32_t i = 0;
    while(i != index){
        ptr++;
        i++;
    }
    return *ptr;
}

void copiar_iesimo(vector_t* vector, size_t index, uint32_t* out){
    uint32_t * ptr = vector->array;
    uint32_t i = 0;
    while(i != index){
        ptr++;
        i++;
    }
    *out = *ptr;
}


// Dado un array de vectores, devuelve un puntero a aquel con mayor longitud.
vector_t* vector_mas_grande(vector_t** array_de_vectores, size_t longitud_del_array) {
    vector_t * res = *array_de_vectores;
    size_t i = 0;
    vector_t* it = *array_de_vectores;
    while(i < longitud_del_array){
        if(it->size > res->size){
            res = it;
        }
        i++;
        it++;
    }
    return res;
}

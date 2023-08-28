#include "classify_chars.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


void classify_chars_in_string(char* string, char** vowels_and_cons) {
    //inicializar vocales y consonantes
    // arr[0] == 
    char* ptr_vowel = vowels_and_cons[0];
    char* ptr_consonant = vowels_and_cons[1];
    char * ptr = string;
    uint64_t it_vowel = 0;
    uint64_t it_consonant = 0;
    while(*ptr != '\0'){ 
        if(*ptr == 'a' || *ptr == 'e' || *ptr == 'i' || *ptr == 'o' || *ptr == 'u' ||
           *ptr == 'A' || *ptr == 'E' || *ptr == 'I' || *ptr == 'O' || *ptr == 'U'){
            ptr_vowel[it_vowel] = *ptr;
            it_vowel++;
            // memset(ptr_vowel, *ptr, sizeof(char)); 
            // ptr_vowel++;
           }
           else{
            ptr_consonant[it_consonant] = *ptr;
            it_consonant++;
            // memset(ptr_consonant, *ptr, sizeof(char));
            // ptr_consonant++;
           }
        ptr++;
    }
}

void classify_chars(classifier_t* array, uint64_t size_of_array) {
    classifier_t* ptr = array;
    uint64_t i = 0;
    while(i < size_of_array){
        ptr->vowels_and_consonants = calloc(2, sizeof(char*));
        ptr->vowels_and_consonants[0] = calloc(64, sizeof(char)); // arr[i] == *(arr+i)
        ptr->vowels_and_consonants[1] = calloc(64, sizeof(char)); //problema aca.
        //reservar el espacio de memoria para vowels_and_consonants
        classify_chars_in_string(ptr->string,ptr->vowels_and_consonants);
        ptr++;
        i++;
    }
}

#include "ej1.h"

list_t* listNew(){
  list_t* l = (list_t*) malloc(sizeof(list_t));
  l->first=NULL;
  l->last=NULL;
  return l;
}

void listAddLast(list_t* pList, pago_t* data){
    listElem_t* new_elem= (listElem_t*) malloc(sizeof(listElem_t));
    new_elem->data=data;
    new_elem->next=NULL;
    new_elem->prev=NULL;
    if(pList->first==NULL){
        pList->first=new_elem;
        pList->last=new_elem;
    } else {
        pList->last->next=new_elem;
        new_elem->prev=pList->last;
        pList->last=new_elem;
    }
}


void listDelete(list_t* pList){
    listElem_t* actual= (pList->first);
    listElem_t* next;
    while(actual != NULL){
        next=actual->next;
        free(actual);
        actual=next;
    }
    free(pList);
}

uint8_t contar_pagos_aprobados(list_t* pList, char* usuario){
    uint8_t res = 0;
    listElem_t* primer = pList->first;
    listElem_t* ultimo = pList->last;

    listElem_t* it = primer;
    while(it != NULL){
        if(it->data->aprobado != 0 && *it->data->cobrador == *usuario){
            res++;
        }
        it = it->next;    
    }
    return res;
}

uint8_t contar_pagos_rechazados(list_t* pList, char* usuario){
    uint8_t res = 0;
    listElem_t* primer = pList->first;
    listElem_t* ultimo = pList->last;

    listElem_t* it = primer;
    while(it != NULL){
        if(it->data->aprobado == 0 && *it->data->cobrador == *usuario){
            res++;
        }
        it = it->next;    
    }
    return res;
}

pagoSplitted_t* split_pagos_usuario(list_t* pList, char* usuario){

    pagoSplitted_t* res = malloc(sizeof(pagoSplitted_t)); //el espacio de memoria respuesta tiene 16 bytes.    
    
    uint8_t cant_ap = contar_pagos_aprobados(pList, usuario);
    uint8_t cant_re = contar_pagos_rechazados(pList, usuario);

    res->cant_aprobados = cant_ap;
    res->cant_rechazados = cant_re;

    res->aprobados = malloc(cant_ap * sizeof(pago_t**));
    res->rechazados = malloc(cant_re * sizeof(pago_t**));

    listElem_t* primer = pList->first;

    listElem_t* it = primer;
    uint8_t counterAp = 0;
    uint8_t counterRep = 0;
    while(it != NULL){
        if(*it->data->cobrador == *usuario){
            if(it->data->aprobado != 0){
                res->aprobados[counterAp] = it->data;
                counterAp++;
            } else{
                res->rechazados[counterRep] = it->data;
                counterRep++;
            }
        }
        it = it->next;
    }
    return res;
}
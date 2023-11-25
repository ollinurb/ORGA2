#include "ej1.h"

string_proc_list* string_proc_list_create(void){
	string_proc_list* res = malloc(sizeof(string_proc_list));
	res->first = NULL;
	res->last = NULL;
	return res;
}

string_proc_node* string_proc_node_create(uint8_t type, char* hash){
	string_proc_node* res = malloc(sizeof(string_proc_node));
	res->previous = NULL;
	res->next = NULL;
	res->hash = hash;
	res->type = type;
	return res;
}

void string_proc_list_add_node(string_proc_list* list, uint8_t type, char* hash){
	string_proc_node* new_node = string_proc_node_create(type, hash);

	if(list->first == NULL){
		list->first = new_node;
		list->last = new_node;
	}else{
		string_proc_node* last_node = list->last;
		last_node->next = new_node;
		new_node->previous = last_node;
		list->last = new_node;
	}
}

char* string_proc_list_concat(string_proc_list* list, uint8_t type , char* hash){

	char* empty_hash = (char*)"";
	char* new_hash = str_concat(empty_hash, hash);

	string_proc_node* it = list->first;
	while(it != NULL){
		if(it->type == type){
			//usamos el concat
			char* hash_temp = new_hash;
			new_hash = str_concat(hash_temp, it->hash);
			free(hash_temp);
			//aca pierdo memoria
		}
		it = it->next;
	}
	return new_hash;
}


/** AUX FUNCTIONS **/

void string_proc_list_destroy(string_proc_list* list){

	/* borro los nodos: */
	string_proc_node* current_node	= list->first;
	string_proc_node* next_node		= NULL;
	while(current_node != NULL){
		next_node = current_node->next;
		string_proc_node_destroy(current_node);
		current_node	= next_node;
	}
	/*borro la lista:*/
	list->first = NULL;
	list->last  = NULL;
	free(list);
}
void string_proc_node_destroy(string_proc_node* node){
	node->next      = NULL;
	node->previous	= NULL;
	node->hash		= NULL;
	node->type      = 0;			
	free(node);
}


char* str_concat(char* a, char* b) {
	int len1 = strlen(a);
    int len2 = strlen(b);
	int totalLength = len1 + len2;
    char *result = (char *)malloc(totalLength + 1); 
    strcpy(result, a);
    strcat(result, b);
    return result;  
}

void string_proc_list_print(string_proc_list* list, FILE* file){
        uint32_t length = 0;
        string_proc_node* current_node  = list->first;
        while(current_node != NULL){
                length++;
                current_node = current_node->next;
        }
        fprintf( file, "List length: %d\n", length );
		current_node    = list->first;
        while(current_node != NULL){
                fprintf(file, "\tnode hash: %s | type: %d\n", current_node->hash, current_node->type);
                current_node = current_node->next;
        }
}
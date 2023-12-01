/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Definicion de funciones del manejador de memoria
*/

#include "mmu.h"
#include "i386.h"

#include "kassert.h"

static pd_entry_t* kpd = (pd_entry_t*)KERNEL_PAGE_DIR;
static pt_entry_t* kpt = (pt_entry_t*)KERNEL_PAGE_TABLE_0;

static const uint32_t identity_mapping_end = 0x003FFFFF;
static const uint32_t user_memory_pool_end = 0x02FFFFFF;

static paddr_t next_free_kernel_page = 0x100000;
static paddr_t next_free_user_page = 0x400000;

/**
 * kmemset asigna el valor c a un rango de memoria interpretado
 * como un rango de bytes de largo n que comienza en s
 * @param s es el puntero al comienzo del rango de memoria
 * @param c es el valor a asignar en cada byte de s[0..n-1]
 * @param n es el tamaño en bytes a asignar
 * @return devuelve el puntero al rango modificado (alias de s)
*/
static inline void* kmemset(void* s, int c, size_t n) {
  uint8_t* dst = (uint8_t*)s;
  for (size_t i = 0; i < n; i++) {
    dst[i] = c;
  }
  return dst;
}

/**
 * zero_page limpia el contenido de una página que comienza en addr
 * @param addr es la dirección del comienzo de la página a limpiar
*/
static inline void zero_page(paddr_t addr) {
  kmemset((void*)addr, 0x00, PAGE_SIZE);
}


void mmu_init(void) {}


/**
 * mmu_next_free_kernel_page devuelve la dirección física de la próxima página de kernel disponible. 
 * Las páginas se obtienen en forma incremental, siendo la primera: next_free_kernel_page
 * @return devuelve la dirección de memoria de comienzo de la próxima página libre de kernel
 */
paddr_t mmu_next_free_kernel_page(void) {
	paddr_t return_page_address = next_free_kernel_page;
  	next_free_kernel_page += PAGE_SIZE;
  	return return_page_address;
}

/**
 * mmu_next_free_user_page devuelve la dirección de la próxima página de usuarix disponible
 * @return devuelve la dirección de memoria de comienzo de la próxima página libre de usuarix
 */
paddr_t mmu_next_free_user_page(void) {
	paddr_t return_page_address = next_free_user_page;
  	next_free_user_page += PAGE_SIZE;
  	return return_page_address;
}

/**
 * mmu_init_kernel_dir inicializa las estructuras de paginación vinculadas al kernel y
 * realiza el identity mapping
 * @return devuelve la dirección de memoria de la página donde se encuentra el directorio
 * de páginas usado por el kernel
 */
paddr_t mmu_init_kernel_dir(void) {
	  // generamos la primera entrada del page directory
  	// en todo la page table, generamos entradas con mismos atributos
  	// y cuyo offset sea el mismo que el tamaño de pagina

  	zero_page(KERNEL_PAGE_DIR);
  	zero_page(KERNEL_PAGE_TABLE_0);

  	kpd[0] = (pd_entry_t){
    	.attrs = MMU_P | MMU_W,
    	.pt = KERNEL_PAGE_TABLE_0 >> 12
  	};

  	for (size_t i = 0; i < 1024; i++){
    		kpt[i] = (pt_entry_t){
      			.attrs = (MMU_P | MMU_W),
      			.page = i
   		};
 	}
  	return KERNEL_PAGE_DIR;
}

/**
 * mmu_map_page agrega las entradas necesarias a las estructuras de paginación de modo de que
 * la dirección virtual virt se traduzca en la dirección física phy con los atributos definidos en attrs
 * @param cr3 el contenido que se ha de cargar en un registro CR3 al realizar la traducción
 * @param virt la dirección virtual que se ha de traducir en phy
 * @param phy la dirección física que debe ser accedida (dirección de destino)
 * @param attrs los atributos a asignar en la entrada de la tabla de páginas
 */

void mmu_map_page(uint32_t cr3, vaddr_t virt, paddr_t phy, uint32_t attrs) {
	
	// tenemos el page directory en cr3. vamos a extraer la direccion del page directory
	paddr_t pd = CR3_TO_PAGE_DIR(cr3);

	// queremos verificar que la pde este presente con el bit P

	pd_entry_t* pde_ptr = (pd_entry_t*) (pd + VIRT_PAGE_DIR(virt) * 4);		// apuntamos a esto-> |pd_entry que no sabemos si la direccion es valida|
	if ((pde_ptr->attrs & MMU_P) == 0){
		paddr_t nueva_tabla = mmu_next_free_kernel_page(); // pagina nueva que vamos a tener que linkear a una pte y luego a esta pde
		zero_page(nueva_tabla);
		pde_ptr->pt = nueva_tabla >> 12;
   	};
	pde_ptr->attrs = pde_ptr->attrs | attrs | MMU_P;
	pt_entry_t* pte_ptr = (pt_entry_t*) ((pde_ptr->pt << 12) + VIRT_PAGE_TABLE(virt) * 4);
	pte_ptr->attrs = attrs | MMU_P;
	pte_ptr->page = phy >> 12;

	tlbflush();
	
}

/**
 * mmu_unmap_page elimina la entrada vinculada a la dirección virt en la tabla de páginas correspondiente
 * @param virt la dirección virtual que se ha de desvincular
 * @return la dirección física de la página desvinculada
 */
paddr_t mmu_unmap_page(uint32_t cr3, vaddr_t virt) {
	// tenemos que utilizar el cr3 que nos dieron
	// de el vamos a poder sacar el pd

	// con la parte de virt correspondiente al indice de pd, vamos a obtener el pde
	// queremos ver si la pde esta marcada como present
	//--------------------------------------------------------------------------------
	
	// tenemos el page directory en cr3. vamos a extraer la direccion del page directory
	paddr_t pd = CR3_TO_PAGE_DIR(cr3);

	// queremos verificar que la pde este presente con el bit P

	pd_entry_t* pde_ptr = (pd_entry_t*) (pd + VIRT_PAGE_DIR(virt) * 4);
	if ((pde_ptr->attrs & MMU_P) == 0){
		tlbflush();

		return (paddr_t) (pde_ptr->pt << 12);		// esto esta bien?
   	} else {
		pt_entry_t* pte_ptr = (pt_entry_t*) ((pde_ptr->pt << 12) + VIRT_PAGE_TABLE(virt) * 4);
		pte_ptr->attrs = pte_ptr->attrs & 0xffe;	//seteamos p en 0. esto cuenta como hardcodear? como se podria hacer sino? (pensamos !MMU_P pero no creemos que sea correcto)
		tlbflush();

		// habría que hacer algo con next_free_kernel_page? ya que si estamos liberando

		return (paddr_t) (pte_ptr->page << 12);
	}

}

#define DST_VIRT_PAGE 0xA00000		// por que estas direcciones en particular? es algo arbitrario o siempre se usan estas?
#define SRC_VIRT_PAGE 0xB00000

/**
 * copy_page copia el contenido de la página física localizada en la dirección src_addr a la página física ubicada en dst_addr
 * @param dst_addr la dirección a cuya página queremos copiar el contenido
 * @param src_addr la dirección de la página cuyo contenido queremos copiar
 *
 * Esta función mapea ambas páginas a las direcciones SRC_VIRT_PAGE y DST_VIRT_PAGE, respectivamente, realiza
 * la copia y luego desmapea las páginas. Usar la función rcr3 definida en i386.h para obtener el cr3 actual
 */
void copy_page(paddr_t dst_addr, paddr_t src_addr) {

	// mapeamos ambas direcciones fisicas para poder utilizarlas
	mmu_map_page(rcr3(), DST_VIRT_PAGE, dst_addr, MMU_W | MMU_P);
	mmu_map_page(rcr3(), SRC_VIRT_PAGE, src_addr, MMU_P);


	//vaddr_t dst = DST_VIRT_PAGE;		// no sabemos por que no podemos usar 'uint8_t* dst = DST_VIRT_PAGE;'
	//vaddr_t src = SRC_VIRT_PAGE;
	
	uint8_t* dst = (uint8_t*)DST_VIRT_PAGE;
	uint8_t* src = (uint8_t*)SRC_VIRT_PAGE;

	for (size_t i = 0; i < PAGE_SIZE; i++) {
		// accedemos a SRC_VIRT_PAGE + i y DST_VIRT_PAGE + i y copiamos byte a byte

		//((uint8_t*)dst)[i] = ((uint8_t*)src)[i];		//se puede iterar page_size/4 veces (1024) y utilizar uint32_t para que esto sea mas eficiente?
		dst[i] = src[i];
	}

	mmu_unmap_page(rcr3(), DST_VIRT_PAGE);	// por que desmapeamos las direcciones si se podrian usar? intuimos que para no ocupar memoria innecesariamente. Pero una pagina parece muy poco
	mmu_unmap_page(rcr3(), SRC_VIRT_PAGE);

}

 /**
 * mmu_init_task_dir inicializa las estructuras de paginación vinculadas a una tarea cuyo código se encuentra en la dirección phy_start
 * @pararm phy_start es la dirección donde comienzan las dos páginas de código de la tarea asociada a esta llamada
 * @return el contenido que se ha de cargar en un registro CR3 para la tarea asociada a esta llamada
 */
paddr_t mmu_init_task_dir(paddr_t phy_start) {
	// hacer un pd
	paddr_t task_pd = mmu_next_free_kernel_page();

	//identity mapping
	zero_page(task_pd);

  	for (size_t i = 0; i < 1024; i++){
		mmu_map_page(task_pd, i*PAGE_SIZE, i*PAGE_SIZE, MMU_W | MMU_P);
	}

	// mappear las paginas de usuario al codigo, stack y shared del programa
	mmu_map_page(task_pd, TASK_CODE_VIRTUAL, phy_start, MMU_U | MMU_P);
	mmu_map_page(task_pd, TASK_CODE_VIRTUAL + PAGE_SIZE, phy_start + PAGE_SIZE, MMU_U | MMU_P);

	// stack (le restamos page_size a la pagina de stack porque la macro marca el final o base, y este crece para arriba)
	mmu_map_page(task_pd, TASK_STACK_BASE - PAGE_SIZE, mmu_next_free_user_page(), MMU_W | MMU_U | MMU_P);

	// shared
	mmu_map_page(task_pd, TASK_SHARED_PAGE, SHARED, MMU_U | MMU_P);

	return task_pd;
}

// COMPLETAR: devuelve true si se atendió el page fault y puede continuar la ejecución 
// y false si no se pudo atender
bool page_fault_handler(vaddr_t virt) {
	print("Atendiendo page fault...", 0, 0, C_FG_WHITE | C_BG_BLACK);
	// Chequeemos si el acceso fue dentro del area on-demand
	// En caso de que si, mapear la pagina
	
	if (ON_DEMAND_MEM_START_VIRTUAL <= virt && virt <= ON_DEMAND_MEM_END_VIRTUAL) {
		
		mmu_map_page(rcr3(), virt, ON_DEMAND_MEM_START_PHYSICAL, MMU_W | MMU_U | MMU_P);	
		return 1;
	} else {
		return 0; // no se pudo atender el pf
	}
}

void test_copy_page(){
	paddr_t pag1 = mmu_next_free_kernel_page();
	paddr_t pag2 = mmu_next_free_kernel_page();

	vaddr_t src = SRC_VIRT_PAGE;
	vaddr_t dst = DST_VIRT_PAGE;
	
	mmu_map_page(rcr3(), src, pag1, MMU_W | MMU_P);
	mmu_map_page(rcr3(), dst, pag2, MMU_P);

	((uint32_t*)src)[0] = 9999;
	((uint32_t*)dst)[0] = 5555;

	mmu_unmap_page(rcr3(), src);
	mmu_unmap_page(rcr3(), dst);

	copy_page((paddr_t)pag1, (paddr_t) pag2);

/*
	mmu_map_page(rcr3(), src, pag1, MMU_W | MMU_P);
	mmu_map_page(rcr3(), dst, pag2, MMU_P);

	kassert( ((uint32_t*)src)[0] != ((uint32_t*)dst)[0], "No esta funcionando correctamente la funcion");

	mmu_unmap_page(rcr3(), src);
	mmu_unmap_page(rcr3(), dst);
*/
	return;
}
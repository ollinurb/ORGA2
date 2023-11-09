## Respuestas Taller 6

1. ¿Que representa cada entry de IDT_ENTRYx?
    - Offset: Direccion de memoria donde comienza la rutina de interrupcion
    - Segment Selector: Que selector debe utilizarse. 
    - P: Si el segmento esta presente en memoria
    - DPL: nivel de privilegio
    - Bits 8 a 12: Tipo especifico de la compuerta de interrucion.

2. ¿Cuál sería un selector de segmento apropiado acorde a los índices definidos en la GDT[segsel]? ¿Y el valor de los atributos si usamos Gate Size de 32 bits?

    - Selector de segmento apropiado: el selector 1 que corresponde al segmento de codigo nivel 0. 
    - Nuestra Gate Size es de 32 bits. Por eso el bit D del type es 1.


3. Al completar la funcion gdt_init(), utilizamos las macros de privilegio 0 ya que teclado y clock corresponden a kernel?
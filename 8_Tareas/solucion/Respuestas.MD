## Respuestas Taller 8

1. Si queremos definir un sistema que utilice sólo dos tareas, ¿Qué nuevas estructuras, cantidad de nuevas entradas en las estructuras ya definidas, y registros tenemos que configurar?¿Qué formato tienen? ¿Dónde se encuentran almacenadas?

    - Task Gate. ¿Cual?
    - Las interrupciones definidas por el usuario son a partir de la 32.
    - Hay que definir un TSS, un descriptor de TSS. Un Task Registry.

2. ¿A qué llamamos cambio de contexto?¿Cuándo se produce?¿Qué efecto tiene sobre los registros del procesador? Expliquen en sus palabras que almacena el registro TR y cómo obtiene la información necesaria para ejecutar una tarea después de un cambio de contexto.

    - Llamamos cambio de contexto a cambiar entre dos tareas. Se produce cuando se cubre el tiempo de ejecucion determinado por el scheduler para la tarea o cuando se produce una interrupcion.
    - Resguarda los registros core y los guarda en un area de memoria de kernel.
    - El Task Registry almacena el selector de segmento de la tarea en ejecucion. Se usa para encontrar la TSS de la tarea actual.

3. Al momento de realizar un cambio de contexto el procesador va almacenar el estado actual de acuerdo al selector indicado en el registro TR y ha de restaurar aquel almacenado en la TSS cuyo selector se asigna en el jmp far. ¿Qué consideraciones deberíamos tener para poder realizar el primer cambio de contexto? ¿Y cuáles cuando no tenemos tareas que ejecutar o se encuentran todas suspendidas?
    - Aca entra en juego la task inicial y la task idle.

4.  ¿Qué hace el scheduler de un Sistema Operativo? ¿A qué nos referimos con que usa una política?
    - El scheduler orquesta las distintas tareas que se ejecutan secuencialmente siguiendo una serie de politicas que evaluan distintas variables.
        - Prioridad
        - Preemption
        - Atomicidad de operaciones
        - Concurrencia
        - Latency
        - Paralelismo

5. En un sistema de una única CPU, ¿cómo se hace para que los programas parezcan ejecutarse en simultáneo?
    - El scheduler otorga una cantidad de ciclos de clock a cada tarea que hace que a simple vista no notemos el cambio de contexto, ya que un ciclo entero de las tareas es imperceptible al ojo humano si hablamos de velocidades de clocks medidas en Mhz.
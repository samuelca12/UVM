class agent #(parameter width = 16);
  
  // Definir la clase trans_fifo primero
  class trans_fifo;
    rand int max_retardo;  
    rand int tipo;         
    rand bit [width-1:0] dato;

    // Constructor
    function new();
      max_retardo = 0;
      tipo = 0;
      dato = 0;
    endfunction

    // Método para imprimir la transacción
    function void print(input string message); // Corregido con 'input'
      $display("%s: max_retardo = %0d, tipo = %0d, dato = %h", message, max_retardo, tipo, dato);
    endfunction
  endclass

  // Ahora puedes declarar transaccion de tipo trans_fifo
  trans_fifo transaccion; 

  // Resto del código...
  comando_test_agent_mbx test_agent_mbx;
  int num_transacciones;
  int max_retardo;
  int ret_spec;
  tipo_trans tpo_spec;
  bit [width-1:0] dto_spec;

  mailbox agnt_drv_mbx;

  // Variable para las instrucciones
  int instruccion;

  // Definición de las instrucciones como un enum
  typedef enum { llenado_aleatorio, trans_aleatoria, trans_especifica, sec_trans_aleatorias } instruccion_t;

  // Definición del tipo de transacción como un enum
  typedef enum { escritura, lectura } tipo_trans_t;

  // Constructor del agente
  function new();
    num_transacciones = 2;
    max_retardo = 10;
    agnt_drv_mbx = new(); // Inicializa el mailbox
    transaccion = new();  // Inicializa la transacción
  endfunction

  // Task que ejecuta el agente
  task run;
    $display("[%g] El Agente fue inicializado", $time);

    forever begin
      #1;

      // Si el mailbox tiene transacciones
      if (test_agent_mbx.num() > 0) begin
        $display("[%g] Agente: se recibe instrucción", $time);

        // Obtener la instrucción desde el mailbox
        test_agent_mbx.get(instruccion);

        // Manejo de instrucciones
        case (instruccion)
          llenado_aleatorio: begin 
            // Esta instrucción genera num_transacciones escrituras seguidas de lecturas
            for (int i = 0; i < num_transacciones; i++) begin
              transaccion = new();  // Instancia nueva de la transacción
              transaccion.max_retardo = max_retardo;
              transaccion.randomize();  // Aleatoriza la transacción
              transaccion.tipo = escritura;
              transaccion.print("Agente: transacción creada");
              agnt_drv_mbx.put(transaccion);  // Enviar transacción al driver
            end
            for (int i = 0; i < num_transacciones; i++) begin
              transaccion = new();  // Instancia nueva de la transacción
              transaccion.randomize();  // Aleatoriza la transacción
              transaccion.tipo = lectura;
              transaccion.print("Agente: transacción creada");
              agnt_drv_mbx.put(transaccion);  // Enviar transacción al driver
            end
          end

          trans_aleatoria: begin
            transaccion = new();  // Instancia nueva de la transacción
            transaccion.max_retardo = max_retardo;
            transaccion.randomize();  // Aleatoriza la transacción
            transaccion.print("Agente: transacción creada");
            agnt_drv_mbx.put(transaccion);  // Enviar transacción al driver
          end

          trans_especifica: begin
            transaccion = new();  // Instancia nueva de la transacción
            transaccion.tipo = tpo_spec;
            transaccion.dato = dto_spec;
            transaccion.retardo = ret_spec;
            transaccion.print("Agente: transacción creada");
            agnt_drv_mbx.put(transaccion);  // Enviar transacción al driver
          end

          sec_trans_aleatorias: begin 
            // Esta instrucción genera una secuencia de transacciones aleatorias
            for (int i = 0; i < num_transacciones; i++) begin
              transaccion = new();  // Instancia nueva de la transacción
              transaccion.max_retardo = max_retardo;
              transaccion.randomize();  // Aleatoriza la transacción
              transaccion.print("Agente: transacción creada");
              agnt_drv_mbx.put(transaccion);  // Enviar transacción al driver
            end
          end
        endcase  // Cierre del bloque case
      end
    end
  endtask
endclass

class agent #(parameter width = 16, parameter depth = 8);
  comando_test_agent_mbx test_agent_mbx; // Mailbox del agente al driver
  int num_transacciones; // Número de transacciones para las funciones del agente
  int max_retardo;
  int ret_spec;
  tipo_trans tpo_spec;
  bit [width-1:0] dto_spec; // para guardar la última instrucción leída
  trans_fifo #( .width(width)) transaccion;

  // Constructor
  function new;
    num_transacciones = 2;
    max_retardo = 10;

    // Inicialización del mailbox
    test_agent_mbx = new();  // Asegúrate de que esté listo para su uso
  endfunction

  task run;
    $display("[%g] El Agente fue inicializado", $time);
    forever begin
      #1;
      if (test_agent_mbx.num() > 0) begin
        $display("[%g] Agente: se recibe instrucción", $time);
        test_agent_mbx.get(instruccion); // Usando el mailbox correcto
        case (instruccion)
          llenado_aleatorio: begin // Genera escrituras y lecturas
            for (int i = 0; i < num_transacciones; i++) begin
              transaccion = new;
              transaccion.max_retardo = max_retardo;
              transaccion.randomize();
              transaccion.tipo = escritura; // Escritura
              transaccion.print("Agente: Escritura generada");
              test_agent_mbx.put(transaccion);
            end
            for (int i = 0; i < num_transacciones; i++) begin
              transaccion = new;
              transaccion.randomize();
              transaccion.tipo = lectura; // Lectura
              transaccion.print("Agente: Lectura generada");
              test_agent_mbx.put(transaccion);
            end
          end
          trans_especifica: begin // Transacción específica de escritura o lectura
            transaccion = new;
            transaccion.tipo = tpo_spec; // Puede ser lectura o escritura
            transaccion.dato = dto_spec;
            transaccion.retardo = ret_spec;
            transaccion.print("Agente: Transacción específica");
            test_agent_mbx.put(transaccion);
          end
          sec_trans_aleatorias: begin // Genera secuencia de transacciones aleatorias
            for (int i = 0; i < num_transacciones; i++) begin
              transaccion = new;
              transaccion.max_retardo = max_retardo;
              transaccion.randomize();
              transaccion.tipo = (i % 2 == 0) ? escritura : lectura; // Alterna escritura y lectura
              transaccion.print("Agente: Transacción aleatoria");
              test_agent_mbx.put(transaccion);
            end
          end
        endcase
      end
    end
  endtask
endclass

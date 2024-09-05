class test #(parameter width=16, parameter depth=8);
  comando_test_sb_mbx test_sb_mbx;
  comando_test_agent_mbx test_agent_mbx;

  parameter num_transacciones = 10;
  parameter max_retardo = 4;
  solicitud_sb orden;
  instrucciones_agente instr_agent;
  solicitud_sb instr_sb;

  // Definición del ambiente de la prueba
  ambiente #(.depth(depth), .width(width)) ambiente_inst;
  // Definición de la interfaz a la que se conectará el DUT
  virtual fifo_if #(.width(width)) _if;

  // Definición de las condiciones iniciales del test
  function new();
    // Instanciación de los mailboxes
    test_sb_mbx = new();
    test_agent_mbx = new();
    // Definición y conexión del driver
    ambiente_inst = new();
    ambiente_inst._if = _if;
    ambiente_inst.test_sb_mbx = test_sb_mbx;
    ambiente_inst.scoreboard_inst.test_sb_mbx = test_sb_mbx;
    ambiente_inst.test_agent_mbx = test_agent_mbx;
    ambiente_inst.agent_inst.test_agent_mbx = test_agent_mbx;
    ambiente_inst.agent_inst.num_transacciones = num_transacciones;
    ambiente_inst.agent_inst.max_retardo = max_retardo;
  endfunction

  task run;
    $display("[%g] El Test fue inicializado", $time);
    fork
      ambiente_inst.run();
    join_none;

    instr_agent = llenado_aleatorio;
    test_agent_mbx.put(instr_agent);
    $display("[%g] Test: Enviada la primera instrucción al agente lleno aleatorio con num_transacciones %g", $time, num_transacciones);

    instr_agent = trans_aleatoria;
    test_agent_mbx.put(instr_agent);
    $display("[%g] Test: Enviada la segunda instrucción al agente transacción_aleatoria", $time);

    ambiente_inst.agent_inst.ret_spec = 3;
    ambiente_inst.agent_inst.tpo_spec = escritura;
    ambiente_inst.agent_inst.dto_spec = {width/4{4'h5}};
    
    instr_agent = trans_especifica;
    test_agent_mbx.put(instr_agent);
    $display("[%g] Test: Enviada la tercera instrucción al agente transacción_específica", $time);

    instr_agent = sec_trans_aleatorias;
    test_agent_mbx.put(instr_agent);
    $display("[%g] Test: Enviada la cuarta instrucción al agente secuencia de transacción_aleatoria", $time);

    #10000;
    $display("[%g] Test: Se alcanza el tiempo límite de la prueba", $time);
    instr_sb = retardo_promedio;
    test_sb_mbx.put(instr_sb);
    instr_sb = reporte;
    test_sb_mbx.put(instr_sb);
    $finish;
  endtask
endclass 
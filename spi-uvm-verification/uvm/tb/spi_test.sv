class spi_test extends uvm_test;
    `uvm_component_utils(spi_test)

    spi_env env;

    function new(string name = "spi_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = spi_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);

        // --------------------------------------------------------
        // Random sequence
        // --------------------------------------------------------
        // randomize() 기반으로 transaction 20개 생성.
        // 다시 random 검증을 하고 싶으면 아래 block을 주석 해제하고,
        // directed sequence block을 주석 처리하면 됨.
        // --------------------------------------------------------
        /*
        spi_base_seq seq;

        phase.raise_objection(this);

        seq = spi_base_seq::type_id::create("seq");
        seq.start(env.agt.sqr);

        #1000;

        phase.drop_objection(this);
        */


        // --------------------------------------------------------
        // Directed sequence
        // --------------------------------------------------------
        // coverage 결과에서 부족했던 data pattern과
        // full-duplex zero/nonzero 조합을 직접 발생시키기 위해 사용.
        // --------------------------------------------------------
        spi_directed_seq seq;

        phase.raise_objection(this);

        seq = spi_directed_seq::type_id::create("seq");
        seq.start(env.agt.sqr);

        #1000;

        phase.drop_objection(this);

    endtask

endclass
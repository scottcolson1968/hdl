// Self-checking TB for the FIFO-straddle tx_csum_open.
//   Models a packet-mode AXIS FIFO between m_fifo (input tap out) and s_fifo
//   (output tap in): the whole frame is captured on input, then replayed on
//   output. Checks the patched csum == true TCP checksum across small..jumbo,
//   field=seed/garbage, non-TCP passthrough, back-to-back frames (meta order),
//   and output backpressure.
`timescale 1ns/1ps
`default_nettype none

module tb_tx_csum_open;
    localparam integer DW=64, KW=8;
    reg aclk=0, aresetn=0; always #5 aclk=~aclk;

    // input tap
    reg  [DW-1:0] si_d; reg [KW-1:0] si_k; reg si_l, si_v; wire si_r;
    wire [DW-1:0] mf_d; wire [KW-1:0] mf_k; wire mf_l, mf_v; reg mf_r;
    // output tap
    reg  [DW-1:0] sf_d; reg [KW-1:0] sf_k; reg sf_l, sf_v; wire sf_r;
    wire [DW-1:0] mo_d; wire [KW-1:0] mo_k; wire mo_l, mo_v; reg mo_r;

    tx_csum_open #(.DATA_W(64), .KEEP_W(8)) dut (
        .aclk(aclk), .aresetn(aresetn),
        .s_in_tdata(si_d), .s_in_tkeep(si_k), .s_in_tlast(si_l), .s_in_tvalid(si_v), .s_in_tready(si_r),
        .m_fifo_tdata(mf_d), .m_fifo_tkeep(mf_k), .m_fifo_tlast(mf_l), .m_fifo_tvalid(mf_v), .m_fifo_tready(mf_r),
        .s_fifo_tdata(sf_d), .s_fifo_tkeep(sf_k), .s_fifo_tlast(sf_l), .s_fifo_tvalid(sf_v), .s_fifo_tready(sf_r),
        .m_out_tdata(mo_d), .m_out_tkeep(mo_k), .m_out_tlast(mo_l), .m_out_tvalid(mo_v), .m_out_tready(mo_r)
    );

    localparam integer MAXB=9200;
    reg [7:0] frame [0:MAXB-1];
    reg [7:0] outf  [0:MAXB-1];
    integer   LEN, errors=0;
    localparam integer START=34, INSERT=50;

    // ---- packet-FIFO model queue: {tlast,tkeep,tdata} per beat ----
    localparam integer QD=16384;
    reg [DW+KW:0] q [0:QD-1];
    integer qwr=0, qrd=0;

    function [31:0] sum16; input integer s; input integer len;
        integer i; reg [31:0] a; reg [15:0] w; begin
            a=0;i=s; while(i<s+len) begin
                if(i+1<s+len) w={frame[i],frame[i+1]}; else w={frame[i],8'h00};
                a=a+w; i=i+2; end
            sum16=a; end
    endfunction
    function [15:0] fold16; input [31:0] x; reg [31:0] t;
        begin t=(x&32'hFFFF)+(x>>16); t=(t&32'hFFFF)+(t>>16); fold16=t[15:0]; end
    endfunction
    reg [31:0] ph; reg [15:0] c_true;

    task build_frame; input integer plen; input isip; input [1:0] fmode; integer k; reg [15:0] seed; begin
        for (k=0;k<MAXB;k=k+1) frame[k]=8'h00;
        for (k=0;k<6;k=k+1) frame[k]=8'hAA;
        for (k=6;k<12;k=k+1) frame[k]=8'hBB;
        if (isip) begin frame[12]=8'h08; frame[13]=8'h00; end else begin frame[12]=8'h08; frame[13]=8'h06; end
        frame[14]=8'h45; frame[15]=8'h00; LEN=54+plen;
        frame[16]=(40+plen)>>8; frame[17]=(40+plen)&8'hFF;
        frame[18]=8'h12; frame[19]=8'h34; frame[20]=8'h40; frame[21]=8'h00;
        frame[22]=8'h40; frame[23]=8'h06; frame[24]=8'h00; frame[25]=8'h00;
        frame[26]=8'h0A; frame[27]=8'h02; frame[28]=8'h02; frame[29]=8'h01;
        frame[30]=8'h0A; frame[31]=8'h02; frame[32]=8'h02; frame[33]=8'h02;
        frame[34]=8'hC0; frame[35]=8'h00; frame[36]=8'h13; frame[37]=8'h88;
        frame[38]=8'h00;frame[39]=8'h00;frame[40]=8'h00;frame[41]=8'h01;
        frame[42]=8'h00;frame[43]=8'h00;frame[44]=8'h00;frame[45]=8'h00;
        frame[46]=8'h50;frame[47]=8'h10;frame[48]=8'hAB;frame[49]=8'hCD;
        frame[50]=8'h00;frame[51]=8'h00;frame[52]=8'h00;frame[53]=8'h00;
        for (k=0;k<plen;k=k+1) frame[54+k]=(8'h41+k[7:0]);
        // reference (true tcp csum with field=0)
        ph = {frame[26],frame[27]}+{frame[28],frame[29]}+{frame[30],frame[31]}
            +{frame[32],frame[33]}+16'h0006+(LEN-START);
        c_true = ~fold16(ph + sum16(START, LEN-START));
        seed = fold16(ph);
        if (isip) begin
            if (fmode==2'd1) begin frame[INSERT]=seed[15:8]; frame[INSERT+1]=seed[7:0]; end
            else if (fmode==2'd2) begin frame[INSERT]=8'h5A; frame[INSERT+1]=8'hA5; end
        end else begin frame[INSERT]=8'hDE; frame[INSERT+1]=8'hAD; end
    end endtask

    // drive one frame into s_in; capture m_fifo beats into queue
    task send_in; integer p,j; reg [DW-1:0] d; reg [KW-1:0] k; begin
        p=0; si_v<=1;
        while (p<LEN) begin
            d=0;k=0; for(j=0;j<8;j=j+1) if(p+j<LEN) begin d[8*j+:8]=frame[p+j]; k[j]=1; end
            si_d<=d; si_k<=k; si_l<=((p+8)>=LEN);
            @(posedge aclk);
            while(!si_r) @(posedge aclk);
            // capture m_fifo (passthrough of s_in) into queue
            q[qwr] = {mf_l, mf_k, mf_d}; qwr=qwr+1;
            p=p+8;
        end
        si_v<=0; si_l<=0;
    end endtask

    // replay one frame (up to tlast) from queue to s_fifo; capture m_out
    task drain_out; integer oc,j; reg last; begin
        oc=0; sf_v<=1; last=0;
        while (!last) begin
            sf_d<=q[qrd][DW-1:0]; sf_k<=q[qrd][DW+KW-1:DW]; sf_l<=q[qrd][DW+KW];
            @(posedge aclk);
            while(!sf_r) @(posedge aclk);
            if (mo_v && mo_r) begin
                for(j=0;j<8;j=j+1) if(mo_k[j]) begin outf[oc]=mo_d[8*j+:8]; oc=oc+1; end
            end
            last = q[qrd][DW+KW]; qrd=qrd+1;
        end
        sf_v<=0; sf_l<=0;
    end endtask

    task check; input [1:0] fmode; integer k; reg [15:0] outchk; begin
        outchk={outf[INSERT],outf[INSERT+1]};
        $display("[LEN=%0d fmode=%0d] c_true=%04x out=%04x", LEN, fmode, c_true, outchk);
        for(k=0;k<LEN;k=k+1)
            if((k!=INSERT&&k!=INSERT+1)&&(outf[k]!==frame[k])) begin
                $display("  FAIL byte %0d %02x->%02x",k,frame[k],outf[k]); errors=errors+1; k=LEN; end
        if(fmode!=2'd3) begin
            if(outchk!==c_true) begin $display("  FAIL csum"); errors=errors+1; end
            else $display("  ok csum");
        end else begin // passthrough
            if(outchk!==16'hDEAD) begin $display("  FAIL passthru"); errors=errors+1; end
            else $display("  ok passthru");
        end
    end endtask

    // packet-mode: whole frame buffered on input before it drains on output
    task one; input integer plen; input isip; input [1:0] fmode; begin
        build_frame(plen, isip, fmode);
        send_in();
        drain_out();
        check(isip ? fmode : 2'd3);
    end endtask

    integer bp=0;
    always @(posedge aclk) mo_r <= bp ? ($random&1) : 1'b1;

    initial begin
        si_v=0;si_l=0;si_k=0;si_d=0; sf_v=0;sf_l=0;sf_k=0;sf_d=0; mf_r=1; mo_r=1;
        repeat(5)@(posedge aclk); aresetn=1; repeat(2)@(posedge aclk);

        one(5,   1'b1, 2'd1);   // small seed
        one(5,   1'b1, 2'd2);   // small garbage
        one(23,  1'b1, 2'd2);   // odd
        one(1448,1'b1, 2'd1);   // MTU
        one(8940,1'b1, 2'd2);   // jumbo garbage
        one(2000,1'b0, 2'd0);   // non-tcp passthrough

        // back-to-back (meta FIFO ordering): 2 frames buffered, then drained in order
        begin : b2b
          reg [15:0] cA, cB, oA, oB;
          build_frame(100, 1'b1, 2'd1); send_in(); cA=c_true;   // A into queue+meta
          build_frame(1448,1'b1, 2'd2); send_in(); cB=c_true;   // B into queue+meta
          drain_out(); oA={outf[INSERT],outf[INSERT+1]};        // drains A
          drain_out(); oB={outf[INSERT],outf[INSERT+1]};        // drains B
          $display("[b2b] A: c=%04x o=%04x  B: c=%04x o=%04x", cA,oA,cB,oB);
          if (oA!==cA || oB!==cB) begin $display("  FAIL b2b meta order"); errors=errors+1; end
          else $display("  ok b2b meta order");
        end

        bp=1;
        one(1448,1'b1,2'd2);    // MTU, output backpressure
        one(8940,1'b1,2'd1);    // jumbo, output backpressure
        bp=0;

        repeat(8)@(posedge aclk);
        if(errors==0) $display("==== ALL TESTS PASSED ====");
        else          $display("==== %0d FAILURES ====", errors);
        $finish;
    end
    initial begin #5000000; $display("TIMEOUT"); $finish; end
endmodule
`default_nettype wire

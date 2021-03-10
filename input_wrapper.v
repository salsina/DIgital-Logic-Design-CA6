module input_wrapper(input clk,rst,ld_reg,icc,inc,input[7:0] bus,output[15:0] x,output[7:0] y);
    reg [1:0] cntr;
    reg [23:0] main_reg;
    always @(posedge clk, posedge rst) begin
      if (rst) cntr <= 2'b0 ;
       else if (inc) cntr <= 2'b0;
      else if (icc) cntr <= cntr + 1;
    end

    always @(posedge clk, posedge rst) begin
        if (rst) main_reg <= 24'b0;
        else if (ld_reg) main_reg <= {bus, main_reg[23:8]};
    end
    assign x = main_reg[15:0];
    assign y = main_reg[23:16];
endmodule

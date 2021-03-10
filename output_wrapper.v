module output_wrapper(input clk,rst,ld_reg,icc,inc,gnt,input[15:0] sinx,output reg[7:0] bus,output reg cnt);
    reg [15:0] output_reg;
    always@(posedge clk,posedge rst) begin
        if (rst) cnt <= 0;
        else if (inc) cnt <= 0;
        else if (icc) cnt <= cnt + 1;
    end
    always@(posedge clk,posedge rst) begin
        if (rst) output_reg <= 16'b0;
        else if (ld_reg) output_reg <= sinx;
        else if (cnt==1 && gnt) bus <= output_reg[7:0];
        else if (cnt==0 && gnt) bus <= output_reg[15:8];
    end
endmodule
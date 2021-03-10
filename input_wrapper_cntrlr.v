module input_wrapper_cntrlr(input clk,rst,input_rdy,outsent,output reg input_acc,ld_reg,inc,icc,start);
    reg[1:0] cnt;
    reg[2:0] ps,ns;
    parameter[2:0] idle=3'b0,rdy = 3'b001,get_data=3'b010,wait_for_input_rdy=3'b011,wait_for_buffer=3'b100,Start=3'b101;
    always@(posedge clk,posedge rst) begin
        if (rst) begin
            ps <= idle; inc<=0; ld_reg<=0;icc<=0;input_acc<=0;start<=0;
        end
        else ps <= ns;
    end
    always@(ps) begin
        icc=0;ld_reg=0;inc=0;input_acc=0;start=0;
        case(ps)
        idle: ns = input_rdy ? rdy : idle;
        rdy: begin
            inc = 1;
            icc = 1;
            ns = get_data;
        end
        get_data: begin
            ld_reg=1;
            icc=1;
            ns = cnt < 3 ? get_data : wait_for_input_rdy;
        end
        wait_for_input_rdy: ns = input_rdy ? wait_for_input_rdy : wait_for_buffer;
        wait_for_buffer: ns = outsent ? Start : wait_for_buffer;
        Start: begin
            start=1;
            ns = idle;
        end
        endcase
    end
endmodule

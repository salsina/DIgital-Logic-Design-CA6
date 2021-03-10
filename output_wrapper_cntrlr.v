module output_wrapper_cntrlr(input clk,rst,gnt,ready,cnt,out_acc,output reg inc,ld_reg,icc,request,out_sent);
    reg[2:0] ps,ns;
    parameter[2:0] idle = 3'b000,get_data=3'b001,counting=3'b010,send_request=3'b011,ready_to_acc=3'b100;
    always@(posedge clk,posedge rst) begin
        if (rst) begin
            ps <= idle; inc<=0; icc<=0; ld_reg <= 0; request <= 0; out_sent<=1;
        end
        else ps <= ns;
    end
    always@(ps,gnt,ready,cnt,out_acc) begin
        inc=0; ld_reg=0; icc=0;out_sent=0;
        case(ps)
            idle: begin
                request=0;
                inc=1;
                ns = ready ? get_data : idle;
            end
            get_data: begin
                ld_reg=1;
                ns = counting;
            end
            counting: begin
                icc=1;
                ns = cnt < 2 ? counting : send_request;
            end
            send_request: begin
                request = 1;
                ns = gnt ? ready_to_acc : send_request;
            end
            ready_to_acc: begin 
                ns = out_acc ? idle : ready_to_acc;
                request=1;
                if (out_acc) out_sent=1;
            end
        endcase
    end
endmodule
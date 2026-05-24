module arbitro_prioridade_fixa (
    input  wire       clk, rst,
    input  wire [1:0] add0, add1, add2, add3, //address(4 disp.)
    input  wire       req0, req1, req2, req3, //requisicao
    output reg        grant0, grant1, grant2, grant3, //atende     
    output reg  [1:0] sel0, sel1, sel2, sel3, //disp. selection
	output reg        clear0, clear1, clear2, clear3
);

always @(posedge clk, posedge rst) begin
	if(rst) begin
		grant0 <= 0; grant1 <= 0; grant2 <= 0; grant3 <= 0;
		sel0 <= 2'b00; sel1 <= 2'b00;	sel2 <= 2'b00;	sel3 <= 2'b00;
	end
	else begin
	 clear0 <= 1'b0; clear1 <= 1'b0; clear2 <= 1'b0; clear3 <= 1'b0;
    // GRANT0
    if      ((add0 == 2'b00) && (req0 == 1'b1)) {grant0, clear0, sel0} <= 4'b1100;
    else if ((add1 == 2'b00) && (req1 == 1'b1)) {grant0, clear1, sel0} <= 4'b1101;
    else if ((add2 == 2'b00) && (req2 == 1'b1)) {grant0, clear2, sel0} <= 4'b1110;
    else if ((add3 == 2'b00) && (req3 == 1'b1)) {grant0, clear3, sel0} <= 4'b1111;
    else {grant0, sel0} <= 3'b000;

    // GRANT1
    if      ((add0 == 2'b01) && (req0 == 1'b1)) {grant1, clear0, sel1} <= 4'b1100;
    else if ((add1 == 2'b01) && (req1 == 1'b1)) {grant1, clear1, sel1} <= 4'b1101;
    else if ((add2 == 2'b01) && (req2 == 1'b1)) {grant1, clear2, sel1} <= 4'b1110;
    else if ((add3 == 2'b01) && (req3 == 1'b1)) {grant1, clear3, sel1} <= 4'b1111;
    else {grant1, sel1} <= 3'b000;

    // GRANT2
    if      ((add0 == 2'b10) && (req0 == 1'b1)) {grant2, clear0, sel2} <= 4'b1100;
    else if ((add1 == 2'b10) && (req1 == 1'b1)) {grant2, clear1, sel2} <= 4'b1101;
    else if ((add2 == 2'b10) && (req2 == 1'b1)) {grant2, clear2, sel2} <= 4'b1110;
    else if ((add3 == 2'b10) && (req3 == 1'b1)) {grant2, clear3, sel2} <= 4'b1111;
    else {grant2, sel2} <= 3'b000;

    // GRANT3
    if      ((add0 == 2'b11) && (req0 == 1'b1)) {grant3, clear0, sel3} <= 4'b1100;
    else if ((add1 == 2'b11) && (req1 == 1'b1)) {grant3, clear1, sel3} <= 4'b1101;
    else if ((add2 == 2'b11) && (req2 == 1'b1)) {grant3, clear2, sel3} <= 4'b1110;
    else if ((add3 == 2'b11) && (req3 == 1'b1)) {grant3, clear3, sel3} <= 4'b1111;
    else {grant3, sel3} <= 3'b000;

	 end
end
endmodule

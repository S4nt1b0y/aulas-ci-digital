module tb_rand;
    initial begin
        usart_sim s = new();
        repeat (10) begin
            if (!s.randomize())
                $fatal(1, "Randomize() falhou");
            $display("kind=%0d data=%0h2 gap=%0d",
                     s.kind.name(), s.data, s.gap);
        end
    end
endmodule
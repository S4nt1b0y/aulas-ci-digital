//==========================================
// Function : Asynchronous FIFO (w/ 2 asynchronous clocks).
// Notes    : This implementation is based on the article 
//            'Asynchronous FIFO in Virtex-II FPGAs'
//            writen by Peter Alfke. This TechXclusive 
//            article can be downloaded from the
//            Xilinx website. It has some minor modifications.
//=========================================

`timescale 1ns/1ps

module aFifo
  #(parameter    DATA_WIDTH    = 8,
                 ADDRESS_WIDTH = 4,
                 FIFO_DEPTH    = (1 << ADDRESS_WIDTH))
     //Reading port
    (output reg  [DATA_WIDTH-1:0]        Data_out, 
     output reg                          Empty_out,
     input wire                          ReadEn_in,
     input wire                          RClk,        
     //Writing port.	 
     input wire  [DATA_WIDTH-1:0]        Data_in,  
     output reg                          Full_out,
     input wire                          WriteEn_in,
     input wire                          WClk,
	 
     input wire                          Clear_in);

    /////Internal connections & variables//////
    reg   [DATA_WIDTH-1:0]              Mem [FIFO_DEPTH-1:0];
    wire  [ADDRESS_WIDTH-1:0]           pNextWordToWrite, pNextWordToRead;
    wire                                EqualAddresses;
    wire                                NextWriteAddressEn, NextReadAddressEn;
    wire                                Set_Status, Rst_Status;
    reg                                 Status;
    wire                                PresetFull, PresetEmpty;
    reg  [ADDRESS_WIDTH:0]            Next_Write_addr_1, Next_Write_addr_2;
    reg  [ADDRESS_WIDTH:0]            Next_Read_addr_1, Next_Read_addr_2;
    
    //////////////Code///////////////
    //Data ports logic:
    //(Uses a dual-port RAM).
    //'Data_out' logic:
    always @ (posedge RClk)
        if (ReadEn_in & !Empty_out)
            Data_out <= Mem[pNextWordToRead];
            
    //'Data_in' logic:
    always @ (posedge WClk)
        if (WriteEn_in & !Full_out)
            Mem[pNextWordToWrite] <= Data_in;

    //Fifo addresses support logic: 
    //'Next Addresses' enable logic:
    assign NextWriteAddressEn = WriteEn_in & ~Full_out;
    assign NextReadAddressEn  = ReadEn_in  & ~Empty_out;
           
    //Addreses (Gray counters) logic:
    GrayCounter #(
        .COUNTER_WIDTH(ADDRESS_WIDTH+1)
    )GrayCounter_pWr
       (.GrayCount_out(pNextWordToWrite),
       
        .Enable_in(NextWriteAddressEn),
        .Clear_in(Clear_in),
        
        .clk(WClk)
       );
       
    GrayCounter #(
        .COUNTER_WIDTH(ADDRESS_WIDTH+1)
     ) GrayCounter_pRd
       (.GrayCount_out(pNextWordToRead),
        .Enable_in(NextReadAddressEn),
        .Clear_in(Clear_in),
        .clk(RClk)
       );

    wire Empty_next; 

    always @ (posedge RClk) begin //D Flip-Flop For Read Sincronization
        if (Clear_in) begin
            Next_Write_addr_1 <= {ADDRESS_WIDTH{1'b 0}};
            Next_Write_addr_2 <= {ADDRESS_WIDTH{1'b 0}};
        end else begin 
            Next_Write_addr_1 <= pNextWordToWrite;
            Next_Write_addr_2 <= Next_Write_addr_1;
        end
    end

    assign Empty_next = (pNextWordToRead == Next_Write_addr_2);

    always @(posedge RClk) begin
        if (Clear_in)
            Empty_out <= 1'b1;
        else
            Empty_out <= Empty_next;
    end

    wire Full_next;

    always @ (posedge WClk) begin //D Flip-Flop For Write Sincronization
        if (Clear_in) begin
            Next_Read_addr_1 <= {ADDRESS_WIDTH{1'b 0}};
            Next_Read_addr_2 <= {ADDRESS_WIDTH{1'b 0}};
        end else begin 
            Next_Read_addr_1 <= pNextWordToRead;
            Next_Read_addr_2 <= Next_Read_addr_1;
        end
    end

    assign Full_next =
    (pNextWordToWrite ==
     {~Next_Read_addr_2[ADDRESS_WIDTH],
      ~Next_Read_addr_2[ADDRESS_WIDTH-1],
       Next_Read_addr_2[ADDRESS_WIDTH-2:0]});
    
    always @(posedge WClk) begin
        if (Clear_in)
            Full_out <= 1'b0;
        else
            Full_out <= Full_next;
    end
            
endmodule

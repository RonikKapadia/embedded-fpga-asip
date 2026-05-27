-- library declaration
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- entity
entity controls is
    port (
    -- Timing Signals
    clk, en, rst: in std_logic;

    -- Register File IO
    rID1, rID2 : out std_logic_vector(4 downto 0);
    wr_enR1, wr_enR2 : out std_logic;
    regrD1, regrD2 : in std_logic_vector(15 downto 0);
    regwD1, regwD2 : out std_logic_vector(15 downto 0);

    -- Framebuffer IO
    fbRST : out std_logic;
    fbAddr1 : out std_logic_vector(11 downto 0);
    fbDin1 : in std_logic_vector(15 downto 0);
    fbDout1 : out std_logic_vector(15 downto 0);
    fbWr_en : out std_logic;

    -- Instruction Memory IO
    irAddr : out std_logic_vector(13 downto 0);
    irWord : in std_logic_vector(31 downto 0);

    -- Data Memory IO
    dAddr : out std_logic_vector(14 downto 0);
    d_wr_en : out std_logic;
    dOut : out std_logic_vector(15 downto 0);
    dIn : in std_logic_vector(15 downto 0);

    -- ALU IO
    aluA, aluB : out std_logic_vector(15 downto 0);
    aluOp : out std_logic_vector(3 downto 0);
    aluResult : in std_logic_vector(15 downto 0);
    
    -- UART IO
    ready, newChar : in std_logic;
    send : out std_logic;
    charRec : in std_logic_vector(7 downto 0);
    charSend : out std_logic_vector(7 downto 0)
);
end controls;

-- architecture
architecture controls of controls is

    -- intermediate signals

   type state_type is (
    --  1         2         3        4         5    
        fetch   , fetch_1 , decode , decode_1, decode_2, 
    --  6         7         8        9        10
        rops    , rops_1  , rops_2 , lops    , lops_1  , 
    --  11        12        13       14        15
        jops    , jops_1  , calc   , calc_1  , calc_2  ,
    --  16        17        18       19        20
        store   , jr      , recv    , rpix   , rpix_1  , 
    --  21        22        23        24        25
        rpix_2  , wpix    , sen     , equals , nequals ,
    --  26        27        28        29        30
        ori     , lw      , lw_1    , lw_2   , lw_3    ,
    --  31        32        33        34        35
        sw      , sw_1    , sw_2    , jmp    , jal     ,
    --  36        37        38
        clrscr  , finish  , reset   , reset_1
    );

    signal state : state_type := fetch;
    signal state_num : integer := 0;

    signal pc : std_logic_vector(15 downto 0) := (others => '0');
    signal instr : std_logic_vector(31 downto 0) := (others => '0');

    subtype OP is natural range 31 downto 30;
    subtype OPCODE is natural range 31 downto 27;
    subtype R1 is natural range 26 downto 22;
    subtype R2 is natural range 21 downto 17;
    subtype R3 is natural range 16 downto 12;
    subtype L_IMM is natural range 16 downto 1;
    subtype J_IMM is natural range 26 downto 11;

    signal reg1_data : std_logic_vector(15 downto 0) := (others => '0');
    signal reg2_data : std_logic_vector(15 downto 0) := (others => '0');
    signal reg3_data : std_logic_vector(15 downto 0) := (others => '0');

    signal store_reg : std_logic_vector(4 downto 0) := (others => '0');
    signal store_data : std_logic_vector(15 downto 0) := (others => '0');

begin 

    -- update state signal
    process(state)
    begin
        state_num <= state_type'pos(state) + 1;
    end process;

    -- main
    process(clk)
    begin


        if rising_edge(clk) then
            
            if    (rst = '1') then 
            
                fbRST <= '1';
                
                wr_enR1 <= '0';
                wr_enR2 <= '0';
                
                fbWr_en <= '0';
                
                d_wr_en <= '0';

                send <= '0';

                state <= reset;
            
            elsif (en = '1') then

                case state is

                    -- fetch
                    when fetch => 
                        rID1 <= "00001";
                        state <= fetch_1;
                    
                    when fetch_1 => 
                        pc <= regrD1;
                        state <= decode;
                    
                    -- decode
                    when decode => 
                        irAddr <= pc(13 downto 0);

                        wr_enR1 <= '1';
                        rID1 <= "00001";
                        regwD1 <= std_logic_vector(unsigned(pc) + 1);

                        state <= decode_1;
                    
                    when decode_1 =>
                        instr <= irWord;

                        wr_enR1 <= '0';

                        state <= decode_2;

                    when decode_2 => 

                        if    (instr(OP) = "00" or instr(OP) = "01") then 
                            state <= rops;
                        elsif (instr(OP) = "10") then 
                            state <= lops;
                        elsif (instr(OP) = "11") then 
                            state <= jops;
                        end if;
                    
                    -- rops
                    when rops => 
                        rID1 <= instr(R2);
                        rID2 <= instr(R3);

                        state <= rops_1;

                    when rops_1 => 
                        reg2_data <= regrD1;
                        reg3_data <= regrD2;

                        rID1 <= instr(R1);

                        state <= rops_2;

                    when rops_2 =>
                        reg1_data <= regrD1;

                        if    (instr(OPCODE) = "01101") then 
                            state <= jr;
                        elsif (instr(OPCODE) = "01100") then 
                            state <= recv;
                        elsif (instr(OPCODE) = "01111") then 
                            state <= rpix;
                        elsif (instr(OPCODE) = "01110") then 
                            state <= wpix;
                        elsif (instr(OPCODE) = "01011") then 
                            state <= sen;
                        else 
                            state <= calc;
                        end if;
                        
                    -- lops
                    when lops => 
                        rID1 <= instr(R1);
                        rID2 <= instr(R2);

                        state <= lops_1;

                    when lops_1 => 
                        reg1_data <= regrD1;
                        reg2_data <= regrD2;
                        
                        if    (instr(OPCODE) = "10000") then 
                            state <= equals;
                        elsif (instr(OPCODE) = "10001") then 
                            state <= nequals;
                        elsif (instr(OPCODE) = "10010") then 
                            state <= ori;
                        elsif (instr(OPCODE) = "10011") then 
                            state <= lw;
                        else 
                            state <= sw;
                        end if;

                    -- jops
                    when jops => 

                        if    (instr(OPCODE) = "11000") then 
                            state <= jmp;
                        elsif (instr(OPCODE) = "11000") then 
                            state <= jal;
                        else
                            state <= clrscr;
                        end if;

                    -- calc
                    when calc => 

                        aluA <= reg2_data;
                        aluB <= reg3_data;

                        case instr(OPCODE) is 
                            -- add
                            when "00000" =>
                                aluOp <= x"0";

                            -- sub
                            when "00001" => 
                                aluOp <= x"1";

                            -- sll
                            when "00010" => 
                                aluOp <= x"5";

                            -- srl
                            when "00011" => 
                                aluOp <= x"6";

                            -- sra
                            when "00100" => 
                                aluOp <= x"7";

                            -- and
                            when "00101" => 
                                aluOp <= x"8";  

                            -- or
                            when "00110" => 
                                aluOp <= x"9";

                            -- xor
                            when "00111" => 
                                aluOp <= x"A";

                            -- slt
                            when "01000" => 
                                aluOp <= x"B";

                            -- sgt
                            when "01001" => 
                                aluOp <= x"C";

                            -- seq
                            when "01010" => 
                                aluOp <= x"D";

                            when others => 
                                -- nothing
                            
                        end case;

                        state <= calc_1;
                        
                    when calc_1 => -- wait for alu to do math
                        
                        state <= calc_2;

                    when calc_2 => 
                        store_reg <= instr(R1);
                        store_data <= aluResult;

                        state <= store;

                    -- store
                    when store => 
                        wr_enR1 <= '1';
                        rID1 <= store_reg;
                        regwD1 <= store_data;

                        state <= finish;

                    -- jr
                    when jr => 
                        store_reg <= "00001";
                        store_data <= reg1_data;

                        state <= store;
                    
                    -- recv
                    when recv => 
                    
                        if    (newChar = '1') then
                            store_reg <= instr(R1);
                            store_data <= x"00" & charRec;

                            state <= store;
                        elsif (newChar = '0') then
                            state <= recv;
                        end if;

                    -- rpix
                    when rpix => 
                        fbAddr1 <= reg2_data(11 downto 0);

                        state <= rpix_1;

                    when rpix_1 => -- wait cuz reads on enable
                        
                        state <= rpix_2;
                        
                    when rpix_2 => 
                        store_reg <= instr(R1);
                        store_data <= fbDin1;
                        
                        state <= store;

                    -- wpix
                    when wpix => 
                        fbAddr1 <= reg1_data(11 downto 0);
                        fbDout1 <= reg2_data;
                        fbWr_en <= '1';

                        state <= finish;
                        
                    -- send
                    when sen => 
                        send <= '1';
                        charSend <= reg1_data(7 downto 0);

                        state <= finish;
                    
                    -- equals - [MODIFIED]
                    when equals => 
                        if (reg1_data =  reg2_data) then
                            store_reg <= "00001";
                            store_data <= instr(L_IMM);

                            state <= store;
                        else
                            store_reg <= "00001";
                            store_data <= std_logic_vector(unsigned(pc) + 1);
                            
                            state <= store; 
                        end if; 
                    
                    -- nequals - [MODIFIED]
                    when nequals =>
                        if (reg1_data /= reg2_data) then
                            store_reg <= "00001";
                            store_data <= instr(L_IMM);
                            
                            state <= store;
                        else
                            store_reg <= "00001";
                            store_data <= std_logic_vector(unsigned(pc) + 1);
                            
                            state <= store; 
                        end if;
                    
                    -- ori - [NEED ALU??]
                    when ori => 
                        store_reg <= instr(R1);
                        store_data <= reg2_data or instr(L_IMM);
                        
                        state <= store;

                    -- lw
                    when lw => 
                        aluOp <= x"0";
                        aluA <= reg2_data;
                        aluB <= instr(L_IMM);

                        state <= lw_1;

                    when lw_1 => -- wait for alu to get result
                        
                        state <= lw_2;

                    when lw_2 => 
                        dAddr <= aluResult(14 downto 0);
                        
                        state <= lw_3;
                    
                    when lw_3 => -- don't need to wait as its not tied to enable
                        store_reg <= instr(R1);
                        store_data <= dIn;

                        state <= store;

                    -- sw
                    when sw => 
                        aluOp <= x"0";
                        aluA <= reg2_data;
                        aluB <= instr(L_IMM);

                        state <= sw_1;

                    when sw_1 =>  -- wait for alu to get result

                        state <= sw_2;

                    when sw_2 =>
                        d_wr_en <= '1';
                        dAddr <= aluResult(14 downto 0);
                        dOut <= reg1_data;

                        state <= finish;
                    
                    -- jmp 
                    when jmp => 
                        wr_enR1 <= '1';
                        rID1 <= "00001";
                        regwD1 <= instr(J_IMM);

                        state <= finish;
                    
                    -- jal
                    when jal => 
                        wr_enR1 <= '1';
                        wr_enR2 <= '1';
                        rID1 <= "00001";
                        rID2 <= "00010";
                        regwD1 <= instr(J_IMM);
                        regwD2 <= pc;

                        state <= finish;
                    
                    -- clrscr
                    when clrscr =>
                        fbRST <= '1';

                        state <= finish;
                    
                    -- finish
                    when finish =>
                        wr_enR1 <= '0';
                        wr_enR2 <= '0';
                        
                        fbRST <= '0';
                        fbWr_en <= '0';
                        
                        d_wr_en <= '0';

                        send <= '0';

                        state <= fetch;

                    -- reset
                    when reset => 
                        -- reset frame buffer -- is this state even needed???


                        state <= reset_1;
                        
                   when reset_1 =>
                        fbRST <= '0';
                        
                        state <= fetch;
                    
                    -- others
                    when others => 
                        -- nothing
                    
                end case;

            end if;
        end if;
    end process;


end controls; 
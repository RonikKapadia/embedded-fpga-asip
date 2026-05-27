-- library declaration
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- entity
entity my_alu is 
    port(
        clk, en : in std_logic;
        opcode  : in std_logic_vector(3 downto 0);
        A       : in std_logic_vector(15 downto 0); 
        B       : in std_logic_vector(15 downto 0);
        X       : out std_logic_vector(15 downto 0)
    );
end my_alu;

-- architecture
architecture my_alu of my_alu is

begin

    process(clk)
    begin
        if rising_edge(clk) then 
            if (en = '1') then

                if    opcode = x"0" then 
                    X <= std_logic_vector(unsigned(A) + unsigned(B));
                elsif opcode = x"1" then 
                    X <= std_logic_vector(unsigned(A) - unsigned(B));
                elsif opcode = x"2" then 
                    X <= std_logic_vector(unsigned(A) + 1);
                elsif opcode = x"3" then 
                    X <= std_logic_vector(unsigned(A) - 1);
                elsif opcode = x"4" then 
                    X <= std_logic_vector(0 - unsigned(A));
                elsif opcode = x"5" then 
                    X <= std_logic_vector(unsigned(A) sll 1);
                elsif opcode = x"6" then 
                    X <= std_logic_vector(unsigned(A) srl 1);
                elsif opcode = x"7" then 
                    X <= std_logic_vector(shift_right(signed(A), 1));
                elsif opcode = x"8" then 
                    X <= (A and B);
                elsif opcode = x"9" then 
                    X <= (A or B);
                elsif opcode = x"A" then 
                    X <= (A xor B);
                elsif opcode = x"B" then 
                    if (signed(A) < signed(B)) then 
                        X <= "0000000000000001"; 
                    else 
                        X <= "0000000000000000";
                    end if;
                elsif opcode = x"C" then 
                    if (signed(A) > signed(B)) then 
                        X <= "0000000000000001"; 
                    else 
                        X <= "0000000000000000";
                    end if;
                elsif opcode = x"D" then 
                    if (unsigned(A) = unsigned(B)) then 
                        X <= "0000000000000001"; 
                    else 
                        X <= "0000000000000000";
                    end if;
                elsif opcode = x"E" then 
                    if (unsigned(A) < unsigned(B)) then 
                        X <= "0000000000000001"; 
                    else 
                        X <= "0000000000000000";
                    end if;
                elsif opcode = x"F" then 
                    if (unsigned(A) > unsigned(B)) then 
                        X <= "0000000000000001"; 
                    else 
                        X <= "0000000000000000";
                    end if;
                end if;

            end if;
        end if;
    end process;
    
end my_alu;
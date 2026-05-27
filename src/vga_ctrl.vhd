-- library declaration
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- entity
entity vga_ctrl is 
    port(
        clk, en : in std_logic;
        hcount, vcount : out std_logic_vector(9 downto 0);
        vid, hs, vs : out std_logic
    );
end vga_ctrl;

-- architecture
architecture vga_ctrl of vga_ctrl is
    -- intermediate signals
    signal hcount_reg, vcount_reg : unsigned(9 downto 0) := (others => '0');
begin

    hcount <= std_logic_vector(hcount_reg);
    vcount <= std_logic_vector(vcount_reg);

    process(clk)
    begin
        if rising_edge(clk) then
            if en = '1' then
                
                -- horizontal counter
                if (hcount_reg < 799) then
                    hcount_reg <= hcount_reg + 1;
                else
                    hcount_reg <= (others => '0');
                    
                    -- vertical counter
                    if (vcount_reg < 524) then
                        vcount_reg <= vcount_reg + 1;
                    else
                        vcount_reg <= (others => '0');
                    end if;

                end if;

            end if;
        end if;
    end process;
    
    process(hcount_reg, vcount_reg) 
    begin
        -- vid
        if (hcount_reg <= 639) and (vcount_reg <= 479) then 
            vid <= '1';
        else
            vid <= '0';
        end if;

        -- hs 
        if (hcount_reg >= 656) and (hcount_reg <= 751) then
            hs <= '0';
        else
            hs <= '1';
        end if;

        -- vs
        if (vcount_reg >= 490) and (vcount_reg <= 491) then
            vs <= '0';
        else
            vs <= '1';
        end if;
    end process;

end vga_ctrl;
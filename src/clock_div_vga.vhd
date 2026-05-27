-- library declaration
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- entity
entity clock_div_vga is 
    port(
        clk : in std_logic;
        div : out std_logic
    );
end clock_div_vga;

-- architecture
architecture clock_div_vga of clock_div_vga is
    
    -- constants
    constant DIV_FACTOR : integer := 5; 

    -- intermediate signals
    signal counter : unsigned(25 downto 0) := (others => '0');

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if (counter < (DIV_FACTOR-1)) then
                div <= '0';
                counter <= unsigned(counter) + 1;
            else
                div <= '1';
                counter <= (others => '0');
            end if;
        end if;
    end process;

end clock_div_vga;
-- library declaration
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- entity
entity debounce is 
    port(
        btn : in std_logic;
        clk : in std_logic;
        dbnc : out std_logic
    );
end debounce;

-- architecture
architecture debounce of debounce is

    -- constants
--    constant MAX_COUNT : integer := 2500000; 
     constant MAX_COUNT : integer := 1; 
    
    -- intermediate signals
    signal shift_register : std_logic_vector(2 downto 0) := (others => '0');
    signal counter : std_logic_vector(21 downto 0) := (others => '0');

begin
    process(clk)
    begin
        if rising_edge(clk) then

            shift_register(1) <= shift_register(0);
            shift_register(0) <= btn;

            if shift_register(1) = '1' then
                if unsigned(counter) = MAX_COUNT-1 then
                    dbnc <= '1';
                else
                    counter <= std_logic_vector(unsigned(counter) + 1);
                    dbnc <= '0';
                end if;
            else
                counter <= (others => '0');
                dbnc <= '0';
            end if;
                
        end if;
    end process;
end debounce;
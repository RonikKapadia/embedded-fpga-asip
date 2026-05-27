-- library declaration
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- entity
entity uart_tx is
    port(
        clk, en, send, rst  : in std_logic;
        char                : in std_logic_vector (7 downto 0);
        ready, tx           : out std_logic := '1'
    );
end uart_tx;

-- architecture
architecture uart_tx of uart_tx is

    -- intermediate signals
    type state is (idle, start, data);
    signal current_state : state := idle;
    signal char_reg : std_logic_vector (7 downto 0) := (others => '0');
    signal count : std_logic_vector (2 downto 0) := (others => '0');

begin

    proc: process(clk)
    begin
        if rising_edge(clk) then

            -- reset machine
            if rst = '1' then 
                current_state <= idle;
                char_reg <= (others => '0');
                count <= (others => '0');
            end if;

            -- main sending
            if en = '1' then
                if send = '1' then
                    char_reg <= char;
                end if;

                case current_state is
                    -- idle
                    when idle =>
                        tx <= '1';
                        ready <= '1';
                        if send = '1' then
                            current_state <= start;
                        end if;  

                    -- start
                    when start => 
                        ready <= '0';
                        tx <= '0';
                        current_state <= data;

                    -- sending data
                    when data =>
                        ready <= '0';
                        tx <= char_reg(to_integer(unsigned(count)));
                        
                        if unsigned(count) < 7 then
                            count <= std_logic_vector(unsigned(count) + 1);
                        else
                            count <= (others => '0');
                            current_state <= idle;
                        end if;

                end case;

            end if;

        end if;
    end process;

end uart_tx;
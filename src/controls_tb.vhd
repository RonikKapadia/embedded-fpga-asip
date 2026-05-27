-- library declaration
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- entity
entity controls_tb is
end controls_tb;

-- architecture
architecture controls_tb of controls_tb is

    -- components
    component controls
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
    end component;

    signal clk : std_logic := '0';
    signal en : std_logic := '0';
    signal rst : std_logic := '0';

    signal rID1, rID2 : std_logic_vector(4 downto 0) := (others => '0');
    signal wr_enR1, wr_enR2 : std_logic := '0';
    signal regrD1, regrD2 : std_logic_vector(15 downto 0) := (others => '0');
    signal regwD1, regwD2 : std_logic_vector(15 downto 0) := (others => '0');

    signal fbRST : std_logic := '0';
    signal fbAddr1 : std_logic_vector(11 downto 0) := (others => '0');
    signal fbDin1 : std_logic_vector(15 downto 0) := (others => '0');
    signal fbDout1 : std_logic_vector(15 downto 0) := (others => '0');
    signal fbWr_en : std_logic := '0';

    signal irAddr : std_logic_vector(13 downto 0) := (others => '0');
    signal irWord : std_logic_vector(31 downto 0) := (others => '0');

    signal dAddr : std_logic_vector(14 downto 0) := (others => '0');
    signal d_wr_en : std_logic := '0';
    signal dOut : std_logic_vector(15 downto 0) := (others => '0');
    signal dIn : std_logic_vector(15 downto 0) := (others => '0');

    signal aluA, aluB : std_logic_vector(15 downto 0) := (others => '0');
    signal aluOp : std_logic_vector(3 downto 0) := (others => '0');
    signal aluResult : std_logic_vector(15 downto 0) := (others => '0');

    signal ready, newChar : std_logic := '0';
    signal send : std_logic := '0';
    signal charRec : std_logic_vector(7 downto 0) := (others => '0');
    signal charSend : std_logic_vector(7 downto 0) := (others => '0');

begin

    controls_0: controls
    port map (
        clk => clk,
        en => en,
        rst => rst,

        rID1 => rID1,
        rID2 => rID2,
        wr_enR1 => wr_enR1,
        wr_enR2 => wr_enR2,
        regrD1 => regrD1,
        regrD2 => regrD2,
        regwD1 => regwD1,
        regwD2 => regwD2,

        fbRST => fbRST,
        fbAddr1 => fbAddr1,
        fbDin1 => fbDin1,
        fbDout1 => fbDout1,
        fbWr_en => fbWr_en,

        irAddr => irAddr,
        irWord => irWord,

        dAddr => dAddr,
        d_wr_en => d_wr_en,
        dOut => dOut,
        dIn => dIn,

        aluA => aluA,
        aluB => aluB,
        aluOp => aluOp,
        aluResult => aluResult,

        ready => ready,
        newChar => newChar,
        send => send,
        charRec => charRec,
        charSend => charSend
    );

    process begin
        clk <= '0';
        wait for 4 ns;
        clk <= '1';
        wait for 4 ns;
    end process;

    process begin
        en <= '0';
        wait for 8672 ns;
        en <= '1';
        wait for 8 ns;
    end process;

    -- main
    process begin
        irWord <= x"00C85000";
        wait for 125000 ns;

        report "End of testbench" severity FAILURE;
    end process;


end controls_tb;

   

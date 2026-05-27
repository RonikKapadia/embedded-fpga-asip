-- library declaration
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- entity
entity top is
    port (
        CTS : out std_logic;
        RTS : out std_logic;
        RXD : in std_logic;
        TXD : out std_logic;
        btn : in std_logic;
        clk : in std_logic;
        vga_b : out std_logic_vector (4 downto 0);
        vga_g : out std_logic_vector (5 downto 0);
        vga_hs : out std_logic;
        vga_r : out std_logic_vector (4 downto 0);
        vga_vs : out std_logic
    );
end top;

-- architecture
architecture top of top is

    component clock_div_cpu is
        port (
            clk : in std_logic;
            div : out std_logic
        );
    end component clock_div_cpu;

    component clock_div_vga is
        port (
            clk : in std_logic;
            div : out std_logic
        );
    end component clock_div_vga;

    component debounce is
        port (
            btn : in std_logic;
            clk : in std_logic;
            dbnc : out std_logic
        );
    end component debounce;

    component framebuffer is
        port (
            clk1 : in std_logic;
            en1 : in std_logic;
            en2 : in std_logic;
            ld : in std_logic;
            addr1 : in std_logic_vector (11 downto 0);
            addr2 : in std_logic_vector (11 downto 0);
            wr_en1 : in std_logic;
            din1 : in std_logic_vector (15 downto 0);
            dout1 : out std_logic_vector (15 downto 0);
            dout2 : out std_logic_vector (15 downto 0)
        );
    end component framebuffer;

    component pixel_pusher is
        port (
            clk : in std_logic;
            en : in std_logic;
            vs : in std_logic;
            vid : in std_logic;
            pixel : in std_logic_vector (15 downto 0);
            hcount : in std_logic_vector (9 downto 0);
            R : out std_logic_vector (4 downto 0);
            B : out std_logic_vector (4 downto 0);
            G : out std_logic_vector (5 downto 0);
            addr : out std_logic_vector (11 downto 0)
        );
    end component pixel_pusher;

    component uart is
        port (
            clk : in std_logic;
            en : in std_logic;
            send : in std_logic;
            rx : in std_logic;
            rst : in std_logic;
            charSend : in std_logic_vector (7 downto 0);
            ready : out std_logic;
            tx : out std_logic;
            newChar : out std_logic;
            charRec : out std_logic_vector (7 downto 0)
        );
    end component uart;

    component vga_ctrl is
        port (
            clk : in std_logic;
            en : in std_logic;
            hcount : out std_logic_vector (9 downto 0);
            vcount : out std_logic_vector (9 downto 0);
            vid : out std_logic;
            hs : out std_logic;
            vs : out std_logic
        );
    end component vga_ctrl;

    component regs is
        port (
            clk : in std_logic;
            en : in std_logic;
            rst : in std_logic;
            id1 : in std_logic_vector (4 downto 0);
            id2 : in std_logic_vector (4 downto 0);
            wr_en1 : in std_logic;
            wr_en2 : in std_logic;
            din1 : in std_logic_vector (15 downto 0);
            din2 : in std_logic_vector (15 downto 0);
            dout1 : out std_logic_vector (15 downto 0);
            dout2 : out std_logic_vector (15 downto 0)
        );
    end component regs;

    component my_alu is
        port (
            clk : in std_logic;
            en : in std_logic;
            opcode : in std_logic_vector (3 downto 0);
            A : in std_logic_vector (15 downto 0);
            B : in std_logic_vector (15 downto 0);
            X : out std_logic_vector (15 downto 0)
        );
    end component my_alu;

    component irMem is
        port (
            clka : in std_logic;
            addra : in std_logic_vector (13 downto 0);
            douta : out std_logic_vector (31 downto 0)
        );
    end component irMem;

    component dMem is
        port (
            clka : in std_logic;
            wea : in std_logic_vector (0 to 0);
            addra : in std_logic_vector (14 downto 0);
            dina : in std_logic_vector (15 downto 0);
            douta : out std_logic_vector (15 downto 0)
        );
    end component dMem;

    component controls is
        port (
            clk : in std_logic;
            en : in std_logic;
            rst : in std_logic;
            rID1 : out std_logic_vector (4 downto 0);
            rID2 : out std_logic_vector (4 downto 0);
            wr_enR1 : out std_logic;
            wr_enR2 : out std_logic;
            regrD1 : in std_logic_vector (15 downto 0);
            regrD2 : in std_logic_vector (15 downto 0);
            regwD1 : out std_logic_vector (15 downto 0);
            regwD2 : out std_logic_vector (15 downto 0);
            fbRST : out std_logic;
            fbAddr1 : out std_logic_vector (11 downto 0);
            fbDin1 : in std_logic_vector (15 downto 0);
            fbDout1 : out std_logic_vector (15 downto 0);
            fbWr_en : out std_logic;
            irAddr : out std_logic_vector (13 downto 0);
            irWord : in std_logic_vector (31 downto 0);
            dAddr : out std_logic_vector (14 downto 0);
            d_wr_en : out std_logic;
            dOut : out std_logic_vector (15 downto 0);
            dIn : in std_logic_vector (15 downto 0);
            aluA : out std_logic_vector (15 downto 0);
            aluB : out std_logic_vector (15 downto 0);
            aluOp : out std_logic_vector (3 downto 0);
            aluResult : in std_logic_vector (15 downto 0);
            ready : in std_logic;
            newChar : in std_logic;
            send : out std_logic;
            charRec : in std_logic_vector (7 downto 0);
            charSend : out std_logic_vector (7 downto 0)
        );
    end component controls;

    signal RXD_1 : std_logic := '1';
    signal btn_1 : std_logic := '0';
    signal clk_1 : std_logic := '0';
    signal clock_div_cpu_0_div : std_logic := '0';
    signal clock_div_vga_0_div : std_logic := '0';
    signal controls_0_aluA : std_logic_vector (15 downto 0) := (others => '0');
    signal controls_0_aluB : std_logic_vector (15 downto 0) := (others => '0');
    signal controls_0_aluOp : std_logic_vector (3 downto 0) := (others => '0');
    signal controls_0_charSend : std_logic_vector (7 downto 0) := (others => '0');
    signal controls_0_dAddr : std_logic_vector (14 downto 0) := (others => '0');
    signal controls_0_dOut : std_logic_vector (15 downto 0) := (others => '0');
    signal controls_0_d_wr_en : std_logic := '0';
    signal controls_0_fbAddr1 : std_logic_vector (11 downto 0) := (others => '0');
    signal controls_0_fbDout1 : std_logic_vector (15 downto 0) := (others => '0');
    signal controls_0_fbRST : std_logic := '0';
    signal controls_0_fbWr_en : std_logic := '0';
    signal controls_0_irAddr : std_logic_vector (13 downto 0) := (others => '0');
    signal controls_0_rID1 : std_logic_vector (4 downto 0) := (others => '0');
    signal controls_0_rID2 : std_logic_vector (4 downto 0) := (others => '0');
    signal controls_0_regwD1 : std_logic_vector (15 downto 0) := (others => '0');
    signal controls_0_regwD2 : std_logic_vector (15 downto 0) := (others => '0');
    signal controls_0_send : std_logic := '0';
    signal controls_0_wr_enR1 : std_logic := '0';
    signal controls_0_wr_enR2 : std_logic := '0';
    signal dMem_douta : std_logic_vector (15 downto 0) := (others => '0');
    signal debounce_0_dbnc : std_logic := '0';
    signal framebuffer_0_dout1 : std_logic_vector (15 downto 0) := (others => '0');
    signal framebuffer_0_dout2 : std_logic_vector (15 downto 0) := (others => '0');
    signal irMem_douta : std_logic_vector (31 downto 0) := (others => '0');
    signal my_alu_0_X : std_logic_vector (15 downto 0) := (others => '0');
    signal pixel_pusher_0_B : std_logic_vector (4 downto 0) := (others => '0');
    signal pixel_pusher_0_G : std_logic_vector (5 downto 0) := (others => '0');
    signal pixel_pusher_0_R : std_logic_vector (4 downto 0) := (others => '0');
    signal pixel_pusher_0_addr : std_logic_vector (11 downto 0) := (others => '0');
    signal regs_0_dout1 : std_logic_vector (15 downto 0) := (others => '0');
    signal regs_0_dout2 : std_logic_vector (15 downto 0) := (others => '0');
    signal uart_0_charRec : std_logic_vector (7 downto 0) := (others => '0');
    signal uart_0_newChar : std_logic := '0';
    signal uart_0_ready : std_logic := '0';
    signal uart_0_tx : std_logic := '1';
    signal vga_ctrl_0_hcount : std_logic_vector (9 downto 0) := (others => '0');
    signal vga_ctrl_0_hs : std_logic := '0';
    signal vga_ctrl_0_vid : std_logic := '0';
    signal vga_ctrl_0_vs : std_logic := '0';
    signal NLW_vga_ctrl_0_vcount_UNCONNECTED : std_logic_vector (9 downto 0) := (others => '0');

begin

    RXD_1 <= RXD;
    TXD <= uart_0_tx;
    btn_1 <= btn;
    clk_1 <= clk;
    vga_b(4 downto 0) <= pixel_pusher_0_B(4 downto 0);
    vga_g(5 downto 0) <= pixel_pusher_0_G(5 downto 0);
    vga_hs <= vga_ctrl_0_hs;
    vga_r(4 downto 0) <= pixel_pusher_0_R(4 downto 0);
    vga_vs <= vga_ctrl_0_vs;
    CTS <= 'Z';
    RTS <= 'Z';

    clock_div_cpu_0 : clock_div_cpu
    port map(
        clk => clk_1,
        div => clock_div_cpu_0_div
    );

    clock_div_vga_0 : clock_div_vga
    port map(
        clk => clk_1,
        div => clock_div_vga_0_div
    );

    controls_0 : controls
    port map(
        aluA(15 downto 0) => controls_0_aluA(15 downto 0),
        aluB(15 downto 0) => controls_0_aluB(15 downto 0),
        aluOp(3 downto 0) => controls_0_aluOp(3 downto 0),
        aluResult(15 downto 0) => my_alu_0_X(15 downto 0),
        charRec(7 downto 0) => uart_0_charRec(7 downto 0),
        charSend(7 downto 0) => controls_0_charSend(7 downto 0),
        clk => clk_1,
        dAddr(14 downto 0) => controls_0_dAddr(14 downto 0),
        dIn(15 downto 0) => dMem_douta(15 downto 0),
        dOut(15 downto 0) => controls_0_dOut(15 downto 0),
        d_wr_en => controls_0_d_wr_en,
        en => clock_div_cpu_0_div,
        fbAddr1(11 downto 0) => controls_0_fbAddr1(11 downto 0),
        fbDin1(15 downto 0) => framebuffer_0_dout1(15 downto 0),
        fbDout1(15 downto 0) => controls_0_fbDout1(15 downto 0),
        fbRST => controls_0_fbRST,
        fbWr_en => controls_0_fbWr_en,
        irAddr(13 downto 0) => controls_0_irAddr(13 downto 0),
        irWord(31 downto 0) => irMem_douta(31 downto 0),
        newChar => uart_0_newChar,
        rID1(4 downto 0) => controls_0_rID1(4 downto 0),
        rID2(4 downto 0) => controls_0_rID2(4 downto 0),
        ready => uart_0_ready,
        regrD1(15 downto 0) => regs_0_dout1(15 downto 0),
        regrD2(15 downto 0) => regs_0_dout2(15 downto 0),
        regwD1(15 downto 0) => controls_0_regwD1(15 downto 0),
        regwD2(15 downto 0) => controls_0_regwD2(15 downto 0),
        rst => debounce_0_dbnc,
        send => controls_0_send,
        wr_enR1 => controls_0_wr_enR1,
        wr_enR2 => controls_0_wr_enR2
    );

    dMem_0 : dMem
    port map(
        addra(14 downto 0) => controls_0_dAddr(14 downto 0),
        clka => clk_1,
        dina(15 downto 0) => controls_0_dOut(15 downto 0),
        douta(15 downto 0) => dMem_douta(15 downto 0),
        wea(0) => controls_0_d_wr_en
    );

    debounce_0 : debounce
    port map(
        btn => btn_1,
        clk => clk_1,
        dbnc => debounce_0_dbnc
    );

    framebuffer_0 : framebuffer
    port map(
        addr1(11 downto 0) => controls_0_fbAddr1(11 downto 0),
        addr2(11 downto 0) => pixel_pusher_0_addr(11 downto 0),
        clk1 => clk_1,
        din1(15 downto 0) => controls_0_fbDout1(15 downto 0),
        dout1(15 downto 0) => framebuffer_0_dout1(15 downto 0),
        dout2(15 downto 0) => framebuffer_0_dout2(15 downto 0),
        en1 => clock_div_cpu_0_div,
        en2 => clock_div_vga_0_div,
        ld => controls_0_fbRST,
        wr_en1 => controls_0_fbWr_en
    );

    irMem_0 : irMem
    port map(
        addra(13 downto 0) => controls_0_irAddr(13 downto 0),
        clka => clk_1,
        douta(31 downto 0) => irMem_douta(31 downto 0)
    );

    my_alu_0 : my_alu
    port map(
        A(15 downto 0) => controls_0_aluA(15 downto 0),
        B(15 downto 0) => controls_0_aluB(15 downto 0),
        X(15 downto 0) => my_alu_0_X(15 downto 0),
        clk => clk_1,
        en => clock_div_cpu_0_div,
        opcode(3 downto 0) => controls_0_aluOp(3 downto 0)
    );

    pixel_pusher_0 : pixel_pusher
    port map(
        B(4 downto 0) => pixel_pusher_0_B(4 downto 0),
        G(5 downto 0) => pixel_pusher_0_G(5 downto 0),
        R(4 downto 0) => pixel_pusher_0_R(4 downto 0),
        addr(11 downto 0) => pixel_pusher_0_addr(11 downto 0),
        clk => clk_1,
        en => clock_div_vga_0_div,
        hcount(9 downto 0) => vga_ctrl_0_hcount(9 downto 0),
        pixel(15 downto 0) => framebuffer_0_dout2(15 downto 0),
        vid => vga_ctrl_0_vid,
        vs => vga_ctrl_0_vs
    );

    regs_0 : regs
    port map(
        clk => clk_1,
        din1(15 downto 0) => controls_0_regwD1(15 downto 0),
        din2(15 downto 0) => controls_0_regwD2(15 downto 0),
        dout1(15 downto 0) => regs_0_dout1(15 downto 0),
        dout2(15 downto 0) => regs_0_dout2(15 downto 0),
        en => clock_div_cpu_0_div,
        id1(4 downto 0) => controls_0_rID1(4 downto 0),
        id2(4 downto 0) => controls_0_rID2(4 downto 0),
        rst => debounce_0_dbnc,
        wr_en1 => controls_0_wr_enR1,
        wr_en2 => controls_0_wr_enR2
    );

    uart_0 : uart
    port map(
        charRec(7 downto 0) => uart_0_charRec(7 downto 0),
        charSend(7 downto 0) => controls_0_charSend(7 downto 0),
        clk => clk_1,
        en => clock_div_cpu_0_div,
        newChar => uart_0_newChar,
        ready => uart_0_ready,
        rst => debounce_0_dbnc,
        rx => RXD_1,
        send => controls_0_send,
        tx => uart_0_tx
    );

    vga_ctrl_0 : vga_ctrl
    port map(
        clk => clk_1,
        en => clock_div_vga_0_div,
        hcount(9 downto 0) => vga_ctrl_0_hcount(9 downto 0),
        hs => vga_ctrl_0_hs,
        vcount(9 downto 0) => NLW_vga_ctrl_0_vcount_UNCONNECTED(9 downto 0),
        vid => vga_ctrl_0_vid,
        vs => vga_ctrl_0_vs
    );

end top;
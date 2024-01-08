LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY top IS
    PORT (
        CLOCK_50 : IN STD_LOGIC;
        KEY : IN STD_LOGIC;

        vga_clk: out std_logic;
        vga_hsync: out std_logic;
        vga_vsync: out std_logic;
        vga_blank_n: out std_logic;
        vga_r: out std_logic_vector(7 downto 0);
        vga_g: out std_logic_vector(7 downto 0);
        vga_b: out std_logic_vector(7 downto 0);

        led: out std_logic_vector(9 downto 0);

		HEX0 : OUT STD_LOGIC_VECTOR(0 TO 6);
		HEX1 : OUT STD_LOGIC_VECTOR(0 TO 6);
		HEX2 : OUT STD_LOGIC_VECTOR(0 TO 6);
		HEX3 : OUT STD_LOGIC_VECTOR(0 TO 6);
		HEX4 : OUT STD_LOGIC_VECTOR(0 TO 6);
		HEX5 : OUT STD_LOGIC_VECTOR(0 TO 6)
    );
END top;

ARCHITECTURE top_rtl OF top IS
    SIGNAL to_HEX_0 : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL to_HEX_1 : STD_LOGIC_VECTOR(31 DOWNTO 0);

    component nios is
        port (
            clk_clk                : in  std_logic := 'X';
            reset_reset_n          : in  std_logic := 'X';
            vga_output_vga_clk     : out std_logic;                   
            vga_output_vga_hsync   : out std_logic;                   
            vga_output_vga_vsync   : out std_logic;                   
            vga_output_vga_blank_n : out std_logic;                   
            vga_output_vga_r       : out std_logic_vector(7 downto 0);
            vga_output_vga_g       : out std_logic_vector(7 downto 0);
            vga_output_vga_b       : out std_logic_vector(7 downto 0);      
            vga_output_led         : out std_logic_vector(9 downto 0);
            to_hex_0_readdata      : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			to_hex_1_readdata      : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
        );
    end component nios;

    COMPONENT hex7seg IS
    PORT ( hex : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        display : OUT STD_LOGIC_VECTOR(0 TO 6) );
	END COMPONENT hex7seg;

BEGIN
    NiosII : nios port map (
        clk_clk                => CLOCK_50,
        reset_reset_n          => KEY,
        vga_output_vga_clk     => vga_clk,
        vga_output_vga_hsync   => vga_hsync,
        vga_output_vga_vsync   => vga_vsync,
        vga_output_vga_blank_n => vga_blank_n,
        vga_output_vga_r       => vga_r,
        vga_output_vga_g       => vga_g,
        vga_output_vga_b       => vga_b,
        vga_output_led         => led,

        to_hex_0_readdata      => to_HEX_0,
        to_hex_1_readdata      => to_HEX_1
    );

    h0: hex7seg PORT MAP (to_HEX_0(3 DOWNTO 0), HEX0);
    h1: hex7seg PORT MAP (to_HEX_0(7 DOWNTO 4), HEX1);
    h2: hex7seg PORT MAP (to_HEX_0(11 DOWNTO 8), HEX2);
    h3: hex7seg PORT MAP (to_HEX_0(15 DOWNTO 12), HEX3);
    h4: hex7seg PORT MAP (to_HEX_1(3 DOWNTO 0), HEX4);
    h5: hex7seg PORT MAP (to_HEX_1(7 DOWNTO 4), HEX5);
END top_rtl;
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

        led: out std_logic_vector(9 downto 0)
    );
END top;

ARCHITECTURE top_rtl OF top IS
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
            vga_output_led         : out std_logic_vector(9 downto 0)
        );
    end component nios;

    BEGIN
    NiosII : nios
        port map (
            clk_clk                => CLOCK_50,
            reset_reset_n          => KEY,
            vga_output_vga_clk     => vga_clk,
            vga_output_vga_hsync   => vga_hsync,
            vga_output_vga_vsync   => vga_vsync,
            vga_output_vga_blank_n => vga_blank_n,
            vga_output_vga_r       => vga_r,
            vga_output_vga_g       => vga_g,
            vga_output_vga_b       => vga_b,
            vga_output_led         => led
        );
END top_rtl;
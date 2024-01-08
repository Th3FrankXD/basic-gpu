library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity vga_timer is
port (
    clk			: in std_logic;
	reset		: in std_logic;

    vga_clk: out std_logic;
	vga_hsync: out std_logic;
	vga_vsync: out std_logic;
	vga_blank_n: out std_logic;
    h_active: out integer;
    v_active: out integer;
    h_count: out integer;
    v_count: out integer
);
end vga_timer;

architecture rtl of vga_timer is

component divider is
    port (
        clk: in std_logic;
        division: in integer;
        divclk: out std_logic
    );
end component;

signal vgaClk: std_logic;
signal hcount: integer := 0;
signal vcount: integer := 0;
signal activeX: integer := 0;
signal activeY: integer := 0;

begin
	 process(vgaClk)
	 begin
		if rising_edge(vgaClk) then
			if hcount = 799 then
				vcount <= vcount + 1;
				hcount <= 0;
				vga_hsync <= '0';
				activeX <= 0;
				if (vcount >= 33 and vcount < 512) then
					activeY <= activeY + 1;
				end if;
			elsif hcount > (799 - 96) then
				vga_hsync <= '0';
				hcount <= hcount + 1;
			else
				vga_hsync <= '1';
				hcount <= hcount + 1;
			end if;
			
			if vcount = 524 then
				vcount <= 0;
				vga_vsync <= '0';
				activeY <= 0;
			elsif vcount > (524 - 2) then
				vga_vsync <= '0';
			else
				vga_vsync <= '1';
			end if;

			if hcount >= 48 and hcount <= 687 and vcount >= 33 and vcount <= 512 then 
				vga_blank_n <= '1';
				activeX <= activeX + 1;
			else
				vga_blank_n <= '0';
			end if;
		end if;
	 end process;

	 div_clk: divider PORT MAP(clk=>clk, division=>2, divclk=>vgaClk);

	 vga_clk <= vgaClk;

     h_active <= activeX;
     v_active <= activeY;

     h_count <= hcount;
     v_count <= vcount;

end architecture;
library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity vga_controller is
port (
    avm_clk			: in std_logic;
	avm_reset		: in std_logic;
	avm_address		: out std_logic_vector(31 downto 0);
	avm_read		: out std_logic;
	avm_readdata	: in std_logic_vector(31 downto 0);
	avm_waitrequest	: in std_logic;

    vga_clk: out std_logic;
	vga_hsync: out std_logic;
	vga_vsync: out std_logic;
	vga_blank_n: out std_logic;
	vga_r: out std_logic_vector(7 downto 0);
	vga_g: out std_logic_vector(7 downto 0);
	vga_b: out std_logic_vector(7 downto 0);

	led: out std_logic_vector(9 downto 0);

	irq: out std_logic
);
end vga_controller;

architecture rtl of vga_controller is

component vga_timer is
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
end component;

signal vgaClk: std_logic;
signal data: std_logic_vector(31 downto 0);
signal read: std_logic := '0';
signal address: integer := 0;
signal pixel: std_logic := '0';
signal v_count: integer;
signal h_count: integer;
signal v_active: integer;
signal h_active: integer;
signal v_sync_buffer: std_logic;
signal reset: std_logic;

begin
    process(avm_clk)
    begin
        if rising_edge(avm_clk) then
			data <= avm_readdata;
        end if;
    end process;

	 process(vgaClk)
	 begin
		if rising_edge(vgaClk) then
			if v_count = 524 then
				address <= 0;
				pixel <= '0';
			end if;
			
			if pixel = '0' then
				vga_r <= data(3 downto 0) & "0000";
				vga_g <= data(7 downto 4) & "0000";
				vga_b <= data(11 downto 8) & "0000";
				pixel <= '1';
			else
				vga_r <= data(19 downto 16) & "0000";
				vga_g <= data(23 downto 20) & "0000";
				vga_b <= data(27 downto 24) & "0000";
				pixel <= '0';
			end if;
			address <= ((v_active/2)*(640/4)+(h_active/4)) * 4;
		end if;
	 end process;
	 
	avm_address <= std_logic_vector(to_unsigned(address, avm_address'length));

	led(7 downto 0) <= data(7 downto 0);
	led(9) <= avm_waitrequest;
	avm_read <= '1';

	vgaTimer: vga_timer PORT MAP(
		clk	=> avm_clk,
		reset => reset,
	
		vga_clk => vgaClk,
		vga_hsync => vga_hsync,
		vga_vsync => v_sync_buffer,
		vga_blank_n => vga_blank_n,
		h_active => h_active,
		v_active => v_active,
		h_count => h_count,
		v_count => v_count
	);

	vga_clk <= vgaClk;

	vga_vsync <= v_sync_buffer;
	irq <= v_sync_buffer;

end architecture;
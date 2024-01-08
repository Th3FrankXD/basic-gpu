library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gpu is
	PORT (
		clock, resetn : in std_logic;
		
		avs_address		: in std_logic;
		avs_write		: in std_logic;
		avs_writedata	: in std_logic_vector(31 downto 0);
		avs_read		: in std_logic;
		avs_readdata	: out std_logic_vector(31 downto 0);
		avs_waitrequest	: out std_logic;

		avm_address		: out std_logic_vector(31 downto 0);
		avm_write		: out std_logic;
		avm_writedata	: out std_logic_vector(31 downto 0);
		avm_waitrequest	: in std_logic
	);
end gpu;

architecture Structure of gpu is
signal command: std_logic_vector(31 downto 0);

begin
	process(clock) is
		variable address: integer;
		variable running: std_logic := '0';
		variable clear: std_logic := '0';
		variable xPos: integer range 0 to 511 := 0;
		variable yPos: integer range 0 to 511 := 0;
		variable size: integer range 0 to 254 := 0;
		variable color: std_logic_vector(31 downto 0);
		variable xCount: integer := 0;
		variable yCount: integer := 0;
	begin
		if rising_edge(clock) then
			if running = '0' and avs_write = '1' then
				command <= avs_writedata;
				running := '1';
				if command(19 downto 17) = "000" then
					color := "0000" & command(31 downto 20) & "0000" & command(31 downto 20);
					clear := '1';
					address := 0;
				else
					color := "0000" & command(31 downto 20) & "0000" & command(31 downto 20);
					size := to_integer(unsigned(command(19 downto 17)))*2;
					xPos := to_integer(unsigned(command(16 downto 8)));
					yPos := to_integer(unsigned(command(7 downto 0)));
					address := (((yPos - size)*320) + (xPos - size))*2;
				end if;
				avm_address <= std_logic_vector(to_unsigned(address, avm_address'length));
				xCount := 0;
				yCount := 0;
			end if;
			if running = '1' and avm_waitrequest = '0' then
				if clear = '1' then
					if xCount < (320*240) then
						avm_address <= std_logic_vector(to_unsigned(address, avm_address'length));
						avm_writedata <= color;
						xCount := xCount + 2;
						address := address + 4;
					else
						clear := '0';
						running := '0';
					end if;
				elsif yCount < (size*2) then
					if xCount < (size*2) then
						avm_address <= std_logic_vector(to_unsigned(address, avm_address'length));
						avm_writedata <= color;
						xCount := xCount + 2;
						address := address + 4;
					else
						address := address + ((320 - (size*2))*2);
						avm_address <= std_logic_vector(to_unsigned(address, avm_address'length));
						yCount := yCount + 1;
						xCount := 0;
					end if;
				else
					running := '0';
				end if;
			end if;
		end if;
		avs_waitrequest <= running;
	end process;
	avm_write <= '1';
end Structure;
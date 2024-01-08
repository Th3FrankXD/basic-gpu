LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY reg32_avalon_interface IS
	PORT ( clock, resetn : IN STD_LOGIC;
		read, write, chipselect : IN STD_LOGIC;
		address : IN STD_LOGIC;
		writedata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		byteenable : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		readdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		Q_export0 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		Q_export1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) );
END reg32_avalon_interface;

ARCHITECTURE Structure OF reg32_avalon_interface IS
	SIGNAL local_byteenable : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL to_reg, from_reg0, from_reg1 : STD_LOGIC_VECTOR(31 DOWNTO 0);

	COMPONENT reg32
		PORT ( clock, resetn : IN STD_LOGIC;
			D : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			byteenable : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			Q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) );
	END COMPONENT;
BEGIN
	local_byteenable(3 DOWNTO 0) <= byteenable WHEN (address = '0' AND chipselect = '1' AND write = '1') ELSE "0000";
	local_byteenable(7 DOWNTO 4) <= byteenable WHEN (address = '1' AND chipselect = '1' AND write = '1') ELSE "0000";

	reg0: reg32 PORT MAP (clock, resetn, to_reg, local_byteenable(3 DOWNTO 0), from_reg0);
	reg1: reg32 PORT MAP (clock, resetn, to_reg, local_byteenable(7 DOWNTO 4), from_reg1);
	
	to_reg <= writedata;
	readdata <= from_reg0 WHEN (address = '0' AND chipselect = '1' AND read = '1') ELSE
				from_reg1 WHEN (address = '1' AND chipselect = '1' AND read = '1') ELSE
				(OTHERS => '0');
	Q_export1 <= from_reg0;
	Q_export0 <= from_reg1;
END Structure;
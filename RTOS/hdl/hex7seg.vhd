LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY hex7seg IS
	PORT ( hex : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		display : OUT STD_LOGIC_VECTOR(0 TO 6) );
END hex7seg;

ARCHITECTURE Behavior OF hex7seg IS
BEGIN
	--		- 0 -
	--	5 |	  | 1
	--		- 6 -
	--	4 |	  | 2
	--		- 3 -
	PROCESS (hex)
	BEGIN
		CASE hex IS
			WHEN "0000" => display <= "0000001";
			WHEN "0001" => display <= "1001111";
			WHEN "0010" => display <= "0010010";
			WHEN "0011" => display <= "0000110";
			WHEN "0100" => display <= "1001100";
			WHEN "0101" => display <= "0100100";
			WHEN "0110" => display <= "0100000";
			WHEN "0111" => display <= "0001111";
			WHEN "1000" => display <= "0000000";
			WHEN "1001" => display <= "0001100";
			WHEN "1010" => display <= "0001000";
			WHEN "1011" => display <= "1100000";
			WHEN "1100" => display <= "0110001";
			WHEN "1101" => display <= "1000010";
			WHEN "1110" => display <= "0110000";
			WHEN "1111" => display <= "0111000";
		END CASE;
	END PROCESS;
END Behavior;
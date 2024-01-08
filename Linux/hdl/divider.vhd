library ieee;
use ieee.std_logic_1164.all;
entity divider is
port (
    clk: in std_logic;
    division: in integer;
    divclk: out std_logic
);
end divider;

architecture rtl of divider is

begin
    process(clk)
    variable currentCount: integer := 0;
    variable newClk: std_logic := '0';
    begin
        if rising_edge(clk) then
            if currentCount = division / 2 then
                currentCount := 0;
                newClk := NOT newClk;
                divclk <= newClk;
            end if;
            currentCount := currentCount + 1;
        end if;
    end process;
end architecture;
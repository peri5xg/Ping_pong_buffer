library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity for_mult is
    port(
        clk      : in  std_logic;
        a_data : in unsigned(22 downto 0);
        b_data : in unsigned(22 downto 0);
        OUT_data : out unsigned(22 downto 0)
    );
end entity;

architecture multip of for_mult is
signal sign_a : unsigned(0 downto 0);
signal E_a: unsigned(3 downto 0);
signal mantisa_a: unsigned(17 downto 0);

signal sign_b : unsigned(0 downto 0);
signal E_b: unsigned(3 downto 0);
signal mantisa_b: unsigned(17 downto 0);

signal sign_OUT: unsigned(0 downto 0);
signal E_OUT: unsigned(3 downto 0);
signal mantisa_OUT: unsigned(37 downto 0);
signal mantisa_OUT_END: unsigned(17 downto 0);
begin
    sign_a <= a_data(22 downto 22);
    E_a <= a_data(21 downto 18);
    mantisa_a <= a_data(17 downto 0);
    
    sign_b <= b_data(22 downto 22);
    E_b       <= b_data(21 downto 18);
    mantisa_b <= b_data(17 downto 0);
    
    sign_OUT    <= sign_a xor sign_b;
    mantisa_OUT <= ('1' & mantisa_a) * ('1' & mantisa_b); 
    
   mantisa_OUT_END <= mantisa_OUT(35 downto 18) when mantisa_OUT(37 downto 36) = "00" or mantisa_OUT(37 downto 36) = "01" 
   else   mantisa_OUT(36 downto 19);
   
   E_OUT <= (E_a + E_b) - 7 when mantisa_OUT(37) = '0' else 
             (E_a + E_b) - 6;
   
    
 process(clk)
    begin
        if rising_edge(clk) then
            
            if a_data(21 downto 0) = "0000000000000000000000" or b_data(21 downto 0) = "0000000000000000000000" then
                OUT_data <= (others => '0');
            else
                OUT_data <= sign_OUT & E_OUT & mantisa_OUT_END;
            end if;
        end if;
    end process;
   end multip;
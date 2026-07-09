library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity complex is
    port(
        clk      : in  std_logic;
        a_R : in unsigned(22 downto 0);
        a_I : in unsigned(22 downto 0);
        
        b_R : in unsigned(22 downto 0);
        b_I : in unsigned(22 downto 0);

        OUT_R : out unsigned(22 downto 0);
        OUT_I : out unsigned(22 downto 0)
    );
end entity;

architecture complex_mult of complex is

component for_mult
        port(
            clk      : in  std_logic;
            a_data   : in  unsigned(22 downto 0);
            b_data   : in  unsigned(22 downto 0);
            OUT_data : out unsigned(22 downto 0)
        );
    end component;
 component for_plusTEST
 generic (
        is_minus : boolean := false
    );
        port(
            clk      : in  std_logic;
            a_data   : in  unsigned(22 downto 0);
            b_data   : in  unsigned(22 downto 0);
            OUT_data : out unsigned(22 downto 0)
        );
    end component;   
    
    component for_minus
        port(
            clk      : in  std_logic;
           a_data   : in  unsigned(22 downto 0);
           b_data   : in  unsigned(22 downto 0);
            OUT_data : out unsigned(22 downto 0)
        );
    end component;
    
    
    signal A_B_r,A_B_i,A_B_ir,A_B_ri :  unsigned(22 downto 0); 
    signal AB_Re, AB_Im :  unsigned(22 downto 0); 
    
    begin
    
    inst_mult_RR: for_mult port map (  
        clk      => clk,
        a_data   => A_R,
        b_data   => B_R,
        OUT_data => A_B_r
    );
    
    inst_mult_II: for_mult port map ( 
        clk      => clk,
        a_data   => A_I,
        b_data   => B_I,
        OUT_data => A_B_i
    );
    
    inst_mult_IR: for_mult port map (  
        clk      => clk,
        a_data   => A_I,
        b_data   => B_R,
        OUT_data => A_B_ir
    );
    
    inst_mult_RI: for_mult port map (  
        clk      => clk,
        a_data   => A_R,
        b_data   => B_I,
        OUT_data => A_B_ri
    );
    
   -- minus_for_Re: for_minus port map ( 
     --  clk      => clk,
      --  a_data   => A_B_r,
       -- b_data   => A_B_i,
       -- OUT_data => AB_Re
    --);
    
  minus_for_Re:for_plus_and_minuss
    generic map (
    is_minus => true
)
     port map (  
       clk      => clk,
        a_data   => A_B_r,
       b_data   => A_B_i,
       OUT_data => AB_Re
    ); 
   
    Plus_for_Ie:for_plus_and_minuss
    generic map (
    is_minus => false
)
      port map (  
        clk      => clk,
        a_data   => A_B_ri,
        b_data   => A_B_ir,
        OUT_data => AB_Im
    );
    
    OUT_R <= AB_Re;
    OUT_I <= AB_Im;
    
end complex_mult;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top is
    generic(
        DATA_WIDTH : integer := 23;
        Block_size : integer := 10
    );
    port(
        clk      : in std_logic;
        rst      : in std_logic;
        enable   : in std_logic;

        a_data   : in std_logic_vector(DATA_WIDTH-1 downto 0)
       
    );
end entity;

architecture rtl of top is

    signal wr_rdy  : std_logic_vector(1 downto 0);
    signal wr_act  : std_logic_vector(1 downto 0);
    signal wr_size : std_logic_vector(9 downto 0);
    --signal wr_stb  : std_logic;
    signal wr_data : std_logic_vector(DATA_WIDTH-1 downto 0);

begin



u_source : entity work.ppfifo_source
generic map(
    DATA_WIDTH => DATA_WIDTH,
    Block_size => Block_size
)
port map(

    clk      => clk,
    rst      => rst,
    i_enable => enable,

    a_data => a_data,

    i_wr_rdy  => wr_rdy,
    o_wr_act  => wr_act,
    i_wr_size => wr_size,
    --o_wr_stb  => wr_stb,
    o_wr_data => wr_data
);



u_fifo : entity work.fifo
generic map(
    DATA_WIDTH => DATA_WIDTH,
    Block_size => Block_size
)
port map(

    clk => clk,
    rst => rst,

    --a_data => a_data,

    write_ready  => wr_rdy,
    write_active => wr_act,
    write_size   => wr_size,
    --write_strob  => wr_stb,
    write_data   => wr_data
);

end architecture;
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ppfifo_source IS
    GENERIC (
        DATA_WIDTH : INTEGER := 23;
        Block_size : INTEGER := 10
    );
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        i_enable : IN STD_LOGIC;

        a_data : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);

        i_wr_rdy : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        o_wr_act : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        i_wr_size : IN STD_LOGIC_VECTOR(9 DOWNTO 0);--?
        --o_wr_stb  : out std_logic;
        o_wr_data : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE rtl OF ppfifo_source IS

    SIGNAL r_count : unsigned(Block_size - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL wr_act_reg : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL wr_stb_reg : STD_LOGIC := '0';
    SIGNAL wr_data_reg : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');

BEGIN

    o_wr_act <= wr_act_reg;
    --o_wr_stb  <= wr_stb_reg;
    o_wr_data <= wr_data_reg;

    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            --wr_stb_reg <= '0';

            IF rst = '1' THEN
                wr_act_reg <= (OTHERS => '0');
                --wr_stb_reg  <= '0';
                wr_data_reg <= (OTHERS => '0');
                r_count <= (OTHERS => '0');

            ELSE

                IF i_enable = '1' THEN

                    IF (unsigned(i_wr_rdy) > 0) AND (unsigned(wr_act_reg) = 0) THEN

                        r_count <= (OTHERS => '0');

                        IF i_wr_rdy(0) = '1' THEN
                            -- Channel 0 is open
                            wr_act_reg <= "01";
                        ELSE
                            -- Channel 1 is open
                            wr_act_reg <= "10";
                        END IF;

                    ELSIF unsigned(wr_act_reg) > 0 THEN

                        IF r_count < unsigned(i_wr_size) THEN
                            r_count <= r_count + 1;
                            --wr_stb_reg <= '1';

                            wr_data_reg <= a_data;

                        ELSE
                            wr_act_reg <= (OTHERS => '0');

                        END IF;

                    END IF;
                ELSE
                    wr_act_reg <= (OTHERS => '0');
                    r_count <= (OTHERS => '0');
                    wr_data_reg <= (OTHERS => '0');
                END IF;

            END IF;

        END IF;
    END PROCESS;

END ARCHITECTURE;
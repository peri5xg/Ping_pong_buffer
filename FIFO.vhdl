LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY fifo IS
    GENERIC (
        DATA_WIDTH : INTEGER := 23;
        Block_size : INTEGER := 10
    );
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;

        --a_data : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);

        write_ready : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        write_active : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        write_size : out std_logic_vector(9 downto 0);
        --write_strob : IN STD_LOGIC;
        write_data : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0)
    );
END ENTITY;
ARCHITECTURE fifo_work OF fifo IS

    SIGNAL count_words : unsigned(9 DOWNTO 0) := (OTHERS => '0');
    SIGNAL write_ready_reg : STD_LOGIC_VECTOR(1 DOWNTO 0) := "01";
    --SIGNAL write_size_reg :  std_logic_vector(9 downto 0) := "0000001010";

    TYPE ram_t IS ARRAY (0 TO Block_size - 1) OF STD_LOGIC_VECTOR(22 DOWNTO 0);
    SIGNAL BUFFER0 : ram_t;
    SIGNAL BUFFER1 : ram_t;

BEGIN

    write_ready <= write_ready_reg;
    write_size <= std_logic_vector(to_unsigned(Block_size, write_size'length));

    PROCESS(clk)
BEGIN
    IF rising_edge(clk) THEN
        IF rst = '1' THEN
            write_ready_reg <= "01";
            count_words <= (OTHERS => '0');

        ELSE

            
            IF (write_ready_reg(0) = '1') AND (write_active(0) = '1') THEN

                IF count_words < to_unsigned(Block_size, count_words'length) THEN
                    BUFFER0(to_integer(count_words)) <= write_data;
                    count_words <= count_words + 1;
                ELSE
                    write_ready_reg <= "10";
                    count_words <= (OTHERS => '0');
                END IF;


            
            ELSIF (write_ready_reg(1) = '1') AND (write_active(1) = '1') THEN

                IF count_words < to_unsigned(Block_size, count_words'length) THEN
                    BUFFER1(to_integer(count_words)) <= write_data;
                    count_words <= count_words + 1;
                ELSE
                    write_ready_reg <= "01";
                    count_words <= (OTHERS => '0');
                END IF;

            END IF;

        END IF;
    END IF;
END PROCESS;
END ARCHITECTURE;
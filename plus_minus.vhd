LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY for_plus_and_minuss IS
    GENERIC (
        is_minus : BOOLEAN := false
    );

    PORT (
        clk : IN STD_LOGIC;
        a_data : IN unsigned(22 DOWNTO 0);
        b_data : IN unsigned(22 DOWNTO 0);
        OUT_data : OUT unsigned(22 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE plus_and_minuss OF for_plus_and_minuss IS
    SIGNAL sign_a : unsigned(0 DOWNTO 0);
    SIGNAL E_a : unsigned(3 DOWNTO 0);
    SIGNAL mantisa_a : unsigned(18 DOWNTO 0);

    SIGNAL sign_b : unsigned(0 DOWNTO 0);
    SIGNAL E_b : unsigned(3 DOWNTO 0);
    SIGNAL mantisa_b : unsigned(18 DOWNTO 0);

    SIGNAL sign_OUT : unsigned(0 DOWNTO 0);
    SIGNAL E_OUT : unsigned(3 DOWNTO 0);

    SIGNAL E_dOBLE : unsigned(3 DOWNTO 0);

    SIGNAL mantisa_OUT : unsigned(18 DOWNTO 0);
    SIGNAL mantisa_OUT_END : unsigned(19 DOWNTO 0);
    SIGNAL mantisa : unsigned(17 DOWNTO 0);

BEGIN

    sign_a <= a_data(22 DOWNTO 22);
    E_a <= a_data(21 DOWNTO 18);
    mantisa_a <= '1' & a_data(17 DOWNTO 0);

    sign_b <= NOT (b_data(22 DOWNTO 22)) WHEN is_minus
        ELSE
        b_data(22 DOWNTO 22);

    E_b <= b_data(21 DOWNTO 18);
    mantisa_b <= '1' & b_data(17 DOWNTO 0);

    mantisa_out <= shift_right(mantisa_b, to_integer(E_a - E_b)) WHEN E_a > E_b ELSE -- ñàìî âûðàâíèâàíèå
        shift_right(mantisa_a, to_integer(E_b - E_a)) WHEN E_b > E_a ELSE
        mantisa_a;

    MANTISA_PROCESS : PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF b_data(21 DOWNTO 0) = 0 AND a_data(21 DOWNTO 0) = 0 THEN
                mantisa_OUT_END <= (OTHERS => '0');
                sign_OUT <= (OTHERS => '0');

            ELSIF a_data(21 DOWNTO 0) = 0 THEN
                IF is_minus THEN
                    sign_OUT <= NOT b_data(22 DOWNTO 22);
                        ELSE
                        sign_OUT <= b_data(22 DOWNTO 22);
                END IF;
                mantisa_OUT_END <= "01" & b_data(17 DOWNTO 0);

            ELSIF b_data(21 DOWNTO 0) = 0 THEN

                sign_OUT <= a_data(22 DOWNTO 22);
                mantisa_OUT_END <= "01" & a_data(17 DOWNTO 0);

            ELSIF sign_a = sign_b THEN

                IF E_a = E_b THEN
                    mantisa_OUT_END <= resize(mantisa_a, 20) + resize(mantisa_b, 20);
                    sign_OUT <= sign_a;
                ELSIF E_a > E_b THEN
                    mantisa_OUT_END <= resize(mantisa_a, 20) + resize(mantisa_out, 20);
                    sign_OUT <= sign_a;
                ELSE
                    mantisa_OUT_END <= resize(mantisa_b, 20) + resize(mantisa_out, 20);
                    sign_OUT <= sign_b;

                END IF;
            ELSE
                IF E_a = E_b THEN

                    IF mantisa_a >= mantisa_b THEN
                        mantisa_OUT_END <= resize(mantisa_a, 20) - resize(mantisa_b, 20);
                        sign_OUT <= sign_a;
                    ELSE
                        mantisa_OUT_END <= resize(mantisa_b, 20) - resize(mantisa_a, 20);
                        sign_OUT <= sign_b;
                    END IF;

                ELSIF E_a > E_b THEN
                    mantisa_OUT_END <= resize(mantisa_a, 20) - resize(mantisa_out, 20);
                    sign_OUT <= sign_a;
                ELSE
                    mantisa_OUT_END <= resize(mantisa_b, 20) - resize(mantisa_out, 20);
                    sign_OUT <= sign_b;

                END IF;
            END IF;
        END IF;

    END PROCESS MANTISA_PROCESS;
    
    -- E_OUT <= E_a when E_a > E_b else E_b;
    E_DOBLE <= E_a WHEN E_a > E_b ELSE
        E_b;

    PROCESS (mantisa_OUT_END, E_DOBLE)

        VARIABLE v_mantisa : unsigned(19 DOWNTO 0);
        VARIABLE v_E : unsigned(3 DOWNTO 0);

    BEGIN
        v_mantisa := mantisa_OUT_END;
        v_E := E_DOBLE;

        IF v_mantisa(19 DOWNTO 18) = "00" THEN
            FOR i IN 0 TO 18 LOOP
                IF v_mantisa(19 DOWNTO 18) = "01" OR v_E = 0 THEN
                    EXIT;
                END IF;

                IF v_mantisa = 0 THEN
                    v_E := (OTHERS => '0');
                    v_mantisa := (OTHERS => '0');
                    --sign_OUT <="0";
                    EXIT;
                END IF;

                v_mantisa := shift_left(v_mantisa, 1);
                v_E := v_E - 1;
            END LOOP;

            mantisa <= v_mantisa(17 DOWNTO 0);
            E_OUT <= v_E;

        ELSIF v_mantisa(19 DOWNTO 18) = "01" THEN

            mantisa <= v_mantisa(17 DOWNTO 0);
            E_OUT <= v_E;

        ELSIF v_mantisa(19) = '1' THEN

            mantisa <= v_mantisa(18 DOWNTO 1);
            E_OUT <= v_E + 1;

        END IF;
    END PROCESS;
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF mantisa = 0 THEN
                OUT_data <= "0" & E_OUT & mantisa;
            ELSE
                OUT_data <= sign_OUT & E_OUT & mantisa;
            END IF;
        END IF;
    END PROCESS;

END plus_and_minuss;
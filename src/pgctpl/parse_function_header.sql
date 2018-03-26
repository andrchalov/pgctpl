
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgctpl.parse_function_header(
  IN a_src text,
  OUT title text
)
  LANGUAGE plpgsql
AS $$
--
-- Функция парсинга заголовка тела функции.
--
DECLARE
  v_header text NOT NULL = '';
  v_line text;
  v_regexp text[];
  v_val text;
BEGIN
  v_regexp = regexp_matches(a_src, E'--\s*\n--([^\n]+)\n--\s*\n');

  title = trim(v_regexp[1]);
END;
$$;
--------------------------------------------------------------------------------

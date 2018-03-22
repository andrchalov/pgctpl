
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgctpl.parse_function_footer(a_src text)
  RETURNS json
  LANGUAGE plpgsql
AS $$
--
-- Функция возвращает footer тела функции в json формате и null если его нет.
-- Footer должен быть определен как комментарий в теле которого yaml.
--
DECLARE
  v_header text NOT NULL = '';
	v_line text;
	v_regexp text[];
	v_val text;
BEGIN
  v_regexp = regexp_matches(a_src, 'END;\s+\/\*(.*)\*\/\s+$');

  IF v_regexp[1] NOTNULL THEN
    RETURN pgctpl.yaml_to_json(v_regexp[1]);
  END IF;

  RETURN null;
END;
$$;
--------------------------------------------------------------------------------


-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgctpl._scan()
  RETURNS void
  LANGUAGE plpgsql
AS $function$
--
-- Сканирует все схемы и находит в них определения шаблонов.
-- Заполняет таблицу func всеми функциями, имеющими шаблоны.
-- Заполняет таблицу template всеми найденными шаблонами.
--
DECLARE
  v_func record;
  v_title text;
  v_template record;
BEGIN
  FOR v_func IN
    SELECT nspname||'.'||proname AS fullname, nspname, proname, prosrc
      FROM pg_catalog.pg_proc p
      JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
      LEFT JOIN pg_catalog.pg_description d ON p.oid = d.objoid
  LOOP
    v_title = pgctpl._parse_function_header(v_func.prosrc);

    FOR v_template IN
      SELECT * FROM pgctpl._parse_function(v_func.prosrc)
    LOOP
      INSERT INTO pgctpl.func (nspname, proname, title)
        VALUES (v_func.nspname, v_func.proname, v_title)
        ON CONFLICT ON CONSTRAINT func_pkey DO NOTHING;

      INSERT INTO pgctpl.template (
          code, nspname, proname, nm, descr, data, vars, type,
          definition
        )
        VALUES (
          v_template.code,
          v_func.nspname,
          v_func.proname,
          v_template.name,
          v_template.descr,
          v_template.data,
          v_template.vars,
          v_template.tp,
          v_template.definition
        );
    END LOOP;
  END LOOP;
END;
$function$;
-------------------------------------------------------------------------------

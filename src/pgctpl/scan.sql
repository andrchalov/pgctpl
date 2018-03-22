
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgctpl.scan()
  RETURNS void
  LANGUAGE plpgsql
AS $function$
--
-- Функция сканирует все функции схемы и находит в них определения
-- контент-шаблонов, добавляет в таблицу
--
DECLARE
  v_func record;
  v_footer json;
  v_template record;
  v_template_type_nm text;
  v_vars text[];
BEGIN
  FOR v_func IN
    SELECT nspname||'.'||proname AS fullname, nspname, proname, prosrc
      FROM pg_catalog.pg_proc p
      JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
      LEFT JOIN pg_catalog.pg_description d ON p.oid = d.objoid
  LOOP
    v_footer = pgctpl.parse_function_footer(v_func.prosrc);

    IF v_footer NOTNULL THEN
      FOR v_template IN
        SELECT key AS code, value FROM json_each(v_footer)
      LOOP
        SELECT nm
          FROM pgctpl.template_type
          WHERE nm = v_template.value->>'type'
          INTO v_template_type_nm;
        --
        IF NOT found THEN
          RAISE 'PGCTPL: template type "%" is not defined',
            v_template.value->>'type';
        END IF;

        IF v_template.value->'vars' NOTNULL THEN
          SELECT array_agg(
            CASE json_typeof(value)
              WHEN 'string' THEN value #>> '{}'
              WHEN 'object' THEN value->>'name'
              ELSE value::text
            END
          )
          FROM json_array_elements(v_template.value->'vars')
          INTO v_vars;
        ELSE
          v_vars = '{}';
        END IF;

        INSERT INTO pgctpl.template (
            code, fn_scheme, fn_name, nm, descr, body, vars, template_type,
            definition
          )
          VALUES (
            v_template.code,
            v_func.nspname,
            v_func.proname,
            v_template.value->>'name',
            v_template.value->>'descr',
            v_template.value->>'body',
            v_vars,
            v_template_type_nm,
            v_template.value
          );
      END LOOP;
    END IF;
  END LOOP;
END;
$function$;
-------------------------------------------------------------------------------

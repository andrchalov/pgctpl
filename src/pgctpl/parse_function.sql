
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgctpl.parse_function(text)
  RETURNS TABLE (
    code varchar(4),
    name text,
    descr text,
    data hstore,
    vars hstore,
    tp text,
    definition json
  )
  LANGUAGE plpgsql
AS $function$
DECLARE
  v_footer json;
  v_template record;
  v_template_type_nm text;
  v_vars hstore;
  v_body hstore;
BEGIN
  v_footer = pgctpl.parse_function_footer($1);

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
        CASE json_typeof(v_template.value->'vars')
          WHEN 'array' THEN
            SELECT hstore(
                    array_agg(array[
                      CASE json_typeof(value)
                        WHEN 'string' THEN value #>> '{}'
                        WHEN 'object' THEN value->>'name'
                        ELSE value::text
                      END,
                      CASE json_typeof(value)
                        WHEN 'string' THEN ''
                        WHEN 'object' THEN COALESCE(value->>'descr', '')
                        ELSE value::text
                      END]
                    )
                  )
              FROM json_array_elements(v_template.value->'vars')
              INTO v_vars;
          WHEN 'object' THEN
            SELECT hstore(
                    array_agg(key),
                    array_agg(value)
                   )
              FROM json_each_text(v_template.value->'vars')
              INTO v_vars;
          ELSE
            RAISE 'PGCTPL: Unsupported vars format';
        END CASE;
      ELSE
        v_vars = '';
      END IF;

      CASE json_typeof(v_template.value->'body')
        WHEN 'string' THEN
          v_body = hstore('default', v_template.value->>'body');
        WHEN 'array' THEN
          SELECT hstore(array_agg(key), array_agg(value))
            FROM (
              SELECT (json_each_text(a)).*
                FROM json_array_elements(v_template.value->'body') a
            ) AS foo
            INTO v_body;
        WHEN 'object' THEN
          SELECT hstore(array_agg(key), array_agg(
              CASE json_typeof(value)
                WHEN 'string' THEN
                  value #>> '{}'
                WHEN 'object' THEN
                  value->>'data'
                ELSE
                  value::text
              END::text
            ))
            FROM json_each(v_template.value->'body')
            INTO v_body;
        ELSE
          RAISE 'bug';
      END CASE;

      RETURN QUERY
        SELECT
          v_template.code::varchar(4),
          v_template.value->>'name',
          v_template.value->>'descr',
          v_body,
          v_vars,
          v_template_type_nm,
          v_template.value;
    END LOOP;
  END IF;
END;
$function$;
-------------------------------------------------------------------------------

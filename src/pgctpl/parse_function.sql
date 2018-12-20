
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgctpl.parse_function(text)
  RETURNS TABLE (
    code varchar(4),
    name text,
    descr text,
    data hstore,
    vars hstore,
    tp text,
    definition jsonb
  )
  LANGUAGE plpgsql
AS $function$
DECLARE
  v_footer jsonb;
  v_template record;
  v_template_type_nm text;
  v_vars hstore;
  v_body hstore;
BEGIN
  v_footer = pgctpl.parse_function_footer($1);

  IF v_footer NOTNULL THEN
    FOR v_template IN
      SELECT key::varchar(4) AS code, value FROM jsonb_each(v_footer)
    LOOP
      SELECT nm
        FROM pgctpl.template_type
        WHERE nm = COALESCE(v_template.value->>'type', 'default')
        INTO v_template_type_nm;
      --
      IF NOT found THEN
        IF v_template.value->>'type' ISNULL THEN
          RAISE 'PGCTPL: template type for "%" is not specified and "default" template type is not defined',
            v_template.code;
        ELSE
          RAISE 'PGCTPL: template type "%" is not defined',
            v_template.value->>'type';
        END IF;
      END IF;

      IF v_template.value->'vars' NOTNULL THEN
        CASE jsonb_typeof(v_template.value->'vars')
          WHEN 'array' THEN
            SELECT hstore(
                    array_agg(array[
                      CASE jsonb_typeof(value)
                        WHEN 'string' THEN value #>> '{}'
                        WHEN 'object' THEN value->>'name'
                        ELSE value::text
                      END,
                      CASE jsonb_typeof(value)
                        WHEN 'string' THEN ''
                        WHEN 'object' THEN COALESCE(value->>'descr', '')
                        ELSE value::text
                      END]
                    )
                  )
              FROM jsonb_array_elements(v_template.value->'vars')
              INTO v_vars;
          WHEN 'object' THEN
            SELECT hstore(
                    array_agg(key),
                    array_agg(value)
                   )
              FROM jsonb_each_text(v_template.value->'vars')
              INTO v_vars;
          ELSE
            RAISE 'PGCTPL: Unsupported vars format';
        END CASE;
      ELSE
        v_vars = '';
      END IF;

      v_body = ''::hstore;

      CASE jsonb_typeof(v_template.value)
        WHEN 'string' THEN
          v_body = hstore('default', v_template.value#>>'{}');
        ELSE
          IF v_template.value ? 'body' THEN
            CASE jsonb_typeof(v_template.value->'body')
              WHEN 'string' THEN
                v_body = hstore('default', v_template.value->>'body');
              WHEN 'array' THEN
                SELECT hstore(array_agg(key), array_agg(value))
                  FROM (
                    SELECT (jsonb_each_text(a)).*
                      FROM jsonb_array_elements(v_template.value->'body') a
                  ) AS foo
                  INTO v_body;
              WHEN 'object' THEN
                SELECT hstore(array_agg(key), array_agg(
                    CASE jsonb_typeof(value)
                      WHEN 'string' THEN
                        value #>> '{}'
                      WHEN 'object' THEN
                        value->>'data'
                      ELSE
                        value #>> '{}'
                    END::text
                  ))
                  FROM jsonb_each(v_template.value->'body')
                  INTO v_body;
              ELSE
                RAISE 'bug';
            END CASE;
          ELSE
            v_body = hstore('default', null);
          END IF;
      END CASE;

      DECLARE
        v_block text = null;
      BEGIN
        SELECT f.block
          FROM pgctpl_body_filler f
          WHERE f.code = v_template.code
            AND v_body->(f.block) NOTNULL
          LIMIT 1
          INTO v_block;
        --
        IF found THEN
          RAISE 'Duplicate template <%> body block <%> definition in '
            '"pgctpl_body_filler" and in function footer',
            v_template.code, v_block;
        END IF;
      END;

      DECLARE
        v_block text;
        v_value text;
      BEGIN
        FOR v_block, v_value IN
          SELECT block, value
            FROM pgctpl_body_filler f
            WHERE f.code = v_template.code
        LOOP
          IF NOT v_body ? v_block THEN
            RAISE 'Missing block <%> definition in template <%>', v_block, v_template.code;
          END IF;

          v_body = v_body || hstore(v_block, v_value);

          IF v_template.code = 'STHT' THEN
            /* RAISE '! %', v_value; */
          END IF;
        END LOOP;
      END;

      RETURN QUERY
        SELECT
          v_template.code,
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

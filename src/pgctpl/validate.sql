
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgctpl.validate(
  a_body hstore,
  a_template pgctpl.template
)
  RETURNS text
	LANGUAGE plpgsql
AS $function$
--
-- Validate template body
--
-- Проверка на содержание всех переменных и допустимых плейсхолдеров, возвращает
-- текст ошибки или null.
--
DECLARE
  v_template_type pgctpl.template_type;
  v_key text;
  v_val text;
  v_missing_vars text[];
  v_unknown_vars text[];
	v_data_vars text[];					 -- найденные в теле переменные шаблона
	v_data_placeholders text[];	 -- найденные в теле системные плейсхолдеры
	v_unknown_placeholders text[];
  v_merged_data text;
BEGIN
  SELECT * INTO v_template_type
    FROM pgctpl.template_type
    WHERE nm = a_template.template_type;
  --
  IF NOT found THEN
    RETURN format('Template type %L not found', a_template.template_type);
  END IF;

  FOR v_key, v_val IN SELECT * FROM each(a_body)
  LOOP
    IF v_val ISNULL THEN
      RETURN 'Empty data for block '||v_key;
    END IF;
  END LOOP;

  SELECT COALESCE(string_agg(v, ' '), '')
    FROM svals(a_body) v
    INTO STRICT v_merged_data;

 	v_data_vars = pgctpl.find_placeholders(v_merged_data, '<\$', '\$>');

  FOR v_key, v_val IN SELECT * FROM each(a_body)
  LOOP
    IF NOT COALESCE((a_template.definition->'body'->v_key->>'ignore_missing_vars')::boolean, false)
    THEN
      SELECT array_agg(e)
        FROM (
          select skeys(a_template.vars)
          except
          select unnest(pgctpl.find_placeholders(v_val, '<\$', '\$>'))
        ) t (e)
        INTO v_missing_vars;

      IF array_length(v_missing_vars, 1) > 0 THEN
        RETURN 'Missing var: "'||array_to_string(v_missing_vars, ',')||'" in body block "'||v_key||'"';
      END IF;
    END IF;
  END LOOP;

  SELECT array_agg(e)
    FROM (
      select unnest(v_data_vars)
      except
      select skeys(a_template.vars)
    ) t (e)
    INTO v_unknown_vars;

  IF array_length(v_unknown_vars, 1) > 0 THEN
    RETURN 'Unknown var: "'||array_to_string(v_unknown_vars, ',')||'" in template body';
  END IF;

 	v_data_placeholders = pgctpl.find_placeholders(v_merged_data, '<@', '@>');

	SELECT array_agg(e) INTO v_unknown_placeholders
	  FROM (
		  SELECT unnest(v_data_placeholders)
			EXCEPT
			SELECT unnest(v_template_type.placeholders)
		) t (e);

	IF v_unknown_placeholders NOTNULL THEN
    RETURN format('Unknown placeholders: "%L" in template definition',
      array_to_string(v_unknown_placeholders, ','));
	END IF;

	RETURN null;
END;
$function$;
--------------------------------------------------------------------------------

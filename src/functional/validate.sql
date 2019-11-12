
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgctpl.validate(
  a_template pgctpl.template,
  a_custom_data hstore DEFAULT null
)
  RETURNS text
	LANGUAGE plpgsql
AS $function$
--
-- Validate template
--
-- Проверка на содержание всех переменных и допустимых плейсхолдеров, возвращает
-- текст ошибки или null.
--
DECLARE
  v_data hstore NOT NULL = COALESCE(a_custom_data, a_template.data);
  v_type pgctpl.type;
  v_key text;
  v_val text;
  v_missing_vars text[];
  v_unknown_vars text[];
	v_data_vars text[];					   -- найденные в теле переменные
	v_data_placeholders text[];	   -- найденные в теле плейсхолдеры
	v_unknown_placeholders text[];
  v_merged_data text;
BEGIN
  SELECT * INTO v_type
    FROM pgctpl.type
    WHERE nm = a_template.type;
  --
  IF NOT found THEN
    RETURN format('Template type %L not found', a_template.type);
  END IF;

  FOR v_key, v_val IN SELECT * FROM each(v_data)
  LOOP
    IF v_val ISNULL THEN
      RETURN format('Empty data for block `%L`', v_key);
    END IF;
  END LOOP;

  SELECT COALESCE(string_agg(v, ' '), '')
    FROM svals(v_data) v
    INTO STRICT v_merged_data;

 	v_data_vars = pgctpl._find_placeholders(v_merged_data, v_type.var_prefix, v_type.var_suffix);

  FOR v_key, v_val IN SELECT * FROM each(v_data)
  LOOP
    IF NOT COALESCE((a_template.definition->'body'->v_key->>'ignore_missing_vars')::boolean, false)
    THEN
      SELECT array_agg(e)
        FROM (
          SELECT skeys(a_template.vars || v_type.global_vars)
          EXCEPT
          SELECT unnest(pgctpl._find_placeholders(v_val, v_type.var_prefix, v_type.var_suffix))
        ) t (e)
        INTO v_missing_vars;

      IF array_length(v_missing_vars, 1) > 0 THEN
        RETURN 'Missing var'||CASE WHEN array_length(v_missing_vars, 1) > 1 THEN 's' ELSE '' END||': '||array_to_string(v_missing_vars, ',')||' in body block `'||v_key||'`';
      END IF;
    END IF;
  END LOOP;

  SELECT array_agg(e)
    FROM (
      select unnest(v_data_vars)
      except
      select skeys(a_template.vars || v_type.global_vars)
    ) t (e)
    INTO v_unknown_vars;

  IF array_length(v_unknown_vars, 1) > 0 THEN
    RETURN 'Unknown var: "'||array_to_string(v_unknown_vars, ',')||'" in template body';
  END IF;

 	v_data_placeholders = pgctpl._find_placeholders(
    v_merged_data,
    v_type.placeholder_prefix,
    v_type.placeholder_suffix
  );

	SELECT array_agg(e) INTO v_unknown_placeholders
	  FROM (
		  SELECT unnest(v_data_placeholders)
			EXCEPT
			SELECT unnest(v_type.placeholders)
		) t (e);

	IF v_unknown_placeholders NOTNULL THEN
    RETURN format('Unknown placeholders: "%L" in template definition',
      array_to_string(v_unknown_placeholders, ','));
	END IF;

	RETURN null;
END;
$function$;
--------------------------------------------------------------------------------

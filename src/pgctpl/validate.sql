
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgctpl.validate(
  a_data hstore,
  a_vars text[],
  a_placeholders text[]
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
  v_missing_vars text[];
  v_unknown_vars text[];
	v_template_data_vars text[];					 -- найденные в теле переменные шаблона
	v_template_data_placeholders text[];	 -- найденные в теле системные плейсхолдеры
	v_unknown_placeholders text[];
  v_merged_data text;
BEGIN
  SELECT COALESCE(string_agg(v, ' '), '')
    FROM svals(a_data) v
    INTO STRICT v_merged_data;

 	v_template_data_vars = pgctpl.find_placeholders(v_merged_data, '<\$', '\$>');

  SELECT array_agg(e)
    FROM (
      select unnest(a_vars)
      except
      select unnest(v_template_data_vars)
    ) t (e)
    INTO v_missing_vars;

  IF array_length(v_missing_vars, 1) > 0 THEN
    RETURN 'Missing var: "'||array_to_string(v_missing_vars, ',')||'" in template body';
  END IF;

  SELECT array_agg(e)
    FROM (
      select unnest(v_template_data_vars)
      except
      select unnest(a_vars)
    ) t (e)
    INTO v_unknown_vars;

  IF array_length(v_unknown_vars, 1) > 0 THEN
    RETURN 'Unknown var: "'||array_to_string(v_unknown_vars, ',')||'" in template body';
  END IF;

 	v_template_data_placeholders = pgctpl.find_placeholders(v_merged_data, '<@', '@>');

	SELECT array_agg(e) INTO v_unknown_placeholders
	  FROM (
		  SELECT unnest(v_template_data_placeholders)
			EXCEPT
			SELECT unnest(a_placeholders)
		) t (e);

	IF v_unknown_placeholders NOTNULL THEN
    RETURN format('Unknown placeholders: "%L" in template definition',
      array_to_string(v_unknown_placeholders, ','));
	END IF;

	RETURN null;
END;
$function$;
--------------------------------------------------------------------------------

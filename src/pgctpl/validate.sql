
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgctpl.validate(
  a_body text,
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
	v_template_body_vars text[];					 -- найденные в теле переменные шаблона
	v_template_body_placeholders text[];	 -- найденные в теле системные плейсхолдеры
	v_unknown_placeholders text[];
BEGIN
 	v_template_body_vars = pgctpl.find_placeholders(a_body, '<\$', '\$>');

  SELECT array_agg(e)
    FROM (
      select unnest(v_template_body_vars)
      except
      select unnest(a_vars)
    ) t (e)
    INTO v_missing_vars;

  IF array_length(v_missing_vars, 1) > 0 THEN
    RETURN format('Missing vars "%L" in template definition',
      array_to_string(v_missing_vars, ','));
  END IF;

 	v_template_body_placeholders = pgctpl.find_placeholders(a_body, '<@', '@>');

	SELECT array_agg(e) INTO v_unknown_placeholders
	  FROM (
		  SELECT unnest(v_template_body_placeholders)
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

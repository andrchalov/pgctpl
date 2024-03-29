
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgctpl.blocks(
  a_code varchar(6),
  a_context text DEFAULT NULL,
  a_vars hstore DEFAULT ''::hstore,
  a_custom_data hstore DEFAULT NULL
)
  RETURNS hstore
  LANGUAGE plpgsql
AS $function$
DECLARE
  v_code varchar(4);
  v_template record;
  v_missing_vars text[];
  v_unknown_vars text[];
  v_template_type record;
  v_data hstore;
  v_placeholders hstore;
  v_result hstore;
BEGIN
  IF a_code ISNULL THEN
    PERFORM 'PGCTPL: code argument is not defined';
  END IF;

  IF a_vars ISNULL THEN
    PERFORM 'PGCTPL: vars argument should not be null';
  END IF;

  IF NOT a_code SIMILAR TO '\%[A-Z0-9]{4}\%' THEN
    RAISE 'PGCTPL: Wrong template code format: "%", should be like "%%[A-Z0-9]{4}%%"', a_code;
  END IF;

  v_code = substring(a_code from 2 for 4);

  -- поиск шаблона
  SELECT *
    FROM pgctpl.template
    WHERE code = v_code
    INTO v_template;
  --
  IF NOT found THEN
    RAISE 'PGCTPL: template by code "%" not found', v_code;
  END IF;

  -- поиск типа шаблона
  SELECT *
    FROM pgctpl.type
    WHERE nm = v_template.type
    INTO STRICT v_template_type;

  IF a_custom_data ISNULL THEN
    v_data = v_template.data;
  ELSE
    v_data = a_custom_data;
  END IF;

  -- переданные переменные должны соответствовать переменным шаблона
	IF akeys(a_vars) <> akeys(v_template.vars || v_template_type.global_vars) THEN
		-- в аргументе a_vars что-то не так
		-- сформируем понятную ошибку

  	-- найти, пропущенные в аргументе a_vars, обязательные переменные
  	SELECT COALESCE(array_agg(e), '{}')
	    FROM (
		  	SELECT unnest(akeys(v_template.vars))
			  EXCEPT
			  SELECT skeys(a_vars)
      ) t (e)
			INTO STRICT v_missing_vars;

  	IF array_length(v_missing_vars, 1) > 0 THEN
      RAISE 'PGCTPL: missing variables: "%" in a_vars argument',
        array_to_string(v_missing_vars, ',');
	  END IF;

  	-- найти, лишние аргументы в a_vars
	  SELECT COALESCE(array_agg(e), '{}')
	    FROM (
			  SELECT skeys(a_vars)
			  EXCEPT
			  SELECT unnest(akeys(v_template.vars))
      ) t (e)
			INTO STRICT v_unknown_vars;

		IF array_length(v_unknown_vars, 1) > 0 THEN
      RAISE 'PGCTPL: unknown variables: "%" in a_vars argument',
        array_to_string(v_unknown_vars, ',');
		END IF;

		RAISE 'PGCTPL: bug in pgctpl.blocks()';
	END IF;

  EXECUTE format(
    $$
      SELECT placeholders
        FROM %I.%I(%L);
    $$,
    v_template_type.handler_nspname, v_template_type.handler_proname, a_context
  ) INTO v_placeholders;

  -- в результирующий v_data добавим значения по-умолчанию для
  -- непереопределенных блоков
  SELECT hstore(array_agg(t.key), array_agg(COALESCE(NULLIF(trim(d.value), ''), t.value)))
    FROM each(v_template.data) t
    LEFT JOIN each(v_data) d ON t.key = d.key
    INTO v_data;

  SELECT hstore(
      array_agg(key),
      array_agg(
        pgctpl._embed_placeholders(
          pgctpl._embed_placeholders(value, a_vars, v_template_type.var_prefix, v_template_type.var_suffix),
          v_placeholders,
          v_template_type.placeholder_prefix, v_template_type.placeholder_suffix
        )
      )
    )
    FROM each(v_data)
    INTO v_result;

  RETURN v_result;
END;
$function$;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgctpl.blocks(
  varchar(6),int,hstore DEFAULT '',hstore DEFAULT NULL
)
  RETURNS hstore
  LANGUAGE sql
AS $function$
SELECT pgctpl.blocks($1,$2::text,$3,$4);
$function$;
-------------------------------------------------------------------------------

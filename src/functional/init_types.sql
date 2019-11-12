
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgctpl._init_types()
  RETURNS void
  LANGUAGE plpgsql
AS $function$
--
-- Найти функции, определяющие типы шаблонов
--
DECLARE
  v_current_user_oid oid;
  v_typefunc record;            -- функция, объявляющая тип шаблона
BEGIN
  SELECT oid INTO STRICT v_current_user_oid
    FROM pg_roles
    WHERE rolname = current_user;

  FOR v_typefunc IN
    SELECT nspname||'.'||proname AS fullname, nspname, proname, prosrc
      FROM pg_catalog.pg_proc p
      JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
      LEFT JOIN pg_catalog.pg_description d ON p.oid = d.objoid
      WHERE proname ~ '^pgctpl_declare_type__(.+)'
        AND proowner = v_current_user_oid   -- for security reasons
  LOOP
    DECLARE
      v_typefunc_result record;
      v_typefunc_result_map hstore;
      v_unknown_out_params text[];
    BEGIN
      EXECUTE 'SELECT * FROM '||
        quote_ident(v_typefunc.nspname)||'.'||quote_ident(v_typefunc.proname)||'()'
        INTO STRICT v_typefunc_result;

      v_typefunc_result_map = hstore(v_typefunc_result);

      SELECT array_agg(key) INTO v_unknown_out_params
        FROM each(v_typefunc_result_map)
        WHERE key <> ALL ('{placeholders,placeholder_prefix,placeholder_suffix,var_prefix,var_suffix}');

      IF array_length(v_unknown_out_params, 1) > 0 THEN
        RAISE 'Bad function `%` declaration, unknown out params: %',
          v_typefunc.fullname, array_to_string(v_unknown_out_params, ',');
      END IF;

      INSERT INTO pgctpl.type (
        nm, handler_nspname, handler_proname, placeholders,
        placeholder_prefix, placeholder_suffix, var_prefix, var_suffix
      ) VALUES (
        regexp_replace(v_typefunc.proname, '^pgctpl_declare_type__', ''),
        v_typefunc.nspname, v_typefunc.proname, akeys(v_typefunc_result.placeholders),
        COALESCE(v_typefunc_result_map->'placeholder_prefix', '<@'),
        COALESCE(v_typefunc_result_map->'placeholder_suffix', '@>'),
        COALESCE(v_typefunc_result_map->'var_prefix', '<\$'),
        COALESCE(v_typefunc_result_map->'var_suffix', '\$>')
      );
    END;
  END LOOP;
END;
$function$;
-------------------------------------------------------------------------------

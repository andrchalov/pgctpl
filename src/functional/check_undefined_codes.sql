
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgctpl.check_undefined_codes()
  RETURNS void
  LANGUAGE plpgsql
AS $function$
--
-- Prevent undefined template codes in functions
--
-- Чтобы быть уверенным, что все коды сообщений, используемые в функциях
-- определены в шаблонах, функция сканирует все тела функций по регулярному
-- выражению соответствующему кодам и удостоверяется что все найденные шаблоны
-- определены.
--
-- TODO: Можно даже проверить что он определен именно для этой функции,
-- таким образом это обеспечит проверку что функции не используют сообщения из
-- других функций
--
DECLARE
  v_func record;
  v_undefined_code varchar(4);
BEGIN
  FOR v_func IN
    SELECT nspname||'.'||proname AS fullname, nspname, proname, prosrc
      FROM pg_catalog.pg_proc p
      JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
      LEFT JOIN pg_catalog.pg_description d ON p.oid = d.objoid
  LOOP
    SELECT r[1]
      FROM regexp_matches(v_func.prosrc, '%([A-Z0-9]{4})%', 'g') r
      LEFT JOIN pgctpl.template t ON r[1] = t.code
      WHERE t ISNULL
      LIMIT 1
      INTO v_undefined_code;
    --
    IF FOUND THEN
      RAISE 'Content template code "%" is undefined in function "%"',
        v_undefined_code, v_func.fullname;
    END IF;
  END LOOP;
END;
$function$;
-------------------------------------------------------------------------------

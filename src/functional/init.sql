--
-- PGCTPL.init
--

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgctpl.init()
  RETURNS void
  LANGUAGE plpgsql
AS $function$
BEGIN
  TRUNCATE pgctpl.template CASCADE;
  TRUNCATE pgctpl.func CASCADE;
  TRUNCATE pgctpl.type CASCADE;
  
  PERFORM pgctpl._init_types();
  PERFORM pgctpl._scan();
  PERFORM pgctpl.check_undefined_codes();
END;
$function$;
-------------------------------------------------------------------------------

--
-- PGCTPL.init
--

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgctpl.init()
  RETURNS void
  LANGUAGE plpgsql
AS $function$
BEGIN
  PERFORM pgctpl.scan();
  PERFORM pgctpl.check_undefined_codes();
END;
$function$;
-------------------------------------------------------------------------------

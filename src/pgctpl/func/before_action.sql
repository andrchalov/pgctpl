
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgctpl.func_before_action()
  RETURNS trigger
  LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.mo = now();

	RETURN NEW;
END;
$function$;
--------------------------------------------------------------------------------

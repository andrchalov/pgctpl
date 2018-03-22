
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgctpl.template_type_before_action()
  RETURNS trigger
  LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.mo = now();

	RETURN NEW;
END;
$function$;
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgctpl.template_before_action()
  RETURNS trigger
  LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.mo = now();
	NEW.vars = pgctpl.find_placeholders(NEW.body, '<\$', '\$>');

	RETURN NEW;
END;
$function$;
--------------------------------------------------------------------------------

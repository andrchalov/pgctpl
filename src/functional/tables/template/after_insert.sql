
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgctpl.template_after_insert()
  RETURNS trigger
  LANGUAGE plpgsql
AS $function$
DECLARE
  v_validation_error text;
BEGIN
  v_validation_error = pgctpl.validate(NEW);

  IF v_validation_error NOTNULL THEN
    RAISE 'PGCTPL: % in template `%`', v_validation_error, NEW.code;
  END IF;

  RETURN NEW;
END;
$function$;
-------------------------------------------------------------------------------

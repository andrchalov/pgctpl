
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgctpl.template_after_constr()
  RETURNS trigger
  LANGUAGE plpgsql
AS $function$
DECLARE
  v_placeholders text[];
  v_validation_error text;
BEGIN
  v_validation_error = pgctpl.validate(NEW.data, NEW);

  IF v_validation_error NOTNULL THEN
    RAISE 'PGCTPL: % in template `%`', v_validation_error, NEW.code;
  END IF;

  IF EXISTS(
    SELECT
      FROM pgctpl.template
      WHERE mo <> now()
      LIMIT 1
  ) THEN
    RAISE 'PGCTPL: All templates should be added only in one transaction!';
  END IF;

  RETURN NEW;
END;
$function$;
-------------------------------------------------------------------------------

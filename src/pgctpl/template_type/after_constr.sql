
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgctpl.template_type_after_constr()
  RETURNS trigger
  LANGUAGE plpgsql
AS $function$
BEGIN
  IF EXISTS(
    SELECT
      FROM pgctpl.template_type
      WHERE mo <> now()
      LIMIT 1
  ) THEN
    RAISE 'PGCTPL: All template types should be added only in one transaction!';
  END IF;

  RETURN NEW;
END;
$function$;
-------------------------------------------------------------------------------

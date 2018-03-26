
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgctpl.func_after_constr()
  RETURNS trigger
  LANGUAGE plpgsql
AS $function$
BEGIN
  IF EXISTS(
    SELECT
      FROM pgctpl.func
      WHERE mo <> now()
      LIMIT 1
  ) THEN
    RAISE 'PGCTPL: All functions should be added only in one transaction!';
  END IF;

  RETURN NEW;
END;
$function$;
-------------------------------------------------------------------------------

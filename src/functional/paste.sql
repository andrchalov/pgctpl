
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgctpl.paste(
  a_code varchar(6),
  a_context text DEFAULT NULL,
  a_vars hstore DEFAULT ''::hstore,
  a_block text DEFAULT 'default'
)
  RETURNS text
  LANGUAGE plpgsql
AS $function$
DECLARE
  v_result text;
BEGIN
  v_result = (pgctpl.blocks(a_code, a_context, a_vars))->a_block;

  IF v_result ISNULL THEN
    RAISE 'PGCTPL: block `%` not specified in template %', a_block, a_code;
  END IF;

  RETURN v_result;
END;
$function$;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgctpl.paste(varchar(6),int,hstore DEFAULT '',text DEFAULT 'default')
  RETURNS text
  LANGUAGE sql
AS $function$
SELECT pgctpl.paste($1,$2::text,$3,$4);
$function$;
-------------------------------------------------------------------------------

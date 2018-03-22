
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgctpl.template_type_add(
  a_nm text,
  a_placeholders text[],
  a_handler_func text DEFAULT NULL
)
  RETURNS void
  LANGUAGE plpgsql
AS $function$
BEGIN
  INSERT INTO pgctpl.template_type (nm, handler_func, placeholders)
    VALUES (a_nm, a_handler_func, a_placeholders);
END;
$function$;
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgctpl.template_type_add(
  a_nm text,
  a_placeholders text[],
  a_handler_func text DEFAULT NULL,
  a_placeholder_prefix text DEFAULT '<@',
  a_placeholder_suffix text DEFAULT '@>',
  a_var_prefix text DEFAULT '<\$',
  a_var_suffix text DEFAULT '\$>',
  a_global_vars hstore DEFAULT ''
)
  RETURNS void
  LANGUAGE plpgsql
AS $function$
BEGIN
  INSERT INTO pgctpl.template_type (
    nm, handler_func, placeholders, placeholder_prefix, placeholder_suffix,
    var_prefix, var_suffix, global_vars
  ) VALUES (
    a_nm, a_handler_func, a_placeholders, a_placeholder_prefix,
    a_placeholder_suffix, a_var_prefix, a_var_suffix, a_global_vars
  );
END;
$function$;
-------------------------------------------------------------------------------

/* -------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgctpl.template_type_add(hstore)
  RETURNS void
  LANGUAGE sql
AS $function$
SELECT pgctpl.template_type_add()
$function$;
------------------------------------------------------------------------------- */

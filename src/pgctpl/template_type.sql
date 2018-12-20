
--------------------------------------------------------------------------------
CREATE TABLE pgctpl.template_type (
  nm text NOT NULL,
  handler_func text,
  placeholders text[] NOT NULL DEFAULT '{}',   -- допустимые плейсхолдеры
                                               -- они нужны для валидации шаблона на этапе добавления
  placeholder_prefix text NOT NULL,
  placeholder_suffix text NOT NULL,
  var_prefix text NOT NULL,
  var_suffix text NOT NULL,
  global_vars hstore NOT NULL,
  mo timestamp with time zone NOT NULL,
	CONSTRAINT template_type_pkey PRIMARY KEY (nm)
);
--------------------------------------------------------------------------------

\ir template_type/after_constr.sql
\ir template_type/before_action.sql
\ir template_type/add.sql

--------------------------------------------------------------------------------
CREATE TRIGGER t000b_action
  BEFORE INSERT
  ON pgctpl.template_type
  FOR EACH ROW
  EXECUTE PROCEDURE pgctpl.template_type_before_action();
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
CREATE CONSTRAINT TRIGGER t600a_constr
  AFTER INSERT
  ON pgctpl.template_type
  FOR EACH ROW
  EXECUTE PROCEDURE pgctpl.template_type_after_constr();
--------------------------------------------------------------------------------

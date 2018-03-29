--
-- PGCTPL.func
--

--------------------------------------------------------------------------------
CREATE TABLE pgctpl.func (
  fn_scheme text NOT NULL,         -- function schema
  fn_name text NOT NULL,           -- function name
  /* fullname text NOT NULL, */
  title text,
  mo timestamp with time zone NOT NULL,
	CONSTRAINT func_pkey PRIMARY KEY (fn_scheme, fn_name)
);
--------------------------------------------------------------------------------

\ir func/before_action.sql
\ir func/after_constr.sql

--------------------------------------------------------------------------------
CREATE TRIGGER t000b_action
 BEFORE INSERT
 ON pgctpl.func
 FOR EACH ROW
 EXECUTE PROCEDURE pgctpl.func_before_action();
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
CREATE CONSTRAINT TRIGGER t600a_constr
 AFTER INSERT
 ON pgctpl.func
 FOR EACH ROW
 EXECUTE PROCEDURE pgctpl.func_after_constr();
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Deny delete from table
CREATE RULE d AS ON DELETE TO pgctpl.func DO INSTEAD NOTHING;
--------------------------------------------------------------------------------

--
-- PGCTPL.template
--

--------------------------------------------------------------------------------
CREATE TABLE pgctpl.template (
  code varchar(4) NOT NULL,
  fn_scheme text NOT NULL,         -- function schema
  fn_name text NOT NULL,           -- function name
  nm text,
  descr text,
	body text NOT NULL,
	vars text[] NOT NULL,
	template_type text NOT NULL,
  definition json NOT NULL,
  mo timestamp with time zone NOT NULL,
	CONSTRAINT template_pkey PRIMARY KEY (code),
  CONSTRAINT template_fkey0 FOREIGN KEY (template_type)
    REFERENCES pgctpl.template_type (nm)
    MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION
);
/* COMMENT ON TABLE sys.ctpl IS 'Контент-шаблоны'; */
--------------------------------------------------------------------------------

\ir template/before_action.sql
\ir template/after_constr.sql

--------------------------------------------------------------------------------
CREATE TRIGGER t000b_action
 BEFORE INSERT
 ON pgctpl.template
 FOR EACH ROW
 EXECUTE PROCEDURE pgctpl.template_before_action();
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
CREATE CONSTRAINT TRIGGER t600a_constr
 AFTER INSERT
 ON pgctpl.template
 FOR EACH ROW
 EXECUTE PROCEDURE pgctpl.template_after_constr();
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Deny to change table
CREATE RULE u AS ON UPDATE TO pgctpl.template DO INSTEAD NOTHING;
CREATE RULE d AS ON DELETE TO pgctpl.template DO INSTEAD NOTHING;
--------------------------------------------------------------------------------

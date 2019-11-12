--
-- PGCTPL.template
--

--------------------------------------------------------------------------------
CREATE TABLE pgctpl.template (
  mo timestamptz NOT NULL DEFAULT now(),
  code varchar(4) NOT NULL,
  nspname text NOT NULL,           -- function schema
  proname text NOT NULL,           -- function name
  nm text,
  descr text,
  data hstore NOT NULL,
	vars hstore NOT NULL,
	type text NOT NULL,
  definition json NOT NULL,

	CONSTRAINT template_pkey PRIMARY KEY (code),
  CONSTRAINT template_fkey0 FOREIGN KEY (nspname, proname)
    REFERENCES pgctpl.func (nspname, proname)
    MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT template_fkey1 FOREIGN KEY (type)
    REFERENCES pgctpl.type (nm)
    MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION
);
ALTER TABLE pgctpl.template OWNER TO :"schema_owner";
--------------------------------------------------------------------------------

\ir template/after_insert.sql

--------------------------------------------------------------------------------
CREATE TRIGGER after_insert
 AFTER INSERT
 ON pgctpl.template
 FOR EACH ROW
 EXECUTE PROCEDURE pgctpl.template_after_insert();
--------------------------------------------------------------------------------

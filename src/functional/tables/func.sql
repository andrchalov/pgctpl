--
-- PGCTPL.func
--

--------------------------------------------------------------------------------
CREATE TABLE pgctpl.func (
  mo timestamptz NOT NULL DEFAULT now(),
  nspname text NOT NULL,
  proname text NOT NULL,
  title text,
  
	CONSTRAINT func_pkey PRIMARY KEY (nspname, proname)
);
ALTER TABLE pgctpl.func OWNER TO :"schema_owner";
--------------------------------------------------------------------------------

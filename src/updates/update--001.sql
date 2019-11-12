--
-- PGCTPL
-- update--001.sql
--

--------------------------------------------------------------------------------
CREATE SCHEMA _pgctpl AUTHORIZATION :"schema_owner";
REVOKE ALL ON SCHEMA _pgctpl FROM public;
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
CREATE TABLE _pgctpl.bigbody(
  code varchar(4) NOT NULL,
  block text NOT NULL DEFAULT 'default',
  value text NOT NULL,

  CONSTRAINT bigbody_pkey PRIMARY KEY (code, block),
  CONSTRAINT bigbody_chk0 CHECK (value <> '')
);
ALTER TABLE _pgctpl.bigbody OWNER TO :"schema_owner";
--------------------------------------------------------------------------------

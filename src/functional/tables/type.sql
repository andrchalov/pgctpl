--
-- PGCTPL.type
--

--------------------------------------------------------------------------------
CREATE TABLE pgctpl.type (
  mo timestamptz NOT NULL DEFAULT now(),
  nm text NOT NULL,
  handler_nspname text NOT NULL,
  handler_proname text NOT NULL,

  placeholders text[] NOT NULL,   -- допустимые плейсхолдеры, они нужны для
                                  -- валидации шаблона на этапе добавления
  placeholder_prefix text NOT NULL,
  placeholder_suffix text NOT NULL,
  var_prefix text NOT NULL,
  var_suffix text NOT NULL,
  global_vars hstore NOT NULL DEFAULT '',

	CONSTRAINT type_pkey PRIMARY KEY (nm)
);
ALTER TABLE pgctpl.type OWNER TO :"schema_owner";
--------------------------------------------------------------------------------

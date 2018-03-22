--
-- pgctpl.json_to_text_array()
--

--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgctpl.json_to_text_array(json)
  RETURNS text[]
	IMMUTABLE
	LANGUAGE sql
AS $$
SELECT COALESCE(array_agg(s), NULLIF(ARRAY[($1->>0)::text], '{NULL}'))
  FROM json_array_elements_text($1) s
  WHERE json_typeof($1) = 'array'
$$;
--------------------------------------------------------------------------------

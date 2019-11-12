
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgctpl._embed_placeholders(
  a_text text,
	a_data hstore,
	a_prefix text,
	a_suffix text
)
  RETURNS text
  LANGUAGE sql
AS $function$
WITH RECURSIVE r (n, txt) AS (
	SELECT 1, a_text
  UNION ALL
	SELECT n+1, regexp_replace(txt,
														 a_prefix||E'\\s*'||k[n]||E'\\s*'||a_suffix,
														 COALESCE(v[n], ''), 'g')
    FROM r, (SELECT akeys(COALESCE(a_data,'')) k, avals(COALESCE(a_data, '')) v) foo
		WHERE n <= array_length(k, 1)
)
SELECT txt FROM r ORDER BY n DESC LIMIT 1
$function$;
--------------------------------------------------------------------------------

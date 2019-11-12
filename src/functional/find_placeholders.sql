
--------------------------------------------------------------------------------
CREATE FUNCTION pgctpl._find_placeholders(txt_ text, prefix_ text, suffix_ text)
 RETURNS text[]
 LANGUAGE sql
 STRICT
AS $function$
/*
 * Find placeholders in text.
 *
 * Placeholder format can be customized by specify prefix and suffix. Key format
 * is "[a-z0-9_]+".
 * For prefix '<@' and suffix '@>' placeholders format is <@\s*[a-z0-9_]+\s*@>
 * example: <@ some_key @>, <@var@>, ...
 */
SELECT COALESCE(array_agg(r[1]), '{}'::text[])
  FROM regexp_matches($1, $2 || E'\\s*([a-z0-9_\.]+)\\s*' || $3, 'g') r;
$function$;
--------------------------------------------------------------------------------

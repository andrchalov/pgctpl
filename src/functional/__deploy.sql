--
-- PGCTPL deploy
--

--------------------------------------------------------------------------------
CREATE SCHEMA pgctpl AUTHORIZATION :"schema_owner";
--------------------------------------------------------------------------------

\ir yaml_to_json.sql

SET SESSION AUTHORIZATION :"schema_owner";

\ir tables/type.sql
\ir tables/func.sql
\ir tables/template.sql

\ir check_undefined_codes.sql
\ir embed_placeholders.sql
\ir find_placeholders.sql
\ir json_to_text_array.sql
\ir parse_function_footer.sql
\ir parse_function_header.sql
\ir parse_function.sql

\ir validate.sql
\ir init_types.sql
\ir init.sql
\ir scan.sql
\ir blocks.sql
\ir paste.sql

SELECT pgctpl.init();

RESET SESSION AUTHORIZATION;

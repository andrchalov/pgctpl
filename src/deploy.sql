--
-- PGCTPL deploy
--

--------------------------------------------------------------------------------
CREATE SCHEMA pgctpl;
--
COMMENT ON SCHEMA pgctpl IS 'Content templates';
--------------------------------------------------------------------------------

\ir pgctpl/check_undefined_codes.sql
\ir pgctpl/embed_placeholders.sql
\ir pgctpl/find_placeholders.sql
\ir pgctpl/init.sql
\ir pgctpl/json_to_text_array.sql
\ir pgctpl/parse_function_footer.sql
\ir pgctpl/paste.sql
\ir pgctpl/scan.sql
\ir pgctpl/template_type.sql
\ir pgctpl/template.sql
\ir pgctpl/validate.sql
\ir pgctpl/yaml_to_json.sql
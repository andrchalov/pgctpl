
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgctpl.yaml_to_json(a_in text)
  RETURNS json
  LANGUAGE plpythonu
AS $function$
import yaml
import json
# try:
return json.dumps(yaml.load(a_in));
#except Exception as exc:
#  raise Exception(a_in)
$function$;
-------------------------------------------------------------------------------

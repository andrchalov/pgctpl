
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgctpl.yaml_to_json(a_in text)
  RETURNS json
  LANGUAGE plpython3u
AS $function$
import yaml
import json
return json.dumps(yaml.load(a_in));
$function$;
-------------------------------------------------------------------------------

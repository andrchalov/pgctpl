
CREATE TEMPORARY TABLE pgctpl_body_filler(
  code varchar(4) NOT NULL,
  block text NOT NULL DEFAULT 'default',
  value text NOT NULL,
  CONSTRAINT body_filler_ukey0 UNIQUE (code, block),
  CONSTRAINT body_filler_chk0 CHECK (value <> '')
);

GRANT INSERT ON TABLE pgctpl_body_filler TO PUBLIC;

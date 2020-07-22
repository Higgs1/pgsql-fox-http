-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION http" to load this file. \quit

CREATE DOMAIN http_version NUMERIC(2, 1)
DEFAULT 1.0;

CREATE TYPE http_header AS (
    field VARCHAR,
    value VARCHAR
);

CREATE TYPE http_response AS (
    status  INTEGER,
    content_type TEXT,
    headers http_header[],
    content TEXT
);

CREATE TYPE http_request AS (
    method  TEXT,
    uri     TEXT,
    version http_version,
    headers http_header[],
    content TEXT
);

CREATE OR REPLACE FUNCTION http_set_curlopt (curlopt VARCHAR, value VARCHAR) 
    RETURNS boolean
    AS 'MODULE_PATHNAME', 'http_set_curlopt'
    LANGUAGE 'c';

CREATE OR REPLACE FUNCTION http_reset_curlopt () 
    RETURNS boolean
    AS 'MODULE_PATHNAME', 'http_reset_curlopt'
    LANGUAGE 'c';

CREATE OR REPLACE FUNCTION http_header (field VARCHAR, value VARCHAR) 
    RETURNS http_header
    AS $$ SELECT $1, $2 $$ 
    LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION http(request http_request)
    RETURNS http_response
    AS 'MODULE_PATHNAME', 'http_request'
    LANGUAGE 'c';

CREATE OR REPLACE FUNCTION http_get(uri VARCHAR)
    RETURNS http_response
    AS $$ SELECT http(('GET', $1, NULL, NULL, NULL)::http_request) $$
    LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION http_post(uri VARCHAR, content VARCHAR)
    RETURNS http_response
    AS $$ SELECT http(('POST', $1, NULL, NULL, $2)::http_request) $$
    LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION http_put(uri VARCHAR, content VARCHAR)
    RETURNS http_response
    AS $$ SELECT http(('PUT', $1, NULL, NULL, $2)::http_request) $$
    LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION http_patch(uri VARCHAR, content VARCHAR)
    RETURNS http_response
    AS $$ SELECT http(('PATCH', $1, NULL, NULL, $2)::http_request) $$
    LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION http_delete(uri VARCHAR)
    RETURNS http_response
    AS $$ SELECT http(('DELETE', $1, NULL, NULL, NULL)::http_request) $$
    LANGUAGE 'sql';
    
CREATE OR REPLACE FUNCTION http_head(uri VARCHAR)
    RETURNS http_response
    AS $$ SELECT http(('HEAD', $1, NULL, NULL, NULL)::http_request) $$
    LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION url_quote_plus(string VARCHAR)
    RETURNS TEXT
    AS 'MODULE_PATHNAME'
    LANGUAGE 'c'
    IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION url_unquote_plus(string VARCHAR)
    RETURNS TEXT
    AS 'MODULE_PATHNAME'
    LANGUAGE 'c'
    IMMUTABLE STRICT;

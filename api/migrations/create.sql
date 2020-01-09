
CREATE SCHEMA if not exists main
;
create table if not exists main.cls_payment_type(
   id BIGSERIAL PRIMARY KEY,
   name character varying(255) NOT NULL,
   code character varying(32) NOT NULL,
   parent_code character varying(32) NOT NULL
)
;
create table if not exists main.cls_action(
   id BIGSERIAL PRIMARY KEY,
   name character varying(255) NOT NULL,
   code character varying(32) NOT NULL,
   parent_code character varying(32) NOT NULL
)
;
create table if not exists main.cls_life_situation(
   id BIGSERIAL PRIMARY KEY,
   name character varying(255) NOT NULL,
   code character varying(32) NOT NULL,
   parent_code character varying(32) NOT NULL
)
;

create table if not exists main.reg_practice(
   id BIGSERIAL PRIMARY KEY,
   name text NOT NULL,
   content text NOT NULL,
   code character varying(32) NOT NULL,
   number character varying(255) NOT NULL
)
;

create table if not exists main.reg_practice_attribute(
   id BIGSERIAL PRIMARY KEY,
   code_attribute character varying(32) NOT NULL,
   code_practice character varying(32) NOT NULL,
   attribute_type integer not null -- 1 - cls_payment_type 2 - cls_action 3 - cls_life_situation
)
;

CREATE OR REPLACE FUNCTION main.make_tsvector(description TEXT)
   RETURNS tsvector AS $$
BEGIN
  RETURN to_tsvector('russian', description);
END
$$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE INDEX IF NOT EXISTS idx_fts_reg_practice_content ON main.reg_practice
  USING gin(main.make_tsvector(content));
CREATE INDEX IF NOT EXISTS idx_fts_reg_practice_name ON main.reg_practice
  USING gin(main.make_tsvector(name));

CREATE OR REPLACE FUNCTION main.get_reg_practice_parameter_table(attributes character varying(32)[], attr_type integer)
RETURNS table(
    code_attribute character varying,
    attribute_type integer
) AS
$$
BEGIN
  RETURN QUERY
        SELECT cast(s.unnest as  character varying) as code_attribute,
        attr_type as attribute_type
        from(
            SELECT unnest FROM unnest( attributes )
        ) as s
	;
END

;

---DROP FUNCTION main.get_reg_practice(text,character varying[],character varying[],character varying[]);
CREATE OR REPLACE FUNCTION main.get_reg_practice(text_query text,
    payment_types character varying(32)[],
    actions character varying(32)[],
    life_situations character varying(32)[]
)
RETURNS table(
    id bigint,
    name character varying(255),
    content text,
    code character varying(255),
    number character varying(255)
) AS
$$
DECLARE
    payment_type_type integer = 1;
    action_type integer = 2;
    life_situation_type integer = 3;
    attributes_count integer;
BEGIN

  SELECT CNT INTO attributes_count
  FROM (
    SELECT COUNT(*) AS CNT FROM (
        SELECT CODE_ATTRIBUTE, ATTRIBUTE_TYPE FROM
        MAIN.GET_REG_PRACTICE_PARAMETER_TABLE(payment_types, payment_type_type)
        UNION
        SELECT CODE_ATTRIBUTE, ATTRIBUTE_TYPE FROM
        MAIN.GET_REG_PRACTICE_PARAMETER_TABLE(actions, action_type)
        UNION
        SELECT CODE_ATTRIBUTE, ATTRIBUTE_TYPE FROM
        MAIN.GET_REG_PRACTICE_PARAMETER_TABLE(life_situations, life_situation_type)
    ) AS S
  ) AS S;

  IF attributes_count > 0 THEN
    RETURN QUERY
                WITH ATTR AS(
                    SELECT CODE_ATTRIBUTE, ATTRIBUTE_TYPE FROM
                    MAIN.GET_REG_PRACTICE_PARAMETER_TABLE(payment_types, payment_type_type)
                    UNION
                    SELECT CODE_ATTRIBUTE, ATTRIBUTE_TYPE FROM
                    MAIN.GET_REG_PRACTICE_PARAMETER_TABLE(actions, action_type)
                    UNION
                    SELECT CODE_ATTRIBUTE, ATTRIBUTE_TYPE FROM
                    MAIN.GET_REG_PRACTICE_PARAMETER_TABLE(life_situations, life_situation_type)
                ),
                ATTR_PRACT AS(
                    SELECT CODE_PRACTICE
                    FROM MAIN.REG_PRACTICE_ATTRIBUTE AS RPA
                    INNER JOIN ATTR ON (RPA.CODE_ATTRIBUTE, RPA.ATTRIBUTE_TYPE) = (ATTR.CODE_ATTRIBUTE, ATTR.ATTRIBUTE_TYPE)
                )
                select
                RP.id,
                cast (RP.name as character varying(255)) as name,
                RP.content,
                cast (RP.code as character varying(255)) as code,
                cast (RP.number as character varying(255)) as number
		from main.reg_practice AS RP
                WHERE (MAIN.make_tsvector(RP.content) @@ to_tsquery('russian', text_query)
                    OR MAIN.make_tsvector(RP.name) @@ to_tsquery('russian', text_query)
                )
                AND RP.CODE IN (SELECT CODE_PRACTICE FROM ATTR_PRACT)
		;
  ELSE
    RETURN QUERY select
                RP.id,
                cast (RP.name as character varying(255)) as name,
                RP.content,
                cast (RP.code as character varying(255)) as code,
                cast (RP.number as character varying(255)) as number
		from main.reg_practice as RP
                WHERE (MAIN.make_tsvector(RP.content) @@ to_tsquery('russian', text_query)
                    OR MAIN.make_tsvector(RP.name) @@ to_tsquery('russian', text_query)
                )
		;
  END IF;
END
$$ LANGUAGE plpgsql
;
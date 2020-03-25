DROP SCHEMA IF EXISTS sizeclass CASCADE;
CREATE SCHEMA sizeclass
  AUTHORIZATION "%db_admin%";

GRANT ALL ON SCHEMA sizeclass TO "%db_admin%";
GRANT USAGE ON SCHEMA sizeclass TO "%db_read%";
ALTER DEFAULT PRIVILEGES IN SCHEMA sizeclass GRANT SELECT ON TABLES TO "%db_read%";


CREATE TABLE sizeclass.sizeclass
(
  id_sizeclass serial NOT NULL,
  size_min real,
  size_step real,
  size_max real,
  size_avg real,
  CONSTRAINT sizeclass_pkey PRIMARY KEY (id_sizeclass)
);
ALTER TABLE sizeclass.sizeclass
  OWNER TO "%db_admin%";
GRANT ALL ON TABLE sizeclass.sizeclass TO "%db_admin%";
COMMENT ON TABLE sizeclass.sizeclass IS '"sizeclass.sizeclass" table stores the characterstics of the different size class used in the database which are lenght intervalls (fork length), minimal value included, maximal value excluded' ;
COMMENT ON COLUMN sizeclass.sizeclass.id_sizeclass IS '"id_sizeclass" identifier of this size class';
COMMENT ON COLUMN sizeclass.sizeclass.size_min IS '"size_min" the minimal size of this intervall';
COMMENT ON COLUMN sizeclass.sizeclass.size_step IS '"size_step" the width of the intervall which can be different (1cm, 2cm..)';
COMMENT ON COLUMN sizeclass.sizeclass.size_max IS '"size_max" the maximal size of this intervall';
COMMENT ON COLUMN sizeclass.sizeclass.size_avg IS '"size_avg" average size';
    

CREATE OR REPLACE FUNCTION sizeclass.sizeclass_calc_size_avg()
  RETURNS trigger AS
$BODY$
 BEGIN
 NEW.size_avg=(NEW.size_min+NEW.size_min+NEW.size_step)/2;
 RETURN NEW;
 END;
 $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION sizeclass.sizeclass_calc_size_avg()
  OWNER TO "%db_admin%";
GRANT EXECUTE ON FUNCTION sizeclass.sizeclass_calc_size_avg() TO "%db_admin%";

CREATE OR REPLACE FUNCTION sizeclass.sizeclass_calc_size_max()
  RETURNS trigger AS
$BODY$
 BEGIN
 NEW.size_max=NEW.size_min+NEW.size_step;
 RETURN NEW;
 END;
 $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION sizeclass.sizeclass_calc_size_max()
  OWNER TO "%db_admin%";
GRANT EXECUTE ON FUNCTION sizeclass.sizeclass_calc_size_max() TO "%db_admin%";
  

CREATE TRIGGER trigg_sizeclass_calc_size_avg
  BEFORE INSERT OR UPDATE
  ON sizeclass.sizeclass
  FOR EACH ROW
  EXECUTE PROCEDURE sizeclass.sizeclass_calc_size_avg();


CREATE TRIGGER trigg_sizeclass_calc_size_max
  BEFORE INSERT OR UPDATE
  ON sizeclass.sizeclass
  FOR EACH ROW
  EXECUTE PROCEDURE sizeclass.sizeclass_calc_size_max();
  
  INSERT INTO sizeclass.sizeclass(size_min,size_step) VALUES (1,0);

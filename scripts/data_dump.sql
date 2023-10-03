-- Description: This script creates the database schema and inserts the data from the S3 bucket into the database.
DROP FUNCTION IF EXISTS insert_states_data();
DROP FUNCTION IF EXISTS insert_individuals_data();
DROP INDEX IF EXISTS states_geometry_index;
DROP INDEX IF EXISTS individuals_location_index;
DROP TABLE IF EXISTS states;
DROP TABLE IF EXISTS individuals;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create tables
CREATE TABLE IF NOT EXISTS states (
  id uuid DEFAULT uuid_generate_v4(),
  shape_id VARCHAR(50),
  name VARCHAR(300),
  geometry GEOMETRY(Geometry, 4326),
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS individuals (
  id uuid DEFAULT uuid_generate_v4(),
  first_name VARCHAR(255),
  last_name VARCHAR(255),
  location GEOMETRY(Point, 4326),
  PRIMARY KEY (id)
);

-- Create indexes
CREATE INDEX states_geometry_index ON states USING GIST(geometry);

CREATE INDEX individuals_location_index ON individuals USING GIST(location);

-- Create functions
CREATE OR REPLACE FUNCTION insert_states_data(data_directory text) RETURNS void AS $$
DECLARE
    file_name text;
begin
    FOR file_name IN
    	SELECT *
        FROM pg_ls_dir(data_directory)
    loop
	   	IF file_name LIKE '%.geojson' then
            RAISE NOTICE 'Processing file: %', file_name;

	   	    INSERT INTO states (shape_id, name, geometry)
		    SELECT el->'properties'->>'shapeId', el->'properties'->>'name', ST_GeomFromGeoJSON(el->'geometry')
		    FROM jsonb_array_elements((pg_read_file(data_directory || '/' || file_name)::jsonb)->'features') as features(el);

		    RAISE NOTICE 'Inserted data for file %', file_name;
        END IF;
    END LOOP;
    RETURN;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION insert_individuals_data(data_directory text) RETURNS void AS $$
DECLARE
    file_name text;
    individuals_data text;
    first_row boolean := TRUE;
    individual_data text;
    individuals_data_array text[];
BEGIN
    FOR file_name IN
        SELECT *
        FROM pg_ls_dir(data_directory)
    LOOP
        IF file_name LIKE '%.csv' THEN
            file_name := data_directory || '/' || file_name;
            individuals_data := pg_read_file(file_name);
            individuals_data_array := regexp_split_to_array(individuals_data, E'\n');

            FOREACH individual_data IN ARRAY individuals_data_array
            LOOP
                IF first_row THEN
                    first_row := FALSE;
                    CONTINUE;
                END IF;

               individual_data := trim(individual_data);
               RAISE NOTICE 'Processing row: %', individual_data;

               DECLARE
               	   individual_data_parts text[];
                   first_name text;
                   last_name text;
                   location jsonb;
               BEGIN
	               individual_data_parts := string_to_array(individual_data, ',');

                   first_name := trim(individual_data_parts[1]);
                   last_name := trim(individual_data_parts[2]);
                   location := (individual_data_parts[3] || ',' || individual_data_parts[4] || ',' || individual_data_parts[5] || ',' || individual_data_parts[6] || ',' || individual_data_parts[7])::jsonb;

                   INSERT INTO individuals (first_name, last_name, location)
            	   VALUES (first_name, last_name, ST_GeomFromGeoJSON(location->>'geometry'));

            	   RAISE NOTICE 'Inserted data for row: %', individual_data;
                END;
            END LOOP;
        END IF;
    END LOOP;
    RETURN;
END;
$$ LANGUAGE plpgsql;

-- Insert data
SELECT insert_states_data('/dataFromS3');

SELECT insert_individuals_data('/dataFromS3');
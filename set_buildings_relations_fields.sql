ALTER TABLE osm_buildings ADD COLUMN center geometry(Geometry, 3857);
UPDATE osm_buildings
SET center = st_centroid(geometry);


-- UPDATE city field
UPDATE osm_buildings b
SET city = c.name
FROM osm_cities c
WHERE c.type = 'city' AND public.st_contains(c.geometry, b.geometry) AND coalesce(b.city, '') = '';

UPDATE osm_buildings b
SET city = c.name
FROM osm_cities c
WHERE c.type = 'town' AND public.st_contains(c.geometry, b.geometry) AND coalesce(b.city, '') = '';

UPDATE osm_buildings b
SET city = c.name
FROM osm_cities c
WHERE c.type = 'village' AND public.st_contains(c.geometry, b.geometry) AND coalesce(b.city, '') = '';

UPDATE osm_buildings b
SET city = c.name
FROM osm_cities c
WHERE c.type = 'hamlet' AND public.st_contains(c.geometry, b.geometry) AND coalesce(b.city, '') = '';

UPDATE osm_buildings b
SET city = c.name
FROM osm_cities c
WHERE c.type = 'allotments' AND public.st_contains(c.geometry, b.geometry) AND coalesce(b.city, '') = '';
-- END UPDATE city field

-- add thesaurus_russian_osm
CREATE TEXT SEARCH DICTIONARY thesaurus_russian_osm (
TEMPLATE = thesaurus,
  DictFile = thesaurus_russian_osm,
  DICTIONARY = pg_catalog.russian_stem
);

ALTER TEXT SEARCH CONFIGURATION russian
ALTER MAPPING FOR hword, hword_part, word
WITH thesaurus_russian_osm, pg_catalog.russian_stem;
-- END add thesaurus_russian_osm

-- CREATE ts_vector_function
CREATE OR REPLACE FUNCTION make_tsvector(housenumber TEXT, street TEXT, city TEXT)
  RETURNS TSVECTOR AS $$
BEGIN
  RETURN (setweight(to_tsvector(housenumber), 'C') || setweight(to_tsvector(street), 'B') ||
          setweight(to_tsvector(city), 'A'));
END
$$
LANGUAGE 'plpgsql'
IMMUTABLE;
-- END CREATE ts_vector_function

-- ADD INDEX on address
CREATE INDEX IF NOT EXISTS osm_buildings_address_gin_index
  ON osm_buildings USING GIN (make_tsvector(housenumber, street, city));
-- END ADD INDEX
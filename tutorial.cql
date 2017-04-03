CREATE KEYSPACE If NOT EXISTS cycling with replication = {'class': 'NetworkTopologyStrategy', 'datacenter1': 3};
USE cycling;

CREATE TABLE cycling.cyclist_alt_stats ( id UUID PRIMARY KEY, lastname text, birthday timestamp, nationality text, weight text, height text );
CREATE TABLE cycling.whimsey ( id UUID PRIMARY KEY, lastname text, cyclist_teams set<text>, events list<text>, teams map<int,text> );
CREATE TABLE cycling.route (race_id int, race_name text, point_id int, lat_long tuple<text, tuple<float,float>>, PRIMARY KEY (race_id, point_id));
CREATE TABLE cycling.cyclist_name ( id UUID, lastname text, firstname text, PRIMARY KEY (id) );

CREATE TABLE cycling.rank_by_year_and_name (
race_year int,
race_name text,
cyclist_name text,
rank int,
PRIMARY KEY ((race_year, race_name), rank)
);

CREATE TABLE cycling.cyclist_category (
category text,
points int,
id UUID,
lastname text,
PRIMARY KEY (category, points)
) WITH CLUSTERING ORDER BY (points DESC);

INSERT INTO cycling.race_winners ( race_name, race_position, cyclist_name ) VALUES (
  'National Championships South Africa WJ-ITT (CN)',
  1,
  {firstname:'Frances',lastname:'DU TOUT'}
);

-- Using COUNTER
USE cycling;
CREATE TABLE popular_count (
  id UUID PRIMARY KEY,
  popularity counter
  );
UPDATE cycling.popular_count
 SET popularity = popularity + 1
 WHERE id = 6ab09bec-e68e-48d9-a5f8-97e6fb4c9b47;

SELECT * FROM cycling.popular_count;


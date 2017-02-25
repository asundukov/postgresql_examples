DROP TABLE IF EXISTS photo;
DROP TABLE IF EXISTS person;

CREATE TABLE person (
  person_id serial PRIMARY KEY,
  name varchar(100)
);

DROP TABLE IF EXISTS photo;

CREATE TABLE photo (
  photo_id serial PRIMARY KEY,
  person_id int REFERENCES person (person_id),
  title varchar(100),
  url varchar(500)
);


/* add n persons (n=800)*/
INSERT INTO person (name)
SELECT md5(cast(random() as text)) as name
FROM generate_series(1,800) AS t(num);

/* add ~10*n photos with different times on each person */
INSERT INTO photo (person_id, title, url)
SELECT p.person_id, concat(md5(cast(random() as text))) as title, concat('http://', md5(cast(random() as text)), '.ru') as url
FROM person p
LEFT JOIN generate_series(1,100) AS t(num) ON (1 = round(random()*10));

/* or add m photos for each of ~1/3 persons (m=10) */
INSERT INTO photo (person_id, title, url)
SELECT p.person_id, concat(md5(cast(random() as text))) as title, concat('http://', md5(cast(random() as text)), '.ru') as url
FROM (SELECT p.person_id FROM person p WHERE 1 = round(random()*3)) p
LEFT JOIN generate_series(1,10) AS t(num) ON (true);

/* multiply current photo count for active users k times (k = 1.7) */
postgres=# INSERT INTO photo (person_id, title, url)
SELECT p.person_id, concat(md5(cast(random() as text))) as title, concat('http://', md5(cast(random() as text)), '.ru') as url
FROM photo p
WHERE 7 > round(random()*10);

/* see result allocation */
SELECT 
  count_of_photos,
  count(*) count_of_persons
FROM (
    SELECT 
      count(photo_id) count_of_photos, 
      person_id 
    FROM person
    LEFT JOIN photo USING (person_id)
    GROUP BY person_id
) t 
GROUP BY count_of_photos 
ORDER BY 2 DESC;


/* out example:
 count_of_photos | count_of_persons
-----------------+-----------------
              13 |               74
              12 |               65
              11 |               64
              10 |               61
               9 |               53
               8 |               51
              21 |               43
              14 |               40
              20 |               36
              19 |               33
              15 |               32
              16 |               31
               7 |               29
              18 |               28
              22 |               27
              23 |               24
              17 |               23
               6 |               22
              24 |               18
              25 |               16
              26 |               12
               5 |                6
               4 |                4
              27 |                3
               3 |                2
              30 |                1
              29 |                1
              28 |                1
(28 rows)

*/


/* In real system you can change any param (n, m, k) at any time. And all data still valid after next data generation */

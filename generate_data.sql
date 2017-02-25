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
INSERT INTO photo (person_id, title, url)
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
              16 |               48
              14 |               45
              17 |               39
              21 |               37
              18 |               37
              19 |               34
              15 |               34
              12 |               30
              20 |               30
              13 |               29
              22 |               27
              11 |               25
              34 |               24
              32 |               22
              36 |               22
              29 |               22
              23 |               21
              33 |               20
              30 |               20
              35 |               20
              24 |               20
              25 |               17
              28 |               17
               9 |               17
              27 |               16
              10 |               16
              37 |               15
              26 |               15
              31 |               13
              39 |               12
              38 |               11
               8 |               10
               7 |                8
               6 |                5
              40 |                5
              41 |                3
              43 |                3
              42 |                2
              45 |                1
               3 |                1
               1 |                1
              44 |                1
               4 |                1
              48 |                1
              47 |                1
               2 |                1
               5 |                1
(47 rows)
*/


/* In real system you can change any param (n, m, k) at any time. And all data still valid after next data generation */

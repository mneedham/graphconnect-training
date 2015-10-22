LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/mneedham/graphconnect-training/master/people.csv' as row

WITH toInt(row.personId) as personId,
     row.name as personName,
     toInt(row.birthYear) as birthYear,
     toInt(row.deathYear) as deathYear

MERGE(person:Person {id: personId})
  ON CREATE SET
    person.name = personName,
    person.born = birthYear,
    person.died = deathYear;

LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/mneedham/graphconnect-training/master/new_movies.csv' as record
WITH toInt(record.movieId) as movieId,
     record.title as title,
     toFloat(record.avgVote) as avgVote,
     toInt(record.releaseYear) as releaseYear,
     record.tagline as tagline,
     split(record.genres, ":") as genres
MERGE (movie:Movie {id:movieId})
ON CREATE SET
  movie.title = title,
  movie.avgVote = avgVote,
  movie.releaseYear = releaseYear,
  movie.tagline = tagline,
  movie.genres = genres;

LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/mneedham/graphconnect-training/master/directors.csv' as record
WITH toInt(record.movieId) as movieId, toInt(record.personId) as personId
MATCH (movie:Movie {id:movieId})
MATCH (person:Person {id: personId})
MERGE (person)-[:DIRECTED]->(movie);

LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/mneedham/graphconnect-training/master/actors.csv' as record
WITH toInt(record.movieId) as movieId,
     toInt(record.personId) as personId,
    CASE WHEN record.characters IS NULL then [] ELSE split(record.characters, ":") END as roles
MATCH (movie:Movie {id:movieId})
MATCH (person:Person {id: personId})
MERGE (person)-[:ACTED_IN {roles:roles}]->(movie);

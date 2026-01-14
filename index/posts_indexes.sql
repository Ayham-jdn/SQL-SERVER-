use StackOverflow2010

SELECT score
FROM posts
WHERE id = 5
  AND score > 50
ORDER BY score DESC;

CREATE	NONCLUSTERED INDEX indx_posts
  ON posts (score);

  -----------------------------------------------------

SELECT Id, Title, Score
FROM Posts
WHERE Score > 100
  AND Title IS NOT NULL
ORDER BY Score DESC;


CREATE NONCLUSTERED INDEX IX_Posts_HighValue
ON Posts (Score)
INCLUDE (Title, Id)
WHERE Score > 100
  AND Title IS NOT NULL;

-- psql -U grieg --csv --file ./code/ngr.sql 

\pset footer

CREATE TEMP VIEW ngr AS
  SELECT 
    s.sid, s.code, s.stid,
    q.qid, q.name
  FROM subject s
  JOIN qcopy q ON q.rid = s.sid
  WHERE s.stid = 27
   AND q.name = 'demo-3-pl' AND q.is_complete;

\o ./data/questionnaires/demo-by-subject.csv

SELECT sid, code,
       c.opt AS sex,
       2023 - t.val :: INTEGER AS age
FROM ngr n
LEFT JOIN choice c ON c.qid = n.qid AND c.ord = 0
LEFT JOIN txt t ON t.qid = n.qid AND t.ord = 2
ORDER BY sid;

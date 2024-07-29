-- psql -U grieg --csv --file ./code/ngr.sql 

\pset footer

CREATE TEMP VIEW ngr AS
  SELECT 
    s.sid, s.code, s.stid
  FROM subject s
  JOIN qcopy q ON q.rid = s.sid
  WHERE s.stid = 27
   AND q.name ~ '^demo' AND q.is_complete;

\o ./data/questionnaires/demographic.csv

SELECT sid, code, q.name, a.ord, a.val
FROM ngr n
LEFT JOIN qcopy q ON q.rid = n.sid
LEFT JOIN answer a ON a.qid = q.qid
WHERE q.name ~ '^demo'
ORDER BY sid, a.ord;

\o ./data/questionnaires/psychometric.csv

SELECT sid, code, q.name, c.ord, c.opt
FROM ngr n
LEFT JOIN qcopy q ON q.rid = n.sid
LEFT JOIN choice c ON c.qid = q.qid
WHERE q.name ~ '^(PCAE|PD|NRm|ICE)'
ORDER BY sid, q.name, c.ord;

-- Inspect table sizes and stats recency
SELECT tab, tbl_rows, size, unsorted, stats_off
FROM SVV_TABLE_INFO
WHERE schema = 'mart' OR schema = 'core'
ORDER BY size DESC;


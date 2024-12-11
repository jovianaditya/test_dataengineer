1.  Tulis query untuk menghasilkan nama lokasi, kuartal (Q1, Q2, Q3, Q4), dan total kapasitas kontainer.
SELECT 
pd.location AS nama_lokasi,
CASE 
WHEN month IN (1,2,3) THEN ‘Q1’
WHEN month IN (4,5,6) THEN ‘Q2’
WHEN month IN (7,8,9) THEN ‘Q3’
WHEN month IN (10,11,12) THEN ‘Q4’
END AS kuartal,
SUM(capacity) total_kapasitas_kontainer
FROM port_details pd
JOIN port_container_capacity pc ON pd.port_id = pc.port_id 
GROUP BY 
pd.location,
CASE 
WHEN month IN (1,2,3) THEN ‘Q1’
WHEN month IN (4,5,6) THEN ‘Q2’
WHEN month IN (7,8,9) THEN ‘Q3’
WHEN month IN (10,11,12) THEN ‘Q4’
END


2.Tulis query untuk mendapatkan lokasi, rata-rata kapasitas tahunan, dan perbedaan rata-rata kapasitas antara kedua lokasi.
Asumsi bahwa pada table port_details isinya hanya ada 2 DISTINCT location karena kalimat pada pertanyaan berikut : “perbedaan rata-rata kapasitas antara kedua lokasi.”
WITH base AS(
SELECT 
	pd.location AS lokasi, 
	year,
AVG(pc.capacity) AS avg_kapasitas_tahunan
FROM port_details pd
JOIN port_container_capacity pc ON pd.port_id = pc.port_id 
GROUP BY pd.location, year
)
,
base2 AS(
SELECT 
	MAX(avg_capacity) – MIN(avg_capacity) AS diff_avg_capacity
FROM (
SELECT
	pd.location AS lokasi,
	AVG(capacity) AS avg_capacity
FROM port_details pd
JOIN port_container_capacity pc ON pd.port_id = pc.port_id 
GROUP BY 1
) A
)
SELECT
	b1.lokasi,
	b1.avg_kapasitas_tahunan,
	b2.diff_avg_capacity
FROM base b1
CROSS JOIN base2 b2



3.Tulis query untuk mendapatkan nama pelabuhan, lokasi, dan bulan-bulan di mana kapasitas meningkat dibandingkan bulan sebelumnya.
WITH base AS(
SELECT 
	pd.port_name AS nama_pelabuhan
	pd.location AS lokasi, 
	pd.year,
	pc.month,
	pc.capacity,
LAG(pc.capacity) OVER (PARTITION BY pd.port_id ORDER BY pccyear, pc.month )  AS prev_mth_capacity
FROM port_details pd
JOIN port_container_capacity pc ON pd.port_id = pc.port_id
)
SELECT DISTINCT
	nama_pelabuhan,
	lokasi,
	month
FROM base
WHERE prev_mth_capacity IS NOT NULL AND capacity > prev_mth_capacity

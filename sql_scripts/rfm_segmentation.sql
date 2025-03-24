CREATE TABLE rfm_detail AS

WITH rfm_cal AS (
    SELECT 
        customer_id, 
        DATE_PART('day', '2022-09-01'::timestamp - MAX(purchase_date::timestamp)) AS recency,
        COUNT(DISTINCT purchase_date::timestamp) AS frequency,
        SUM(gmv) AS monetary
    FROM customer_transaction
    WHERE customer_id <> 0 
    GROUP BY customer_id
    HAVING SUM(gmv) <> 0)

, thresholds AS (  -- Xác định các ngưỡng phân vị
    SELECT 
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY recency) AS r_25,
        PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY recency) AS r_50,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY recency) AS r_75,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY frequency) AS f_25,
        PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY frequency) AS f_50,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY frequency) AS f_75,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY monetary) AS m_25,
        PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY monetary) AS m_50,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY monetary) AS m_75
    FROM rfm_cal
)

, rfm_score AS (
    SELECT 
        rfm_cal.customer_id,
        recency,
        frequency,
        monetary,

        -- Recency: giá trị thấp hơn thì điểm cao hơn
        CASE  
            WHEN recency < r_25 THEN 4
            WHEN recency < r_50 THEN 3
            WHEN recency < r_75 THEN 2
            ELSE 1  
        END AS r,

        -- Frequency: giá trị cao hơn thì điểm cao hơn
        CASE  
            WHEN frequency = 1 THEN 1  
            WHEN frequency = 2 THEN 2  
            WHEN frequency = 3 THEN 3  
            ELSE 4 
        END AS f,

        -- Monetary: giá trị cao hơn thì điểm cao hơn 
        CASE  
            WHEN monetary > m_75 THEN 4
            WHEN monetary > m_50 THEN 3
            WHEN monetary > m_25 THEN 2
            ELSE 1  
        END AS m

    FROM rfm_cal, thresholds
)
SELECT 
	*,
    CASE 
        WHEN rfm IN ('444', '443', '434', '344') THEN 'Champions'
        WHEN rfm IN ('442', '441', '432', '431', '433', '343', '342', '341') THEN 'Loyal Customer'
        WHEN rfm IN ('424', '423', '324', '323', '413', '414', '343', '334') THEN 'Potential Loyalist'
        WHEN rfm IN ('333', '332', '331', '313', '314') THEN 'Promising'
        WHEN rfm IN ('422', '421', '412', '411', '311', '321', '312', '322') THEN 'New Customer'
        WHEN rfm IN ('131', '132', '141', '142', '231', '232', '241', '242') THEN 'Price Sensitive'
        WHEN rfm IN ('244', '234', '243', '233', '224', '214', '213', '134', '144', '143', '133') THEN 'Needs Attention'
        WHEN rfm IN ('223', '221', '222', '211', '212', '124') THEN 'About to sleep'
        WHEN rfm IN ('111', '112', '113', '114', '121', '122', '123') THEN 'Lost Customer'
    END AS segment
FROM(
    SELECT 
        customer_id,
        recency,
        frequency,
        monetary,
        CONCAT(r, f, m) AS rfm
    FROM rfm_score ) AS rfm_all

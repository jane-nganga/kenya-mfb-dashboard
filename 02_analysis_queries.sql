USE kenya_mfb_2024;

-- =============================================
-- SECTION 1: NPL ANALYSIS
-- =============================================

-- 1.1 View all NPL data
SELECT * FROM npl_by_mfb;

-- 1.2 Provision coverage ratio by MFB
-- Shows what % of gross NPLs each MFB has provisioned for
-- Higher = more conservative, lower = more exposed
SELECT
    mfb_name,
    mfb_size,
    gross_npl_ksh_m,
    impairment_allowance_ksh_m,
    ROUND((impairment_allowance_ksh_m / 
        NULLIF(gross_npl_ksh_m, 0)) * 100, 2) AS provision_coverage_pct
FROM npl_by_mfb
ORDER BY provision_coverage_pct DESC;

-- 1.3 MFBs with zero impairment allowance
-- These institutions carry real NPL exposure with no financial buffer
SELECT
    mfb_name,
    mfb_size,
    gross_npl_ksh_m,
    impairment_allowance_ksh_m
FROM npl_by_mfb
WHERE impairment_allowance_ksh_m = 0;

-- 1.4 Sector-wide NPL summary
SELECT
    SUM(gross_npl_ksh_m) AS total_gross_npl,
    SUM(impairment_allowance_ksh_m) AS total_provisions,
    SUM(net_npl_ksh_m) AS total_net_npl,
    ROUND((SUM(impairment_allowance_ksh_m) / 
        SUM(gross_npl_ksh_m)) * 100, 2) AS sector_coverage_pct
FROM npl_by_mfb;

-- 1.5 NPL exposure grouped by bank size
SELECT
    mfb_size,
    COUNT(mfb_name) AS number_of_mfbs,
    SUM(gross_npl_ksh_m) AS total_gross_npl,
    SUM(impairment_allowance_ksh_m) AS total_provisions,
    ROUND((SUM(impairment_allowance_ksh_m) / 
        NULLIF(SUM(gross_npl_ksh_m), 0)) * 100, 2) AS coverage_pct
FROM npl_by_mfb
GROUP BY mfb_size
ORDER BY total_gross_npl DESC;

-- =============================================
-- SECTION 2: PROFITABILITY ANALYSIS
-- =============================================

-- 2.1 Profitability status by MFB
SELECT
    mfb_name,
    total_income_2024_ksh_m,
    total_expenses_2024_ksh_m,
    net_profit_2024_ksh_m,
    CASE
        WHEN net_profit_2024_ksh_m > 0 THEN 'Profitable'
        WHEN net_profit_2024_ksh_m = 0 THEN 'Break Even'
        ELSE 'Loss Making'
    END AS profitability_status
FROM performance_by_mfb
ORDER BY net_profit_2024_ksh_m DESC;

-- 2.2 Sector profitability summary
SELECT
    CASE
        WHEN net_profit_2024_ksh_m > 0 THEN 'Profitable'
        WHEN net_profit_2024_ksh_m = 0 THEN 'Break Even'
        ELSE 'Loss Making'
    END AS profitability_status,
    COUNT(mfb_name) AS number_of_mfbs,
    SUM(net_profit_2024_ksh_m) AS total_net_profit
FROM performance_by_mfb
GROUP BY profitability_status
ORDER BY total_net_profit DESC;

-- 2.3 Cost efficiency ratio
-- % of income consumed by expenses
-- Lower = more efficient
SELECT
    mfb_name,
    total_income_2024_ksh_m,
    total_expenses_2024_ksh_m,
    ROUND((total_expenses_2024_ksh_m / 
        NULLIF(total_income_2024_ksh_m, 0)) * 100, 2) AS cost_to_income_pct
FROM performance_by_mfb
ORDER BY cost_to_income_pct ASC;

-- =============================================
-- SECTION 3: CROSS-TABLE CONSISTENCY CHECK
-- =============================================

-- 3.1 Identify banks in NPL table not present in deposit accounts table
-- Expected result: Daraja and Maisha only
-- Any other result indicates a naming mismatch requiring correction
SELECT mfb_name FROM npl_by_mfb
WHERE mfb_name NOT IN (SELECT mfb_name FROM deposit_accounts_by_mfb);

-- =============================================
-- SECTION 4: DEPOSITOR RISK ANALYSIS
-- =============================================

-- 4.1 Deposit protection ratio by MFB
-- Shows what % of each MFB's customer deposits are KDIC-insured
SELECT
    mfb_name,
    dec24_insured_ksh_m,
    dec24_customer_ksh_m,
    (dec24_customer_ksh_m - dec24_insured_ksh_m) AS unprotected_deposits_ksh_m,
    ROUND((dec24_insured_ksh_m / 
        NULLIF(dec24_customer_ksh_m, 0)) * 100, 2) AS pct_deposits_protected
FROM protected_deposits_by_mfb
ORDER BY pct_deposits_protected ASC;

-- =============================================
-- SECTION 5: COMBINED ANALYSIS (JOIN)
-- =============================================
-- 4.2 Combined depositor risk profile
-- Identifies institutions with low deposit protection AND loss-making status
-- The highest risk combination for depositors
SELECT
    p.mfb_name,
    CASE
        WHEN p.net_profit_2024_ksh_m > 0 THEN 'Profitable'
        WHEN p.net_profit_2024_ksh_m = 0 THEN 'Break Even'
        ELSE 'Loss Making'
    END AS profitability_status,
    ROUND((pd.dec24_insured_ksh_m /
        NULLIF(pd.dec24_customer_ksh_m, 0)) * 100, 2) AS pct_deposits_protected,
    ROUND((p.total_expenses_2024_ksh_m /
        NULLIF(p.total_income_2024_ksh_m, 0)) * 100, 2) AS cost_to_income_pct,
    n.gross_npl_ksh_m
FROM performance_by_mfb p
LEFT JOIN protected_deposits_by_mfb pd ON p.mfb_name = pd.mfb_name
LEFT JOIN npl_by_mfb n ON p.mfb_name = n.mfb_name
ORDER BY pct_deposits_protected ASC;

-- 5.1 NPL exposure vs profitability
-- INNER JOIN: only returns banks present in both tables (all 14 in this case)
SELECT
    n.mfb_name,
    n.mfb_size,
    n.gross_npl_ksh_m,
    ROUND((n.impairment_allowance_ksh_m / 
        NULLIF(n.gross_npl_ksh_m, 0)) * 100, 2) AS provision_coverage_pct,
    p.total_income_2024_ksh_m,
    p.net_profit_2024_ksh_m,
    CASE
        WHEN p.net_profit_2024_ksh_m > 0 THEN 'Profitable'
        WHEN p.net_profit_2024_ksh_m = 0 THEN 'Break Even'
        ELSE 'Loss Making'
    END AS profitability_status
FROM npl_by_mfb n
JOIN performance_by_mfb p ON n.mfb_name = p.mfb_name
ORDER BY n.gross_npl_ksh_m DESC;

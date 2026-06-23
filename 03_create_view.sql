USE kenya_mfb_2024;

CREATE OR REPLACE VIEW vw_mfb_dashboard AS
SELECT
    n.mfb_name,
    n.mfb_size,
    n.gross_npl_ksh_m,
    n.net_npl_ksh_m,
    n.impairment_allowance_ksh_m,
    ROUND((n.impairment_allowance_ksh_m /
        NULLIF(n.gross_npl_ksh_m, 0)) * 100, 2) AS provision_coverage_pct,
    p.total_income_2024_ksh_m,
    p.total_expenses_2024_ksh_m,
    p.net_profit_2024_ksh_m,
    ROUND((p.total_expenses_2024_ksh_m /
        NULLIF(p.total_income_2024_ksh_m, 0)) * 100, 2) AS cost_to_income_pct,
    CASE
        WHEN p.net_profit_2024_ksh_m > 0 THEN 'Profitable'
        WHEN p.net_profit_2024_ksh_m = 0 THEN 'Break Even'
        ELSE 'Loss Making'
    END AS profitability_status,
    d.dec24_total AS total_deposit_accounts_2024,
    d.dec23_total AS total_deposit_accounts_2023,
    d.change_total AS deposit_account_change,
    CASE
        WHEN d.change_total > 0 THEN 'Growing'
        WHEN d.change_total = 0 THEN 'Flat'
        WHEN d.change_total IS NULL THEN 'No Data'
        ELSE 'Shrinking'
    END AS customer_growth_status,
    pd.dec24_customer_ksh_m AS customer_deposits_2024_ksh_m,
    pd.dec23_customer_ksh_m AS customer_deposits_2023_ksh_m,
    pd.dec24_insured_ksh_m AS insured_deposits_2024_ksh_m,
    (pd.dec24_customer_ksh_m - pd.dec24_insured_ksh_m)
        AS unprotected_deposits_ksh_m,
    ROUND((pd.dec24_insured_ksh_m /
        NULLIF(pd.dec24_customer_ksh_m, 0)) * 100, 2) AS pct_deposits_protected,
    ROUND((n.gross_npl_ksh_m /
        NULLIF(pd.dec24_customer_ksh_m, 0)) * 100, 2) AS npl_to_deposits_pct
FROM npl_by_mfb n
JOIN performance_by_mfb p ON n.mfb_name = p.mfb_name
LEFT JOIN deposit_accounts_by_mfb d ON n.mfb_name = d.mfb_name
LEFT JOIN protected_deposits_by_mfb pd ON n.mfb_name = pd.mfb_name;

-- Verify the view
SELECT * FROM vw_mfb_dashboard;

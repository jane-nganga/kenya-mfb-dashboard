CREATE DATABASE IF NOT EXISTS kenya_mfb_2024;
USE kenya_mfb_2024;

CREATE TABLE npl_by_mfb (
    mfb_name VARCHAR(50),
    mfb_size VARCHAR(20),
    gross_npl_ksh_m INT,
    interest_suspense_ksh_m INT,
    total_npl_ksh_m INT,
    impairment_allowance_ksh_m INT,
    net_npl_ksh_m INT
);

CREATE TABLE performance_by_mfb (
    mfb_name VARCHAR(50),
    total_income_2024_ksh_m INT,
    interest_fee_expense_deposits INT,
    other_fees_commissions_expense INT,
    provision_loan_impairment INT,
    staff_costs INT,
    directors_emoluments INT,
    rental_charges INT,
    depreciation_charges INT,
    amortization_charges INT,
    other_admin_expense INT,
    non_operating_expense INT,
    total_expenses_2024_ksh_m INT,
    net_profit_2024_ksh_m INT
);

CREATE TABLE deposit_accounts_by_mfb (
    mfb_name VARCHAR(50),
    mfb_size VARCHAR(20),
    dec23_under_500k INT,
    dec23_over_500k INT,
    dec23_total INT,
    dec24_under_500k INT,
    dec24_over_500k INT,
    dec24_total INT,
    change_total INT
);

CREATE TABLE protected_deposits_by_mfb (
    mfb_name VARCHAR(50),
    mfb_size VARCHAR(20),
    dec23_insured_ksh_m INT,
    dec23_customer_ksh_m INT,
    dec24_insured_ksh_m INT,
    dec24_customer_ksh_m INT,
    change_insured_ksh_m INT,
    change_customer_ksh_m INT
);

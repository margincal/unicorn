--
-- PostgreSQL database dump
--

-- Dumped from database version 11.3
-- Dumped by pg_dump version 11.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'standard public schema';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: account; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account (
    "AccountIdentifier" character varying(300) NOT NULL,
    region_number character varying(6),
    branch_number character varying(6) NOT NULL,
    broker_number character varying(300) NOT NULL,
    account_status character varying(1),
    "RecordChangedDate" timestamp without time zone,
    authorized_trading_level character varying(1) NOT NULL,
    account_name character varying(128) NOT NULL,
    lot_method character varying(1),
    default_portfolio_name character varying(30),
    brokerage_id numeric(18,0) NOT NULL,
    setup_date timestamp without time zone,
    "CurrencyCode" character varying(3) NOT NULL,
    ownership_id character varying(300) NOT NULL,
    option_trading_level numeric(18,0) NOT NULL,
    last_update_datetime timestamp without time zone,
    allow_day_trading_flag character varying(1) DEFAULT '0'::character varying,
    pattern_daytrader_flag character varying(1) DEFAULT '0'::character varying,
    source character varying(12),
    origination character varying(1),
    dvp_account_flag character varying(1) DEFAULT '0'::character varying,
    insert_date timestamp without time zone DEFAULT now() NOT NULL,
    update_date timestamp without time zone DEFAULT now() NOT NULL,
    email_notification_flag character varying(1) DEFAULT '0'::character varying,
    advisory_flag character varying(1) DEFAULT '0'::character varying,
    retirement_type character varying(2),
    ha_custodian_code character varying(32),
    ha_account_no character varying(255)
);


ALTER TABLE public.account OWNER TO postgres;

--
-- Name: balance_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.balance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.balance_id_seq OWNER TO postgres;

--
-- Name: balance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.balance (
    account_id character varying(300),
    "RegTRequirement" numeric(17,2),
    maint_call_total numeric(38,4),
    sma numeric(38,4),
    excess numeric(38,4),
    fund_balance numeric(38,4),
    money_market numeric(38,4),
    credit_interest numeric(38,4),
    currency character varying(3) DEFAULT 'USD'::character varying NOT NULL,
    day_trader_buying_power numeric(38,4),
    day_trading_call numeric(38,4),
    overnight_day_trader_buying_power numeric(38,4),
    overnight_buying_power numeric(38,4),
    insert_date timestamp without time zone DEFAULT now() NOT NULL,
    update_date timestamp without time zone DEFAULT now() NOT NULL,
    balance_id numeric(18,0) DEFAULT nextval('public.balance_id_seq'::regclass) NOT NULL,
    source character varying(12) DEFAULT 'BPSA'::character varying,
    tot_mkt_value numeric(17,2),
    type1avail numeric(17,2),
    type2avail numeric(17,2),
    maxcsh12 numeric(17,2),
    marginable numeric(17,2),
    treasuries numeric(17,2),
    corporates numeric(17,2),
    muni numeric(17,2),
    housecall numeric(17,2),
    newhousecall numeric(17,2),
    "NYSERequirement" numeric(17,2),
    margininterest numeric(17,2),
    marginrate numeric(17,2),
    creditrate numeric(7,5),
    mmfavlbltdy numeric(17,2),
    lqdtngequity numeric(17,2),
    mmfclose numeric(17,2)
);


ALTER TABLE public.balance OWNER TO postgres;

--
-- Name: balance_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.balance_detail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.balance_detail_id_seq OWNER TO postgres;

--
-- Name: balancedetail; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.balancedetail (
    balance_detail_date timestamp without time zone NOT NULL,
    account_type character varying(1) NOT NULL,
    last_activity_date timestamp without time zone,
    trade_date_balance numeric(38,4),
    settlement_date_balance numeric(38,4),
    market_value numeric(38,4),
    equity numeric(38,4),
    free_cash numeric(38,4),
    balance_id numeric(18,0) NOT NULL,
    insert_date timestamp without time zone DEFAULT now() NOT NULL,
    update_date timestamp without time zone DEFAULT now() NOT NULL,
    balance_detail_id numeric(18,0) DEFAULT nextval('public.balance_detail_id_seq'::regclass) NOT NULL
);


ALTER TABLE public.balancedetail OWNER TO postgres;

--
-- Name: position_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.position_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.position_id_seq OWNER TO postgres;

--
-- Name: position; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."position" (
    account_id character varying(300) NOT NULL,
    symbol character varying(255) NOT NULL,
    symbol_type character varying(1) NOT NULL,
    "CurrencyCode" character varying(3) NOT NULL,
    cusip character varying(12),
    ul_cusip character varying(12),
    ul_symbol character varying(32),
    security_desc_line_1 character varying(255) NOT NULL,
    security_desc_line_2 character varying(255),
    security_desc_line_3 character varying(255),
    price numeric(19,8),
    price_datetime date,
    close_price numeric(19,8) DEFAULT 0 NOT NULL,
    instrument_currency character varying(3) DEFAULT 'USD'::character varying,
    currency character varying(3) DEFAULT 'USD'::character varying NOT NULL,
    security_class character varying(6),
    insert_date timestamp without time zone DEFAULT now() NOT NULL,
    update_date timestamp without time zone DEFAULT now() NOT NULL,
    position_id numeric(18,0) DEFAULT nextval('public.position_id_seq'::regclass) NOT NULL,
    source character varying(12) DEFAULT 'BPSA'::character varying,
    maturity_date timestamp without time zone,
    interest_rate numeric(23,9),
    market_value numeric(24,5),
    non_neg_position numeric(17,5),
    mvcalctypecd character(1),
    mvcalcnum numeric(15,8),
    symbol10 character(8),
    symbol11 character(20),
    symbol12 character(12),
    symbol13 character(20),
    symbol14 character(15),
    symbol14o character(15),
    symbol15 character(7),
    "DescriptionHolderText" character(30),
    memo character(2),
    margin character(1),
    adpnbr character(7),
    "Action" character(1),
    cmoindicator character(1),
    state character(2),
    prerefundeddate timestamp without time zone,
    bondfactor numeric(13,10),
    optfactor numeric(15,8),
    bridge character(1),
    isin character(20),
    pcttotal numeric(3,2),
    foreignexchangerate numeric(15,8),
    foreigncode character(3),
    pctforeigndomestic numeric(3,2),
    symbolcountrycode character(2),
    expirationdate timestamp without time zone,
    strikepriceamount numeric(16,8),
    callputind character(1),
    "MarginHouseRequirementPercent" smallint,
    currcd character(3),
    closemktval numeric(17,2),
    bookvalue numeric(17,2),
    loan_amt numeric(17,2),
    exchcloseprice character(11),
    exchclosemktval numeric(17,8),
    "MarginHouseRequirementAmount" numeric(17,2),
    pricesource character(1),
    sourcepricecode character(1),
    isrecordaddedonline character(1),
    segregationfreelockcode character(1),
    housepriceprintformat character(11),
    registeredrepresentativecode character(3),
    todaytotalquantity numeric(17,2),
    checkdigitbranchaccount character(1),
    globalintegrationtodayquantity numeric(17,5),
    dailyaccruedinterest numeric(17,2),
    textlinecounternumber smallint
);


ALTER TABLE public."position" OWNER TO postgres;

--
-- Name: position_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.position_detail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.position_detail_id_seq OWNER TO postgres;

--
-- Name: position_s; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.position_s (
    account_id character varying(300),
    symbol character varying(255),
    symbol_type character varying(1),
    "CurrencyCode" character varying(3),
    cusip character varying(12),
    ul_cusip character varying(12),
    ul_symbol character varying(32),
    security_desc_line_1 character varying(255),
    security_desc_line_2 character varying(255),
    security_desc_line_3 character varying(255),
    price numeric(19,8),
    price_datetime date,
    close_price numeric(19,8),
    instrument_currency character varying(3),
    currency character varying(3),
    security_class character varying(6),
    insert_date timestamp without time zone,
    update_date timestamp without time zone,
    position_id numeric(18,0),
    source character varying(12),
    maturity_date timestamp without time zone,
    interest_rate numeric(23,9),
    market_value numeric(24,5),
    non_neg_position numeric(17,5),
    mvcalctypecd character(1),
    mvcalcnum numeric(15,8),
    symbol10 character(8),
    symbol11 character(20),
    symbol12 character(12),
    symbol13 character(20),
    symbol14 character(15),
    symbol14o character(15),
    symbol15 character(7),
    "DescriptionHolderText" character(30),
    memo character(2),
    margin character(1),
    adpnbr character(7),
    "Action" character(1),
    cmoindicator character(1),
    state character(2),
    prerefundeddate timestamp without time zone,
    bondfactor numeric(13,10),
    optfactor numeric(15,8),
    bridge character(1),
    isin character(20),
    pcttotal numeric(3,2),
    foreignexchangerate numeric(15,8),
    foreigncode character(3),
    pctforeigndomestic numeric(3,2),
    symbolcountrycode character(2),
    expirationdate timestamp without time zone,
    strikepriceamount numeric(16,8),
    callputind character(1),
    "MarginHouseRequirementPercent" smallint,
    currcd character(3),
    closemktval numeric(17,2),
    bookvalue numeric(17,2),
    loan_amt numeric(17,2),
    exchcloseprice character(11),
    exchclosemktval numeric(17,8),
    "MarginHouseRequirementAmount" numeric(17,2),
    pricesource character(1),
    sourcepricecode character(1),
    isrecordaddedonline character(1),
    segregationfreelockcode character(1),
    housepriceprintformat character(11),
    registeredrepresentativecode character(3),
    todaytotalquantity numeric(17,2),
    checkdigitbranchaccount character(1),
    globalintegrationtodayquantity numeric(17,5),
    dailyaccruedinterest numeric(17,2),
    textlinecounternumber smallint
);


ALTER TABLE public.position_s OWNER TO postgres;

--
-- Name: positiondetail; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.positiondetail (
    position_detail_date timestamp without time zone NOT NULL,
    "AccountType" character varying(1) NOT NULL,
    "TradeDateQuantity" numeric(19,6) NOT NULL,
    "SettlementDateQuantity" numeric(19,6),
    transfer_quantity numeric(19,6),
    safekeeping_quantity numeric(19,6),
    required_box_quantity numeric(19,6),
    "TradeDateMarketValue" numeric(17,2) DEFAULT 0 NOT NULL,
    non_neg_position numeric(19,6),
    daytrading_quantity numeric(19,6),
    daytrading_amount numeric,
    position_id numeric(18,0) NOT NULL,
    insert_date timestamp without time zone DEFAULT now() NOT NULL,
    update_date timestamp without time zone DEFAULT now() NOT NULL,
    position_detail_id numeric(18,0) DEFAULT nextval('public.position_detail_id_seq'::regclass) NOT NULL,
    "LastActivityDate" timestamp without time zone,
    settlementdatemarketvalue numeric(17,2)
);


ALTER TABLE public.positiondetail OWNER TO postgres;

--
-- Name: price; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.price (
    price_date timestamp without time zone NOT NULL,
    symbol character varying(255) NOT NULL,
    price numeric(19,8) NOT NULL
);


ALTER TABLE public.price OWNER TO postgres;

--
-- Name: requirements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.requirements (
    security_class character varying(6),
    category character varying(20),
    multiplier numeric(4,2)
);


ALTER TABLE public.requirements OWNER TO postgres;

--
-- Name: transaction_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transaction_history (
    historyid numeric(18,0) NOT NULL,
    customer character varying(180),
    lastname character varying(50),
    account character varying(300),
    currency character varying(32),
    currency_cd character varying(3),
    type_account_cd character varying(1),
    transcode character varying(23),
    symbol character varying(255),
    sym_desc character varying(130),
    processingdt timestamp without time zone,
    transdt timestamp without time zone,
    transaction_dt timestamp without time zone,
    quantity numeric(19,6),
    price numeric(19,8),
    transamt numeric(38,4),
    grossamt numeric(38,4),
    withholding numeric(38,4),
    rr_trans_cd character varying(300),
    rr_cd character varying(300),
    commission numeric(38,4),
    grosscredit numeric(38,4),
    settledt timestamp without time zone,
    adpnumber character(7),
    tagnbr character(5),
    tran_desc character varying(255),
    desc_history_txt_1 character varying(30),
    desc_history_txt_2 character varying(30),
    desc_history_txt_3 character varying(30),
    desc_history_txt_4 character varying(30),
    desc_history_txt_5 character varying(30),
    desc_history_txt_6 character varying(30),
    cusip character varying(21),
    branch_cd character varying(10),
    account_cd character varying(300),
    client_nbr character(4),
    batch_cd character(2),
    entry_cd character varying(32),
    activity_ch_cd character(2),
    type_tran_ch_cd character(1),
    seq_nbr integer,
    transaction_amt numeric(17,2),
    transaction_qty numeric(17,5),
    cross_reference_cd_pri character(20),
    cross_reference_cd_alt character(20),
    security_adp_nbr character(7),
    symbol_pri character varying(20),
    symbol_alt character varying(20),
    sec_nm character varying(20),
    msd_class1_cd character(1),
    msd_class2_cd character(1),
    msd_class3_cd character(1),
    msd_class4_cd character(1),
    msd_class5_cd character(1),
    msd_class6_cd character(1),
    msd_class7_cd character(1),
    security_ida_cd character(4),
    type_security_cd character varying(3),
    country_cd character(2),
    opt_call_put_ind character(1),
    opt_root_sym character(6),
    opt_exp_dt timestamp without time zone,
    opt_strike_amt numeric(16,8),
    cross_reference_cd_cu character(20),
    cross_reference_cd_isn character(20),
    cross_reference_cd_ci character(20),
    cross_reference_cd_cb character(20),
    desc_sec_line1_txt character varying(30),
    desc_sec_line2_txt character varying(30),
    desc_sec_line3_txt character varying(30),
    chk_brch_acct_nbr character varying(1),
    trade_dt timestamp without time zone,
    insertdate timestamp without time zone DEFAULT now() NOT NULL,
    updatedate timestamp without time zone DEFAULT now() NOT NULL,
    executionexchange character(1),
    fee_amt numeric(13,2),
    city_nm character varying(30),
    state_cd character(2),
    zip5_cd character varying(5),
    short_nm character varying(30),
    source character varying(12),
    ib_advisory_fee_status character varying(1),
    tcurrency_cvrsn_processing_dt timestamp without time zone,
    cnvrt_trd_crrna_rt numeric(15,8),
    plan_type_cd_1 character(1),
    mngd_acct_symbol_txt character(12),
    debit_credit_cd character(1),
    trans_acct_hist_cd character(1),
    action_cd character(1),
    rec_type_cd character(3),
    ticker_symbol_cd character(12),
    transaction_id character(4),
    prime_broker_cd character(1),
    trans_control_id character(25),
    sleeve_cd character(6),
    ctgy_cd character(5),
    cmmsn_grpng_nbr character(7),
    extnl_assets_ind character(1),
    parent_cntl_nbr character(25),
    dol_ind character(1),
    prte_ind character(1),
    sdi_ind character(1),
    trans_hist_seq_nbr integer,
    updt_last_tmstp timestamp without time zone
);


ALTER TABLE public.transaction_history OWNER TO postgres;

--
-- Data for Name: account; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.account ("AccountIdentifier", region_number, branch_number, broker_number, account_status, "RecordChangedDate", authorized_trading_level, account_name, lot_method, default_portfolio_name, brokerage_id, setup_date, "CurrencyCode", ownership_id, option_trading_level, last_update_datetime, allow_day_trading_flag, pattern_daytrader_flag, source, origination, dvp_account_flag, insert_date, update_date, email_notification_flag, advisory_flag, retirement_type, ha_custodian_code, ha_account_no) FROM stdin;
A1234	\N	000	YYY	0	\N	3	MURPHY MAUREEN	1	ACCOUNT	10	2019-05-13 18:10:09.246	USD	1	0	\N	1	0	\N	B	0	2019-05-13 18:10:09.246	2013-10-14 05:00:22.736	\N	0	\N	\N	\N
B1234	\N	000	YYY	0	\N	3	JOHN JOHNY	1	ACCOUNT	11	2019-05-13 18:10:09.246	USD	1	0	\N	1	0	\N	B	0	2019-05-15 18:10:09.246	2013-10-16 05:00:22.736	\N	0	\N	\N	\N
C1234	\N	000	YYY	0	\N	3	RYAN JOHNY	1	ACCOUNT	12	2019-05-15 00:00:00	USD	1	0	\N	1	0	\N	B	0	2019-05-15 00:00:00	2019-05-15 00:00:00	\N	0	\N	\N	\N
D1234	\N	000	YYY	0	\N	3	HARRY JOHNY	1	ACCOUNT	13	2019-05-15 00:00:00	USD	1	0	\N	1	0	\N	B	0	2019-05-15 00:00:00	2019-05-15 00:00:00	\N	0	\N	\N	\N
E1234	\N	000	YYY	0	\N	3	ALBERT JOHNY	1	ACCOUNT	14	2019-05-15 00:00:00	USD	1	0	\N	1	0	\N	B	0	2019-05-15 00:00:00	2019-05-15 00:00:00	\N	0	\N	\N	\N
F1234	\N	000	YYY	0	\N	3	PETER JOHNY	1	ACCOUNT	15	2019-05-15 00:00:00	USD	1	0	\N	1	0	\N	B	0	2019-05-15 00:00:00	2019-05-15 00:00:00	\N	0	\N	\N	\N
G1234	\N	000	YYY	0	\N	3	HARRY SINGH 	1	ACCOUNT	16	2019-05-13 18:10:09.246	USD	1	0	\N	1	0	\N	B	0	2019-05-13 18:10:09.246	2013-10-14 05:00:22.736	\N	0	\N	\N	\N
H1234	\N	000	YYY	0	\N	3	HUMPTY DUMPTY	1	ACCOUNT	17	2019-05-13 18:10:09.246	USD	1	0	\N	1	0	\N	B	0	2019-05-13 18:10:09.246	2013-10-14 05:00:22.736	\N	0	\N	\N	\N
J1234	\N	000	YYY	0	\N	3	JAMES BOND	1	ACCOUNT	18	2019-05-13 18:10:09.246	USD	1	0	\N	1	0	\N	B	0	2019-05-13 18:10:09.246	2013-10-14 05:00:22.736	\N	0	\N	\N	\N
K1234	\N	000	YYY	0	\N	3	CHRIS RIVER	1	ACCOUNT	19	2019-05-13 18:10:09.246	USD	1	0	\N	1	0	\N	B	0	2019-05-13 18:10:09.246	2013-10-14 05:00:22.736	\N	0	\N	\N	\N
A101	\N	000	YYY	0	\N	3	THOMAS JOHNY	1	ACCOUNT	20	2019-05-15 00:00:00	USD	1	0	\N	1	0	\N	B	0	2019-05-15 00:00:00	2019-05-15 00:00:00	\N	0	\N	\N	\N
B101	\N	000	YYY	0	\N	3	CHRIS JOHNY	1	ACCOUNT	21	2019-05-15 00:00:00	USD	1	0	\N	1	0	\N	B	0	2019-05-15 00:00:00	2019-05-15 00:00:00	\N	0	\N	\N	\N
C101	\N	000	YYY	0	\N	3	TONY JOHNY	1	ACCOUNT	22	2019-05-15 00:00:00	USD	1	0	\N	1	0	\N	B	0	2019-05-15 00:00:00	2019-05-15 00:00:00	\N	0	\N	\N	\N
D101	\N	000	YYY	0	\N	3	MARK JOHNY	1	ACCOUNT	23	2019-05-15 00:00:00	USD	1	0	\N	1	0	\N	B	0	2019-05-15 00:00:00	2019-05-15 00:00:00	\N	0	\N	\N	\N
S101	\N	000	YYY	0	\N	3	SOME NAME 	1	ACCOUNT	24	2019-05-15 00:00:00	USD	1	0	\N	1	0	\N	B	0	2019-05-15 00:00:00	2019-05-15 00:00:00	\N	0	\N	\N	\N
S102	\N	000	YYY	0	\N	3	GOOD NAME	1	ACCOUNT	25	2019-05-15 00:00:00	USD	1	0	\N	1	0	\N	B	0	2019-05-15 00:00:00	2019-05-15 00:00:00	\N	0	\N	\N	\N
M101	\N	000	YYY	0	\N	3	ARNOLD	1	ACCOUNT	26	2019-05-13 18:10:09.246	USD	1	0	\N	1	0	\N	B	0	2019-05-13 18:10:09.246	2013-10-14 05:00:22.736	\N	0	\N	\N	\N
M102	\N	000	YYY	0	\N	3	CHARLIE	1	ACCOUNT	27	2019-05-13 18:10:09.246	USD	1	0	\N	1	0	\N	B	0	2019-05-13 18:10:09.246	2013-10-14 05:00:22.736	\N	0	\N	\N	\N
M103	\N	000	YYY	0	\N	3	ALICE	1	ACCOUNT	28	2019-05-13 18:10:09.246	USD	1	0	\N	1	0	\N	B	0	2019-05-13 18:10:09.246	2013-10-14 05:00:22.736	\N	0	\N	\N	\N
M104	\N	000	YYY	0	\N	3	COOPER	1	ACCOUNT	29	2019-05-13 18:10:09.246	USD	1	0	\N	1	0	\N	B	0	2019-05-13 18:10:09.246	2013-10-14 05:00:22.736	\N	0	\N	\N	\N
C9876	\N	000	YYY	0	\N	3	KIA KIA	1	ACCOUNT	30	2019-06-02 00:00:00	USD	1	0	\N	1	0	\N	B	0	2019-06-02 00:00:00	2019-06-02 00:00:00	\N	0	\N	\N	\N
A9876	\N	000	YYY	0	\N	3	FORWARD CONVERSION	1	ACCOUNT	31	2019-06-02 00:00:00	USD	1	0	\N	1	0	\N	B	0	2019-06-02 00:00:00	2019-06-02 00:00:00	\N	0	\N	\N	\N
B9876	\N	000	YYY	0	\N	3	REVERSE CONVERSION	1	ACCOUNT	32	2019-06-02 00:00:00	USD	1	0	\N	1	0	\N	B	0	2019-06-02 00:00:00	2019-06-02 00:00:00	\N	0	\N	\N	\N
COL101	\N	000	YYY	0	\N	3	COLLAR1	1	ACCOUNT	33	2019-06-03 00:00:00	USD	1	0	\N	1	0	\N	B	0	2019-06-03 00:00:00	2019-06-03 00:00:00	\N	0	\N	\N	\N
COL102	\N	000	YYY	0	\N	3	COLLAR2	1	ACCOUNT	34	2019-06-03 00:00:00	USD	1	0	\N	1	0	\N	B	0	2019-06-03 00:00:00	2019-06-03 00:00:00	\N	0	\N	\N	\N
BLG101	\N	000	YYY	0	\N	3	BANK LETTER	1	ACCOUNT	35	2019-06-06 00:00:00	USD	1	0	\N	1	0	\N	B	0	2019-06-06 00:00:00	2019-06-06 00:00:00	\N	0	\N	\N	\N
ER101	\N	000	YYY	0	\N	3	HU	1	ACCOUNT	36	2019-06-06 00:00:00	USD	1	0	\N	1	0	\N	B	0	2019-06-06 00:00:00	2019-06-06 00:00:00	\N	0	\N	\N	\N
\.


--
-- Data for Name: balance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.balance (account_id, "RegTRequirement", maint_call_total, sma, excess, fund_balance, money_market, credit_interest, currency, day_trader_buying_power, day_trading_call, overnight_day_trader_buying_power, overnight_buying_power, insert_date, update_date, balance_id, source, tot_mkt_value, type1avail, type2avail, maxcsh12, marginable, treasuries, corporates, muni, housecall, newhousecall, "NYSERequirement", margininterest, marginrate, creditrate, mmfavlbltdy, lqdtngequity, mmfclose) FROM stdin;
A1234	\N	\N	\N	\N	\N	\N	\N	USD	\N	\N	\N	\N	2019-05-14 15:13:46.646123	2019-05-14 15:13:46.646123	2	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
B1234	\N	\N	\N	\N	\N	\N	\N	USD	\N	\N	\N	\N	2019-05-16 15:56:07.907752	2019-05-16 15:56:07.907752	3	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
G1234	\N	\N	\N	\N	\N	\N	\N	USD	\N	\N	\N	\N	2019-05-28 11:04:39.849953	2019-05-28 11:04:39.849953	4	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
H1234	\N	\N	\N	\N	\N	\N	\N	USD	\N	\N	\N	\N	2019-05-28 11:05:11.441066	2019-05-28 11:05:11.441066	5	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: balancedetail; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.balancedetail (balance_detail_date, account_type, last_activity_date, trade_date_balance, settlement_date_balance, market_value, equity, free_cash, balance_id, insert_date, update_date, balance_detail_id) FROM stdin;
2019-05-06 00:00:00	1	\N	6000.0000	6000.0000	\N	\N	\N	2	2019-05-14 15:17:52.276834	2019-05-14 15:17:52.276834	1
2019-05-07 00:00:00	1	\N	5000.0000	5000.0000	\N	\N	\N	2	2019-05-14 15:18:49.737281	2019-05-14 15:18:49.737281	2
2019-05-08 00:00:00	1	\N	5000.0000	5000.0000	\N	\N	\N	2	2019-05-14 15:18:49.737281	2019-05-14 15:18:49.737281	3
2019-05-09 00:00:00	1	\N	4500.0000	4500.0000	\N	\N	\N	2	2019-05-14 15:18:49.737281	2019-05-14 15:18:49.737281	4
2019-05-10 00:00:00	1	\N	12800.0000	12800.0000	\N	\N	\N	2	2019-05-14 15:18:49.737281	2019-05-14 15:18:49.737281	5
2019-05-11 00:00:00	1	\N	12800.0000	12800.0000	\N	\N	\N	2	2019-05-14 15:18:49.737281	2019-05-14 15:18:49.737281	6
2019-05-06 00:00:00	1	\N	-6000.0000	-6000.0000	\N	\N	\N	3	2019-05-16 16:10:18.278869	2019-05-16 16:10:18.278869	7
2019-05-07 00:00:00	1	\N	4000.0000	4000.0000	\N	\N	\N	3	2019-05-16 16:10:18.278869	2019-05-16 16:10:18.278869	8
2019-05-08 00:00:00	1	\N	4000.0000	4000.0000	\N	\N	\N	3	2019-05-16 16:10:18.278869	2019-05-16 16:10:18.278869	9
2019-05-09 00:00:00	1	\N	-1000.0000	-1000.0000	\N	\N	\N	3	2019-05-16 16:10:18.278869	2019-05-16 16:10:18.278869	10
2019-05-10 00:00:00	1	\N	-1000.0000	-1000.0000	\N	\N	\N	3	2019-05-16 16:10:18.278869	2019-05-16 16:10:18.278869	11
2019-05-20 00:00:00	1	\N	-750000.0000	-750000.0000	\N	\N	\N	4	2019-05-28 11:11:49.534381	2019-05-28 11:11:49.534381	12
2019-05-20 00:00:00	1	\N	-1750000.0000	-1750000.0000	\N	\N	\N	5	2019-05-28 11:11:49.534381	2019-05-28 11:11:49.534381	13
\.


--
-- Data for Name: position; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."position" (account_id, symbol, symbol_type, "CurrencyCode", cusip, ul_cusip, ul_symbol, security_desc_line_1, security_desc_line_2, security_desc_line_3, price, price_datetime, close_price, instrument_currency, currency, security_class, insert_date, update_date, position_id, source, maturity_date, interest_rate, market_value, non_neg_position, mvcalctypecd, mvcalcnum, symbol10, symbol11, symbol12, symbol13, symbol14, symbol14o, symbol15, "DescriptionHolderText", memo, margin, adpnbr, "Action", cmoindicator, state, prerefundeddate, bondfactor, optfactor, bridge, isin, pcttotal, foreignexchangerate, foreigncode, pctforeigndomestic, symbolcountrycode, expirationdate, strikepriceamount, callputind, "MarginHouseRequirementPercent", currcd, closemktval, bookvalue, loan_amt, exchcloseprice, exchclosemktval, "MarginHouseRequirementAmount", pricesource, sourcepricecode, isrecordaddedonline, segregationfreelockcode, housepriceprintformat, registeredrepresentativecode, todaytotalquantity, checkdigitbranchaccount, globalintegrationtodayquantity, dailyaccruedinterest, textlinecounternumber) FROM stdin;
A1234	CSCO	T	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	\N	\N	0.00000000	USD	USD	\N	2019-05-14 16:16:10.715869	2019-05-14 16:16:10.715869	1	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
A1234	IBM	T	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	\N	\N	0.00000000	USD	USD	\N	2019-05-14 16:19:06.590579	2019-05-14 16:19:06.590579	2	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
B1234	XYZ	T	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	\N	\N	0.00000000	USD	USD	\N	2019-05-16 16:17:11.650142	2019-05-16 16:17:11.650142	3	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
A1234	912796QH5	C	USD	912796QH5	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	\N	\N	0.00000000	USD	USD	T	2019-05-22 14:33:20.538092	2019-05-22 14:33:20.538092	4	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
B1234	345370CR99	C	USD	345370CR99	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	\N	\N	0.00000000	USD	USD	CB	2019-05-22 14:33:20.538092	2019-05-22 14:33:20.538092	5	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
C1234	@MSFT 190607C00115000	C	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	12.10000000	\N	0.00000000	USD	USD	O	2019-05-22 14:36:17.195698	2019-05-22 14:36:17.195698	6	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100.00000000	\N	\N	\N	\N	\N	\N	\N	2019-06-07 00:00:00	115.00000000	C	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
D1234	@MSFT 190607C00130000	C	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	0.94000000	\N	0.00000000	USD	USD	O	2019-05-22 14:36:17.195698	2019-05-22 14:36:17.195698	7	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100.00000000	\N	\N	\N	\N	\N	\N	\N	2019-06-07 00:00:00	130.00000000	C	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
F1234	@MSFT 190607P00130000	C	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	3.96000000	\N	0.00000000	USD	USD	O	2019-05-22 14:36:17.195698	2019-05-22 14:36:17.195698	9	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100.00000000	\N	\N	\N	\N	\N	\N	\N	2019-06-07 00:00:00	130.00000000	P	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
COL102	@MSFT 190701P00125000	C	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	3.16000000	\N	0.00000000	USD	USD	O	2019-06-06 13:54:04.907664	2019-06-06 13:54:04.907664	48	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100.00000000	\N	\N	\N	\N	\N	\N	\N	2019-07-01 00:00:00	125.00000000	P	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
E1234	@MSFT 190607P00115000	C	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	0.19000000	\N	0.00000000	USD	USD	O	2019-05-22 14:36:17.195698	2019-05-22 14:36:17.195698	8	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100.00000000	\N	\N	\N	\N	\N	\N	\N	2019-06-07 00:00:00	115.00000000	P	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
G1234	@MSFT 190607C00130000	C	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	\N	\N	0.00000000	USD	USD	O	2019-05-24 15:13:12.331707	2019-05-24 15:13:12.331707	10	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100.00000000	\N	\N	\N	\N	\N	\N	\N	2019-06-07 00:00:00	130.00000000	C	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
H1234	@MSFT 190607P00130000	C	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	\N	\N	0.00000000	USD	USD	O	2019-05-24 15:13:12.331707	2019-05-24 15:13:12.331707	11	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100.00000000	\N	\N	\N	\N	\N	\N	\N	2019-06-07 00:00:00	130.00000000	P	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
G1234	MSFT	T	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	\N	\N	0.00000000	USD	USD	E	2019-05-24 15:20:13.855031	2019-05-24 15:20:13.855031	12	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	C	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
H1234	MSFT	T	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	\N	\N	0.00000000	USD	USD	E	2019-05-24 15:20:13.855031	2019-05-24 15:20:13.855031	13	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	P	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
J1234	@MSFT 190607C00130000	C	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	\N	\N	0.00000000	USD	USD	O	2019-05-29 10:37:07.159703	2019-05-29 10:37:07.159703	14	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100.00000000	\N	\N	\N	\N	\N	\N	\N	2019-06-07 00:00:00	130.00000000	C	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
K1234	@MSFT 190607P00130000	C	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	\N	\N	0.00000000	USD	USD	O	2019-05-29 10:37:07.159703	2019-05-29 10:37:07.159703	15	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100.00000000	\N	\N	\N	\N	\N	\N	\N	2019-06-07 00:00:00	130.00000000	P	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
J1234	MSFT	T	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	\N	\N	0.00000000	USD	USD	E	2019-05-29 10:37:32.487799	2019-05-29 10:37:32.487799	16	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	C	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
K1234	MSFT	T	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	\N	\N	0.00000000	USD	USD	E	2019-05-29 10:37:32.487799	2019-05-29 10:37:32.487799	17	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	P	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
A101	@MSFT 190719P00120000	C	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	3.45000000	\N	0.00000000	USD	USD	O	2019-05-30 11:21:13.018651	2019-05-30 11:21:13.018651	18	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100.00000000	\N	\N	\N	\N	\N	\N	\N	2019-07-19 00:00:00	120.00000000	P	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
B101	@IBM 190719P00125000	C	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	3.11000000	\N	0.00000000	USD	USD	O	2019-05-30 11:21:13.018651	2019-05-30 11:21:13.018651	19	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100.00000000	\N	\N	\N	\N	\N	\N	\N	2019-07-19 00:00:00	125.00000000	P	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
C101	@FB 190719C00200000	C	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	2.75000000	\N	0.00000000	USD	USD	O	2019-05-30 11:21:13.018651	2019-05-30 11:21:13.018651	20	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100.00000000	\N	\N	\N	\N	\N	\N	\N	2019-07-19 00:00:00	200.00000000	C	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
D101	@ORCL 190719C00060000	C	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	4.05000000	\N	0.00000000	USD	USD	O	2019-05-30 11:21:13.018651	2019-05-30 11:21:13.018651	21	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100.00000000	\N	\N	\N	\N	\N	\N	\N	2019-07-19 00:00:00	60.00000000	C	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
S101	@JNJ 190621P00125000	C	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	5.70000000	\N	0.00000000	USD	USD	O	2019-05-30 12:54:14.002975	2019-05-30 12:54:14.002975	22	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100.00000000	\N	\N	\N	\N	\N	\N	\N	2019-06-21 00:00:00	125.00000000	P	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
S101	@JNJ 190621P00145000	C	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	5.10000000	\N	0.00000000	USD	USD	O	2019-05-30 12:54:14.002975	2019-05-30 12:54:14.002975	23	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100.00000000	\N	\N	\N	\N	\N	\N	\N	2019-06-21 00:00:00	145.00000000	C	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
S102	@NTNX 190621P00025000	C	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	4.26000000	\N	0.00000000	USD	USD	O	2019-05-30 13:14:35.85669	2019-05-30 13:14:35.85669	26	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100.00000000	\N	\N	\N	\N	\N	\N	\N	2019-06-21 00:00:00	25.00000000	P	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
S102	@NTNX 190621P00040000	C	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	3.12000000	\N	0.00000000	USD	USD	O	2019-05-30 13:14:35.85669	2019-05-30 13:14:35.85669	27	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100.00000000	\N	\N	\N	\N	\N	\N	\N	2019-06-21 00:00:00	40.00000000	C	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
M101	@KLAC 190801P00095000	C	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	4.26000000	\N	0.00000000	USD	USD	O	2019-05-30 13:51:34.233775	2019-05-30 13:51:34.233775	28	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100.00000000	\N	\N	\N	\N	\N	\N	\N	2019-08-01 00:00:00	95.00000000	P	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
M102	@BR 190801P00120000	C	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	5.24000000	\N	0.00000000	USD	USD	O	2019-05-30 13:51:34.233775	2019-05-30 13:51:34.233775	29	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100.00000000	\N	\N	\N	\N	\N	\N	\N	2019-08-01 00:00:00	120.00000000	P	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
M101	KLAC	T	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	\N	\N	0.00000000	USD	USD	E	2019-05-30 13:51:48.092477	2019-05-30 13:51:48.092477	30	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	P	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
M102	BR	T	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	\N	\N	0.00000000	USD	USD	E	2019-05-30 13:51:48.092477	2019-05-30 13:51:48.092477	31	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	P	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
M103	@GOOG 190701C01300000	C	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	10.10000000	\N	0.00000000	USD	USD	O	2019-05-30 14:06:27.338611	2019-05-30 14:06:27.338611	32	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100.00000000	\N	\N	\N	\N	\N	\N	\N	2019-07-01 00:00:00	1300.00000000	C	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
M104	@INTC 190701C00045000	C	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	3.00000000	\N	0.00000000	USD	USD	O	2019-05-30 14:06:27.338611	2019-05-30 14:06:27.338611	33	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100.00000000	\N	\N	\N	\N	\N	\N	\N	2019-07-01 00:00:00	45.00000000	C	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
M103	GOOG	T	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	\N	\N	0.00000000	USD	USD	E	2019-05-30 14:07:44.91781	2019-05-30 14:07:44.91781	34	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	C	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
M104	INTC	T	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	\N	\N	0.00000000	USD	USD	E	2019-05-30 14:07:44.91781	2019-05-30 14:07:44.91781	35	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	C	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
C9876	@MSFT 190607P00115000	C	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	\N	\N	0.00000000	USD	USD	O	2019-06-02 13:05:44.165456	2019-06-02 13:05:44.165456	36	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100.00000000	\N	\N	\N	\N	\N	\N	\N	2019-06-07 00:00:00	115.00000000	P	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
C9876	@MSFT 190607C00130000	C	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	\N	\N	0.00000000	USD	USD	O	2019-06-02 13:05:44.165456	2019-06-02 13:05:44.165456	37	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100.00000000	\N	\N	\N	\N	\N	\N	\N	2019-06-07 00:00:00	130.00000000	C	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
C9876	MSFT	T	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	\N	\N	0.00000000	USD	USD	E	2019-06-02 13:06:15.03791	2019-06-02 13:06:15.03791	38	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	P	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
A9876	@MSFT 190607P00130000	C	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	3.96000000	\N	0.00000000	USD	USD	O	2019-06-03 15:03:44.729764	2019-06-03 15:03:44.729764	39	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100.00000000	\N	\N	\N	\N	\N	\N	\N	2019-06-07 00:00:00	130.00000000	P	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
A9876	@MSFT 190607C00130000	C	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	0.94000000	\N	0.00000000	USD	USD	O	2019-06-03 15:03:44.729764	2019-06-03 15:03:44.729764	40	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100.00000000	\N	\N	\N	\N	\N	\N	\N	2019-06-07 00:00:00	130.00000000	C	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
B9876	@MSFT 190607P00130000	C	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	3.96000000	\N	0.00000000	USD	USD	O	2019-06-03 15:03:44.729764	2019-06-03 15:03:44.729764	41	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100.00000000	\N	\N	\N	\N	\N	\N	\N	2019-06-07 00:00:00	130.00000000	P	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
B9876	@MSFT 190607P00130000	C	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	0.94000000	\N	0.00000000	USD	USD	O	2019-06-03 15:03:44.729764	2019-06-03 15:03:44.729764	42	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100.00000000	\N	\N	\N	\N	\N	\N	\N	2019-06-07 00:00:00	130.00000000	C	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
A9876	MSFT	T	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	\N	\N	0.00000000	USD	USD	E	2019-06-03 15:04:10.165604	2019-06-03 15:04:10.165604	43	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
B9876	MSFT	T	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	\N	\N	0.00000000	USD	USD	E	2019-06-03 15:04:10.165604	2019-06-03 15:04:10.165604	44	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
COL101	@FB 190701P00175000	C	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	3.43000000	\N	0.00000000	USD	USD	O	2019-06-06 13:46:44.582619	2019-06-06 13:46:44.582619	45	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100.00000000	\N	\N	\N	\N	\N	\N	\N	2019-07-01 00:00:00	175.00000000	P	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
COL101	@FB 190701C00195000	C	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	3.00000000	\N	0.00000000	USD	USD	O	2019-06-06 13:46:44.582619	2019-06-06 13:46:44.582619	46	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100.00000000	\N	\N	\N	\N	\N	\N	\N	2019-07-01 00:00:00	195.00000000	C	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
COL101	FB	T	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	\N	\N	0.00000000	USD	USD	E	2019-06-06 13:46:44.582619	2019-06-06 13:46:44.582619	47	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
COL102	@MSFT 190701C00135000	C	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	1.36000000	\N	0.00000000	USD	USD	O	2019-06-06 13:54:04.907664	2019-06-06 13:54:04.907664	49	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100.00000000	\N	\N	\N	\N	\N	\N	\N	2019-07-01 00:00:00	135.00000000	C	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
COL102	MSFT	T	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	\N	\N	0.00000000	USD	USD	E	2019-06-06 13:54:04.907664	2019-06-06 13:54:04.907664	50	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
BLG101	@MSFT 190607P00130000	C	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	3.96000000	\N	0.00000000	USD	USD	O	2019-06-06 15:55:27.641719	2019-06-06 15:55:27.641719	51	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100.00000000	\N	\N	\N	\N	\N	\N	\N	2019-06-07 00:00:00	130.00000000	P	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
ER101	@MSFT 190607C00130000	C	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	0.94000000	\N	0.00000000	USD	USD	O	2019-06-06 15:55:27.641719	2019-06-06 15:55:27.641719	52	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100.00000000	\N	\N	\N	\N	\N	\N	\N	2019-06-07 00:00:00	130.00000000	C	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
BLG101	MSFT	T	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	\N	\N	0.00000000	USD	USD	BLG	2019-06-06 16:11:46.425841	2019-06-06 16:11:46.425841	53	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
ER101	MSFT	T	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	\N	\N	0.00000000	USD	USD	ESC	2019-06-06 16:11:46.425841	2019-06-06 16:11:46.425841	54	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: position_s; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.position_s (account_id, symbol, symbol_type, "CurrencyCode", cusip, ul_cusip, ul_symbol, security_desc_line_1, security_desc_line_2, security_desc_line_3, price, price_datetime, close_price, instrument_currency, currency, security_class, insert_date, update_date, position_id, source, maturity_date, interest_rate, market_value, non_neg_position, mvcalctypecd, mvcalcnum, symbol10, symbol11, symbol12, symbol13, symbol14, symbol14o, symbol15, "DescriptionHolderText", memo, margin, adpnbr, "Action", cmoindicator, state, prerefundeddate, bondfactor, optfactor, bridge, isin, pcttotal, foreignexchangerate, foreigncode, pctforeigndomestic, symbolcountrycode, expirationdate, strikepriceamount, callputind, "MarginHouseRequirementPercent", currcd, closemktval, bookvalue, loan_amt, exchcloseprice, exchclosemktval, "MarginHouseRequirementAmount", pricesource, sourcepricecode, isrecordaddedonline, segregationfreelockcode, housepriceprintformat, registeredrepresentativecode, todaytotalquantity, checkdigitbranchaccount, globalintegrationtodayquantity, dailyaccruedinterest, textlinecounternumber) FROM stdin;
A1234	CSCO	T	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	\N	\N	0.00000000	USD	USD	\N	2019-05-14 16:16:10.715869	2019-05-14 16:16:10.715869	1	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
A1234	IBM	T	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	\N	\N	0.00000000	USD	USD	\N	2019-05-14 16:19:06.590579	2019-05-14 16:19:06.590579	2	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
B1234	XYZ	T	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	\N	\N	0.00000000	USD	USD	\N	2019-05-16 16:17:11.650142	2019-05-16 16:17:11.650142	3	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
A1234	912796QH5	C	USD	912796QH5	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	\N	\N	0.00000000	USD	USD	T	2019-05-22 14:33:20.538092	2019-05-22 14:33:20.538092	4	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
B1234	345370CR99	C	USD	345370CR99	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	\N	\N	0.00000000	USD	USD	CB	2019-05-22 14:33:20.538092	2019-05-22 14:33:20.538092	5	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
C1234	@MSFT 190607C00115000	C	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	12.10000000	\N	0.00000000	USD	USD	O	2019-05-22 14:36:17.195698	2019-05-22 14:36:17.195698	6	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100.00000000	\N	\N	\N	\N	\N	\N	\N	2019-06-07 00:00:00	115.00000000	C	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
D1234	@MSFT 190607C00130000	C	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	0.94000000	\N	0.00000000	USD	USD	O	2019-05-22 14:36:17.195698	2019-05-22 14:36:17.195698	7	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100.00000000	\N	\N	\N	\N	\N	\N	\N	2019-06-07 00:00:00	130.00000000	C	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
C1234	@MSFT 190607P00115000	C	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	0.19000000	\N	0.00000000	USD	USD	O	2019-05-22 14:36:17.195698	2019-05-22 14:36:17.195698	8	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100.00000000	\N	\N	\N	\N	\N	\N	\N	2019-06-07 00:00:00	115.00000000	P	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
D1234	@MSFT 190607P00130000	C	USD	\N	\N	\N	G N M A PASS THRU POOL 008437M	\N	\N	3.96000000	\N	0.00000000	USD	USD	O	2019-05-22 14:36:17.195698	2019-05-22 14:36:17.195698	9	BPSA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100.00000000	\N	\N	\N	\N	\N	\N	\N	2019-06-07 00:00:00	130.00000000	P	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: positiondetail; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.positiondetail (position_detail_date, "AccountType", "TradeDateQuantity", "SettlementDateQuantity", transfer_quantity, safekeeping_quantity, required_box_quantity, "TradeDateMarketValue", non_neg_position, daytrading_quantity, daytrading_amount, position_id, insert_date, update_date, position_detail_id, "LastActivityDate", settlementdatemarketvalue) FROM stdin;
2019-05-06 00:00:00	1	100.000000	100.000000	\N	\N	\N	0.00	\N	\N	\N	2	2019-05-14 16:31:01.794125	2019-05-14 16:31:01.794125	6	\N	\N
2019-05-08 00:00:00	1	100.000000	100.000000	\N	\N	\N	0.00	\N	\N	\N	2	2019-05-14 16:31:01.794125	2019-05-14 16:31:01.794125	8	\N	\N
2019-05-09 00:00:00	1	100.000000	100.000000	\N	\N	\N	0.00	\N	\N	\N	2	2019-05-14 16:31:01.794125	2019-05-14 16:31:01.794125	9	\N	\N
2019-05-10 00:00:00	1	125.000000	125.000000	\N	\N	\N	0.00	\N	\N	\N	2	2019-05-14 16:31:15.662762	2019-05-14 16:31:15.662762	10	\N	\N
2019-05-10 00:00:00	1	100.000000	100.000000	\N	\N	\N	0.00	\N	\N	\N	1	2019-05-14 16:31:15.662762	2019-05-14 16:31:15.662762	11	\N	\N
2019-05-21 00:00:00	1	-2.000000	-2.000000	\N	\N	\N	0.00	\N	\N	\N	23	2019-05-30 12:56:06.318274	2019-05-30 12:56:06.318274	33	\N	\N
2019-05-07 00:00:00	1	100.000000	100.000000	\N	\N	\N	0.00	\N	\N	\N	2	2019-05-14 16:31:01.794125	2019-05-14 16:31:01.794125	7	\N	\N
2019-05-07 00:00:00	1	100.000000	100.000000	\N	\N	\N	0.00	\N	\N	\N	3	2019-05-16 16:20:05.348134	2019-05-16 16:20:05.348134	12	\N	\N
2019-05-08 00:00:00	1	100.000000	100.000000	\N	\N	\N	0.00	\N	\N	\N	3	2019-05-16 16:20:05.348134	2019-05-16 16:20:05.348134	13	\N	\N
2019-05-09 00:00:00	1	100.000000	100.000000	\N	\N	\N	0.00	\N	\N	\N	3	2019-05-16 16:20:05.348134	2019-05-16 16:20:05.348134	14	\N	\N
2019-05-10 00:00:00	1	100.000000	100.000000	\N	\N	\N	0.00	\N	\N	\N	3	2019-05-16 16:20:05.348134	2019-05-16 16:20:05.348134	15	\N	\N
2019-05-15 00:00:00	1	-100.000000	-100.000000	\N	\N	\N	0.00	\N	\N	\N	6	2019-05-22 14:41:17.177374	2019-05-22 14:41:17.177374	16	\N	\N
2019-05-15 00:00:00	1	-100.000000	-100.000000	\N	\N	\N	0.00	\N	\N	\N	7	2019-05-22 14:41:17.177374	2019-05-22 14:41:17.177374	17	\N	\N
2019-05-15 00:00:00	1	-100.000000	-100.000000	\N	\N	\N	0.00	\N	\N	\N	8	2019-05-22 14:41:17.177374	2019-05-22 14:41:17.177374	18	\N	\N
2019-05-15 00:00:00	1	-100.000000	-100.000000	\N	\N	\N	0.00	\N	\N	\N	9	2019-05-22 14:41:17.177374	2019-05-22 14:41:17.177374	19	\N	\N
2019-05-20 00:00:00	1	-100.000000	-100.000000	\N	\N	\N	0.00	\N	\N	\N	10	2019-05-24 15:31:21.935561	2019-05-24 15:31:21.935561	20	\N	\N
2019-05-20 00:00:00	1	-100.000000	-100.000000	\N	\N	\N	0.00	\N	\N	\N	11	2019-05-24 15:31:21.935561	2019-05-24 15:31:21.935561	21	\N	\N
2019-05-20 00:00:00	1	10000.000000	10000.000000	\N	\N	\N	0.00	\N	\N	\N	12	2019-05-24 15:31:21.935561	2019-05-24 15:31:21.935561	22	\N	\N
2019-05-20 00:00:00	1	-10000.000000	-10000.000000	\N	\N	\N	0.00	\N	\N	\N	13	2019-05-24 15:31:21.935561	2019-05-24 15:31:21.935561	23	\N	\N
2019-05-15 00:00:00	1	100.000000	100.000000	\N	\N	\N	0.00	\N	\N	\N	14	2019-05-29 10:46:24.955692	2019-05-29 10:46:24.955692	24	\N	\N
2019-05-15 00:00:00	1	100.000000	100.000000	\N	\N	\N	0.00	\N	\N	\N	15	2019-05-29 10:46:24.955692	2019-05-29 10:46:24.955692	25	\N	\N
2019-05-15 00:00:00	1	-10000.000000	-10000.000000	\N	\N	\N	0.00	\N	\N	\N	16	2019-05-29 10:46:24.955692	2019-05-29 10:46:24.955692	26	\N	\N
2019-05-15 00:00:00	1	10000.000000	10000.000000	\N	\N	\N	0.00	\N	\N	\N	17	2019-05-29 10:46:24.955692	2019-05-29 10:46:24.955692	27	\N	\N
2019-05-15 00:00:00	1	100.000000	100.000000	\N	\N	\N	0.00	\N	\N	\N	36	2019-06-02 13:09:50.479684	2019-06-02 13:09:50.479684	46	\N	\N
2019-05-15 00:00:00	1	-100.000000	-100.000000	\N	\N	\N	0.00	\N	\N	\N	37	2019-06-02 13:09:50.479684	2019-06-02 13:09:50.479684	47	\N	\N
2019-05-15 00:00:00	1	10000.000000	10000.000000	\N	\N	\N	0.00	\N	\N	\N	38	2019-06-02 13:09:50.479684	2019-06-02 13:09:50.479684	48	\N	\N
2019-05-15 00:00:00	1	100.000000	100.000000	\N	\N	\N	0.00	\N	\N	\N	39	2019-06-03 15:11:18.04122	2019-06-03 15:11:18.04122	49	\N	\N
2019-05-15 00:00:00	1	-100.000000	-100.000000	\N	\N	\N	0.00	\N	\N	\N	40	2019-06-03 15:11:18.04122	2019-06-03 15:11:18.04122	50	\N	\N
2019-05-15 00:00:00	1	-100.000000	-100.000000	\N	\N	\N	0.00	\N	\N	\N	41	2019-06-03 15:11:18.04122	2019-06-03 15:11:18.04122	51	\N	\N
2019-05-15 00:00:00	1	100.000000	100.000000	\N	\N	\N	0.00	\N	\N	\N	42	2019-06-03 15:11:18.04122	2019-06-03 15:11:18.04122	52	\N	\N
2019-05-15 00:00:00	1	10000.000000	10000.000000	\N	\N	\N	0.00	\N	\N	\N	43	2019-06-03 15:11:18.04122	2019-06-03 15:11:18.04122	53	\N	\N
2019-05-15 00:00:00	1	-10000.000000	-10000.000000	\N	\N	\N	0.00	\N	\N	\N	44	2019-06-03 15:11:18.04122	2019-06-03 15:11:18.04122	54	\N	\N
2019-05-15 00:00:00	1	-100.000000	-100.000000	\N	\N	\N	0.00	\N	\N	\N	51	2019-06-06 15:57:32.565514	2019-06-06 15:57:32.565514	61	\N	\N
2019-05-15 00:00:00	1	-100.000000	-100.000000	\N	\N	\N	0.00	\N	\N	\N	52	2019-06-06 15:57:32.565514	2019-06-06 15:57:32.565514	62	\N	\N
2019-05-15 00:00:00	1	9000.000000	9000.000000	\N	\N	\N	0.00	\N	\N	\N	53	2019-06-06 16:12:25.828393	2019-06-06 16:12:25.828393	63	\N	\N
2019-05-15 00:00:00	1	11000.000000	11000.000000	\N	\N	\N	0.00	\N	\N	\N	54	2019-06-06 16:12:25.828393	2019-06-06 16:12:25.828393	64	\N	\N
2019-05-22 00:00:00	1	2.000000	200.000000	\N	\N	\N	0.00	\N	\N	\N	45	2019-06-06 13:50:07.416735	2019-06-06 13:50:07.416735	55	\N	\N
2019-05-22 00:00:00	1	-2.000000	-200.000000	\N	\N	\N	0.00	\N	\N	\N	46	2019-06-06 13:50:07.416735	2019-06-06 13:50:07.416735	56	\N	\N
2019-05-22 00:00:00	1	200.000000	20000.000000	\N	\N	\N	0.00	\N	\N	\N	47	2019-06-06 13:50:07.416735	2019-06-06 13:50:07.416735	57	\N	\N
2019-05-22 00:00:00	1	5.000000	500.000000	\N	\N	\N	0.00	\N	\N	\N	48	2019-06-06 13:56:28.812063	2019-06-06 13:56:28.812063	58	\N	\N
2019-05-22 00:00:00	1	-5.000000	-500.000000	\N	\N	\N	0.00	\N	\N	\N	49	2019-06-06 13:56:28.812063	2019-06-06 13:56:28.812063	59	\N	\N
2019-05-22 00:00:00	1	500.000000	500.000000	\N	\N	\N	0.00	\N	\N	\N	50	2019-06-06 13:56:28.812063	2019-06-06 13:56:28.812063	60	\N	\N
2019-05-21 00:00:00	1	5.000000	5.000000	\N	\N	\N	0.00	\N	\N	\N	28	2019-05-30 14:21:31.313476	2019-05-30 14:21:31.313476	38	\N	\N
2019-05-21 00:00:00	1	500.000000	500.000000	\N	\N	\N	0.00	\N	\N	\N	30	2019-05-30 14:21:31.313476	2019-05-30 14:21:31.313476	40	\N	\N
2019-05-21 00:00:00	1	2.000000	2.000000	\N	\N	\N	0.00	\N	\N	\N	29	2019-05-30 14:21:31.313476	2019-05-30 14:21:31.313476	39	\N	\N
2019-05-21 00:00:00	1	200.000000	200.000000	\N	\N	\N	0.00	\N	\N	\N	31	2019-05-30 14:21:31.313476	2019-05-30 14:21:31.313476	41	\N	\N
2019-05-21 00:00:00	1	1.000000	1.000000	\N	\N	\N	0.00	\N	\N	\N	32	2019-05-30 14:21:46.741093	2019-05-30 14:21:46.741093	42	\N	\N
2019-05-21 00:00:00	1	-100.000000	-100.000000	\N	\N	\N	0.00	\N	\N	\N	34	2019-05-30 14:21:46.741093	2019-05-30 14:21:46.741093	44	\N	\N
2019-05-21 00:00:00	1	3.000000	3.000000	\N	\N	\N	0.00	\N	\N	\N	33	2019-05-30 14:21:46.741093	2019-05-30 14:21:46.741093	43	\N	\N
2019-05-21 00:00:00	1	-300.000000	-300.000000	\N	\N	\N	0.00	\N	\N	\N	35	2019-05-30 14:21:46.741093	2019-05-30 14:21:46.741093	45	\N	\N
2019-05-21 00:00:00	1	-2.000000	-2.000000	\N	\N	\N	0.00	\N	\N	\N	22	2019-05-30 12:56:06.318274	2019-05-30 12:56:06.318274	32	\N	\N
2019-05-21 00:00:00	1	-5.000000	-5.000000	\N	\N	\N	0.00	\N	\N	\N	26	2019-05-30 13:16:47.893816	2019-05-30 13:16:47.893816	36	\N	\N
2019-05-21 00:00:00	1	-5.000000	-5.000000	\N	\N	\N	0.00	\N	\N	\N	27	2019-05-30 13:16:47.893816	2019-05-30 13:16:47.893816	37	\N	\N
2019-05-21 00:00:00	1	-2.000000	-2.000000	\N	\N	\N	0.00	\N	\N	\N	18	2019-05-30 12:32:38.815526	2019-05-30 12:32:38.815526	28	\N	\N
2019-05-21 00:00:00	1	-5.000000	-5.000000	\N	\N	\N	0.00	\N	\N	\N	19	2019-05-30 12:32:38.815526	2019-05-30 12:32:38.815526	29	\N	\N
2019-05-21 00:00:00	1	-5.000000	-5.000000	\N	\N	\N	0.00	\N	\N	\N	21	2019-05-30 12:32:38.815526	2019-05-30 12:32:38.815526	31	\N	\N
2019-05-21 00:00:00	1	-1.000000	-1.000000	\N	\N	\N	0.00	\N	\N	\N	20	2019-05-30 12:32:38.815526	2019-05-30 12:32:38.815526	30	\N	\N
\.


--
-- Data for Name: price; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.price (price_date, symbol, price) FROM stdin;
2019-05-06 00:00:00	IBM	100.00000000
2019-05-07 00:00:00	IBM	100.00000000
2019-05-08 00:00:00	IBM	70.00000000
2019-05-09 00:00:00	IBM	70.00000000
2019-05-10 00:00:00	IBM	90.00000000
2019-05-10 00:00:00	CSCO	60.00000000
2019-05-07 00:00:00	XYZ	100.00000000
2019-05-08 00:00:00	XYZ	70.00000000
2019-05-09 00:00:00	XYZ	80.00000000
2019-05-10 00:00:00	XYZ	60.00000000
2019-05-15 00:00:00	MSFT	125.00000000
2019-05-21 00:00:00	MSFT	125.00000000
2019-05-21 00:00:00	IBM	130.00000000
2019-05-21 00:00:00	FB	185.00000000
2019-05-21 00:00:00	ORCL	50.00000000
2019-05-21 00:00:00	JNJ	135.23000000
2019-05-21 00:00:00	NTNX	32.18000000
2019-05-21 00:00:00	KLAC	102.20000000
2019-05-21 00:00:00	BR	124.53000000
2019-05-21 00:00:00	GOOG	1120.00000000
2019-05-21 00:00:00	INTC	44.67000000
2019-05-22 00:00:00	FB	181.00000000
2019-05-22 00:00:00	MSFT	127.51000000
\.


--
-- Data for Name: requirements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.requirements (security_class, category, multiplier) FROM stdin;
T	House	0.10
T	Maint	0.05
CB	House	0.50
CB	Maint	0.40
O	NYSE	0.20
O	House	0.15
O	Maint	0.10
O	MarriedNYSE	0.10
O	MarriedHouse	0.15
E	LongHouse	0.30
E	LongMaint	0.25
E	LongNYSE	0.25
E	ShortHouse	0.35
E	ShortMaint	0.30
E	ShortNYSE	0.30
O	CallHRR	0.30
O	PutHRR	0.15
O	FCHouse	0.20
O	FCNYSE	0.10
O	RCHouse	0.20
O	RCNYSE	0.10
\.


--
-- Data for Name: transaction_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.transaction_history (historyid, customer, lastname, account, currency, currency_cd, type_account_cd, transcode, symbol, sym_desc, processingdt, transdt, transaction_dt, quantity, price, transamt, grossamt, withholding, rr_trans_cd, rr_cd, commission, grosscredit, settledt, adpnumber, tagnbr, tran_desc, desc_history_txt_1, desc_history_txt_2, desc_history_txt_3, desc_history_txt_4, desc_history_txt_5, desc_history_txt_6, cusip, branch_cd, account_cd, client_nbr, batch_cd, entry_cd, activity_ch_cd, type_tran_ch_cd, seq_nbr, transaction_amt, transaction_qty, cross_reference_cd_pri, cross_reference_cd_alt, security_adp_nbr, symbol_pri, symbol_alt, sec_nm, msd_class1_cd, msd_class2_cd, msd_class3_cd, msd_class4_cd, msd_class5_cd, msd_class6_cd, msd_class7_cd, security_ida_cd, type_security_cd, country_cd, opt_call_put_ind, opt_root_sym, opt_exp_dt, opt_strike_amt, cross_reference_cd_cu, cross_reference_cd_isn, cross_reference_cd_ci, cross_reference_cd_cb, desc_sec_line1_txt, desc_sec_line2_txt, desc_sec_line3_txt, chk_brch_acct_nbr, trade_dt, insertdate, updatedate, executionexchange, fee_amt, city_nm, state_cd, zip5_cd, short_nm, source, ib_advisory_fee_status, tcurrency_cvrsn_processing_dt, cnvrt_trd_crrna_rt, plan_type_cd_1, mngd_acct_symbol_txt, debit_credit_cd, trans_acct_hist_cd, action_cd, rec_type_cd, ticker_symbol_cd, transaction_id, prime_broker_cd, trans_control_id, sleeve_cd, ctgy_cd, cmmsn_grpng_nbr, extnl_assets_ind, parent_cntl_nbr, dol_ind, prte_ind, sdi_ind, trans_hist_seq_nbr, updt_last_tmstp) FROM stdin;
1	\N	\N	B1234	\N	\N	\N	\N	XYZ	\N	\N	\N	\N	100.000000	100.00000000	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2019-05-07 00:00:00	2019-05-16 16:41:06.20564	2019-05-16 16:41:06.20564	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- Name: balance_detail_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.balance_detail_id_seq', 13, true);


--
-- Name: balance_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.balance_id_seq', 5, true);


--
-- Name: position_detail_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.position_detail_id_seq', 64, true);


--
-- Name: position_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.position_id_seq', 54, true);


--
-- Name: balance PK_BALANCE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.balance
    ADD CONSTRAINT "PK_BALANCE" PRIMARY KEY (balance_id);


--
-- Name: balancedetail PK_BALANCE_DETAIL; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.balancedetail
    ADD CONSTRAINT "PK_BALANCE_DETAIL" PRIMARY KEY (balance_detail_id);


--
-- Name: account accountid; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT accountid PRIMARY KEY ("AccountIdentifier");


--
-- Name: position pk_position; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."position"
    ADD CONSTRAINT pk_position PRIMARY KEY (position_id);


--
-- Name: positiondetail pk_positiondetail; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.positiondetail
    ADD CONSTRAINT pk_positiondetail PRIMARY KEY (position_detail_id);


--
-- Name: IDX_ACCOUNT; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_ACCOUNT" ON public.account USING btree (brokerage_id);


--
-- Name: IDX_ACCOUNT_02; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_ACCOUNT_02" ON public.account USING btree (account_name, "AccountIdentifier");


--
-- Name: IDX_ACCOUNT_03; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_ACCOUNT_03" ON public.account USING btree ("AccountIdentifier", account_status);


--
-- Name: IDX_BALANCEDETAIL_01; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_BALANCEDETAIL_01" ON public.balancedetail USING btree (balance_detail_date, balance_id, account_type);


--
-- Name: IDX_BALANCE_01; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_BALANCE_01" ON public.balance USING btree (account_id, currency);


--
-- Name: IDX_BALANCE_02; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_BALANCE_02" ON public.balance USING btree (source, account_id);


--
-- Name: IDX_POSITIONDETAIL_01; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_POSITIONDETAIL_01" ON public.positiondetail USING btree (position_detail_date, position_id, "AccountType");


--
-- Name: balancedetail FK_BALANCEDETAIL_01; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.balancedetail
    ADD CONSTRAINT "FK_BALANCEDETAIL_01" FOREIGN KEY (balance_id) REFERENCES public.balance(balance_id);


--
-- Name: positiondetail FK_POSITIONDETAIL_01; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.positiondetail
    ADD CONSTRAINT "FK_POSITIONDETAIL_01" FOREIGN KEY (position_id) REFERENCES public."position"(position_id);


--
-- Name: balance fk_balance_account; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.balance
    ADD CONSTRAINT fk_balance_account FOREIGN KEY (account_id) REFERENCES public.account("AccountIdentifier");


--
-- PostgreSQL database dump complete
--

-- 
-- Developer: Vikram More
-- Desc: Database for margin calculations
--

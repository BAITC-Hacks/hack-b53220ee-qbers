--
-- PostgreSQL database dump
--

\restrict ZW2Wulpz7lq9qk9OXKhApPicSTcBY4jgLa8gSNcsBcBx18cvD8rYamlGgHRmF1G

-- Dumped from database version 18.6 (Debian 18.6-1.pgdg13+2)
-- Dumped by pg_dump version 18.6 (Debian 18.6-1.pgdg13+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.django_admin_log DROP CONSTRAINT IF EXISTS django_admin_log_user_id_c564eba6_fk_auth_user_id;
ALTER TABLE IF EXISTS ONLY public.django_admin_log DROP CONSTRAINT IF EXISTS django_admin_log_content_type_id_c4bce8eb_fk_django_co;
ALTER TABLE IF EXISTS ONLY public.core_railstation DROP CONSTRAINT IF EXISTS core_railstation_district_id_2c6685d0_fk_core_district_id;
ALTER TABLE IF EXISTS ONLY public.core_populationcell DROP CONSTRAINT IF EXISTS core_populationcell_district_id_9c890c6e_fk_core_district_id;
ALTER TABLE IF EXISTS ONLY public.core_busstop DROP CONSTRAINT IF EXISTS core_busstop_district_id_b862811f_fk_core_district_id;
ALTER TABLE IF EXISTS ONLY public.auth_user_user_permissions DROP CONSTRAINT IF EXISTS auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id;
ALTER TABLE IF EXISTS ONLY public.auth_user_user_permissions DROP CONSTRAINT IF EXISTS auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm;
ALTER TABLE IF EXISTS ONLY public.auth_user_groups DROP CONSTRAINT IF EXISTS auth_user_groups_user_id_6a12ed8b_fk_auth_user_id;
ALTER TABLE IF EXISTS ONLY public.auth_user_groups DROP CONSTRAINT IF EXISTS auth_user_groups_group_id_97559544_fk_auth_group_id;
ALTER TABLE IF EXISTS ONLY public.auth_permission DROP CONSTRAINT IF EXISTS auth_permission_content_type_id_2f476e4b_fk_django_co;
ALTER TABLE IF EXISTS ONLY public.auth_group_permissions DROP CONSTRAINT IF EXISTS auth_group_permissions_group_id_b120cbf9_fk_auth_group_id;
ALTER TABLE IF EXISTS ONLY public.auth_group_permissions DROP CONSTRAINT IF EXISTS auth_group_permissio_permission_id_84c5c92e_fk_auth_perm;
DROP INDEX IF EXISTS public.django_session_session_key_c0390e0f_like;
DROP INDEX IF EXISTS public.django_session_expire_date_a5c62663;
DROP INDEX IF EXISTS public.django_admin_log_user_id_c564eba6;
DROP INDEX IF EXISTS public.django_admin_log_content_type_id_c4bce8eb;
DROP INDEX IF EXISTS public.core_railstation_district_id_2c6685d0;
DROP INDEX IF EXISTS public.core_populationcell_district_id_9c890c6e;
DROP INDEX IF EXISTS public.core_busstop_district_id_b862811f;
DROP INDEX IF EXISTS public.auth_user_username_6821ab7c_like;
DROP INDEX IF EXISTS public.auth_user_user_permissions_user_id_a95ead1b;
DROP INDEX IF EXISTS public.auth_user_user_permissions_permission_id_1fbb5f2c;
DROP INDEX IF EXISTS public.auth_user_groups_user_id_6a12ed8b;
DROP INDEX IF EXISTS public.auth_user_groups_group_id_97559544;
DROP INDEX IF EXISTS public.auth_permission_content_type_id_2f476e4b;
DROP INDEX IF EXISTS public.auth_group_permissions_permission_id_84c5c92e;
DROP INDEX IF EXISTS public.auth_group_permissions_group_id_b120cbf9;
DROP INDEX IF EXISTS public.auth_group_name_a6ea08ec_like;
ALTER TABLE IF EXISTS ONLY public.django_session DROP CONSTRAINT IF EXISTS django_session_pkey;
ALTER TABLE IF EXISTS ONLY public.django_migrations DROP CONSTRAINT IF EXISTS django_migrations_pkey;
ALTER TABLE IF EXISTS ONLY public.django_content_type DROP CONSTRAINT IF EXISTS django_content_type_pkey;
ALTER TABLE IF EXISTS ONLY public.django_content_type DROP CONSTRAINT IF EXISTS django_content_type_app_label_model_76bd3d3b_uniq;
ALTER TABLE IF EXISTS ONLY public.django_admin_log DROP CONSTRAINT IF EXISTS django_admin_log_pkey;
ALTER TABLE IF EXISTS ONLY public.core_transportscenario DROP CONSTRAINT IF EXISTS core_transportscenario_pkey;
ALTER TABLE IF EXISTS ONLY public.core_railstation DROP CONSTRAINT IF EXISTS core_railstation_pkey;
ALTER TABLE IF EXISTS ONLY public.core_populationcell DROP CONSTRAINT IF EXISTS core_populationcell_pkey;
ALTER TABLE IF EXISTS ONLY public.core_exchangerates DROP CONSTRAINT IF EXISTS core_exchangerates_pkey;
ALTER TABLE IF EXISTS ONLY public.core_district DROP CONSTRAINT IF EXISTS core_district_pkey;
ALTER TABLE IF EXISTS ONLY public.core_district DROP CONSTRAINT IF EXISTS core_district_osm_id_key;
ALTER TABLE IF EXISTS ONLY public.core_busstop DROP CONSTRAINT IF EXISTS core_busstop_pkey;
ALTER TABLE IF EXISTS ONLY public.core_busroute DROP CONSTRAINT IF EXISTS core_busroute_pkey;
ALTER TABLE IF EXISTS ONLY public.core_budgetplan DROP CONSTRAINT IF EXISTS core_budgetplan_pkey;
ALTER TABLE IF EXISTS ONLY public.auth_user DROP CONSTRAINT IF EXISTS auth_user_username_key;
ALTER TABLE IF EXISTS ONLY public.auth_user_user_permissions DROP CONSTRAINT IF EXISTS auth_user_user_permissions_user_id_permission_id_14a6b632_uniq;
ALTER TABLE IF EXISTS ONLY public.auth_user_user_permissions DROP CONSTRAINT IF EXISTS auth_user_user_permissions_pkey;
ALTER TABLE IF EXISTS ONLY public.auth_user DROP CONSTRAINT IF EXISTS auth_user_pkey;
ALTER TABLE IF EXISTS ONLY public.auth_user_groups DROP CONSTRAINT IF EXISTS auth_user_groups_user_id_group_id_94350c0c_uniq;
ALTER TABLE IF EXISTS ONLY public.auth_user_groups DROP CONSTRAINT IF EXISTS auth_user_groups_pkey;
ALTER TABLE IF EXISTS ONLY public.auth_permission DROP CONSTRAINT IF EXISTS auth_permission_pkey;
ALTER TABLE IF EXISTS ONLY public.auth_permission DROP CONSTRAINT IF EXISTS auth_permission_content_type_id_codename_01ab375a_uniq;
ALTER TABLE IF EXISTS ONLY public.auth_group DROP CONSTRAINT IF EXISTS auth_group_pkey;
ALTER TABLE IF EXISTS ONLY public.auth_group_permissions DROP CONSTRAINT IF EXISTS auth_group_permissions_pkey;
ALTER TABLE IF EXISTS ONLY public.auth_group_permissions DROP CONSTRAINT IF EXISTS auth_group_permissions_group_id_permission_id_0cd325b0_uniq;
ALTER TABLE IF EXISTS ONLY public.auth_group DROP CONSTRAINT IF EXISTS auth_group_name_key;
DROP TABLE IF EXISTS public.django_session;
DROP TABLE IF EXISTS public.django_migrations;
DROP TABLE IF EXISTS public.django_content_type;
DROP TABLE IF EXISTS public.django_admin_log;
DROP TABLE IF EXISTS public.core_transportscenario;
DROP TABLE IF EXISTS public.core_railstation;
DROP TABLE IF EXISTS public.core_populationcell;
DROP TABLE IF EXISTS public.core_exchangerates;
DROP TABLE IF EXISTS public.core_district;
DROP TABLE IF EXISTS public.core_busstop;
DROP TABLE IF EXISTS public.core_busroute;
DROP TABLE IF EXISTS public.core_budgetplan;
DROP TABLE IF EXISTS public.auth_user_user_permissions;
DROP TABLE IF EXISTS public.auth_user_groups;
DROP TABLE IF EXISTS public.auth_user;
DROP TABLE IF EXISTS public.auth_permission;
DROP TABLE IF EXISTS public.auth_group_permissions;
DROP TABLE IF EXISTS public.auth_group;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: auth_group; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_group (
    id integer NOT NULL,
    name character varying(150) NOT NULL
);


--
-- Name: auth_group_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.auth_group ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: auth_group_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_group_permissions (
    id bigint NOT NULL,
    group_id integer NOT NULL,
    permission_id integer NOT NULL
);


--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.auth_group_permissions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_group_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: auth_permission; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_permission (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    content_type_id integer NOT NULL,
    codename character varying(100) NOT NULL
);


--
-- Name: auth_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.auth_permission ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_permission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: auth_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_user (
    id integer NOT NULL,
    password character varying(128) NOT NULL,
    last_login timestamp with time zone,
    is_superuser boolean NOT NULL,
    username character varying(150) NOT NULL,
    first_name character varying(150) NOT NULL,
    last_name character varying(150) NOT NULL,
    email character varying(254) NOT NULL,
    is_staff boolean NOT NULL,
    is_active boolean NOT NULL,
    date_joined timestamp with time zone NOT NULL
);


--
-- Name: auth_user_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_user_groups (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    group_id integer NOT NULL
);


--
-- Name: auth_user_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.auth_user_groups ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_user_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: auth_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.auth_user ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: auth_user_user_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_user_user_permissions (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    permission_id integer NOT NULL
);


--
-- Name: auth_user_user_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.auth_user_user_permissions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_user_user_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_budgetplan; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_budgetplan (
    id bigint NOT NULL,
    name character varying(120) NOT NULL,
    mode character varying(10) NOT NULL,
    currency character varying(3) NOT NULL,
    money jsonb NOT NULL,
    units jsonb NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: core_budgetplan_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_budgetplan ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_budgetplan_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_busroute; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_busroute (
    id bigint NOT NULL,
    short_name character varying(10) NOT NULL,
    long_name character varying(200) NOT NULL,
    color character varying(7) NOT NULL,
    fleet smallint NOT NULL,
    vehicles_seen smallint NOT NULL,
    trips_per_day integer NOT NULL,
    peak_headway double precision NOT NULL,
    avg_headway double precision NOT NULL,
    trip_minutes smallint NOT NULL,
    first_departure character varying(5) NOT NULL,
    last_departure character varying(5) NOT NULL,
    days_observed smallint NOT NULL,
    shape jsonb NOT NULL,
    CONSTRAINT core_busroute_days_observed_check CHECK ((days_observed >= 0)),
    CONSTRAINT core_busroute_fleet_check CHECK ((fleet >= 0)),
    CONSTRAINT core_busroute_trip_minutes_check CHECK ((trip_minutes >= 0)),
    CONSTRAINT core_busroute_trips_per_day_check CHECK ((trips_per_day >= 0)),
    CONSTRAINT core_busroute_vehicles_seen_check CHECK ((vehicles_seen >= 0))
);


--
-- Name: core_busroute_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_busroute ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_busroute_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_busstop; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_busstop (
    id bigint NOT NULL,
    name character varying(120) NOT NULL,
    lat double precision NOT NULL,
    lon double precision NOT NULL,
    source character varying(10) NOT NULL,
    routes jsonb NOT NULL,
    district_id bigint NOT NULL
);


--
-- Name: core_busstop_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_busstop ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_busstop_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_district; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_district (
    id bigint NOT NULL,
    osm_id bigint NOT NULL,
    name character varying(60) NOT NULL,
    name_kk character varying(60) NOT NULL,
    population integer NOT NULL,
    population_share double precision NOT NULL,
    population_change double precision,
    t1_congestion smallint,
    t2_accessibility smallint,
    color character varying(7) NOT NULL,
    area_km2 double precision NOT NULL,
    bbox jsonb NOT NULL,
    outline jsonb NOT NULL,
    holes jsonb NOT NULL,
    CONSTRAINT core_district_population_check CHECK ((population >= 0)),
    CONSTRAINT core_district_t1_congestion_check CHECK ((t1_congestion >= 0)),
    CONSTRAINT core_district_t2_accessibility_check CHECK ((t2_accessibility >= 0))
);


--
-- Name: core_district_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_district ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_district_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_exchangerates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_exchangerates (
    id bigint NOT NULL,
    base character varying(3) NOT NULL,
    rates jsonb NOT NULL,
    source_updated_at timestamp with time zone,
    fetched_at timestamp with time zone NOT NULL
);


--
-- Name: core_exchangerates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_exchangerates ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_exchangerates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_populationcell; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_populationcell (
    id bigint NOT NULL,
    lat double precision NOT NULL,
    lon double precision NOT NULL,
    population double precision NOT NULL,
    district_id bigint NOT NULL
);


--
-- Name: core_populationcell_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_populationcell ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_populationcell_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_railstation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_railstation (
    id bigint NOT NULL,
    name character varying(120) NOT NULL,
    name_en character varying(120) NOT NULL,
    kind character varying(4) NOT NULL,
    lat double precision NOT NULL,
    lon double precision NOT NULL,
    district_id bigint
);


--
-- Name: core_railstation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_railstation ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_railstation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_transportscenario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_transportscenario (
    id bigint NOT NULL,
    data jsonb NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: core_transportscenario_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_transportscenario ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_transportscenario_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_admin_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.django_admin_log (
    id integer NOT NULL,
    action_time timestamp with time zone NOT NULL,
    object_id text,
    object_repr character varying(200) NOT NULL,
    action_flag smallint NOT NULL,
    change_message text NOT NULL,
    content_type_id integer,
    user_id integer NOT NULL,
    CONSTRAINT django_admin_log_action_flag_check CHECK ((action_flag >= 0))
);


--
-- Name: django_admin_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.django_admin_log ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_admin_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_content_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.django_content_type (
    id integer NOT NULL,
    app_label character varying(100) NOT NULL,
    model character varying(100) NOT NULL
);


--
-- Name: django_content_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.django_content_type ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_content_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.django_migrations (
    id bigint NOT NULL,
    app character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    applied timestamp with time zone NOT NULL
);


--
-- Name: django_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.django_migrations ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_migrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_session; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.django_session (
    session_key character varying(40) NOT NULL,
    session_data text NOT NULL,
    expire_date timestamp with time zone NOT NULL
);


--
-- Data for Name: auth_group; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.auth_group (id, name) FROM stdin;
\.


--
-- Data for Name: auth_group_permissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.auth_group_permissions (id, group_id, permission_id) FROM stdin;
\.


--
-- Data for Name: auth_permission; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.auth_permission (id, name, content_type_id, codename) FROM stdin;
1	Can add log entry	1	add_logentry
2	Can change log entry	1	change_logentry
3	Can delete log entry	1	delete_logentry
4	Can view log entry	1	view_logentry
5	Can add permission	3	add_permission
6	Can change permission	3	change_permission
7	Can delete permission	3	delete_permission
8	Can view permission	3	view_permission
9	Can add group	2	add_group
10	Can change group	2	change_group
11	Can delete group	2	delete_group
12	Can view group	2	view_group
13	Can add user	4	add_user
14	Can change user	4	change_user
15	Can delete user	4	delete_user
16	Can view user	4	view_user
17	Can add content type	5	add_contenttype
18	Can change content type	5	change_contenttype
19	Can delete content type	5	delete_contenttype
20	Can view content type	5	view_contenttype
21	Can add session	6	add_session
22	Can change session	6	change_session
23	Can delete session	6	delete_session
24	Can view session	6	view_session
25	Can add location	7	add_location
26	Can change location	7	change_location
27	Can delete location	7	delete_location
28	Can view location	7	view_location
29	Can add metric	8	add_metric
30	Can change metric	8	change_metric
31	Can delete metric	8	delete_metric
32	Can view metric	8	view_metric
33	Can add waitlist signup	9	add_waitlistsignup
34	Can change waitlist signup	9	change_waitlistsignup
35	Can delete waitlist signup	9	delete_waitlistsignup
36	Can view waitlist signup	9	view_waitlistsignup
37	Can add budget plan	10	add_budgetplan
38	Can change budget plan	10	change_budgetplan
39	Can delete budget plan	10	delete_budgetplan
40	Can view budget plan	10	view_budgetplan
41	Can add exchange rates	11	add_exchangerates
42	Can change exchange rates	11	change_exchangerates
43	Can delete exchange rates	11	delete_exchangerates
44	Can view exchange rates	11	view_exchangerates
45	Can add bus route	12	add_busroute
46	Can change bus route	12	change_busroute
47	Can delete bus route	12	delete_busroute
48	Can view bus route	12	view_busroute
49	Can add transport scenario	17	add_transportscenario
50	Can change transport scenario	17	change_transportscenario
51	Can delete transport scenario	17	delete_transportscenario
52	Can view transport scenario	17	view_transportscenario
53	Can add district	14	add_district
54	Can change district	14	change_district
55	Can delete district	14	delete_district
56	Can view district	14	view_district
57	Can add rail station	16	add_railstation
58	Can change rail station	16	change_railstation
59	Can delete rail station	16	delete_railstation
60	Can view rail station	16	view_railstation
61	Can add population cell	15	add_populationcell
62	Can change population cell	15	change_populationcell
63	Can delete population cell	15	delete_populationcell
64	Can view population cell	15	view_populationcell
65	Can add bus stop	13	add_busstop
66	Can change bus stop	13	change_busstop
67	Can delete bus stop	13	delete_busstop
68	Can view bus stop	13	view_busstop
\.


--
-- Data for Name: auth_user; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.auth_user (id, password, last_login, is_superuser, username, first_name, last_name, email, is_staff, is_active, date_joined) FROM stdin;
\.


--
-- Data for Name: auth_user_groups; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.auth_user_groups (id, user_id, group_id) FROM stdin;
\.


--
-- Data for Name: auth_user_user_permissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.auth_user_user_permissions (id, user_id, permission_id) FROM stdin;
\.


--
-- Data for Name: core_budgetplan; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.core_budgetplan (id, name, mode, currency, money, units, updated_at) FROM stdin;
1	Astana city budget	money	KZT	{"split": "equal", "total": "1000000000.00", "allocations": {"city": "200000000.00", "safety": "200000000.00", "social": "200000000.00", "greenery": "200000000.00", "transport": "200000000.00"}}	{"split": "equal", "total": "10000", "allocations": {"city": "2000", "safety": "2000", "social": "2000", "greenery": "2000", "transport": "2000"}}	2026-09-23 10:00:22.199017+00
\.


--
-- Data for Name: core_busroute; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.core_busroute (id, short_name, long_name, color, fleet, vehicles_seen, trips_per_day, peak_headway, avg_headway, trip_minutes, first_departure, last_departure, days_observed, shape) FROM stdin;
7	46	Karasu Street – Comfort Town – Karasu Street	#8E44AD	21	83	158	10.4	10.8	96	06:00	22:32	55	{"1": [[71.336176, 51.2002], [71.332534, 51.199202], [71.329542, 51.198032], [71.326759, 51.195531], [71.333633, 51.190785], [71.331741, 51.188188], [71.336499, 51.186986], [71.342774, 51.184701], [71.348129, 51.183275], [71.351165, 51.182882], [71.352844, 51.185123], [71.354588, 51.186014], [71.359345, 51.184823], [71.364728, 51.183492], [71.370006, 51.182213], [71.375246, 51.181185], [71.39805, 51.175483], [71.406421, 51.174294], [71.407836, 51.168656], [71.408992, 51.165119], [71.409894, 51.161876], [71.412344, 51.152474], [71.410961, 51.143451], [71.409255, 51.139146], [71.407758, 51.135727], [71.406852, 51.133596], [71.406038, 51.126641], [71.413462, 51.126971], [71.41924, 51.127479], [71.425135, 51.126475], [71.434369, 51.130015], [71.438057, 51.129666], [71.438909, 51.128731], [71.434479, 51.11695], [71.432458, 51.112013], [71.431061, 51.108051], [71.429513, 51.103887], [71.427752, 51.098826], [71.425912, 51.093429], [71.429894, 51.090648], [71.437556, 51.089541]], "2": [[71.449045, 51.091371], [71.444982, 51.088501], [71.439612, 51.089233], [71.432873, 51.090195], [71.426175, 51.092836], [71.427621, 51.096744], [71.429179, 51.100996], [71.430719, 51.104883], [71.432403, 51.109783], [71.433985, 51.114246], [71.435278, 51.118202], [71.438133, 51.125828], [71.438057, 51.129666], [71.430626, 51.125954], [71.423095, 51.127124], [71.406553, 51.131155], [71.408445, 51.136214], [71.409835, 51.139728], [71.411519, 51.143945], [71.412726, 51.148229], [71.412781, 51.153112], [71.410281, 51.162113], [71.409464, 51.165023], [71.408097, 51.169754], [71.407056, 51.173858], [71.398737, 51.175852], [71.392767, 51.176964], [71.373284, 51.181974], [71.368327, 51.183288], [71.362819, 51.184704], [71.358148, 51.185614], [71.351221, 51.183159], [71.348477, 51.183249], [71.342767, 51.184743], [71.340728, 51.185624], [71.335649, 51.187087], [71.331761, 51.188421], [71.333291, 51.191766], [71.326084, 51.193952], [71.327803, 51.196568], [71.336883, 51.200259], [71.336989, 51.201686], [71.33248, 51.200851]]}
8	10	Astana Railway Station – International Airport – Astana Railway Station	#E4572E	22	35	129	10.7	11.3	88	06:00	22:28	55	{"1": [[71.408673, 51.190697], [71.412379, 51.189515], [71.415359, 51.187413], [71.417188, 51.180703], [71.418487, 51.17573], [71.421875, 51.170907], [71.426572, 51.167332], [71.427507, 51.163984], [71.42857, 51.160341], [71.429438, 51.157355], [71.438775, 51.151905], [71.444438, 51.150663], [71.438057, 51.129666], [71.434369, 51.130015], [71.426564, 51.131258], [71.419177, 51.132429], [71.413143, 51.127682], [71.413462, 51.126971], [71.412388, 51.122751], [71.411521, 51.117798], [71.410845, 51.113741], [71.408628, 51.106637], [71.406344, 51.100272], [71.403492, 51.092419], [71.402369, 51.089197], [71.399555, 51.081376], [71.398449, 51.078323], [71.396747, 51.073524], [71.401264, 51.067075], [71.406409, 51.063899], [71.412648, 51.059963], [71.421896, 51.054624], [71.431166, 51.047042], [71.43112, 51.042645], [71.433817, 51.041765], [71.437795, 51.041761]], "2": [[71.438528, 51.041884], [71.432969, 51.041854], [71.43129, 51.042514], [71.431283, 51.045979], [71.431283, 51.045979], [71.430155, 51.04938], [71.421386, 51.054871], [71.412235, 51.060467], [71.406157, 51.064276], [71.399967, 51.068135], [71.397507, 51.074303], [71.400593, 51.083368], [71.402941, 51.089881], [71.404511, 51.093909], [71.406832, 51.100724], [71.40968, 51.10846], [71.410926, 51.112486], [71.412062, 51.119061], [71.413003, 51.123533], [71.417948, 51.132835], [71.419177, 51.132429], [71.424826, 51.131715], [71.426564, 51.131258], [71.438057, 51.129666], [71.445312, 51.142342], [71.444833, 51.149138], [71.443195, 51.152045], [71.437263, 51.152195], [71.429667, 51.15801], [71.428652, 51.161684], [71.427414, 51.165925], [71.421858, 51.171026], [71.419598, 51.172931], [71.418492, 51.177301], [71.416792, 51.182818], [71.415691, 51.186782], [71.413766, 51.189287], [71.408363, 51.19091], [71.407909, 51.192853], [71.407909, 51.192853]]}
9	12	Astana Railway Station – International Airport – Astana Railway Station	#3E7CB1	13	83	99	16.6	15.8	89	06:00	22:31	55	{"1": [[71.406632, 51.190469], [71.407598, 51.187289], [71.408368, 51.184623], [71.410055, 51.178385], [71.408387, 51.175396], [71.406421, 51.174294], [71.407836, 51.168656], [71.408992, 51.165119], [71.409894, 51.161876], [71.412344, 51.152474], [71.410961, 51.143451], [71.409255, 51.139146], [71.407758, 51.135727], [71.419177, 51.132429], [71.426564, 51.131258], [71.434369, 51.130015], [71.438057, 51.129666], [71.438909, 51.128731], [71.434479, 51.11695], [71.432458, 51.112013], [71.431061, 51.108051], [71.429513, 51.103887], [71.427752, 51.098826], [71.425912, 51.093429], [71.424571, 51.089811], [71.42304, 51.0855], [71.421862, 51.082013], [71.420348, 51.078073], [71.419182, 51.074826], [71.417835, 51.071015], [71.416031, 51.066046], [71.41454, 51.061706], [71.421896, 51.054624], [71.431166, 51.047042], [71.427101, 51.044585], [71.425602, 51.042905], [71.428509, 51.041784], [71.433817, 51.041765], [71.437795, 51.041761]], "2": [[71.438528, 51.041884], [71.432969, 51.041854], [71.427554, 51.041973], [71.428648, 51.044536], [71.431283, 51.045979], [71.431283, 51.045979], [71.430155, 51.04938], [71.421386, 51.054871], [71.414896, 51.061502], [71.417109, 51.067273], [71.418672, 51.07175], [71.42027, 51.076055], [71.421862, 51.080955], [71.423319, 51.084602], [71.424578, 51.088105], [71.426175, 51.092836], [71.427621, 51.096744], [71.429179, 51.100996], [71.430719, 51.104883], [71.432403, 51.109783], [71.433985, 51.114246], [71.435278, 51.118202], [71.438133, 51.125828], [71.438057, 51.129666], [71.426564, 51.131258], [71.424826, 51.131715], [71.419177, 51.132429], [71.417948, 51.132835], [71.408445, 51.136214], [71.409835, 51.139728], [71.411519, 51.143945], [71.412726, 51.148229], [71.412781, 51.153112], [71.410281, 51.162113], [71.409464, 51.165023], [71.408097, 51.169754], [71.407056, 51.173858], [71.40843, 51.175269], [71.410194, 51.179925], [71.409529, 51.182389], [71.408547, 51.185903], [71.407519, 51.189325], [71.407909, 51.192853], [71.407909, 51.192853]]}
\.


--
-- Data for Name: core_busstop; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.core_busstop (id, name, lat, lon, source, routes, district_id) FROM stdin;
2005	Bus stop	51.1508857	71.474053	osm	[]	14
2006	Bus stop	51.1515648	71.474363	osm	[]	14
2007	ТД Меридиан	51.1503866	71.4695517	osm	[]	14
2008	ТД Мередиан	51.1496312	71.4696413	osm	[]	14
2009	Еуразия	51.148479	71.4705425	osm	[]	14
2010	Bus stop	51.1551334	71.4735895	osm	[]	14
2011	Институт травматологии и ортопедии	51.1581837	71.4769734	osm	[]	14
2012	Сымбат	51.196194	71.3923062	osm	[]	15
2013	Железнодорожный колледж	51.1949113	71.3965049	osm	[]	15
2014	Парк Ж. Жабаева	51.1521204	71.4433247	osm	["10", "12", "46"]	16
2015	Микрорайон Жастар	51.1582029	71.4429038	osm	[]	16
2016	Bus stop	51.1413523	71.5805757	osm	[]	14
2017	Bus stop	51.1423013	71.5741679	osm	[]	14
2018	Bus stop	51.144563	71.5637181	osm	[]	14
2019	Bus stop	51.1432874	71.5699515	osm	[]	14
2020	Bus stop	51.1546058	71.4785893	osm	[]	14
2021	Bus stop	51.1500994	71.5521475	osm	[]	14
2022	Bus stop	51.1450701	71.5622326	osm	[]	14
2023	Bus stop	51.1547967	71.5715507	osm	[]	14
2024	улица Ж. Жабаева	51.1465711	71.5542021	osm	[]	14
2025	Встреча	51.1551738	71.4848441	osm	[]	14
2026	Встреча	51.1540922	71.4867378	osm	[]	14
2027	Бараева	51.1576398	71.4360618	osm	[]	16
2028	Бараева	51.1585931	71.4382401	osm	[]	16
2029	№15 мектеп-лицей	51.1784142	71.4100935	osm	["12", "46"]	15
2030	переулок Мукана Тулеубаева	51.2019528	71.3716144	osm	[]	15
2031	Ұялы тұйық көшесі	51.2001893	71.3652728	osm	[]	15
2032	Герцен көшесі	51.1966635	71.3665216	osm	[]	15
2033	Назарбаев Университеті	51.0898408	71.4031285	osm	["10", "12"]	13
2034	Назарбаев Университеті	51.0891323	71.4022552	osm	["10", "12"]	18
2035	International Airport – 2	51.0283122	71.4623786	osm	["10", "12"]	13
2036	Нұра-Есіл каналы	51.0604917	71.4122304	osm	["10", "12"]	13
2037	Цирк	51.1435999	71.4205643	osm	[]	13
2038	Bus stop	51.1447053	71.4207808	osm	[]	18
2039	Bus stop	51.1953963	71.4340023	osm	[]	16
2040	Парк Ж.Жабаева	51.1508712	71.4443261	osm	["10", "12", "46"]	16
2041	ЖК Номад	51.1247616	71.4234039	osm	[]	13
2042	Думан	51.1469193	71.4186513	osm	[]	18
2043	Республиканская школа Жас-Улан	51.1466842	71.3758792	osm	[]	18
2044	АО "Народный Банк"	51.1659381	71.4275336	osm	["10"]	16
2045	Bus stop	51.1660894	71.4330481	osm	[]	16
2046	Bus stop	51.1666547	71.437916	osm	[]	16
2047	Bus stop	51.1668936	71.4378934	osm	[]	16
2048	Шокана Уалиханова	51.1676898	71.4399078	osm	[]	16
2049	Bus stop	51.1684211	71.4393725	osm	[]	16
2050	Жаннур	51.1697947	71.4377792	osm	[]	16
2051	Евразийский национальный университет	51.1557929	71.4720954	osm	[]	14
2052	Дворец Жастар	51.1716997	71.4275105	osm	[]	16
2053	ЦОН района «Сарыарка»	51.1735932	71.4253229	osm	[]	16
2054	House of Ministries	51.1296748	71.4381133	osm	["10", "12", "46"]	13
2055	Монумент Байтерек	51.130003	71.4344846	osm	["10", "12", "46"]	13
2056	Bus stop	51.1878779	71.4208499	osm	[]	15
2057	Ильяса Есенберлина	51.1893528	71.4135102	osm	["10", "12"]	15
2058	Нұра-Есіл каналы	51.0598975	71.4128049	osm	["10", "12"]	13
2059	Bus stop	51.0660456	71.4160309	osm	["10", "12"]	13
2060	Е 319	51.0672733	71.4171086	osm	["10", "12"]	13
2061	Детский сад Карлыгаш-2	51.0704519	71.4176157	osm	[]	13
2062	Детский сад Карлыгаш-2	51.0716598	71.4186834	osm	["10", "12"]	13
2063	Bus stop	51.0748255	71.4191817	osm	["10", "12"]	13
2064	Bus stop	51.0760551	71.4202701	osm	["10", "12"]	13
2065	Bus stop	51.0780728	71.4203477	osm	["10", "12"]	13
2066	Асыл-Тау	51.1191136	71.4121504	osm	["10", "12"]	13
2067	Асыл-Тау	51.1177458	71.411511	osm	["10", "12"]	18
2068	Астана Арена	51.1084605	71.40968	osm	["10", "12"]	13
2069	Астана Арена	51.1065896	71.408429	osm	["10", "12"]	18
2070	Алау мұз айдыны	51.1007236	71.4068324	osm	["10", "12"]	13
2071	Алау мұз айдыны	51.1002308	71.4063276	osm	["10", "12"]	18
2072	Экспо-Плаза	51.0924187	71.4034923	osm	["10", "12"]	18
2073	Экспо-Плаза	51.0939087	71.4045112	osm	["10", "12"]	13
2074	Акбулак	51.0743153	71.3974065	osm	["10", "12"]	13
2075	Акбулак	51.0735086	71.3967778	osm	["10", "12"]	18
2076	трасса Каркаралы	51.0681204	71.3999959	osm	["10", "12"]	13
2077	трасса Каркаралы	51.0669361	71.4013568	osm	["10", "12"]	13
2078	дачный масив "Авиатор"	51.0544928	71.4214576	osm	["10", "12"]	13
2079	дачный масив "Авиатор"	51.0548706	71.4213864	osm	["10", "12"]	13
2080	улица Сарытогай	51.0459788	71.4312831	osm	["10", "12"]	13
2081	улица Сарытогай	51.0466013	71.43099	osm	[]	13
2082	Жилой массив "Пригородный"	51.0425143	71.4312896	osm	["10", "12"]	13
2083	Жилой массив "Пригородный"	51.0426454	71.4311203	osm	["10", "12"]	13
2084	Нейрохирургия орталығы	51.1235329	71.413003	osm	["10", "12"]	13
2085	Нейрохирургия орталығы	51.1227114	71.4123378	osm	["10", "12"]	18
2086	Ұлттық кардиохирургиялық орталық	51.1268527	71.4134746	osm	["10", "12", "46"]	13
2087	Ұлттық кардиохирургиялық орталық	51.1276695	71.4131502	osm	["10", "12", "46"]	18
2088	Қонаев көшесі	51.1327964	71.4180775	osm	["10", "12", "46"]	13
2089	Қонаев көшесі	51.1323522	71.4192519	osm	["10", "12", "46"]	13
2090	Национальная компания Казахстан Темир Жолы	51.1311826	71.4267075	osm	["10", "12", "46"]	13
2091	Национальная компания Казахстан Темир Жолы	51.1317683	71.4248889	osm	["10", "12", "46"]	13
2092	House of Ministries	51.1303324	71.4400329	osm	[]	13
2093	Парк Ататюрк	51.1518742	71.4389712	osm	["10", "12", "46"]	16
2094	микрорайон Самал	51.1572177	71.4294054	osm	["10", "12", "46"]	15
2095	Samal	51.1580039	71.429706	osm	["10", "12", "46"]	16
2096	Улица Ж. Тархана	51.1603409	71.4285696	osm	["10", "12"]	15
2097	улица А. Иманова	51.1616314	71.4286821	osm	["10", "12", "46"]	16
2098	улица А. Иманова	51.1639292	71.4275217	osm	["10", "12"]	15
2099	АО "Народный Банк"	51.1672902	71.4265765	osm	["10", "12"]	15
2100	Банк КазКом	51.1710797	71.4220604	osm	["10"]	15
2101	Банк КазКом	51.1707518	71.4210043	osm	[]	15
2102	улица А. Жангельдина	51.1729313	71.4195984	osm	["10"]	15
2103	Бейбітшілік көшесі	51.1756421	71.4184515	osm	["10"]	15
2104	Политехнический колледж	51.1773011	71.4184919	osm	["10"]	15
2105	Bus stop	51.1557851	71.4988121	osm	[]	14
2106	Bus stop	51.1561629	71.499529	osm	[]	14
2107	Bus stop	51.1533949	71.4960592	osm	[]	14
2108	Bus stop	51.1534271	71.4959167	osm	[]	14
2109	Bus stop	51.1521139	71.4921315	osm	[]	14
2110	Bus stop	51.1510255	71.4950066	osm	[]	14
2111	Ұлттық ғылыми медициналық орталықтың	51.1501543	71.497856	osm	[]	14
2112	Средняя школа №38	51.1530912	71.5012555	osm	[]	14
2113	Торговый дом "Айтолкын"	51.1511437	71.4997939	osm	[]	14
2114	Средняя школа №38	51.1534219	71.5019777	osm	[]	14
2115	"Мирас" мектебі	51.152766	71.490922	osm	[]	14
2116	Манаса	51.1570055	71.4888981	osm	[]	14
2117	Микрорайон Аль-Фараби	51.159076	71.4918974	osm	[]	14
2118	7-я поликлиника	51.1544738	71.5040079	osm	[]	14
2119	Дастан	51.1558717	71.5000994	osm	[]	14
2120	Микрорайон №9	51.1511038	71.5068466	osm	[]	14
2121	Силети	51.1485568	71.5044563	osm	[]	14
2122	Ғ. Мұстафин көшесі	51.148993	71.5009125	osm	[]	14
2123	Силети	51.1493853	71.5058434	osm	[]	14
2124	Ә. Молдағұлова көшесі	51.1848501	71.4064504	osm	[]	15
2125	Теміржол вокзалы	51.1947659	71.4090914	osm	["10", "12", "46"]	15
2126	Abylai khan avenue	51.1597297	71.4726822	osm	[]	14
2127	МЦ "Астана-Эколайф"	51.1935817	71.4647269	osm	[]	16
2128	Агротехнический университет	51.1867086	71.4157646	osm	["10", "12"]	15
2129	Шапагат	51.178365	71.4325597	osm	[]	15
2130	Театр Жастар	51.1905826	71.4065876	osm	["10", "12"]	15
2131	Театр Жастар	51.189357	71.4075471	osm	["12"]	15
2132	Дәулет сауда үйі	51.1928527	71.4079089	osm	["10", "12"]	15
2133	Bus stop	51.1546848	71.5040964	osm	[]	14
2134	Музыкальная академия	51.1739151	71.411796	osm	[]	15
2135	Улица Сусамыр	51.2164997	71.38052	osm	[]	16
2136	Улица Сусамыр	51.2163026	71.38043	osm	[]	16
2137	Улица А. Молдагуловой	51.1854182	71.4103895	osm	[]	15
2138	Карбышева	51.1926492	71.3664983	osm	[]	15
2139	Карбышева	51.1921837	71.3674838	osm	[]	15
2140	Средняя школа №20	51.1918618	71.3808853	osm	[]	15
2141	Коктерек	51.194547	71.3727544	osm	[]	15
2142	Bus stop	51.1822512	71.3699849	osm	["12", "46"]	15
2143	Bus stop	51.1844604	71.3628517	osm	["46"]	15
2144	улица Медеу	51.1835287	71.3647558	osm	["12", "46"]	15
2145	Кладбище	51.1848597	71.3593196	osm	["12", "46"]	15
2146	Bus stop	51.1856273	71.3580879	osm	["46"]	15
2147	Bus stop	51.1860133	71.3545983	osm	["12", "46"]	15
2148	Bus stop	51.1869006	71.3528995	osm	[]	15
2149	Строительный рынок Саянур	51.1880674	71.3462529	osm	[]	15
2150	Bus stop	51.1890301	71.3441718	osm	[]	15
2151	Bus stop	51.1908635	71.3348475	osm	[]	15
2152	Bus stop	51.1916823	71.33327	osm	["46"]	15
2153	Акан Серы	51.1819223	71.3732832	osm	["46"]	15
2154	Бейбитшилик	51.1765098	71.4196913	osm	[]	15
2155	Агротехнический университет	51.1860599	71.4146003	osm	[]	15
2156	Астанинский медицинский университет	51.1807295	71.4170728	osm	["10", "12"]	15
2157	Астанинский медицинский университет	51.1829315	71.4169141	osm	["10"]	15
2158	Казахский Агротехнический университет имени С. Сейфулина	51.1871887	71.4153329	osm	["10", "12"]	15
2159	Улица А. Молдагуловой	51.1852432	71.4078935	osm	[]	15
2160	Улица А. Молдагуловой	51.1846227	71.4083684	osm	["12"]	15
2161	Театр Жастар	51.190851	71.4081554	osm	["10", "12"]	15
2162	Музыкальная Академия	51.17578	71.4126428	osm	[]	15
2163	Музыкальная Академия	51.1761283	71.412547	osm	[]	15
2164	ТД Орбита	51.1525985	71.4619897	osm	[]	14
2165	Микрорайон Жастар	51.1588009	71.4427704	osm	[]	16
2166	Микрорайон Жастар	51.1590103	71.4412138	osm	[]	16
2167	Bus stop	51.1614165	71.4417598	osm	[]	16
2168	Bus stop	51.1604323	71.4418024	osm	[]	16
2169	Бахус	51.1939107	71.400194	osm	[]	15
2170	Бахус	51.1936586	71.4004568	osm	[]	15
2171	Железнодорожный колледж	51.1947528	71.3977559	osm	[]	15
2172	Республика даңғылы	51.1654895	71.4262286	osm	[]	15
2173	Дворец Жастар	51.1715762	71.4281005	osm	[]	16
2174	Рынок "Артем"	51.1724594	71.4340251	osm	[]	16
2175	Рынок "Артем"	51.1724106	71.4352992	osm	[]	16
2176	Городская поликлиника № 1	51.1703123	71.4173688	osm	[]	15
2177	Городская поликлиника № 1	51.1706233	71.4182428	osm	[]	15
2178	Лицей № 9	51.1651874	71.4089205	osm	["12", "46"]	15
2179	Лицей № 9	51.1650228	71.4094638	osm	["12", "46"]	15
2180	Парк "Астаналык"	51.1531116	71.4127808	osm	["12", "46"]	18
2181	Парк Астана	51.152474	71.4123438	osm	["12", "46"]	18
2182	Думан	51.1482216	71.4127044	osm	["12", "46"]	18
2183	ТЦ Keruen City	51.1434738	71.4109169	osm	["12", "46"]	18
2184	ТЦ Keruen City	51.1439382	71.4115928	osm	["12", "46"]	18
2185	ТРЦ Сарыарка	51.1391538	71.409204	osm	["12", "46"]	18
2186	ТРЦ Сарыарка	51.1397388	71.4099219	osm	["12", "46"]	18
2187	Жағалау-3	51.1372074	71.3691332	osm	[]	18
2188	Астана Опера	51.1362398	71.4085309	osm	["12", "46"]	18
2189	Астана Опера	51.1357035	71.407855	osm	["12", "46"]	18
2190	Khan Shatyr	51.1334549	71.4068734	osm	["10", "12", "46"]	18
2191	Khan Shatyr	51.1311545	71.4065528	osm	["12", "46"]	18
2192	Хабар	51.1697536	71.4080971	osm	["12", "46"]	15
2193	Азат	51.1706136	71.4127883	osm	[]	15
2194	Азат	51.1710966	71.4121256	osm	[]	15
2195	Музыкальная академия	51.1745139	71.4112263	osm	[]	15
2196	Коктем	51.1755748	71.4074095	osm	[]	15
2197	Коктем	51.175269	71.4084299	osm	["12", "46"]	15
2198	Zhannur	51.1703163	71.4391462	osm	[]	16
2199	ТД Жаннур	51.1697971	71.4399743	osm	[]	16
2200	Номад	51.12448	71.4194406	osm	[]	13
2201	Номад	51.1243745	71.4220064	osm	[]	13
2202	Чехова	51.1929569	71.3778883	osm	[]	15
2203	Чехова	51.1930411	71.3780739	osm	[]	15
2204	Средняя школа №20	51.1918027	71.3815031	osm	[]	15
2205	ТД Арман	51.1989375	71.3912722	osm	[]	15
2206	Күләш Бәйсейітова көшесі	51.1961845	71.3909917	osm	[]	15
2207	ТД Арман	51.1994451	71.3903579	osm	[]	15
2208	Талапкер	51.1857972	71.3737573	osm	[]	15
2209	Ақан Серi	51.1833559	71.3754975	osm	[]	15
2210	Муса Жалел	51.1902336	71.3746398	osm	[]	15
2211	Муса Жалел	51.1897998	71.3763454	osm	[]	15
2212	Талапкер	51.1856205	71.3730537	osm	[]	15
2213	Герцен көшесі	51.1972035	71.3673641	osm	[]	15
2214	Завод Пенопласт	51.2053321	71.377166	osm	[]	15
2215	Дулатов көшесі	51.1989927	71.3682395	osm	[]	15
2216	переулок Мукана Тулеубаева	51.2029924	71.3728217	osm	[]	15
2217	Дулатова	51.1995309	71.369029	osm	[]	15
2218	Депо №1	51.2023555	71.3862396	osm	[]	15
2219	Депо №1	51.2027434	71.3856584	osm	[]	15
2220	Завод Пенопласт	51.2046254	71.3791085	osm	[]	15
2221	Bus stop	51.1795183	71.4243893	osm	[]	15
2222	Аламан	51.158066	71.4951548	osm	[]	14
2223	Bus stop	51.182389	71.4095289	osm	["12"]	15
2224	Bus stop	51.1858431	71.40849	osm	["12"]	15
2225	«Ақжайық» сауда үйі	51.1775842	71.4252919	osm	[]	15
2226	Bus stop	51.1772996	71.422815	osm	[]	15
2227	Мөлдiр	51.1924539	71.3878683	osm	[]	15
2228	Окжетпес	51.1904002	71.386427	osm	[]	15
2229	Окжетпес	51.1903784	71.3858918	osm	[]	15
2230	Мөлдiр	51.1937568	71.3892373	osm	[]	15
2231	Школа №26	51.1978865	71.3870391	osm	[]	15
2232	Институт травматологии и ортопедии	51.1583705	71.475586	osm	[]	14
2233	ЖК "Барыс"	51.1321717	71.4952889	osm	[]	14
2234	Улица Берен	51.1311979	71.4945323	osm	[]	14
2235	ЖК "Барыс"	51.1315427	71.4966493	osm	[]	14
2236	ЖК "Барыс"	51.1305277	71.4958883	osm	[]	14
2237	Улица Кумкент	51.1323489	71.4985958	osm	[]	14
2238	Кеген көшесі	51.1296948	71.489178	osm	[]	14
2239	Берен көшесі	51.1298771	71.4906906	osm	[]	14
2240	Кеген көшесі	51.1285221	71.4860954	osm	[]	14
2241	Сарыкол	51.1276536	71.4852849	osm	[]	14
2242	Сарыкол	51.1268229	71.4864847	osm	[]	14
2243	ТРЦ "Astana Mall"	51.1411485	71.4638586	osm	[]	14
2244	ТРЦ "Astana Mall"	51.1407935	71.4634965	osm	[]	14
2245	5 Поликлиника	51.1855965	71.3820813	osm	[]	15
2246	Айдана	51.1981571	71.3926286	osm	[]	15
2247	5 Поликлиника	51.1852817	71.3816373	osm	[]	15
2248	Шакпак	51.1866126	71.3827325	osm	[]	15
2249	Шакпак	51.1859945	71.3824093	osm	[]	15
2250	Агрогородок	51.1838476	71.3801766	osm	[]	15
2251	Агрогородок	51.1836813	71.3803263	osm	[]	15
2252	Коктерек	51.1946138	71.3730409	osm	[]	15
2253	Акан Серы	51.1810166	71.375024	osm	["12", "46"]	15
2254	Департамент Юстиции	51.1685077	71.4129785	osm	[]	15
2255	АТФ Банк	51.1679248	71.4135724	osm	[]	15
2256	Шапагат	51.1780064	71.4330429	osm	[]	16
2257	Тұран мейрамханасы	51.1406744	71.4764964	osm	[]	14
2258	Туран	51.1395605	71.4759315	osm	[]	14
2259	Баимбета Майлина	51.1441153	71.4736029	osm	[]	14
2260	Монумент защитников Отечества	51.1515966	71.4582592	osm	[]	14
2261	Отан қорғаушылар монументі	51.1520828	71.4560329	osm	[]	14
2262	Школа-лицей №53	51.139186	71.4771716	osm	[]	14
2263	ТД Орбита	51.1522332	71.4593203	osm	[]	14
2264	Микрорайон Целинный	51.1559107	71.4528615	osm	[]	16
2265	Bus stop	51.179129	71.4365095	osm	[]	15
2266	Каныша Сатпаева	51.1522703	71.4677791	osm	[]	14
2267	Тұлпар СО	51.1742839	71.4381252	osm	[]	16
2268	Автобусный парк № 12	51.1678288	71.4779788	osm	[]	16
2269	Автобусный парк № 12	51.1680579	71.4775712	osm	[]	16
2270	Bus stop	51.152062	71.4464307	osm	[]	16
2271	Мечта	51.1492489	71.4449474	osm	["10", "12", "46"]	14
2272	Микрорайон Целинный	51.1557868	71.452471	osm	[]	16
2273	Bus stop	51.1296062	71.5293646	osm	[]	17
2274	Bus stop	51.1147105	71.5337419	osm	[]	17
2275	Bus stop	51.114569	71.531682	osm	[]	17
2276	Вокзал Нурлы Жол	51.1125215	71.5327441	osm	[]	17
2277	Bus stop	51.1632438	71.4408705	osm	[]	16
2278	Сауда-экономикалық колледжі	51.167706	71.4481446	osm	[]	16
2279	Bus stop	51.1217044	71.6476205	osm	[]	14
2280	Алаш тасжолы	51.1886841	71.4541179	osm	[]	16
2281	Алаш тасжолы	51.1887134	71.4533331	osm	[]	16
2282	Алем	51.1801299	71.4354443	osm	[]	15
2283	Bus stop	51.1493368	71.4574521	osm	[]	14
2284	Bus stop	51.1568702	71.4795157	osm	[]	14
2285	Семейный спортивный центр SANA SPORT	51.154594	71.4691222	osm	[]	14
2286	Семейный спортивный центр SANA SPORT	51.1536704	71.4645222	osm	[]	14
2287	Думан	51.146338	71.4157703	osm	[]	18
2288	Bus stop	51.1492237	71.4248496	osm	[]	13
2289	Bus stop	51.1498361	71.4249516	osm	[]	18
2290	Евразийский национальный университет	51.1563696	71.475235	osm	[]	14
2291	Bus stop	51.1410256	71.4813128	osm	[]	14
2292	Bus stop	51.1425166	71.4863983	osm	[]	14
2293	Bus stop	51.1384693	71.4907864	osm	[]	14
2294	Bus stop	51.1355982	71.4928383	osm	[]	14
2295	Bus stop	51.1352178	71.4977735	osm	[]	14
2296	Bus stop	51.1363034	71.5015769	osm	[]	14
2297	Bus stop	51.1380267	71.507585	osm	[]	14
2298	Bus stop	51.1388615	71.510514	osm	[]	14
2299	А-426 көшесі	51.1123295	71.515224	osm	[]	17
2300	Bus stop	51.1134519	71.5106266	osm	[]	17
2301	Bus stop	51.1172374	71.5158464	osm	[]	17
2302	Bus stop	51.1177041	71.5147546	osm	[]	17
2303	Ильяса Есенберлина	51.1894977	71.4123291	osm	["10", "12"]	15
2304	Bus stop	51.1895508	71.3854172	osm	[]	15
2305	Bus stop	51.1936968	71.3361034	osm	[]	15
2306	Bus stop	51.1943961	71.3341963	osm	[]	15
2307	Bus stop	51.1952365	71.330688	osm	[]	15
2308	Bus stop	51.2084277	71.3193583	osm	[]	15
2309	Московская	51.1815927	71.4083648	osm	[]	15
2310	Bus stop	51.1796204	71.3924244	osm	[]	15
2311	Bus stop	51.1797297	71.392014	osm	[]	15
2312	Bus stop	51.134999	71.5280825	osm	[]	17
2313	Bus stop	51.1391377	71.5204021	osm	[]	14
2314	Детская больница № 2	51.1385434	71.5275085	osm	[]	17
2315	Детская больница № 2	51.1386535	71.5278259	osm	[]	14
2316	Городская больница № 1	51.1439995	71.5277874	osm	[]	14
2317	Bus stop	51.1460461	71.5265188	osm	[]	14
2318	Буктырма	51.1481906	71.5209827	osm	[]	14
2319	Школа-гимназия № 52	51.1504334	71.5152025	osm	[]	14
2320	проспект Шaкaрим Кудайбердыулы	51.1533608	71.5076333	osm	[]	14
2321	Bus stop	51.155304	71.5025023	osm	[]	14
2322	Bus stop	51.1570317	71.497854	osm	[]	14
2323	Bus stop	51.1577819	71.4892817	osm	[]	14
2324	Bus stop	51.1418452	71.4477825	osm	[]	14
2325	Bus stop	51.1418357	71.449723	osm	[]	14
2326	Bus stop	51.1299328	71.5298447	osm	[]	17
2327	Bus stop	51.1375033	71.4664909	osm	[]	14
2328	Tauelsizdik avenue	51.1365878	71.4655361	osm	[]	14
2329	Bus stop	51.1438561	71.4619419	osm	[]	14
2330	Bus stop	51.1445157	71.4608449	osm	[]	14
2331	Bus stop	51.0979935	71.4082555	osm	[]	13
2332	Тұрар Рысқұлов көшесі	51.0860524	71.4031595	osm	[]	13
2333	Bus stop	51.0852953	71.4084023	osm	[]	13
2334	Ұлттық ғылыми кардиохирургия орталығы	51.1183565	71.4018192	osm	[]	18
2335	Образовательный центр Сана	51.1217995	71.4023781	osm	[]	18
2336	Центр материнства и детства	51.1261975	71.4039499	osm	[]	18
2337	Bus stop	51.1271385	71.4230767	osm	["10", "12", "46"]	13
2338	Bus stop	51.1265448	71.4251125	osm	["10", "12", "46"]	13
2339	Bus stop	51.160571	71.4816776	osm	[]	14
2340	Bus stop	51.1611008	71.4818653	osm	[]	14
2341	Bus stop	51.1578627	71.4791375	osm	[]	14
2342	Bus stop	51.1225545	71.5216506	osm	[]	17
2343	Bus stop	51.1276755	71.5182817	osm	[]	17
2344	Bus stop	51.1297324	71.517131	osm	[]	17
2345	Bus stop	51.138641	71.5108976	osm	[]	14
2346	Bus stop	51.1363917	71.5024714	osm	[]	14
2347	Bus stop	51.1342231	71.494858	osm	[]	14
2348	Bus stop	51.1362461	71.4918137	osm	[]	14
2349	Bus stop	51.1389233	71.4898925	osm	[]	14
2350	Bus stop	51.1415254	71.4880612	osm	[]	14
2351	Bus stop	51.1253861	71.4325181	osm	[]	13
2352	Роза Бағланова ат. қазақконцерт	51.1250141	71.4365172	osm	[]	13
2353	Қорғаныс министрлігі	51.12595	71.4305735	osm	["12", "46"]	13
2354	Bus stop	51.1283034	71.4154726	osm	[]	13
2355	Бейбітшілік көшесі	51.1766392	71.4171302	osm	[]	15
2356	Bus stop	51.1170323	71.4342937	osm	["10", "12", "46"]	13
2357	ЖК Акжайык	51.1142369	71.4340083	osm	["10", "12", "46"]	13
2358	Қарлығаш балабақшасы	51.1097834	71.4324027	osm	["10", "12", "46"]	13
2359	Қарлығаш балабақшасы	51.1075874	71.4309329	osm	[]	13
2360	Bus stop	51.1009585	71.4292578	osm	["10", "12", "46"]	13
2361	Бухар жырау	51.0988262	71.4277518	osm	["10", "12", "46"]	13
2362	Bus stop	51.0966226	71.4178866	osm	[]	13
2363	Bus stop	51.0967122	71.4195894	osm	[]	13
2364	Bus stop	51.0960182	71.4244714	osm	[]	13
2365	Банный комплекс Керемет	51.1460722	71.4095986	osm	[]	18
2366	«12 месяцев» дүкені	51.191171	71.4601941	osm	[]	16
2367	Bus stop	51.1189972	71.4665633	osm	[]	17
2368	Bus stop	51.1186633	71.467316	osm	[]	17
2369	Bus stop	51.1262059	71.4692992	osm	[]	17
2370	Bus stop	51.1260556	71.4702668	osm	[]	17
2371	Bus stop	51.1322236	71.4704686	osm	[]	14
2372	Bus stop	51.0951292	71.4284422	osm	[]	13
2373	Bus stop	51.0929512	71.4437536	osm	[]	13
2374	Bus stop	51.0936257	71.4389192	osm	[]	13
2375	Bus stop	51.0928587	71.4470906	osm	[]	13
2376	Bus stop	51.1182089	71.4353842	osm	["10", "12", "46"]	13
2377	Сервис-центр Toyota	51.1467147	71.4598662	osm	[]	14
2378	Сервис-центр Toyota	51.1468077	71.4591199	osm	[]	14
2379	Гостиница Уйгентас	51.1912736	71.3947714	osm	[]	15
2380	Кафе Самурык	51.1881375	71.3916153	osm	[]	15
2381	Кафе Самурык	51.1884303	71.3919943	osm	[]	15
2382	Гостиница Уйгентас	51.1913204	71.394999	osm	[]	15
2383	Кожахметова	51.1868361	71.390275	osm	[]	15
2384	Кожахметова	51.186921	71.3905094	osm	[]	15
2385	ТЦ Астыкжан-2	51.1828305	71.3862994	osm	[]	15
2386	Ресторан Толеп	51.1843346	71.3773169	osm	[]	15
2387	Городская поликлиника №5	51.1845552	71.3800326	osm	[]	15
2388	Городская поликлиника №5	51.184629	71.3796576	osm	[]	15
2389	Ресторан Толеп	51.1832882	71.3765861	osm	[]	15
2390	Бокеева	51.2061944	71.3738486	osm	[]	15
2391	Ұялы тұйық көшесі	51.2002706	71.3644498	osm	[]	15
2392	Карасай батыра	51.1949951	71.4043059	osm	[]	15
2393	Школа №36	51.1968546	71.3984964	osm	[]	15
2394	Московская	51.1812393	71.4064361	osm	[]	15
2395	Школа №14	51.1808664	71.403038	osm	[]	15
2396	Окжетпес	51.189852	71.3856566	osm	[]	15
2397	Хабар	51.1692547	71.4070019	osm	[]	15
2398	Жағалау-3	51.136005	71.3691001	osm	[]	18
2399	Ильяса Омарова	51.1324657	71.3677445	osm	[]	18
2400	Дворец школьников	51.1359034	71.4669654	osm	[]	14
2401	БЦ Саад	51.1276865	71.4019073	osm	[]	18
2402	Республиканская школа Жас Улан	51.1472096	71.372906	osm	[]	18
2403	Bus stop	51.1486163	71.3897771	osm	[]	18
2404	КАЗГЮУ им. М.С. Нарикбаева	51.148088	71.3812905	osm	[]	18
2405	Bus stop	51.1718364	71.379346	osm	[]	15
2406	Bus stop	51.2091082	71.3176578	osm	[]	15
2407	Центр материнства и детства	51.1251454	71.40432	osm	[]	18
2408	Образовательный центр Сана	51.1224704	71.4033464	osm	[]	18
2409	Жилой комплекс Зелёный Квартал	51.1278101	71.3966837	osm	[]	18
2410	Bus stop	51.0808926	71.4219823	osm	["10", "12"]	13
2411	№3 көпбейінді қалалық балалар ауруханасы	51.0838935	71.4183533	osm	[]	13
2412	Перинатальной центр #1	51.0845978	71.4134234	osm	[]	13
2413	Тұрар Рысқұлов көшесі	51.085976	71.4057657	osm	[]	13
2414	Bus stop	51.085302	71.4105052	osm	[]	13
2415	Bus stop	51.157104	71.3958201	osm	[]	18
2416	Bus stop	51.171934	71.3811752	osm	[]	15
2417	Bus stop	51.1489242	71.365959	osm	[]	18
2418	Bus stop	51.135992	71.5397876	osm	[]	14
2419	Bus stop	51.1354417	71.4229506	osm	[]	13
2420	Bus stop	51.1346086	71.4259306	osm	[]	13
2421	Bus stop	51.1361465	71.4168296	osm	[]	13
2422	Парк Ататюрк	51.152253	71.4369598	osm	["10", "12", "46"]	16
2423	Деловой дом Алматы	51.1643171	71.4426449	osm	[]	16
2424	Bus stop	51.1647593	71.4439872	osm	[]	16
2425	Bus stop	51.1632186	71.4520687	osm	[]	16
2426	Bus stop	51.1613784	71.4578891	osm	[]	16
2427	Bus stop	51.1575918	71.4594743	osm	[]	16
2428	Bus stop	51.1462052	71.4632196	osm	[]	14
2429	Bus stop	51.1491311	71.4693783	osm	[]	14
2430	Конституции	51.1973296	71.3890759	osm	[]	15
2431	микрорайон Акбулак 2	51.1477338	71.4480703	osm	[]	14
2432	Bus stop	51.1934193	71.4122228	osm	[]	15
2433	Bus stop	51.0898113	71.4245711	osm	["10", "12", "46"]	13
2434	RC Promenade Expo (Lines 12, 27, 43, 46, 70)	51.0934699	71.4258947	osm	["10", "12", "46"]	13
2435	Bus stop	51.0973166	71.4132703	osm	[]	13
2436	Bus stop	51.0855001	71.4230402	osm	["10", "12"]	13
2437	Bus stop	51.0846022	71.423319	osm	["10", "12"]	13
2438	Bus stop	51.0981269	71.4096682	osm	[]	13
2439	RC Promenade Expo (Lines 12, 27, 43, 46, 70)	51.092434	71.4261375	osm	[]	13
2440	Bus stop	51.0881047	71.4245778	osm	["10", "12", "46"]	13
2441	Bus stop	51.0960604	71.4222463	osm	[]	13
2442	Орынбор Тауерс	51.0903717	71.4298902	osm	["46"]	13
2443	УДП	51.0966499	71.4277022	osm	["10", "12", "46"]	13
2444	Bus stop	51.0973311	71.4152408	osm	[]	13
2445	Bus stop	51.0937206	71.4413189	osm	[]	13
2446	ЖК Акжайык	51.1118478	71.4324357	osm	["10", "12", "46"]	13
2447	Роза Бағланова ат. қазақконцерт	51.1258281	71.4381327	osm	["12", "46"]	13
2448	House of Ministries	51.1285987	71.4388195	osm	["10", "12", "46"]	13
2449	Bus stop	51.1150795	71.4274552	osm	[]	13
2450	Bus stop	51.1013474	71.4225579	osm	[]	13
2451	Bus stop	51.0974894	71.4211804	osm	[]	13
2452	ЖК Уют	51.1208586	71.429699	osm	[]	13
2453	ЖК Уют	51.1200715	71.4289751	osm	[]	13
2454	Ұлттық ғылыми кардиохирургия орталығы	51.118782	71.4013085	osm	[]	18
2455	Bus stop	51.1118333	71.4168349	osm	[]	13
2456	Akkum street	51.110832	71.4428018	osm	[]	13
2457	Royal city Park town	51.106666	71.4486819	osm	[]	13
2458	Bus stop	51.115826	71.4148491	osm	[]	13
2459	улица Енбекшилер	51.1125344	71.4377806	osm	[]	13
2460	Автоцентр Сары-Арка	51.1463953	71.4045168	osm	[]	18
2461	Карашаш Ана	51.1466115	71.4004514	osm	[]	18
2462	Карашаш Ана	51.147309	71.3984947	osm	[]	18
2463	Бозарал	51.1476781	71.3933687	osm	[]	18
2464	Bus stop	51.1490442	71.3639595	osm	[]	18
2465	Bus stop	51.1498534	71.3607236	osm	[]	18
2466	№3 көпбейінді қалалық балалар ауруханасы	51.0839813	71.4194985	osm	[]	13
2467	Bus stop	51.0814596	71.4095593	osm	[]	13
2468	Bus stop	51.0823753	71.4031569	osm	[]	13
2469	Bus stop	51.0812852	71.3995207	osm	["10", "12"]	18
2470	Bus stop	51.0845942	71.4153024	osm	[]	13
2471	ЖК Кулагер	51.1321318	71.3661407	osm	[]	18
2472	ЖК Кулагер	51.1314418	71.3677261	osm	[]	18
2473	Bus stop	51.1308532	71.3762794	osm	[]	18
2474	№16 орта мектеп	51.1662511	71.4525327	osm	[]	16
2475	Bus stop	51.1203743	71.4979505	osm	[]	17
2476	Bus stop	51.1155085	71.5285907	osm	[]	17
2477	Bus stop	51.116081	71.5253144	osm	[]	17
2478	Bus stop	51.1357693	71.4600838	osm	[]	14
2479	Bus stop	51.1706111	71.3853117	osm	[]	15
2480	Bus stop	51.1649342	71.4560746	osm	[]	16
2481	Korday	51.1324651	71.5049328	osm	[]	14
2482	Ainakol	51.1334863	71.5026439	osm	[]	14
2483	Korday	51.1322279	71.5049225	osm	[]	14
2484	Ainakol	51.1339934	71.5053042	osm	[]	14
2485	Исатай батыр	51.1096362	71.2522799	osm	[]	18
2486	Исатай батыр	51.1099873	71.2543936	osm	[]	18
2487	Bus stop	51.1175274	71.2756865	osm	[]	18
2488	Bus stop	51.1111249	71.4641498	osm	[]	17
2489	Кошкарбаева	51.1258945	71.4797373	osm	[]	17
2490	Кошкарбаева	51.126119	71.4808384	osm	[]	14
2491	Нажимеденова	51.1201049	71.4649703	osm	[]	17
2492	Нажимеденова	51.1204386	71.4633421	osm	[]	17
2493	Bus stop	51.1337906	71.2709284	osm	[]	18
2494	Bus stop	51.1366198	71.2750483	osm	[]	18
2495	Bus stop	51.1366568	71.2761909	osm	[]	18
2496	Bus stop	51.1379426	71.2819898	osm	[]	18
2497	Улица Мурата Насырова	51.1305513	71.285757	osm	[]	18
2498	Шота Руставели	51.1275358	71.288749	osm	[]	18
2499	Шота Руставели	51.1263036	71.2895563	osm	[]	18
2500	АЗС Аурика	51.1318129	71.3105017	osm	[]	18
2501	АЗС Аурика	51.1311598	71.3085973	osm	[]	18
2502	Садоводческое общество	51.1282141	71.3047591	osm	[]	18
2503	Садоводческое общество	51.1281115	71.3036326	osm	[]	18
2504	Микрорайон Уркер	51.1262497	71.3002932	osm	[]	18
2505	Микрорайон Уркер	51.1259921	71.2982601	osm	[]	18
2506	Улица Шота Руставели	51.1237448	71.2931988	osm	[]	18
2507	Уркер-2	51.1234518	71.2911013	osm	[]	18
2508	Садоводческое общество	51.1216825	71.2874132	osm	[]	18
2509	ЖК Үркер city	51.1221741	71.2874588	osm	[]	18
2510	АЗС Тайм	51.1199109	71.2824289	osm	[]	18
2511	АЗС Тайм	51.1195645	71.2801552	osm	[]	18
2512	Улица 38	51.122499	71.2787792	osm	[]	18
2513	Улица 38	51.1241033	71.2776339	osm	[]	18
2514	Военный городок	51.1268187	71.2752038	osm	[]	18
2515	Военный городок	51.1268978	71.2744153	osm	[]	18
2516	Военный городок	51.1274533	71.2743026	osm	[]	18
2517	201-ші көше	51.1300035	71.2795973	osm	[]	18
2518	201-ші көше	51.1305673	71.2817028	osm	[]	18
2519	Улица Назыма Хикмета	51.1315857	71.2839371	osm	[]	18
2520	Bus stop	51.1361267	71.288183	osm	[]	18
2521	Уркер 3-я	51.1329288	71.2883681	osm	[]	18
2522	Еңлік балабақшасы	51.1347163	71.2900257	osm	[]	18
2523	Ұзақ Батыр көшесі	51.1294379	71.2959963	osm	[]	18
2524	Ұзақ Батыр көшесі	51.1302256	71.2955403	osm	[]	18
2525	Жаменке абыз	51.1328161	71.2931478	osm	[]	18
2526	Улица Жаменке абыз	51.1330062	71.2927401	osm	[]	18
2527	Ботаникалық бақ	51.1097974	71.4225746	osm	[]	13
2528	Ботаникалық бақ	51.109949	71.4239199	osm	[]	13
2529	Детский сад Айару	51.1104771	71.4202411	osm	[]	13
2530	Айару балабақшасы	51.1105352	71.4174024	osm	[]	13
2531	Времена года.Весна	51.1113908	71.4137664	osm	[]	13
2532	Времена года.Весна	51.111294	71.4121433	osm	[]	13
2533	Bus stop	51.1002111	71.425372	osm	[]	13
2534	№ 84 мектеп-лицей	51.1011055	71.4208582	osm	[]	13
2535	Бұқар Жырау көшесі	51.1023125	71.4114016	osm	[]	13
2536	Bus stop	51.1029771	71.3963558	osm	[]	18
2537	Bus stop	51.1032714	71.3958147	osm	[]	18
2538	Улица Курмангазы	51.193282	71.4366183	osm	[]	16
2539	Жилмассив Мичурино	51.1218626	71.6469151	osm	[]	14
2540	Жилмассив Мичурино	51.1217616	71.6464296	osm	[]	17
2541	Жилмассив Мичурино	51.1209922	71.6476795	osm	[]	17
2542	Улица Кызылтас	51.1190561	71.6464457	osm	[]	17
2543	Улица Кызылтас	51.117859	71.6460192	osm	[]	17
2544	Улица Кокил	51.1165306	71.6471913	osm	[]	17
2545	Улица Кокил	51.1160625	71.6483822	osm	[]	17
2546	Школа № 43	51.1128431	71.6459414	osm	[]	17
2547	Школа № 43	51.1128178	71.6455659	osm	[]	17
2548	Детский сад Арай	51.1123867	71.6481113	osm	[]	17
2549	Детский сад Арай	51.1124339	71.6484868	osm	[]	17
2550	Bus stop	51.1676928	71.5320058	osm	[]	14
2551	Локомотив шығаратын зауыт	51.1693912	71.5243167	osm	[]	14
2552	Локомотив шығаратын зауыт	51.1708551	71.526259	osm	[]	14
2553	Трубопроводный завод	51.1704389	71.5355605	osm	[]	14
2554	Трубопроводный завод	51.1687908	71.5372463	osm	[]	14
2555	Bus stop	51.1641384	71.5199578	osm	[]	14
2556	Bus stop	51.1633699	71.5184748	osm	[]	14
2557	Bus stop	51.1559256	71.529665	osm	[]	14
2558	Bus stop	51.1554559	71.5310016	osm	[]	14
2559	Единый консолидирующий центр	51.1595751	71.5215728	osm	[]	14
2560	Центр обучения технологиям транспорта	51.1596189	71.5224364	osm	[]	14
2561	Улица Акжар	51.1434674	71.5752813	osm	[]	14
2562	Улица Акжар	51.1437029	71.5753055	osm	[]	14
2563	Школа № 29	51.146386	71.5773359	osm	[]	14
2564	Воинская часть	51.1540809	71.5723067	osm	[]	14
2565	Воинская часть	51.15381	71.5723443	osm	[]	14
2566	Школа № 29	51.146259	71.5610549	osm	[]	14
2567	Школа № 29	51.1464407	71.5609878	osm	[]	14
2568	Кладбище	51.1510727	71.5664354	osm	[]	14
2569	Кладбище	51.1507749	71.566135	osm	[]	14
2570	По требованию	51.1531219	71.5636647	osm	[]	14
2571	По требованию	51.1524288	71.5625918	osm	[]	14
2572	улица Ж. Жабаева	51.1465198	71.5536091	osm	[]	14
2573	По требованию	51.1490111	71.5500637	osm	[]	14
2574	Интеллектуальная школа	51.0829213	71.3950932	osm	[]	18
2575	ЖК Family Village	51.0609704	71.420994	osm	[]	13
2576	ЖК Family Village	51.0614711	71.4215881	osm	[]	13
2577	Халықаралық балабақша	51.0639179	71.4254987	osm	[]	13
2578	Халықаралық балабақша	51.0647893	71.4263356	osm	[]	13
2579	A-82 көшесі	51.1107584	71.5250516	osm	[]	17
2580	ЖК Урбан	51.106577	71.5102887	osm	[]	17
2581	A-427 көшесі	51.1116088	71.5199219	osm	[]	17
2582	Bus stop	51.1621126	71.4102813	osm	["12", "46"]	15
2583	Bus stop	51.1012006	71.3956212	osm	[]	18
2584	Барыс арена	51.1071056	71.3979914	osm	[]	18
2585	Bus stop	51.111011	71.3993007	osm	[]	18
2586	ЖК Алтын кулек	51.1145766	71.4003866	osm	[]	18
2587	ЖК Sauran Towers	51.120483	71.4203119	osm	[]	13
2588	Алматы көшесі	51.117	71.4212288	osm	[]	13
2589	Ansar business centre	51.1235918	71.430722	osm	[]	13
2590	Сыртқы істер министрлігі	51.1335485	71.4320599	osm	[]	13
2591	Bus stop	51.1155553	71.4651805	osm	[]	17
2592	Bus stop	51.1090122	71.4624732	osm	[]	17
2593	Royal city Park town	51.1076213	71.447886	osm	[]	13
2594	Ұлттық ғылыми кардиохирургия орталығы	51.1172681	71.4024371	osm	[]	18
2595	Қан орталығы	51.1165709	71.4074025	osm	[]	18
2596	Парк имени Момышулы	51.1333555	71.4599817	osm	[]	14
2597	Туран	51.1411695	71.4827428	osm	[]	14
2598	Tauelsizdik avenue	51.1369572	71.4679769	osm	[]	14
2599	Туран	51.1397506	71.4778587	osm	[]	14
2600	Каныша Сатпаева	51.1520824	71.4682975	osm	[]	14
2601	Еуразия	51.1473847	71.4716857	osm	[]	14
2602	Супермаркет Спутник	51.1628278	71.4628229	osm	[]	16
2603	Bus stop	51.1639859	71.4696335	osm	[]	16
2604	Средняя школа №50	51.1461933	71.4711441	osm	[]	14
2605	Сауран	51.1165671	71.4180637	osm	[]	13
2606	Қан орталығы	51.1171237	71.4054894	osm	[]	18
2607	Bus stop	51.1265746	71.4616111	osm	[]	17
2608	проспект Тлендиева	51.1802103	71.3796304	osm	[]	15
2609	Bus stop	51.0750257	71.4117552	osm	[]	13
2610	Bus stop	51.0739246	71.407272	osm	[]	13
2611	Bus stop	51.0707162	71.4113861	osm	[]	13
2612	Bus stop	51.0732799	71.4140251	osm	[]	13
2613	Bus stop	51.0781084	71.4057672	osm	[]	13
2614	Bus stop	51.0714458	71.4143238	osm	[]	13
2615	Bus stop	51.0642259	71.4062233	osm	["10", "12"]	13
2616	Bus stop	51.0635739	71.4068323	osm	[]	13
2617	Bus stop	51.1270603	71.4723211	osm	[]	17
2618	Bus stop	51.1240576	71.4741508	osm	[]	17
2619	Bus stop	51.1246587	71.4752978	osm	[]	17
2620	Триумфальная арка Мангилик Ел	51.1046702	71.4307281	osm	["10", "12", "46"]	13
2621	Триумфальная арка Мангилик Ел	51.1038871	71.4295126	osm	["10", "12", "46"]	13
2622	Рио-Де-Жанейро	51.1730971	71.358212	osm	[]	15
2623	Рио-Де-Жанейро	51.173652	71.3573705	osm	[]	15
2624	Bus stop	51.1195409	71.4716769	osm	[]	17
2625	Bus stop	51.1209488	71.4739297	osm	[]	17
2626	Bus stop	51.1243209	71.4704947	osm	[]	17
2627	Bus stop	51.1197055	71.4685497	osm	[]	17
2628	SVOY DOM	51.1140551	71.3996603	osm	[]	18
2629	Bus stop	51.1169551	71.4007006	osm	[]	18
2630	Bus stop	51.1406683	71.3856577	osm	[]	18
2631	Bus stop	51.1464925	71.4729938	osm	[]	14
2632	Ресторан Алтын-адам	51.148113	71.4838738	osm	[]	14
2633	Городская поликлиника №6	51.1469533	71.4809745	osm	[]	14
2634	Городская поликлиника №6	51.1461241	71.4790735	osm	[]	14
2635	Алтын-адам	51.1470528	71.4841004	osm	[]	14
2636	Алтын-адам	51.1478957	71.4852144	osm	[]	14
2637	Bus stop	51.1817784	71.4224737	osm	[]	15
2638	Bus stop	51.1376926	71.4060729	osm	[]	18
2639	Bus stop	51.137265	71.4059908	osm	[]	18
2640	Bus stop	51.1904394	71.4572936	osm	[]	16
2641	Bus stop	51.1993066	71.4604736	osm	[]	16
2642	Bus stop	51.180478	71.3987118	osm	[]	15
2643	Bus stop	51.2004029	71.4558213	osm	[]	16
2644	Bus stop	51.1804541	71.399503	osm	[]	15
2645	Ақмешіт	51.1342224	71.4298843	osm	[]	13
2646	Bus stop	51.2016738	71.4108588	osm	[]	16
2647	Bus stop	51.1884977	71.4461716	osm	[]	16
2648	Bus stop	51.2036354	71.4123987	osm	[]	16
2649	Bus stop	51.1975126	71.4229955	osm	[]	16
2650	Bus stop	51.1709024	71.4221691	osm	["10"]	15
2651	Bus stop	51.1830228	71.5061522	osm	[]	14
2652	Bus stop	51.181443	71.5030502	osm	[]	14
2653	Bus stop	51.1693702	71.4088237	osm	[]	15
2654	Кенесары көшесі	51.1619475	71.4099655	osm	["12", "46"]	15
2655	Bus stop	51.1631326	71.4078817	osm	[]	15
2656	Binom school De Luxe	51.0803722	71.4379691	osm	[]	13
2657	“Венский квартал” тұрғын үй кешені	51.0858911	71.4311782	osm	[]	13
2658	Сембинов Әлмуқан	51.1672559	71.4489558	osm	[]	16
2659	Тұлпар СО	51.1752855	71.4378235	osm	[]	16
2660	Bus stop	51.1352831	71.3983071	osm	[]	18
2661	Керей Және Жәнібек Хандар көшесі	51.1133846	71.4225557	osm	[]	13
2662	Bus stop	51.1302157	71.3812023	osm	[]	18
2663	Bus stop	51.1295024	71.3833546	osm	[]	18
2664	Bus stop	51.1203409	71.4107597	osm	[]	18
2665	Bus stop	51.0990247	71.4034838	osm	[]	18
2666	Супермаркет Спутник	51.1628196	71.4632505	osm	[]	16
2667	Республиканский диагностический центр	51.1266034	71.4060541	osm	["10", "46"]	18
2668	Дворец единоборств имени Жаксылыка Ушкемпирова	51.1145475	71.410925	osm	[]	18
2669	Бизнес-центр Асылтау	51.1181315	71.4130345	osm	[]	13
2670	ЖК Айсанам	51.1154841	71.432751	osm	[]	13
2671	Алматы көшесі	51.1169812	71.4225967	osm	[]	13
2672	Бауыржана Момышулы	51.1466708	71.5009947	osm	[]	14
2673	Bus stop	51.1176669	71.4175046	osm	[]	13
2674	ЖК Айсанам	51.1156091	71.4311231	osm	[]	13
2675	Bus stop	51.0977176	71.4663531	osm	[]	13
2676	Bus stop	51.0987152	71.4645549	osm	[]	13
2677	Bus stop	51.1001019	71.460814	osm	[]	13
2678	Bus stop	51.1012889	71.4591337	osm	[]	13
2679	Bus stop	51.1021987	71.4568598	osm	[]	13
2680	Bus stop	51.102865	71.4555244	osm	[]	13
2681	Saranda Residential Complex	51.10442	71.4533055	osm	[]	13
2682	Akkum street	51.1101431	71.4442812	osm	[]	13
2683	улица Енбекшилер	51.1112798	71.4377583	osm	[]	13
2684	Bus stop	51.1129677	71.4390543	osm	[]	13
2685	ЖК Акжайык	51.1128501	71.4340898	osm	[]	13
2686	ЖК Асыл Парк	51.1091585	71.4275243	osm	[]	13
2687	ЖК Асыл Парк	51.1089975	71.4302002	osm	[]	13
2688	Барыс арена	51.106592	71.396808	osm	[]	18
2689	ЖК Акжайык	51.1133768	71.4320643	osm	[]	13
2690	Школа-лицей №76	51.1133533	71.4302041	osm	[]	13
2691	Дворец Тилеп кобыз	51.1142642	71.4258019	osm	[]	13
2692	Дворец Тилеп кобыз	51.1140993	71.4248285	osm	[]	13
2693	улица Сауран	51.1149962	71.4189473	osm	[]	13
2694	улица Сауран	51.1150053	71.4205486	osm	[]	13
2695	Военная Полиция	51.1962919	71.4292744	osm	[]	16
2696	Военная Полиция	51.1962412	71.4297312	osm	[]	16
2697	ЖК Арман Делюкс2	51.1130128	71.4166319	osm	[]	13
2698	Білім-инновация	51.0825013	71.4297542	osm	[]	13
2699	Білім-инновация	51.0821934	71.4303497	osm	[]	13
2700	Aiqyn	51.0829454	71.4250748	osm	[]	13
2701	Школа Binom им. Абиша Кекилбаева	51.0814597	71.4355187	osm	[]	13
2702	Bus stop	51.0818877	71.4340678	osm	[]	13
2703	Bus stop	51.0837007	71.4391838	osm	[]	13
2704	Бактыораз Бейсекбаев	51.1676132	71.4579921	osm	[]	16
2705	Бактыораз Бейсекбаев	51.1684245	71.4562846	osm	[]	16
2706	Bus stop	51.0725047	71.3930127	osm	[]	18
2707	Bus stop	51.0755651	71.3884304	osm	[]	18
2708	Bus stop	51.0770377	71.387666	osm	[]	18
2709	Bus stop	51.0813503	71.3887599	osm	[]	18
2710	Bus stop	51.0827099	71.3882342	osm	[]	18
2711	Bus stop	51.0785828	71.3867613	osm	[]	18
2712	АЗС Аурика	51.0744807	71.3885247	osm	[]	18
2713	Bus stop	51.0698687	71.3852166	osm	[]	18
2714	Bus stop	51.0707791	71.3859226	osm	[]	18
2715	Bus stop	51.0666194	71.3840873	osm	[]	18
2716	Bus stop	51.0675548	71.3943349	osm	[]	18
2717	Центральный госпиталь МВД	51.083536	71.4007706	osm	["10", "12"]	13
2718	Ілияс Жансүгіров көшесі	51.1630651	71.4814998	osm	[]	14
2719	Ілияс Жансүгіров көшесі	51.1631026	71.4821537	osm	[]	14
2720	Кафе Салауат	51.186738	71.4501051	osm	[]	16
2721	Сауран	51.1161649	71.4182786	osm	[]	13
2722	Bus stop	51.1261017	71.4235542	osm	[]	13
2723	ЖК Sauran Towers	51.1193819	71.4199525	osm	[]	13
2724	Сыганак	51.1232721	71.4221684	osm	[]	13
2725	Bus stop	51.3413471	71.6840517	osm	[]	16
2726	Bus stop	51.320396	71.6605497	osm	[]	16
2727	Bus stop	51.091644	71.449249	osm	["12", "46"]	13
2728	Bus stop	51.0901908	71.4328061	osm	["46"]	13
2729	Bus stop	51.0866342	71.433803	osm	[]	13
2730	Bus stop	51.088897	71.4340222	osm	[]	13
2731	Bus stop	51.0892946	71.4374293	osm	["46"]	13
2732	Bus stop	51.0892131	71.4397156	osm	["46"]	13
2733	Bus stop	51.088504	71.4448665	osm	["46"]	13
2734	Bus stop	51.0882895	71.4442989	osm	[]	13
2735	ЖК Алатау	51.1200279	71.4254591	osm	[]	13
2736	ЖК Алатау	51.1194774	71.4249241	osm	[]	13
2737	Акмешит	51.1159239	71.4239019	osm	[]	13
2738	Акмешит	51.1154559	71.4233875	osm	[]	13
2739	Керей Және Жәнібек Хандар көшесі	51.1122203	71.4226007	osm	[]	13
2740	ЖК Хайвилл Парк	51.112481	71.4039851	osm	[]	18
2741	ЖК Хайвилл Парк	51.1123741	71.4060806	osm	[]	18
2742	Жилой комплекс Зелёный Квартал	51.1285662	71.3944644	osm	[]	18
2743	Bus stop	51.1262943	71.4103886	osm	[]	18
2744	№81 мектеп-лицей	51.1422419	71.373999	osm	[]	18
2745	Қазақ технология және бизнес университеті	51.143547	71.3692986	osm	[]	18
2746	Брюссель ТҮК	51.1431546	71.3689532	osm	[]	18
2747	Bus stop	51.1287754	71.3961304	osm	[]	18
2748	Bus stop	51.1384123	71.4342078	osm	[]	13
2749	Bus stop	51.1381513	71.434816	osm	[]	13
2750	ЖК Коркем-2	51.1088154	71.424759	osm	[]	13
2751	Olymp Palace	51.113365	71.4263428	osm	[]	13
2752	Национальный музей Экспо	51.0862285	71.4163157	osm	[]	13
2753	Национальный музей Экспо	51.0864934	71.4160791	osm	[]	13
2754	Bus stop	51.0995349	71.418015	osm	[]	13
2755	Bus stop	51.0986512	71.4172837	osm	[]	13
2756	Bus stop	51.0951732	71.4164893	osm	[]	13
2757	Bus stop	51.0962365	71.4164287	osm	[]	13
2758	Bus stop	51.1475282	71.3494037	osm	[]	18
2759	Bus stop	51.1484482	71.3519932	osm	[]	18
2760	Bus stop	51.1485468	71.3546228	osm	[]	18
2761	Национальный центр биотехнологии	51.1471189	71.3820282	osm	[]	18
2762	Университет КАЗГЮУ	51.1480985	71.3835432	osm	[]	18
2763	Паралимпийский тренировочный центр	51.1471612	71.3972532	osm	[]	18
2764	Автоцентр Сары-Арка	51.145678	71.4075605	osm	[]	18
2765	Бозарал	51.1478037	71.3949883	osm	[]	18
2766	Bus stop	51.1494223	71.3695497	osm	[]	18
2767	Корпорация Казакмыс	51.1297898	71.4043153	osm	[]	18
2768	Корпорация Казакмыс	51.1302911	71.4027599	osm	[]	18
2769	Резиденция Хан Шатыр	51.132381	71.3995119	osm	[]	18
2770	улица Е-308	51.1348317	71.4048464	osm	[]	18
2771	Bus stop	51.1274566	71.4192119	osm	["12", "46"]	13
2772	Қорғаныс министрлігі	51.1258532	71.4305428	osm	[]	13
2773	Bus stop	51.1167952	71.4893252	osm	[]	17
2774	Bus stop	51.1159077	71.4925399	osm	[]	17
2775	Bus stop	51.1126207	71.4767176	osm	[]	17
2776	Bus stop	51.1130224	71.4752792	osm	[]	17
2777	Bus stop	51.1133387	71.4721485	osm	[]	17
2778	Bus stop	51.1138081	71.4703038	osm	[]	17
2779	Bus stop	51.1959292	71.4336027	osm	[]	16
2780	Bus stop	51.2077901	71.4081034	osm	[]	16
2781	Bus stop	51.2074476	71.4086515	osm	[]	16
2782	Bus stop	51.1463848	71.3417057	osm	[]	18
2783	Bus stop	51.146417	71.3438471	osm	[]	18
2784	Bus stop	51.1453532	71.3385359	osm	[]	18
2785	Bus stop	51.1431068	71.3294995	osm	[]	18
2786	Bus stop	51.1430849	71.3283274	osm	[]	18
2787	Bus stop	51.1404631	71.3236067	osm	[]	18
2788	Bus stop	51.1406247	71.3246823	osm	[]	18
2789	Bus stop	51.1374224	71.3186407	osm	[]	18
2790	Bus stop	51.1375645	71.3197184	osm	[]	18
2791	Bus stop	51.134289	71.314453	osm	[]	18
2792	Bus stop	51.1341158	71.3133099	osm	[]	18
2793	Bus stop	51.1075823	71.2467949	osm	[]	18
2794	Bus stop	51.1075379	71.2479328	osm	[]	18
2795	Bus stop	51.110474	71.2525219	osm	[]	18
2796	Bus stop	51.1105606	71.2527307	osm	[]	18
2797	Bus stop	51.1118029	71.2583097	osm	[]	18
2798	Bus stop	51.1118184	71.2596038	osm	[]	18
2799	Bus stop	51.1135254	71.2631583	osm	[]	18
2800	Bus stop	51.1135273	71.2644524	osm	[]	18
2801	Bus stop	51.1153397	71.2682745	osm	[]	18
2802	Bus stop	51.1157646	71.2707483	osm	[]	18
2803	Bus stop	51.1175931	71.274638	osm	[]	18
2804	Bus stop	51.1453147	71.3362234	osm	[]	18
2805	Bus stop	51.1474988	71.3472473	osm	[]	18
2806	Bus stop	51.146019	71.3667699	osm	[]	18
2807	Bus stop	51.1458303	71.3675166	osm	[]	18
2808	№17 мектеп-гимназия	51.1406509	71.4182226	osm	[]	18
2809	Bus stop	51.1386127	71.4173925	osm	[]	13
2810	Bus stop	51.1643385	71.3997113	osm	[]	15
2811	Bus stop	51.1656746	71.3998929	osm	[]	15
2812	Bus stop	51.1182029	71.4535921	osm	[]	17
2813	Bus stop	51.1160006	71.4541466	osm	[]	17
2814	Bus stop	51.1128813	71.4562463	osm	[]	17
2815	Bus stop	51.114935	71.4541448	osm	[]	17
2816	Bus stop	51.1694572	71.398813	osm	[]	15
2817	Bus stop	51.1703355	71.3979772	osm	[]	15
2818	Bus stop	51.1682429	71.3976485	osm	[]	15
2819	Bus stop	51.168136	71.3914373	osm	[]	15
2820	Bus stop	51.1697948	71.3885776	osm	[]	15
2821	Bus stop	51.1658885	71.3876743	osm	[]	15
2822	Bus stop	51.1647099	71.38143	osm	[]	15
2823	Bus stop	51.1659578	71.3792667	osm	[]	15
2824	Bus stop	51.1769618	71.3926964	osm	["46"]	15
2825	Bus stop	51.1854632	71.3791952	osm	[]	15
2826	Bus stop	51.1870517	71.3806302	osm	[]	15
2827	Bus stop	51.1879854	71.3821947	osm	[]	15
2828	Bus stop	51.1971533	71.3640686	osm	[]	15
2829	Bus stop	51.2020964	71.3501238	osm	[]	15
2830	Bus stop	51.2028426	71.3506966	osm	[]	15
2831	Bus stop	51.2043593	71.3509983	osm	[]	15
2832	Bus stop	51.2049299	71.3514725	osm	[]	15
2833	Bus stop	51.1941092	71.4057891	osm	[]	15
2834	Bus stop	51.127115	71.4747439	osm	[]	14
2835	Bus stop	51.1592445	71.4655987	osm	[]	16
2836	Парк имени Момышулы	51.1327563	71.4591875	osm	[]	14
2837	Bus stop	51.1362784	71.5374668	osm	[]	14
2838	Bus stop	51.1358453	71.5386276	osm	[]	17
2839	ЖК Денсаулык Бакыт	51.1362997	71.5499588	osm	[]	14
2840	ЖК Денсаулык Бакыт	51.1360899	71.5512852	osm	[]	17
2841	Bus stop	51.1348117	71.5570303	osm	[]	17
2842	Bus stop	51.134438	71.5575832	osm	[]	17
2843	Bus stop	51.129949	71.5551027	osm	[]	17
2844	Bus stop	51.1291124	71.5554702	osm	[]	17
2845	Bus stop	51.1501522	71.5489315	osm	[]	14
2846	Bus stop	51.0615734	71.4150693	osm	["10", "12"]	13
2847	Bus stop	51.0616756	71.414492	osm	["10", "12"]	13
2848	Мясоперерабатывающий завод Целинная	51.1852684	71.4941485	osm	[]	16
2849	Мясоперерабатывающий завод Целинная	51.1858703	71.4952321	osm	[]	16
2850	Автобусный парк № 7	51.1936415	71.5025785	osm	[]	16
2851	Автобусный парк № 7	51.1930249	71.5015214	osm	[]	16
2852	ТЭЦ № 2	51.1962559	71.5045698	osm	[]	16
2853	ТЭЦ № 2	51.1968946	71.5056534	osm	[]	16
2854	Bus stop	51.1985523	71.5057955	osm	[]	16
2855	Bus stop	51.1975766	71.5074339	osm	[]	16
2856	Bus stop	51.1763733	71.5261335	osm	[]	14
2857	Bus stop	51.1779301	71.5245868	osm	[]	14
2858	Bus stop	51.1963962	71.5113759	osm	[]	16
2859	Bus stop	51.19573	71.5122398	osm	[]	16
2860	Bus stop	51.2034625	71.4920899	osm	[]	16
2861	Bus stop	51.2024448	71.4956086	osm	[]	16
2862	Bus stop	51.201673	71.4967692	osm	[]	16
2863	Bus stop	51.2004745	71.5007575	osm	[]	16
2864	Bus stop	51.1997319	71.5018592	osm	[]	16
2865	Bus stop	51.2391152	71.5651111	osm	[]	16
2866	Bus stop	51.2388681	71.5655659	osm	[]	16
2867	Bus stop	51.2480019	71.5798565	osm	[]	16
2868	Bus stop	51.248279	71.5793872	osm	[]	16
2869	Bus stop	51.1125086	71.5359747	osm	[]	17
2870	Bus stop	51.1114202	71.5235432	osm	[]	17
2871	Bus stop	51.1124513	71.5170091	osm	[]	17
2872	Bus stop	51.1138563	71.5057977	osm	[]	17
2873	Bus stop	51.1143595	71.5047688	osm	[]	17
2874	Bus stop	51.1149873	71.4984998	osm	[]	17
2875	Bus stop	51.1137669	71.5001843	osm	[]	17
2876	Александра Пушкина	51.162994	71.4708155	osm	[]	16
2877	Bus stop	51.1541084	71.4509233	osm	[]	16
2878	Магазин Pilot	51.1880591	71.4972997	osm	[]	16
2879	Магазин Pilot	51.1874293	71.4963207	osm	[]	16
2880	Автоцентр Камаз	51.1817783	71.4908313	osm	[]	16
2881	Автоцентр Камаз	51.1824118	71.4918379	osm	[]	16
2882	АО Астана Зеленстрой	51.1781394	71.4873315	osm	[]	16
2883	АО Астана Зеленстрой	51.1777041	71.4874239	osm	[]	16
2884	Проспект Шакарима Кудайбердиулы	51.1522891	71.5095341	osm	[]	14
2885	Школа-гимназия № 52	51.1506962	71.5136274	osm	[]	14
2886	Козыбасы	51.1505868	71.5167026	osm	[]	14
2887	Школа № 52	51.1493433	71.515174	osm	[]	14
2888	Школа № 52	51.1494835	71.5155651	osm	[]	14
2889	Буктырма	51.1484917	71.5192631	osm	[]	14
2890	Bus stop	51.1614683	71.4863687	osm	[]	14
2891	Городская больница № 1	51.1440231	71.5283264	osm	[]	14
2892	А-187	51.173892	71.5299908	osm	[]	14
2893	А-187	51.1750447	71.528789	osm	[]	14
2894	Астанинский трубный завод	51.1641067	71.5411119	osm	[]	14
2895	Масаты	51.1366579	71.5205812	osm	[]	14
2896	Кобыз	51.1346334	71.5160491	osm	[]	14
2897	Кобыз	51.1348076	71.5184707	osm	[]	17
2898	Bus stop	51.1323469	71.5082708	osm	[]	14
2899	Bus stop	51.1326459	71.5106384	osm	[]	17
2900	ЖК Турсын Астана-1	51.1271487	71.4893843	osm	[]	14
2901	ЖК Турсын Астана-2	51.1285947	71.4947239	osm	[]	14
2902	ЖК Турсын Астана-2	51.1282116	71.4952393	osm	[]	17
2903	ЖК Жайна	51.1304411	71.5029824	osm	[]	17
2904	ЖК Жайна	51.130158	71.5003845	osm	[]	14
2905	Abylai khan avenue	51.1599131	71.4712513	osm	[]	14
2906	Bus stop	51.1396956	71.5204839	osm	[]	14
2907	Орхон	51.1412506	71.5211662	osm	[]	14
2908	Орхон	51.1402978	71.5228576	osm	[]	14
2909	Есиль	51.1425097	71.5171559	osm	[]	14
2910	Есиль	51.1431851	71.5161078	osm	[]	14
2911	Бурабай	51.1444621	71.5120458	osm	[]	14
2912	Бурабай	51.1453614	71.5103521	osm	[]	14
2913	ЖК Достар-2	51.1546131	71.5102847	osm	[]	14
2914	ЖК Достар-2	51.1537244	71.5099888	osm	[]	14
2915	Бауыржана Момышулы	51.1455931	71.4986217	osm	[]	14
2916	Дом дружбы	51.1446631	71.4952524	osm	[]	14
2917	Дом дружбы	51.1446922	71.4941222	osm	[]	14
2918	Bus stop	51.1431271	71.4898851	osm	[]	14
2919	“Венский квартал” тұрғын үй кешені	51.0863934	71.4252157	osm	[]	13
2920	Bus stop	51.117719	71.465159	osm	[]	17
2921	Bus stop	51.118915	71.4550299	osm	[]	17
2922	International Airport – 1	51.0274541	71.4603008	osm	[]	13
2923	Bus stop	51.1195956	71.4530954	osm	[]	17
2924	КазМунайГаз	51.13492	71.414864	osm	["10", "12", "46"]	18
2925	Bus stop	51.1425827	71.382932	osm	[]	18
2926	Bus stop	51.1186754	71.5020639	osm	[]	17
2927	Bus stop	51.1200254	71.5036057	osm	[]	17
2928	Bus stop	51.115393	71.5270195	osm	[]	17
2929	Bus stop	51.1376988	71.519449	osm	[]	14
2930	Bus stop	51.1384567	71.5182228	osm	[]	14
2931	Bus stop	51.1399697	71.5127829	osm	[]	14
2932	Bus stop	51.1395382	71.5129343	osm	[]	14
2933	Bus stop	51.1407001	71.5111673	osm	[]	14
2934	Bus stop	51.1370331	71.51508	osm	[]	14
2935	Bus stop	51.1364097	71.5137152	osm	[]	14
2936	Bus stop	51.1825184	71.5108425	osm	[]	14
2937	Bus stop	51.1363954	71.4591578	osm	[]	14
2938	Bus stop	51.1994511	71.476049	osm	[]	16
2939	Bus stop	51.1991151	71.475301	osm	[]	16
2940	Bus stop	51.2025292	71.4625552	osm	[]	16
2941	Bus stop	51.2039256	71.4598027	osm	[]	16
2942	Bus stop	51.1996081	71.4713921	osm	[]	16
2943	Bus stop	51.2006991	71.4693898	osm	[]	16
2944	Bus stop	51.1834183	71.4551603	osm	[]	16
2945	Bus stop	51.1824139	71.4570347	osm	[]	16
2946	Bus stop	51.1809862	71.4626339	osm	[]	16
2947	Bus stop	51.179966	71.4646222	osm	[]	16
2948	Bus stop	51.1793552	71.4677237	osm	[]	16
2949	Bus stop	51.1783314	71.4695148	osm	[]	16
2950	Bus stop	51.1772093	71.47362	osm	[]	16
2951	Bus stop	51.1763899	71.4747283	osm	[]	16
2952	Kafe Sulukol'	51.18512276135868	71.3528443759532	zenodo	["46"]	15
2953	prospekt Tlendieva	51.1792857933539	71.38321235359834	zenodo	["46"]	15
2954	Sarybulak	51.17680182248764	71.39435418502224	zenodo	["46"]	15
2955	Sredniaia shkola No. 18	51.17548306787644	71.39804998850084	zenodo	["12", "46"]	15
2956	Zharkyn	51.088733725184106	71.44419210601382	zenodo	["46"]	13
2957	ZhK Komfort taun	51.08860909112646	71.44868975486412	zenodo	["12", "46"]	13
2958	NK Kazmunaigaz	51.13435060403942	71.41487597180254	zenodo	["10", "12", "46"]	13
2959	Sredniaia shkola No. 18	51.17585228262476	71.39873748216235	zenodo	["46"]	15
2960	prospekt Tlendieva	51.180032406360205	71.38172306878802	zenodo	["46"]	15
2961	K'artaly	51.18328805464409	71.36832656597443	zenodo	["46"]	15
2962	Shugyla	51.18315929424949	71.35122112599142	zenodo	["46"]	15
2963	Titova	51.183248582162506	71.34847676618949	zenodo	["46"]	15
2964	Ardagerler	51.18474312769264	71.34276675301597	zenodo	["46"]	15
2965	Babataiuly	51.18562388563353	71.34072758121034	zenodo	["46"]	15
2966	per. Taitobe	51.18708691151863	71.33564891835546	zenodo	["46"]	15
2967	Zhanakonys	51.1884213368695	71.33176118744055	zenodo	["46"]	15
2968	Gostinitsa Bakhyt	51.19395165254147	71.32608362297202	zenodo	["46"]	15
2969	zh/m Koktal-2	51.196567631964726	71.32780341455846	zenodo	["46"]	15
2970	Tarbagatai	51.200851465106936	71.3324804277106	zenodo	["46"]	15
2971	Mu'sa dukeni	51.20025948812925	71.33688297418169	zenodo	["46"]	15
2972	Nauryz48	51.20168568523773	71.33698941157755	zenodo	["46"]	15
2973	ulitsa Karasu	51.200426687006505	71.33076771758407	zenodo	["46"]	15
2974	Zh/d vokzal Astana 1	51.195	71.408	zenodo	["10", "12"]	15
2975	ul.Ybyrai Altynsarina	51.187289	71.407598	zenodo	["12"]	15
2976	Prospekt Saryarka	51.174294	71.406421	zenodo	["12", "46"]	15
2977	Sportivnyi kompleks ABYROY	51.1686558	71.407836	zenodo	["12", "46"]	15
2978	K'arlyg'ash balabak'shasy	51.108050533972666	71.4310605225266	zenodo	["10", "12", "46"]	13
2979	ZhK Ekspo Siti	51.082013	71.421862	zenodo	["10", "12"]	13
2980	Detskii sad Karlygash	51.07101538085358	71.41783477700184	zenodo	["10", "12"]	13
2981	ulitsa Karasu	51.20053675217712	71.33146497827295	zenodo	["46"]	15
2982	Mu'sa dukeni	51.20019995904532	71.33617625429603	zenodo	["46"]	15
2983	Tarbagatai	51.1992016089265	71.33253419309649	zenodo	["46"]	15
2984	Aktobe	51.19803194321285	71.32954210029943	zenodo	["46"]	15
2985	Ulytau	51.19553087377446	71.32675914734659	zenodo	["46"]	15
2986	Gostinitsa Bakhyt	51.19402700372381	71.32210101291399	zenodo	["46"]	15
2987	Keleshek	51.19078530654348	71.33363293842872	zenodo	["46"]	15
2988	per. Taitobe	51.18698587437736	71.3364987698196	zenodo	["46"]	15
2989	ZhK Promenad Ekspo	51.092836	71.426175	zenodo	["10", "12", "46"]	13
2990	Prospekt Saryarka	51.173858	71.407056	zenodo	["12", "46"]	15
2991	Shkola-litsei No. 15	51.179925	71.410194	zenodo	["12"]	15
2992	ul. Zhanadariia	51.04704157208384	71.43116576882497	zenodo	["10", "12"]	13
2993	Detskii sad Balbulak	51.0445846248775	71.4271008652745	zenodo	["10", "12"]	13
2994	Sarytogai	51.042905252237496	71.42560161251365	zenodo	["12"]	13
2995	sredniaia shkola No. 24	51.0417836474827	71.4285087766178	zenodo	["10", "12"]	13
2996	Ulitsa Arnasai	51.041765	71.433817	zenodo	["10", "12"]	13
2997	Mechet' Al'zhan Ana	51.041761	71.437795	zenodo	["10", "12"]	13
2998	Mechet' Al'zhan Ana	51.041884	71.438528	zenodo	["10", "12"]	13
2999	Ulitsa Arnasai	51.041854	71.432969	zenodo	["10", "12"]	13
3000	sredniaia shkola No. 24	51.0419725292984	71.4275539102721	zenodo	["12"]	13
3001	Detskii sad Balbulak	51.0445357926555	71.4286482514086	zenodo	["10", "12"]	13
3002	ZhK Aq-Jol	51.04938026082487	71.43015536518286	zenodo	["10", "12"]	13
3003	Dvorets edinoborstv im. Zhaksylyka Ushkempirova	51.1137412	71.4108454	zenodo	["10", "12"]	18
3004	ZhK Budapesht	51.0783226321179	71.39844854977864	zenodo	["10", "12"]	18
3005	Dvorets edinoborstv	51.112486	71.410926	zenodo	["10", "12"]	13
3006	ZhK Milanskii kvartal	51.1423416137695	71.4453125	zenodo	["10", "12", "46"]	14
\.


--
-- Data for Name: core_district; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.core_district (id, osm_id, name, name_kk, population, population_share, population_change, t1_congestion, t2_accessibility, color, area_km2, bbox, outline, holes) FROM stdin;
13	3479876	Yesil	Есіл	333348	19.8	9.2	45	62	#4FC3C6	192.8	[71.380497, 50.930694, 71.60827, 51.151897]	[[[71.428229, 51.151897], [71.429341, 51.151021], [71.431058, 51.150267], [71.433161, 51.150051], [71.435865, 51.149594], [71.437839, 51.148355], [71.43801, 51.147736], [71.438473, 51.147543], [71.439813, 51.146982], [71.441014, 51.145798], [71.441401, 51.144748], [71.441701, 51.142217], [71.441787, 51.140494], [71.446059, 51.133963], [71.446826, 51.132789], [71.447178, 51.132281], [71.447419, 51.131785], [71.447405, 51.13131], [71.447362, 51.13089], [71.448512, 51.129294], [71.449045, 51.12882], [71.450952, 51.127798], [71.451462, 51.127488], [71.45204, 51.127054], [71.452558, 51.126218], [71.4526, 51.125782], [71.452551, 51.125345], [71.452322, 51.124756], [71.452042, 51.124342], [71.451604, 51.123923], [71.451157, 51.123628], [71.450529, 51.123314], [71.448409, 51.122391], [71.447874, 51.122208], [71.446789, 51.121915], [71.446303, 51.121591], [71.445833, 51.12026], [71.450113, 51.115204], [71.450456, 51.112402], [71.450756, 51.109681], [71.451116, 51.108885], [71.451786, 51.108199], [71.453975, 51.107094], [71.456893, 51.10607], [71.460069, 51.105612], [71.471656, 51.10545], [71.472772, 51.105181], [71.474016, 51.104669], [71.474583, 51.104208], [71.475334, 51.103367], [71.475797, 51.102823], [71.476278, 51.102515], [71.476991, 51.102241], [71.479149, 51.101395], [71.480214, 51.101018], [71.483209, 51.100614], [71.487061, 51.100046], [71.489723, 51.099629], [71.491264, 51.100194], [71.492327, 51.100654], [71.494997, 51.101819], [71.498059, 51.103116], [71.499125, 51.103406], [71.500048, 51.103551], [71.500788, 51.103587], [71.50145, 51.103571], [71.502961, 51.103327], [71.507405, 51.102126], [71.51084, 51.101186], [71.512899, 51.100852], [71.514266, 51.100812], [71.515707, 51.100934], [71.517407, 51.101276], [71.518997, 51.101762], [71.522538, 51.102951], [71.523684, 51.103271], [71.524357, 51.103369], [71.525186, 51.103441], [71.526041, 51.103448], [71.527619, 51.103404], [71.532827, 51.102837], [71.53872, 51.102232], [71.550876, 51.100983], [71.587794, 51.097189], [71.599215, 51.094103], [71.601781, 51.093198], [71.604, 51.092415], [71.605396, 51.092134], [71.606545, 51.09168], [71.60788, 51.091323], [71.603478, 51.085864], [71.588049, 51.074702], [71.579469, 51.070421], [71.570784, 51.063028], [71.567355, 51.06009], [71.56425, 51.057448], [71.55995, 51.053054], [71.555887, 51.048875], [71.547414, 51.051111], [71.545537, 51.04891], [71.539749, 51.048168], [71.544351, 51.040025], [71.550243, 51.029597], [71.550811, 51.028197], [71.553097, 51.022495], [71.555846, 51.01538], [71.5462, 51.012409], [71.544119, 51.011769], [71.53946, 51.0093], [71.53887, 51.009013], [71.538355, 51.008679], [71.537911, 51.008308], [71.537544, 51.007901], [71.537265, 51.007466], [71.537076, 51.007024], [71.53702, 51.004854], [71.536966, 50.998275], [71.536896, 50.993048], [71.536875, 50.990035], [71.536924, 50.98944], [71.537071, 50.988848], [71.537315, 50.988277], [71.537649, 50.987719], [71.538083, 50.987194], [71.540399, 50.985346], [71.542829, 50.983404], [71.545721, 50.981108], [71.548639, 50.978804], [71.55263, 50.975602], [71.554298, 50.968299], [71.548698, 50.946511], [71.547856, 50.938047], [71.547432, 50.934044], [71.54693, 50.930891], [71.531033, 50.930741], [71.520784, 50.930694], [71.511177, 50.930731], [71.486557, 50.930819], [71.482702, 50.939622], [71.471614, 50.937655], [71.469221, 50.945825], [71.466695, 50.947689], [71.460571, 50.947201], [71.46114, 50.950528], [71.462178, 50.952772], [71.463192, 50.958459], [71.450913, 50.960439], [71.451531, 50.964899], [71.452648, 50.968786], [71.456328, 50.982563], [71.451642, 50.983313], [71.452964, 50.992094], [71.45367, 50.996784], [71.453893, 50.998307], [71.454188, 51.000859], [71.452073, 51.001177], [71.450461, 51.001465], [71.448607, 51.001796], [71.44554, 51.002338], [71.442599, 51.002856], [71.440173, 51.00329], [71.439084, 51.003484], [71.43795, 51.003683], [71.436759, 51.003114], [71.435278, 51.004158], [71.432443, 51.004679], [71.431009, 51.004946], [71.430476, 51.005025], [71.429105, 51.005228], [71.425286, 51.005783], [71.422528, 51.006182], [71.420893, 51.006421], [71.419012, 51.006695], [71.41611, 51.007117], [71.415045, 51.007273], [71.413029, 51.007594], [71.411067, 51.00791], [71.409915, 51.008094], [71.40759, 51.008464], [71.4069, 51.008574], [71.404732, 51.00892], [71.403684, 51.009086], [71.402775, 51.009234], [71.401412, 51.009775], [71.400757, 51.010076], [71.40018, 51.010315], [71.396976, 51.010807], [71.390997, 51.011728], [71.385904, 51.012513], [71.383648, 51.012862], [71.38168, 51.013167], [71.381048, 51.013155], [71.380904, 51.014183], [71.380762, 51.016287], [71.380655, 51.017371], [71.380641, 51.018169], [71.380585, 51.018778], [71.380507, 51.020067], [71.380497, 51.02112], [71.380609, 51.022549], [71.381229, 51.02726], [71.381484, 51.029187], [71.381658, 51.030448], [71.381824, 51.031266], [71.382042, 51.032136], [71.382286, 51.032998], [71.383353, 51.035981], [71.384068, 51.03796], [71.385515, 51.041987], [71.390568, 51.05604], [71.395319, 51.069428], [71.398848, 51.078845], [71.40205, 51.087816], [71.402635, 51.089455], [71.403051, 51.090622], [71.404097, 51.093516], [71.404454, 51.09455], [71.405147, 51.096668], [71.405539, 51.097545], [71.405806, 51.098273], [71.405963, 51.098702], [71.40658, 51.10046], [71.407431, 51.103017], [71.409494, 51.108604], [71.410076, 51.110181], [71.410425, 51.111196], [71.410784, 51.11272], [71.412173, 51.120667], [71.412542, 51.122754], [71.414233, 51.132323], [71.414604, 51.133982], [71.415145, 51.135289], [71.41566, 51.136273], [71.420531, 51.143932], [71.422012, 51.146321], [71.42272, 51.147445], [71.423112, 51.148081], [71.424061, 51.148926], [71.426085, 51.150373], [71.428222, 51.151892], [71.428229, 51.151897]]]	[]
14	3482819	Almaty	Алматы	256353	15.2	-39.6	40	75	#F6B26B	92.6	[71.438473, 51.107675, 71.785191, 51.203289]	[[[71.447389, 51.131155], [71.447431, 51.131576], [71.447301, 51.132067], [71.446826, 51.132789], [71.446059, 51.133963], [71.441787, 51.140494], [71.441701, 51.142217], [71.441401, 51.144748], [71.441014, 51.145798], [71.439813, 51.146982], [71.438473, 51.147543], [71.440755, 51.148457], [71.443137, 51.149419], [71.444274, 51.150038], [71.445691, 51.150839], [71.447632, 51.151936], [71.450401, 51.152771], [71.451624, 51.153047], [71.452385, 51.153114], [71.453136, 51.153323], [71.453619, 51.153659], [71.454681, 51.154238], [71.459584, 51.15551], [71.4654, 51.158161], [71.467105, 51.159022], [71.468919, 51.159954], [71.469645, 51.160373], [71.470001, 51.160787], [71.471915, 51.161604], [71.472467, 51.162084], [71.472874, 51.162709], [71.474017, 51.163656], [71.47452, 51.163789], [71.475034, 51.163861], [71.475875, 51.163898], [71.476698, 51.163983], [71.477452, 51.164098], [71.478032, 51.164617], [71.478978, 51.165797], [71.479651, 51.166697], [71.480423, 51.167477], [71.48086, 51.167797], [71.48157, 51.168118], [71.482139, 51.168342], [71.482746, 51.168356], [71.48378, 51.168235], [71.484194, 51.168295], [71.485343, 51.16888], [71.48617, 51.169569], [71.487909, 51.171081], [71.488321, 51.171319], [71.489556, 51.17203], [71.490252, 51.172215], [71.490744, 51.172434], [71.491645, 51.172657], [71.492093, 51.173933], [71.492973, 51.174768], [71.494603, 51.175615], [71.495419, 51.17583], [71.497114, 51.175857], [71.49776, 51.17577], [71.498085, 51.176357], [71.49942, 51.177804], [71.502463, 51.180978], [71.504348, 51.18305], [71.504895, 51.183542], [71.505476, 51.183392], [71.505922, 51.183262], [71.506774, 51.183043], [71.507273, 51.182938], [71.507708, 51.182866], [71.50821, 51.182801], [71.508818, 51.182742], [71.509543, 51.182702], [71.510399, 51.182683], [71.510914, 51.182681], [71.511406, 51.182655], [71.511984, 51.182614], [71.512615, 51.182525], [71.513171, 51.182445], [71.513871, 51.182321], [71.51442, 51.182193], [71.514936, 51.182058], [71.51568, 51.181834], [71.51642, 51.181552], [71.519856, 51.180269], [71.520833, 51.179898], [71.521674, 51.179503], [71.522615, 51.178979], [71.523831, 51.178184], [71.524837, 51.178669], [71.525341, 51.178996], [71.527112, 51.179234], [71.528378, 51.179113], [71.529837, 51.179556], [71.531038, 51.180041], [71.533399, 51.180727], [71.533764, 51.181198], [71.533292, 51.182274], [71.533377, 51.182906], [71.533914, 51.183471], [71.535201, 51.183807], [71.536725, 51.184506], [71.537733, 51.1853], [71.538441, 51.185972], [71.539557, 51.187385], [71.540973, 51.188595], [71.542518, 51.188945], [71.544471, 51.189066], [71.54608, 51.189657], [71.547797, 51.190034], [71.549235, 51.190088], [71.550093, 51.189698], [71.552196, 51.189805], [71.553977, 51.190195], [71.557037, 51.19084], [71.557885, 51.191331], [71.558021, 51.19206], [71.55918, 51.192793], [71.560274, 51.193203], [71.561058, 51.193606], [71.561862, 51.194608], [71.562613, 51.194924], [71.563568, 51.195428], [71.568632, 51.196733], [71.572065, 51.19885], [71.574694, 51.199959], [71.57582, 51.200618], [71.577505, 51.20127], [71.580026, 51.202763], [71.58178, 51.203075], [71.582946, 51.203289], [71.583257, 51.20267], [71.58782, 51.198553], [71.604567, 51.193417], [71.614179, 51.190439], [71.616123, 51.189834], [71.621449, 51.188178], [71.623414, 51.184162], [71.623795, 51.183384], [71.624226, 51.182506], [71.625178, 51.180565], [71.625384, 51.180144], [71.626859, 51.17713], [71.627336, 51.176156], [71.628096, 51.174567], [71.635082, 51.159463], [71.6361, 51.15746], [71.638896, 51.152064], [71.642152, 51.145782], [71.643329, 51.143512], [71.644317, 51.141606], [71.645205, 51.139899], [71.673037, 51.141013], [71.673044, 51.140087], [71.68455, 51.140541], [71.688686, 51.140431], [71.691807, 51.13957], [71.70042, 51.136125], [71.701605, 51.135635], [71.706271, 51.13379], [71.710926, 51.132046], [71.713481, 51.131517], [71.714669, 51.131345], [71.710603, 51.123452], [71.705114, 51.113011], [71.702098, 51.107675], [71.700491, 51.1081], [71.690353, 51.110564], [71.689417, 51.11079], [71.687396, 51.111275], [71.685993, 51.111611], [71.68467, 51.111929], [71.684006, 51.112088], [71.682516, 51.112443], [71.667729, 51.115957], [71.665928, 51.116414], [71.664261, 51.116892], [71.662401, 51.117437], [71.658414, 51.11859], [71.65544, 51.119423], [71.648162, 51.121366], [71.647624, 51.121491], [71.645881, 51.121928], [71.644312, 51.122255], [71.638035, 51.123446], [71.635671, 51.123887], [71.633582, 51.124282], [71.626486, 51.125496], [71.625331, 51.125692], [71.620945, 51.126442], [71.619998, 51.126599], [71.615483, 51.12737], [71.612429, 51.127893], [71.609803, 51.128341], [71.603312, 51.129447], [71.600757, 51.129879], [71.600076, 51.129973], [71.59926, 51.130132], [71.598517, 51.130247], [71.594095, 51.131], [71.591462, 51.131475], [71.590774, 51.131601], [71.588519, 51.131954], [71.577724, 51.133797], [71.572274, 51.134774], [71.571618, 51.134914], [71.571127, 51.134995], [71.568814, 51.135383], [71.567318, 51.135631], [71.566467, 51.135762], [71.565752, 51.135861], [71.565207, 51.135933], [71.564198, 51.136053], [71.563579, 51.136101], [71.562889, 51.136163], [71.561875, 51.136236], [71.561099, 51.136277], [71.560278, 51.136306], [71.558944, 51.136319], [71.558083, 51.136319], [71.556818, 51.136299], [71.553955, 51.136242], [71.552498, 51.13621], [71.551562, 51.136197], [71.550705, 51.136182], [71.550067, 51.136166], [71.549418, 51.13613], [71.548954, 51.136094], [71.547794, 51.136], [71.546482, 51.135884], [71.545639, 51.135813], [71.545123, 51.135776], [71.544588, 51.135743], [71.544079, 51.135727], [71.543569, 51.135717], [71.543119, 51.13571], [71.54263, 51.135713], [71.541813, 51.135731], [71.541041, 51.135755], [71.54027, 51.135798], [71.539635, 51.135842], [71.538886, 51.135897], [71.53798, 51.136021], [71.53719, 51.136126], [71.536723, 51.136187], [71.536128, 51.136279], [71.535107, 51.136446], [71.534462, 51.136536], [71.533629, 51.136688], [71.532365, 51.137011], [71.53144, 51.137318], [71.530502, 51.137609], [71.529416, 51.137967], [71.528748, 51.138193], [71.528262, 51.138371], [71.52683, 51.138926], [71.525769, 51.139311], [71.52445, 51.139812], [71.523811, 51.139694], [71.522367, 51.138199], [71.521747, 51.137554], [71.521279, 51.137057], [71.520811, 51.136584], [71.520421, 51.136181], [71.519862, 51.135722], [71.519258, 51.135392], [71.518603, 51.135161], [71.518075, 51.135014], [71.517649, 51.134895], [71.51688, 51.13467], [71.514925, 51.134104], [71.514486, 51.13398], [71.513231, 51.133624], [71.51269, 51.133469], [71.510525, 51.132863], [71.509658, 51.132616], [71.509216, 51.13249], [71.508455, 51.132273], [71.507313, 51.131945], [71.506354, 51.131678], [71.505874, 51.131544], [71.503873, 51.130988], [71.501555, 51.130336], [71.499293, 51.129693], [71.498789, 51.129549], [71.497529, 51.129199], [71.497082, 51.129075], [71.496611, 51.128939], [71.496145, 51.128809], [71.491727, 51.127558], [71.491249, 51.127423], [71.48999, 51.127066], [71.487837, 51.126455], [71.487086, 51.126241], [71.48658, 51.126113], [71.485617, 51.12566], [71.485061, 51.12553], [71.484515, 51.12545], [71.483858, 51.125427], [71.483406, 51.12545], [71.481687, 51.125725], [71.480578, 51.125899], [71.479125, 51.126122], [71.477246, 51.126405], [71.476587, 51.126507], [71.476112, 51.126585], [71.475284, 51.126732], [71.473145, 51.127067], [71.472375, 51.127184], [71.471168, 51.127367], [71.470522, 51.127472], [71.469906, 51.127569], [71.468551, 51.127768], [71.465456, 51.128241], [71.464003, 51.12847], [71.463584, 51.128537], [71.462238, 51.128743], [71.461676, 51.128834], [71.460472, 51.129027], [71.458907, 51.129269], [71.458467, 51.129339], [71.458027, 51.129408], [71.455597, 51.129806], [71.454002, 51.130083], [71.447389, 51.131155]], [[71.782424, 51.150455], [71.766137, 51.144685], [71.760879, 51.145722], [71.746858, 51.162145], [71.740388, 51.16606], [71.78511, 51.165569], [71.785191, 51.157303], [71.782424, 51.150455]]]	[]
15	3486954	Saryarqa	Сарыарқа	349923	20.8	-0.3	50	70	#B39DDB	67.3	[71.237303, 51.151897, 71.446405, 51.246318]	[[[71.361207, 51.164892], [71.360176, 51.164788], [71.359206, 51.16475], [71.357712, 51.164695], [71.357103, 51.164717], [71.356344, 51.164507], [71.355542, 51.165174], [71.354655, 51.16586], [71.35323, 51.166129], [71.350535, 51.167351], [71.349909, 51.167674], [71.349179, 51.168374], [71.348836, 51.16903], [71.348355, 51.169574], [71.348038, 51.170295], [71.347952, 51.170811], [71.34663, 51.171511], [71.346003, 51.171963], [71.345428, 51.172329], [71.344398, 51.17277], [71.343085, 51.173147], [71.341738, 51.173755], [71.341085, 51.174014], [71.340313, 51.174213], [71.339369, 51.174304], [71.338407, 51.174336], [71.33748, 51.174401], [71.336624, 51.174186], [71.336107, 51.17432], [71.33542, 51.174282], [71.334464, 51.174263], [71.333974, 51.174132], [71.333472, 51.173798], [71.333049, 51.173498], [71.332371, 51.173009], [71.331947, 51.172915], [71.331086, 51.172679], [71.330945, 51.173543], [71.330529, 51.173872], [71.329666, 51.174218], [71.329011, 51.17425], [71.328394, 51.174222], [71.327783, 51.174618], [71.327204, 51.175142], [71.326753, 51.175681], [71.327623, 51.176463], [71.327445, 51.177268], [71.326571, 51.177817], [71.325634, 51.177799], [71.324982, 51.177767], [71.32446, 51.17772], [71.323947, 51.177565], [71.323672, 51.177159], [71.323229, 51.176712], [71.322539, 51.176809], [71.322005, 51.176896], [71.321557, 51.177388], [71.321175, 51.17785], [71.320746, 51.1779], [71.320357, 51.177458], [71.31981, 51.177288], [71.319402, 51.17764], [71.318742, 51.178061], [71.318222, 51.178276], [71.317661, 51.177958], [71.317345, 51.178375], [71.316669, 51.178688], [71.316153, 51.178778], [71.315512, 51.178906], [71.31525, 51.179349], [71.314931, 51.179761], [71.314392, 51.179868], [71.313948, 51.179749], [71.313466, 51.179635], [71.31295, 51.179654], [71.312547, 51.17957], [71.31208, 51.179437], [71.311579, 51.179411], [71.311663, 51.179863], [71.311177, 51.179968], [71.31046, 51.180077], [71.309985, 51.179865], [71.309511, 51.18018], [71.309344, 51.180624], [71.309294, 51.181065], [71.30945, 51.181533], [71.308885, 51.18169], [71.308334, 51.181614], [71.307974, 51.182035], [71.30721, 51.18235], [71.306743, 51.182276], [71.306292, 51.182107], [71.305624, 51.182007], [71.305213, 51.181999], [71.304431, 51.182126], [71.302951, 51.182524], [71.302505, 51.182665], [71.301982, 51.182623], [71.300888, 51.18313], [71.300216, 51.183166], [71.299484, 51.183509], [71.298656, 51.183469], [71.298809, 51.183872], [71.29931, 51.183916], [71.298948, 51.184362], [71.298421, 51.184313], [71.297982, 51.184482], [71.297822, 51.184903], [71.297243, 51.185121], [71.296839, 51.185514], [71.296704, 51.185971], [71.297325, 51.186361], [71.296991, 51.186865], [71.29648, 51.187373], [71.295829, 51.187749], [71.295195, 51.187755], [71.294649, 51.188006], [71.294101, 51.188075], [71.293671, 51.188327], [71.292655, 51.188897], [71.292055, 51.189247], [71.28999, 51.189244], [71.286231, 51.189072], [71.284631, 51.188884], [71.279834, 51.188319], [71.276879, 51.18764], [71.275451, 51.187901], [71.274077, 51.188106], [71.27328, 51.188174], [71.273278, 51.188596], [71.272651, 51.188749], [71.272024, 51.189082], [71.271572, 51.189282], [71.27112, 51.189094], [71.270681, 51.189097], [71.270087, 51.188993], [71.269473, 51.189024], [71.269642, 51.189469], [71.269077, 51.189647], [71.268521, 51.189036], [71.267238, 51.188703], [71.267086, 51.189124], [71.267038, 51.189562], [71.265967, 51.189633], [71.265351, 51.189104], [71.26484, 51.188936], [71.26439, 51.189148], [71.26481, 51.189636], [71.262722, 51.189834], [71.262189, 51.189767], [71.261497, 51.190261], [71.261149, 51.191154], [71.26192, 51.191547], [71.261239, 51.191922], [71.260552, 51.192158], [71.260112, 51.191605], [71.260308, 51.191012], [71.260207, 51.190226], [71.259318, 51.189979], [71.25826, 51.18994], [71.257447, 51.190309], [71.257002, 51.190157], [71.25695, 51.189486], [71.255704, 51.189359], [71.255078, 51.189629], [71.255123, 51.19034], [71.254756, 51.190906], [71.254059, 51.19131], [71.253482, 51.191189], [71.253037, 51.190295], [71.252111, 51.190249], [71.251413, 51.190584], [71.252818, 51.192416], [71.251891, 51.192601], [71.251423, 51.193391], [71.250726, 51.193504], [71.250017, 51.193213], [71.24924, 51.193653], [71.249317, 51.194109], [71.248831, 51.194989], [71.247609, 51.195562], [71.245449, 51.196571], [71.243488, 51.196926], [71.242339, 51.19783], [71.243398, 51.198353], [71.244372, 51.198308], [71.245038, 51.198578], [71.244705, 51.199115], [71.243399, 51.200068], [71.242222, 51.200627], [71.241765, 51.200826], [71.241138, 51.201095], [71.240429, 51.2014], [71.240029, 51.201967], [71.240499, 51.202507], [71.240201, 51.203285], [71.24135, 51.202807], [71.242744, 51.202781], [71.243087, 51.204411], [71.24283, 51.206762], [71.241532, 51.207571], [71.239847, 51.207621], [71.238144, 51.208572], [71.237358, 51.208458], [71.237638, 51.208862], [71.237449, 51.209638], [71.237993, 51.209763], [71.238592, 51.209682], [71.238788, 51.21009], [71.239922, 51.210245], [71.23943, 51.210249], [71.240074, 51.21049], [71.239653, 51.210764], [71.240098, 51.210882], [71.241112, 51.211081], [71.240698, 51.211327], [71.241141, 51.211675], [71.24062, 51.212039], [71.240046, 51.212344], [71.240759, 51.212696], [71.240858, 51.213332], [71.240452, 51.213535], [71.241462, 51.214157], [71.241271, 51.214606], [71.241279, 51.215202], [71.244423, 51.219115], [71.246172, 51.221114], [71.247314, 51.223537], [71.247722, 51.224387], [71.244691, 51.225133], [71.247387, 51.228368], [71.249491, 51.231008], [71.252043, 51.234229], [71.252815, 51.235185], [71.253387, 51.235917], [71.254218, 51.236965], [71.254886, 51.237805], [71.25568, 51.238797], [71.257536, 51.24181], [71.258617, 51.243551], [71.259953, 51.245719], [71.260318, 51.246318], [71.270461, 51.243106], [71.301586, 51.233233], [71.303262, 51.235878], [71.326199, 51.228453], [71.353389, 51.219883], [71.354378, 51.219501], [71.355278, 51.219108], [71.356121, 51.218671], [71.358306, 51.216959], [71.359675, 51.215633], [71.361011, 51.214005], [71.362386, 51.21248], [71.36326, 51.211658], [71.364469, 51.210797], [71.367195, 51.209464], [71.369627, 51.208662], [71.372896, 51.207612], [71.375789, 51.206714], [71.425727, 51.190771], [71.436889, 51.187389], [71.446405, 51.18435], [71.444877, 51.182457], [71.444376, 51.181948], [71.443558, 51.181225], [71.443103, 51.180882], [71.442411, 51.180427], [71.441541, 51.17994], [71.44069, 51.179555], [71.43978, 51.179241], [71.438613, 51.178931], [71.436827, 51.178625], [71.436409, 51.178585], [71.424141, 51.177232], [71.424385, 51.175979], [71.427537, 51.164819], [71.429658, 51.157274], [71.429776, 51.15686], [71.430076, 51.155779], [71.430216, 51.155331], [71.430657, 51.154723], [71.431225, 51.154278], [71.428231, 51.151901], [71.427496, 51.152501], [71.426337, 51.155354], [71.425522, 51.156889], [71.424707, 51.15845], [71.423591, 51.159419], [71.421784, 51.160243], [71.41933, 51.160421], [71.415459, 51.15886], [71.409365, 51.157212], [71.406678, 51.157352], [71.402241, 51.1583], [71.399031, 51.159678], [71.398201, 51.160222], [71.397663, 51.160667], [71.397145, 51.16131], [71.395945, 51.162483], [71.395262, 51.162813], [71.394463, 51.162914], [71.393483, 51.163015], [71.392088, 51.163161], [71.391481, 51.163202], [71.388792, 51.16336], [71.388238, 51.163413], [71.387644, 51.163467], [71.386908, 51.163521], [71.386261, 51.163562], [71.38525, 51.163609], [71.384153, 51.163672], [71.381698, 51.163893], [71.381014, 51.163944], [71.376821, 51.164335], [71.375531, 51.164446], [71.373819, 51.16458], [71.365027, 51.164583], [71.364545, 51.164623], [71.363897, 51.164677], [71.363268, 51.164729], [71.362675, 51.164778], [71.362072, 51.164825], [71.361207, 51.164892]]]	[]
16	8593081	Baikonyr	Байқоңыр	213554	12.7	-4	52	68	#F48FB1	182	[71.298094, 51.147543, 71.706333, 51.35111]	[[[71.446405, 51.18435], [71.444877, 51.182457], [71.444376, 51.181948], [71.443558, 51.181225], [71.443103, 51.180882], [71.442411, 51.180427], [71.441541, 51.17994], [71.44069, 51.179555], [71.43978, 51.179241], [71.438613, 51.178931], [71.436827, 51.178625], [71.436409, 51.178585], [71.424141, 51.177232], [71.424385, 51.175979], [71.427537, 51.164819], [71.429658, 51.157274], [71.429776, 51.15686], [71.430076, 51.155779], [71.430216, 51.155331], [71.430657, 51.154723], [71.431225, 51.154278], [71.428231, 51.151901], [71.429341, 51.151021], [71.431058, 51.150267], [71.433161, 51.150051], [71.435865, 51.149594], [71.437839, 51.148355], [71.43801, 51.147736], [71.438473, 51.147543], [71.440755, 51.148457], [71.443137, 51.149419], [71.444274, 51.150038], [71.445691, 51.150839], [71.447632, 51.151936], [71.450401, 51.152771], [71.451624, 51.153047], [71.452385, 51.153114], [71.453136, 51.153323], [71.453619, 51.153659], [71.454681, 51.154238], [71.459584, 51.15551], [71.4654, 51.158161], [71.467105, 51.159022], [71.468919, 51.159954], [71.469645, 51.160373], [71.470001, 51.160787], [71.471915, 51.161604], [71.472467, 51.162084], [71.472874, 51.162709], [71.474017, 51.163656], [71.47452, 51.163789], [71.475034, 51.163861], [71.475875, 51.163898], [71.476698, 51.163983], [71.477452, 51.164098], [71.478032, 51.164617], [71.478978, 51.165797], [71.479651, 51.166697], [71.480423, 51.167477], [71.48086, 51.167797], [71.48157, 51.168118], [71.482139, 51.168342], [71.482746, 51.168356], [71.48378, 51.168235], [71.484194, 51.168295], [71.485343, 51.16888], [71.48617, 51.169569], [71.487909, 51.171081], [71.488321, 51.171319], [71.489556, 51.17203], [71.490252, 51.172215], [71.490744, 51.172434], [71.491645, 51.172657], [71.492093, 51.173933], [71.492973, 51.174768], [71.494603, 51.175615], [71.495419, 51.17583], [71.497114, 51.175857], [71.49776, 51.17577], [71.498085, 51.176357], [71.49942, 51.177804], [71.502463, 51.180978], [71.504348, 51.18305], [71.504895, 51.183542], [71.505476, 51.183392], [71.505922, 51.183262], [71.506774, 51.183043], [71.507273, 51.182938], [71.507708, 51.182866], [71.50821, 51.182801], [71.508818, 51.182742], [71.509543, 51.182702], [71.510399, 51.182683], [71.510914, 51.182681], [71.511406, 51.182655], [71.511984, 51.182614], [71.512615, 51.182525], [71.513171, 51.182445], [71.513871, 51.182321], [71.51442, 51.182193], [71.514936, 51.182058], [71.51568, 51.181834], [71.51642, 51.181552], [71.519856, 51.180269], [71.520833, 51.179898], [71.521674, 51.179503], [71.522615, 51.178979], [71.523831, 51.178184], [71.524837, 51.178669], [71.525341, 51.178996], [71.527112, 51.179234], [71.528378, 51.179113], [71.529837, 51.179556], [71.531038, 51.180041], [71.533399, 51.180727], [71.533764, 51.181198], [71.533292, 51.182274], [71.533377, 51.182906], [71.533914, 51.183471], [71.535201, 51.183807], [71.536725, 51.184506], [71.537733, 51.1853], [71.538441, 51.185972], [71.539557, 51.187385], [71.540973, 51.188595], [71.542518, 51.188945], [71.544471, 51.189066], [71.54608, 51.189657], [71.547797, 51.190034], [71.549235, 51.190088], [71.550093, 51.189698], [71.552196, 51.189805], [71.553977, 51.190195], [71.557037, 51.19084], [71.557885, 51.191331], [71.558021, 51.19206], [71.55918, 51.192793], [71.560274, 51.193203], [71.561058, 51.193606], [71.561862, 51.194608], [71.562613, 51.194924], [71.563568, 51.195428], [71.568632, 51.196733], [71.572065, 51.19885], [71.574694, 51.199959], [71.57582, 51.200618], [71.577505, 51.20127], [71.580026, 51.202763], [71.58178, 51.203075], [71.582946, 51.203289], [71.57748, 51.213823], [71.574053, 51.220384], [71.58056, 51.224485], [71.596095, 51.234292], [71.606143, 51.240628], [71.618634, 51.248512], [71.617526, 51.249871], [71.616388, 51.251254], [71.611397, 51.257332], [71.609146, 51.260094], [71.608338, 51.261066], [71.607036, 51.262658], [71.606195, 51.263681], [71.605401, 51.264645], [71.60481, 51.265371], [71.604162, 51.266117], [71.601922, 51.268516], [71.594004, 51.277498], [71.589682, 51.273942], [71.584252, 51.269483], [71.576472, 51.263085], [71.56698, 51.257479], [71.566172, 51.252808], [71.562584, 51.24875], [71.558304, 51.248522], [71.555676, 51.24702], [71.553612, 51.245298], [71.551056, 51.243146], [71.545824, 51.244475], [71.527447, 51.24914], [71.505657, 51.254671], [71.503138, 51.255308], [71.47167, 51.263289], [71.472423, 51.263859], [71.473852, 51.264945], [71.479001, 51.268851], [71.480932, 51.270317], [71.485621, 51.273961], [71.488812, 51.276429], [71.498231, 51.28369], [71.498385, 51.290053], [71.490879, 51.288624], [71.477347, 51.286628], [71.475902, 51.28641], [71.468552, 51.278461], [71.450382, 51.271588], [71.428119, 51.274672], [71.413775, 51.270942], [71.400046, 51.267345], [71.397054, 51.27418], [71.390655, 51.288802], [71.389561, 51.291092], [71.388832, 51.292619], [71.385109, 51.302343], [71.355614, 51.297722], [71.356182, 51.296199], [71.357234, 51.293352], [71.358788, 51.289188], [71.359054, 51.288506], [71.36103, 51.283778], [71.362754, 51.279387], [71.364154, 51.275922], [71.364399, 51.275416], [71.365504, 51.273109], [71.366414, 51.27122], [71.36375, 51.270695], [71.360459, 51.270045], [71.356487, 51.269258], [71.351071, 51.268192], [71.346693, 51.267329], [71.345939, 51.268511], [71.342125, 51.267113], [71.340832, 51.268733], [71.338434, 51.267894], [71.33491, 51.266658], [71.334258, 51.266086], [71.332802, 51.264822], [71.331361, 51.263573], [71.329765, 51.262185], [71.327389, 51.260121], [71.324327, 51.257419], [71.321338, 51.254783], [71.319931, 51.253547], [71.319027, 51.25273], [71.317801, 51.251472], [71.316841, 51.25049], [71.315617, 51.249234], [71.315106, 51.248705], [71.313789, 51.247348], [71.311454, 51.244944], [71.309238, 51.242596], [71.305481, 51.238622], [71.304024, 51.237077], [71.303262, 51.235878], [71.326199, 51.228453], [71.353389, 51.219883], [71.354378, 51.219501], [71.355278, 51.219108], [71.356121, 51.218671], [71.358306, 51.216959], [71.359675, 51.215633], [71.361011, 51.214005], [71.362386, 51.21248], [71.36326, 51.211658], [71.364469, 51.210797], [71.367195, 51.209464], [71.369627, 51.208662], [71.372896, 51.207612], [71.375789, 51.206714], [71.425727, 51.190771], [71.436889, 51.187389], [71.446405, 51.18435]], [[71.336225, 51.271701], [71.309252, 51.263849], [71.298094, 51.272763], [71.307878, 51.277703], [71.306119, 51.290962], [71.320195, 51.295391], [71.336225, 51.271701]], [[71.657955, 51.317188], [71.651311, 51.321517], [71.644526, 51.328371], [71.641526, 51.331666], [71.667813, 51.339884], [71.683868, 51.350943], [71.695098, 51.35111], [71.692711, 51.348879], [71.697736, 51.346587], [71.701135, 51.349766], [71.706333, 51.347604], [71.703911, 51.342829], [71.699921, 51.338876], [71.699047, 51.337871], [71.697366, 51.335345], [71.694179, 51.333528], [71.686602, 51.328888], [71.684245, 51.32565], [71.67876, 51.321736], [71.672494, 51.317453], [71.6716, 51.316561], [71.673317, 51.315661], [71.67075, 51.313985], [71.674233, 51.311145], [71.671874, 51.309431], [71.670358, 51.310375], [71.667737, 51.312194], [71.66655, 51.313018], [71.658034, 51.317161], [71.657955, 51.317188]]]	[]
17	19733918	Saraishyq	Сарайшық	200758	11.9	\N	\N	\N	#E6C84F	60.9	[71.445814, 51.085439, 71.741989, 51.139812]	[[[71.53872, 51.102232], [71.532827, 51.102837], [71.527619, 51.103404], [71.526041, 51.103448], [71.525186, 51.103441], [71.524357, 51.103369], [71.523684, 51.103271], [71.522538, 51.102951], [71.518997, 51.101762], [71.517407, 51.101276], [71.515707, 51.100934], [71.514266, 51.100812], [71.512899, 51.100852], [71.51084, 51.101186], [71.507405, 51.102126], [71.502961, 51.103327], [71.50145, 51.103571], [71.500788, 51.103587], [71.500048, 51.103551], [71.499125, 51.103406], [71.498144, 51.103151], [71.494997, 51.101819], [71.492327, 51.100654], [71.491264, 51.100194], [71.489723, 51.099629], [71.487061, 51.100046], [71.483209, 51.100614], [71.480214, 51.101018], [71.479149, 51.101395], [71.476991, 51.102241], [71.476278, 51.102515], [71.475797, 51.102823], [71.475334, 51.103367], [71.474583, 51.104208], [71.474016, 51.104669], [71.472772, 51.105181], [71.471656, 51.10545], [71.460069, 51.105612], [71.456893, 51.10607], [71.453975, 51.107094], [71.451786, 51.108199], [71.451116, 51.108885], [71.450756, 51.109681], [71.450456, 51.112402], [71.450113, 51.115204], [71.445938, 51.119866], [71.446303, 51.121591], [71.446789, 51.121915], [71.447874, 51.122208], [71.448409, 51.122391], [71.450529, 51.123314], [71.451157, 51.123628], [71.451604, 51.123923], [71.452042, 51.124342], [71.452322, 51.124756], [71.452551, 51.125345], [71.4526, 51.125782], [71.452558, 51.126218], [71.452369, 51.126655], [71.451462, 51.127488], [71.450952, 51.127798], [71.449045, 51.12882], [71.448512, 51.129294], [71.447477, 51.130569], [71.447389, 51.131155], [71.454002, 51.130083], [71.455597, 51.129806], [71.457631, 51.129472], [71.45821, 51.129381], [71.458907, 51.129269], [71.46016, 51.129072], [71.461676, 51.128834], [71.462238, 51.128743], [71.463584, 51.128537], [71.464003, 51.12847], [71.465456, 51.128241], [71.468551, 51.127768], [71.469863, 51.127576], [71.470522, 51.127472], [71.471168, 51.127367], [71.472375, 51.127184], [71.473145, 51.127067], [71.474919, 51.126797], [71.476112, 51.126585], [71.476587, 51.126507], [71.477246, 51.126405], [71.479125, 51.126122], [71.480578, 51.125899], [71.481312, 51.125792], [71.483406, 51.12545], [71.483858, 51.125427], [71.484515, 51.12545], [71.485061, 51.12553], [71.485617, 51.12566], [71.486339, 51.125876], [71.486743, 51.126153], [71.487837, 51.126455], [71.48999, 51.127066], [71.490953, 51.127339], [71.491727, 51.127558], [71.496145, 51.128809], [71.496611, 51.128939], [71.497082, 51.129075], [71.497529, 51.129199], [71.498789, 51.129549], [71.499293, 51.129693], [71.501472, 51.130312], [71.503873, 51.130988], [71.50552, 51.131445], [71.506354, 51.131678], [71.507313, 51.131945], [71.508182, 51.132137], [71.509216, 51.13249], [71.509658, 51.132616], [71.510525, 51.132863], [71.51269, 51.133469], [71.513231, 51.133624], [71.514128, 51.133881], [71.514588, 51.134008], [71.51688, 51.13467], [71.517565, 51.134872], [71.518075, 51.135014], [71.518603, 51.135161], [71.519258, 51.135392], [71.519862, 51.135722], [71.520421, 51.136181], [71.520811, 51.136584], [71.521279, 51.137057], [71.521686, 51.137492], [71.522367, 51.138199], [71.523811, 51.139694], [71.52445, 51.139812], [71.525538, 51.139398], [71.526671, 51.138987], [71.528262, 51.138371], [71.528748, 51.138193], [71.529416, 51.137967], [71.530502, 51.137609], [71.53144, 51.137318], [71.532365, 51.137011], [71.533629, 51.136688], [71.534462, 51.136536], [71.535107, 51.136446], [71.535873, 51.136318], [71.536723, 51.136187], [71.53719, 51.136126], [71.53798, 51.136021], [71.538636, 51.135928], [71.539341, 51.135862], [71.54027, 51.135798], [71.541041, 51.135755], [71.541813, 51.135731], [71.5424, 51.135712], [71.543119, 51.13571], [71.543569, 51.135717], [71.544079, 51.135727], [71.544588, 51.135743], [71.545123, 51.135776], [71.545639, 51.135813], [71.546482, 51.135884], [71.547794, 51.136], [71.548954, 51.136094], [71.549418, 51.13613], [71.550067, 51.136166], [71.550705, 51.136182], [71.551265, 51.136197], [71.552498, 51.13621], [71.553663, 51.136233], [71.556555, 51.136295], [71.557846, 51.136316], [71.558944, 51.136319], [71.560278, 51.136306], [71.561099, 51.136277], [71.561875, 51.136236], [71.562889, 51.136163], [71.563579, 51.136101], [71.564198, 51.136053], [71.564987, 51.135959], [71.565752, 51.135861], [71.566467, 51.135762], [71.567318, 51.135631], [71.568814, 51.135383], [71.571127, 51.134995], [71.571618, 51.134914], [71.572274, 51.134774], [71.577724, 51.133797], [71.588519, 51.131954], [71.590419, 51.131658], [71.591138, 51.131534], [71.594095, 51.131], [71.598517, 51.130247], [71.59926, 51.130132], [71.600076, 51.129973], [71.600757, 51.129879], [71.60302, 51.129496], [71.609803, 51.128341], [71.612162, 51.127946], [71.615483, 51.12737], [71.619998, 51.126599], [71.620945, 51.126442], [71.625331, 51.125692], [71.626486, 51.125496], [71.633582, 51.124282], [71.635671, 51.123887], [71.638035, 51.123446], [71.644312, 51.122255], [71.645881, 51.121928], [71.647624, 51.121491], [71.648162, 51.121366], [71.65544, 51.119423], [71.658414, 51.11859], [71.662401, 51.117437], [71.664261, 51.116892], [71.665928, 51.116414], [71.667729, 51.115957], [71.682516, 51.112443], [71.683668, 51.112169], [71.68467, 51.111929], [71.685993, 51.111611], [71.687396, 51.111275], [71.689417, 51.11079], [71.690353, 51.110564], [71.700491, 51.1081], [71.702098, 51.107675], [71.705114, 51.113011], [71.710498, 51.111878], [71.718732, 51.110122], [71.735187, 51.106578], [71.740992, 51.105281], [71.741255, 51.104192], [71.741969, 51.101554], [71.74023, 51.10131], [71.739467, 51.100773], [71.738888, 51.099549], [71.738739, 51.098896], [71.739167, 51.097981], [71.737885, 51.097044], [71.736577, 51.096746], [71.735256, 51.096705], [71.734463, 51.097176], [71.734044, 51.09742], [71.73323, 51.098054], [71.732534, 51.098582], [71.731153, 51.098758], [71.730593, 51.099144], [71.730075, 51.099641], [71.729421, 51.100265], [71.728971, 51.100876], [71.728955, 51.101457], [71.728944, 51.10218], [71.728903, 51.103048], [71.728238, 51.103291], [71.727399, 51.103612], [71.725719, 51.103667], [71.725034, 51.103496], [71.724515, 51.103375], [71.722703, 51.102348], [71.722449, 51.1013], [71.722319, 51.100714], [71.721085, 51.099587], [71.719952, 51.099035], [71.719217, 51.098759], [71.718586, 51.098854], [71.717602, 51.099587], [71.716322, 51.099562], [71.714218, 51.099521], [71.71281, 51.09913], [71.711168, 51.098679], [71.709529, 51.097967], [71.708322, 51.097684], [71.707342, 51.097195], [71.706597, 51.096821], [71.70755, 51.096069], [71.708103, 51.096102], [71.708735, 51.096358], [71.709368, 51.096229], [71.709838, 51.095978], [71.70991, 51.095476], [71.709213, 51.094673], [71.708796, 51.094089], [71.708663, 51.09286], [71.706926, 51.092564], [71.704959, 51.092579], [71.70377, 51.092632], [71.702397, 51.09287], [71.700731, 51.092122], [71.700386, 51.090785], [71.699217, 51.08947], [71.697233, 51.089492], [71.696667, 51.089239], [71.696097, 51.089482], [71.695661, 51.090144], [71.695888, 51.090802], [71.695267, 51.090853], [71.694637, 51.091007], [71.695721, 51.09195], [71.695815, 51.092531], [71.695096, 51.09258], [71.694398, 51.092806], [71.694065, 51.093739], [71.692312, 51.093914], [71.691557, 51.093863], [71.691837, 51.093241], [71.691397, 51.093027], [71.690407, 51.092849], [71.688912, 51.093259], [71.68916, 51.092499], [71.688359, 51.091496], [71.687286, 51.091514], [71.686918, 51.093213], [71.686284, 51.093055], [71.685362, 51.093237], [71.684632, 51.092701], [71.68512, 51.092081], [71.684316, 51.091596], [71.683097, 51.0917], [71.681575, 51.091219], [71.680391, 51.090582], [71.67883, 51.085439], [71.674393, 51.08631], [71.658657, 51.089419], [71.651533, 51.091023], [71.643905, 51.092751], [71.635347, 51.094688], [71.614914, 51.099502], [71.60827, 51.091386], [71.606545, 51.09168], [71.605396, 51.092134], [71.604, 51.092415], [71.601781, 51.093198], [71.599215, 51.094103], [71.587794, 51.097189], [71.550876, 51.100983], [71.53872, 51.102232]]]	[]
18	20593940	Nura	Нұра	328785	19.5	20.5	55	40	#81C784	186.8	[71.217973, 51.013135, 71.428229, 51.189307]	[[[71.331686, 51.021638], [71.328382, 51.022211], [71.32337, 51.023081], [71.321206, 51.023457], [71.318401, 51.023926], [71.313973, 51.023617], [71.31228, 51.023499], [71.310145, 51.022971], [71.309008, 51.022692], [71.307734, 51.022373], [71.306763, 51.022481], [71.305534, 51.022608], [71.304464, 51.022719], [71.303756, 51.022788], [71.302876, 51.022883], [71.301758, 51.02279], [71.299721, 51.022624], [71.298244, 51.022503], [71.295877, 51.022309], [71.294759, 51.022219], [71.293238, 51.022092], [71.290648, 51.021883], [71.288964, 51.021703], [71.287736, 51.021943], [71.285957, 51.022289], [71.284093, 51.023947], [71.282033, 51.024707], [71.28067, 51.025206], [71.279361, 51.026399], [71.278248, 51.027391], [71.277567, 51.028005], [71.276875, 51.028801], [71.275578, 51.030292], [71.27493, 51.030773], [71.273549, 51.031782], [71.272441, 51.032591], [71.27158, 51.033062], [71.270153, 51.033838], [71.269287, 51.034302], [71.268581, 51.03608], [71.268335, 51.036699], [71.267876, 51.038792], [71.266744, 51.039869], [71.265956, 51.040608], [71.2633, 51.041714], [71.26269, 51.042483], [71.262085, 51.043222], [71.261018, 51.044549], [71.260175, 51.045576], [71.25932, 51.046203], [71.258325, 51.046944], [71.257756, 51.04736], [71.256198, 51.048261], [71.254993, 51.04895], [71.254747, 51.049783], [71.25479, 51.051077], [71.254798, 51.051544], [71.254816, 51.052186], [71.25487, 51.053916], [71.254575, 51.054634], [71.253992, 51.056016], [71.254319, 51.057487], [71.254527, 51.058404], [71.255169, 51.060122], [71.255649, 51.061441], [71.255525, 51.063672], [71.253992, 51.065579], [71.25322, 51.065889], [71.251751, 51.067478], [71.250194, 51.068205], [71.248747, 51.068534], [71.24545, 51.068315], [71.24349, 51.071519], [71.242009, 51.07394], [71.238651, 51.079471], [71.236153, 51.083518], [71.23017, 51.093291], [71.227439, 51.097671], [71.225883, 51.100177], [71.225022, 51.101332], [71.220159, 51.10785], [71.217973, 51.110785], [71.221855, 51.112447], [71.228941, 51.115108], [71.228518, 51.116878], [71.228449, 51.119218], [71.229032, 51.121485], [71.229714, 51.122918], [71.230947, 51.124654], [71.232508, 51.126558], [71.234134, 51.128524], [71.23547, 51.130061], [71.237079, 51.131997], [71.237477, 51.132524], [71.23672, 51.132868], [71.236736, 51.134555], [71.237014, 51.137424], [71.23699, 51.138379], [71.236162, 51.149646], [71.238501, 51.1497], [71.238581, 51.152318], [71.242595, 51.152396], [71.242773, 51.157639], [71.254433, 51.158226], [71.254229, 51.162875], [71.253656, 51.168885], [71.252982, 51.17596], [71.259628, 51.175084], [71.26539, 51.174319], [71.278018, 51.178198], [71.281919, 51.179394], [71.281495, 51.179602], [71.281088, 51.179839], [71.280901, 51.180667], [71.279826, 51.181141], [71.279095, 51.180481], [71.278358, 51.180421], [71.277588, 51.180805], [71.277314, 51.180324], [71.276717, 51.18028], [71.275995, 51.180318], [71.276308, 51.180864], [71.276276, 51.181465], [71.275793, 51.181544], [71.275715, 51.182101], [71.275128, 51.182149], [71.274248, 51.181454], [71.273313, 51.181366], [71.27217, 51.182422], [71.272374, 51.183294], [71.27282, 51.183434], [71.27195, 51.183942], [71.271111, 51.183345], [71.270733, 51.183793], [71.271147, 51.184188], [71.27042, 51.184616], [71.27015, 51.185073], [71.270272, 51.18594], [71.269868, 51.186141], [71.270737, 51.186695], [71.271977, 51.187072], [71.272151, 51.187584], [71.27213, 51.188046], [71.273175, 51.188186], [71.274077, 51.188106], [71.275451, 51.187901], [71.276879, 51.18764], [71.279834, 51.188319], [71.284631, 51.188884], [71.286231, 51.189072], [71.28999, 51.189244], [71.291775, 51.189307], [71.292655, 51.188897], [71.29347, 51.188421], [71.294101, 51.188075], [71.294649, 51.188006], [71.295195, 51.187755], [71.295614, 51.187829], [71.296244, 51.187717], [71.296605, 51.18711], [71.297365, 51.186752], [71.296973, 51.186287], [71.29647, 51.186309], [71.296817, 51.185613], [71.297243, 51.185121], [71.297822, 51.184903], [71.297982, 51.184482], [71.298421, 51.184313], [71.298948, 51.184362], [71.299457, 51.184209], [71.298809, 51.183872], [71.298656, 51.183469], [71.299484, 51.183509], [71.300018, 51.183197], [71.300561, 51.183244], [71.301982, 51.182623], [71.302505, 51.182665], [71.302951, 51.182524], [71.304431, 51.182126], [71.305213, 51.181999], [71.305624, 51.182007], [71.306292, 51.182107], [71.306743, 51.182276], [71.30721, 51.18235], [71.307791, 51.182257], [71.308065, 51.181762], [71.308505, 51.181605], [71.309112, 51.181667], [71.309397, 51.181217], [71.309325, 51.180729], [71.309408, 51.180267], [71.309837, 51.180006], [71.31027, 51.180084], [71.310786, 51.180001], [71.311409, 51.180011], [71.311306, 51.179518], [71.311837, 51.179423], [71.31238, 51.179497], [71.312794, 51.179608], [71.313249, 51.179646], [71.31372, 51.17968], [71.314392, 51.179868], [71.314931, 51.179761], [71.31525, 51.179349], [71.315512, 51.178906], [71.316153, 51.178778], [71.316669, 51.178688], [71.317253, 51.178462], [71.317345, 51.177979], [71.317833, 51.178057], [71.318393, 51.178214], [71.319052, 51.177879], [71.319474, 51.17754], [71.319962, 51.177284], [71.32043, 51.17759], [71.320918, 51.177888], [71.321405, 51.177764], [71.321676, 51.177181], [71.322539, 51.176809], [71.323057, 51.176689], [71.323532, 51.176861], [71.323695, 51.177329], [71.32446, 51.17772], [71.324982, 51.177767], [71.325634, 51.177799], [71.326571, 51.177817], [71.327112, 51.177527], [71.327623, 51.176747], [71.32705, 51.176007], [71.326977, 51.175354], [71.327709, 51.174672], [71.328243, 51.17428], [71.328902, 51.174255], [71.329666, 51.174218], [71.330529, 51.173872], [71.330945, 51.173543], [71.330972, 51.173065], [71.331947, 51.172915], [71.332371, 51.173009], [71.333049, 51.173498], [71.333472, 51.173798], [71.333974, 51.174132], [71.334464, 51.174263], [71.335072, 51.174277], [71.335859, 51.174359], [71.336409, 51.174296], [71.33748, 51.174401], [71.338407, 51.174336], [71.339369, 51.174304], [71.340313, 51.174213], [71.341085, 51.174014], [71.341738, 51.173755], [71.342716, 51.173271], [71.344398, 51.17277], [71.345428, 51.172329], [71.346003, 51.171963], [71.34663, 51.171511], [71.347591, 51.171118], [71.348038, 51.170295], [71.348355, 51.169574], [71.348836, 51.16903], [71.349179, 51.168374], [71.34954, 51.167954], [71.350535, 51.167351], [71.35323, 51.166129], [71.354655, 51.16586], [71.355542, 51.165174], [71.356012, 51.164771], [71.357103, 51.164717], [71.357712, 51.164695], [71.359206, 51.16475], [71.360176, 51.164788], [71.361207, 51.164892], [71.362072, 51.164825], [71.362675, 51.164778], [71.363268, 51.164729], [71.363897, 51.164677], [71.364432, 51.164632], [71.365027, 51.164583], [71.373819, 51.16458], [71.375531, 51.164446], [71.376516, 51.164361], [71.381014, 51.163944], [71.381698, 51.163893], [71.384153, 51.163672], [71.38525, 51.163609], [71.386261, 51.163562], [71.386908, 51.163521], [71.387644, 51.163467], [71.388238, 51.163413], [71.388792, 51.16336], [71.391481, 51.163202], [71.392088, 51.163161], [71.393131, 51.163052], [71.394463, 51.162914], [71.395262, 51.162813], [71.395945, 51.162483], [71.397145, 51.16131], [71.397455, 51.160887], [71.397985, 51.160365], [71.399031, 51.159678], [71.402241, 51.1583], [71.406678, 51.157352], [71.409365, 51.157212], [71.415459, 51.15886], [71.41933, 51.160421], [71.421784, 51.160243], [71.423591, 51.159419], [71.424707, 51.15845], [71.425522, 51.156889], [71.426337, 51.155354], [71.427453, 51.152606], [71.428128, 51.151994], [71.426085, 51.150373], [71.424061, 51.148926], [71.423112, 51.148081], [71.42272, 51.147445], [71.422012, 51.146321], [71.420531, 51.143932], [71.41566, 51.136273], [71.415145, 51.135289], [71.414604, 51.133982], [71.414233, 51.132323], [71.412542, 51.122754], [71.412173, 51.120667], [71.410784, 51.11272], [71.410494, 51.111397], [71.410076, 51.110181], [71.409494, 51.108604], [71.407431, 51.103017], [71.40658, 51.10046], [71.405963, 51.098702], [71.405806, 51.098273], [71.405539, 51.097545], [71.405147, 51.096668], [71.404382, 51.094586], [71.404141, 51.093643], [71.403119, 51.090812], [71.402733, 51.089731], [71.40205, 51.087816], [71.398848, 51.078845], [71.395319, 51.069428], [71.390568, 51.05604], [71.385515, 51.041987], [71.384068, 51.03796], [71.383353, 51.035981], [71.382286, 51.032998], [71.382042, 51.032136], [71.381824, 51.031266], [71.381658, 51.030448], [71.381484, 51.029187], [71.381229, 51.02726], [71.380609, 51.022549], [71.380497, 51.02112], [71.380507, 51.020067], [71.380585, 51.018778], [71.380641, 51.018169], [71.380655, 51.017371], [71.380762, 51.016287], [71.380904, 51.014183], [71.381048, 51.013155], [71.380018, 51.013135], [71.368057, 51.014799], [71.366195, 51.015054], [71.364662, 51.015264], [71.360525, 51.015834], [71.357377, 51.016266], [71.35416, 51.016708], [71.34902, 51.017413], [71.347428, 51.017632], [71.345263, 51.017929], [71.341857, 51.018396], [71.339974, 51.018655], [71.338181, 51.0189], [71.335472, 51.019269], [71.334727, 51.019738], [71.331686, 51.021638]]]	[]
\.


--
-- Data for Name: core_exchangerates; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.core_exchangerates (id, base, rates, source_updated_at, fetched_at) FROM stdin;
1	KZT	{"OP": 0.0165556464, "ADA": 0.0087969398, "AED": 0.0082096956, "AFN": 0.144780633, "ALL": 0.1785163567, "AMD": 0.8123645507, "ANG": 0.0039963345, "AOA": 2.0406339182, "ARB": 0.009497578, "ARS": 3.3844347628, "AUD": 0.0031427551, "AWG": 0.0040008041, "AZN": 0.0037996464, "BAM": 0.003817751, "BBD": 0.0044701722, "BDT": 0.2746250625, "BGN": 0.0037214191, "BHD": 0.0008403924, "BIF": 6.6958051189, "BMD": 0.0022350861, "BNB": 0.0000028352, "BND": 0.0028504057, "BOB": 0.0266645808, "BRL": 0.0114020699, "BSD": 0.0022350861, "BTC": 0.0000000259, "BTN": 0.2138737096, "BWP": 0.0295646067, "BYN": 0.0067723121, "BYR": 43.8076873641, "BZD": 0.0044701722, "CAD": 0.0031439397, "CDF": 5.0797925141, "CHF": 0.0018346931, "CLF": 0.0000516305, "CLP": 2.1131625331, "CNY": 0.0149712799, "COP": 7.1677545947, "CRC": 1.0106425323, "CUC": 0.0022350861, "CUP": 0.0536420662, "CVE": 0.2153505699, "CZK": 0.0475400642, "DAI": 0.0022342389, "DJF": 0.397221735, "DKK": 0.0145956733, "DOP": 0.1325853203, "DOT": 0.0018373265, "DZD": 0.3003263208, "EGP": 0.1153948342, "ERN": 0.0335262914, "ETB": 0.359848922, "ETH": 0.0000008117, "EUR": 0.0019524508, "FJD": 0.0050003353, "FKP": 0.0016751149, "GBP": 0.0016751638, "GEL": 0.0058277643, "GGP": 0.0016751149, "GHS": 0.0257542315, "GIP": 0.0016751148, "GMD": 0.164278853, "GNF": 19.7581648867, "GTQ": 0.0170537097, "GYD": 0.4670883748, "HKD": 0.0175302303, "HNL": 0.0601376806, "HRK": 0.0147103707, "HTG": 0.2920967404, "HUF": 0.7066896274, "IDR": 39.8120296232, "ILS": 0.0067118974, "IMP": 0.0016751148, "INR": 0.2138745181, "IQD": 2.9291254667, "IRR": 3073.702458698, "ISK": 0.270199588, "JEP": 0.0016751149, "JMD": 0.3512214753, "JOD": 0.0015869111, "JPY": 0.351970221, "KES": 0.289379651, "KGS": 0.1955365379, "KHR": 9.063275508, "KMF": 0.9599696617, "KPW": 2.0115778077, "KRW": 3.0189648054, "KWD": 0.0006903065, "KYD": 0.0018625643, "KZT": 1, "LAK": 49.8737160385, "LBP": 200.040225721, "LKR": 0.7362374872, "LRD": 0.385842987, "LSL": 0.0363425069, "LTC": 0.0000355098, "LTL": 0.0067412531, "LVL": 0.0013721479, "LYD": 0.0142518501, "MAD": 0.0213555801, "MDL": 0.0391140117, "MGA": 9.8232050461, "MKD": 0.1200040197, "MMK": 4.6929661595, "MNT": 8.0395234605, "MOP": 0.0180559215, "MRO": 0.7979253497, "MRU": 0.0895168188, "MUR": 0.1063749203, "MVR": 0.0345544346, "MWK": 3.8769921691, "MXN": 0.0386681141, "MYR": 0.0091084238, "MZN": 0.1420397375, "NAD": 0.0361864978, "NGN": 2.9588968771, "NIO": 0.0822491454, "NOK": 0.0211018311, "NPR": 0.3420330485, "NZD": 0.0039051429, "OMR": 0.0008607318, "PAB": 0.0022350864, "PEN": 0.0075512394, "PGK": 0.0097262021, "PHP": 0.1399611139, "PKR": 0.6191859919, "PLN": 0.0084899756, "PYG": 13.2837438166, "QAR": 0.0081379493, "RON": 0.0103024076, "RSD": 0.2292237587, "RUB": 0.1883002214, "RWF": 3.2926622266, "SAR": 0.0083938671, "SBD": 0.017869801, "SCR": 0.0332158414, "SDG": 1.3444042831, "SEK": 0.0219830818, "SGD": 0.0028498469, "SHP": 0.0016747502, "SLE": 0.0512619902, "SLL": 51.1191109134, "SOL": 0.0000188518, "SOS": 1.2776870934, "SRD": 0.0845086137, "STD": 48.1203586904, "STN": 0.0481203585, "SVC": 0.0195570033, "SYP": 0.2716300444, "SZL": 0.0361163144, "THB": 0.0740193561, "TJS": 0.0206765601, "TMT": 0.0078228013, "TND": 0.0066073624, "TOP": 0.0052725688, "TRX": 0.0065392952, "TRY": 0.1091571494, "TTD": 0.0150866105, "TWD": 0.0709103538, "TZS": 5.8626317436, "UAH": 0.1002036183, "UGX": 8.7163902931, "USD": 0.0022350861, "UYU": 0.0896582592, "UZS": 26.3789154286, "VEF": 190323.5953539953, "VES": 1.903235901, "VND": 58.1569499066, "VUV": 0.2647361876, "WST": 0.0060850922, "XAF": 1.2806374245, "XAG": 0.0000331671, "XAU": 0.0000005122, "XCD": 0.0060347324, "XCG": 0.0040261087, "XDR": 0.0016379161, "XOF": 1.280637411, "XPD": 0.0000017025, "XPF": 0.2331195229, "XPT": 0.0000012136, "XRP": 0.0014216788, "YER": 0.5288102722, "ZAR": 0.0361610149, "ZMK": 20.1184569134, "ZMW": 0.0435841857, "ZWG": 0.0596786313, "ZWL": 149.1204361712, "AVAX": 0.0001980156, "USDC": 0.0022335473, "USDT": 0.0022346992, "MATIC": 0.020342402}	2026-09-22 23:59:59+00	2026-09-23 09:11:55.365351+00
\.


--
-- Data for Name: core_populationcell; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.core_populationcell (id, lat, lon, population, district_id) FROM stdin;
9847	51.1938	71.4096	708.89	15
9848	51.1956	71.4067	446.23	15
9849	51.192	71.4067	676.63	15
9850	51.1938	71.4067	727.57	15
9851	51.1938	71.4125	595.05	15
9852	51.192	71.4096	1207.23	15
9853	51.1956	71.398	343.24	15
9854	51.1938	71.4038	654.46	15
9855	51.1974	71.398	175.66	15
9856	51.1974	71.3922	1101.52	15
9857	51.1956	71.3951	479.1	15
9858	51.1668	71.4038	743.52	15
9859	51.1668	71.4067	1550.66	15
9860	51.1902	71.4096	688.49	15
9861	51.1722	71.4183	401.22	15
9862	51.174	71.4183	842.31	15
9863	51.1722	71.4212	1150.49	15
9864	51.1722	71.4154	1120.11	15
9865	51.174	71.4154	753.85	15
9866	51.1722	71.4125	1445.03	15
9867	51.1704	71.4183	919.58	15
9868	51.1704	71.4154	629.11	15
9869	51.1704	71.4125	1069.76	15
9870	51.1704	71.4212	557.99	15
9871	51.1686	71.4154	718.46	15
9872	51.1686	71.4183	1447.46	15
9873	51.1686	71.4125	841.33	15
9874	51.1686	71.4212	246.07	15
9875	51.1722	71.427	597.05	16
9876	51.1704	71.4299	127.62	16
9877	51.1704	71.4328	358.83	16
9878	51.1704	71.4357	472.17	16
9879	51.1686	71.4328	1049.08	16
9880	51.1686	71.4357	860.13	16
9881	51.1686	71.4386	829.37	16
9882	51.1668	71.4357	770.78	16
9883	51.1668	71.4386	690	16
9884	51.1704	71.4415	1315.46	16
9885	51.192	71.4009	526.24	15
9886	51.192	71.4038	640.83	15
9887	51.1902	71.4038	593.7	15
9888	51.1902	71.4009	423.78	15
9889	51.1902	71.4067	1121.02	15
9890	51.1884	71.4067	885.92	15
9891	51.1902	71.4125	819.22	15
9892	51.1884	71.4009	602.82	15
9893	51.1884	71.4038	531.23	15
9894	51.1866	71.4038	973.87	15
9895	51.1884	71.4096	307.88	15
9896	51.1902	71.4154	433.33	15
9897	51.1884	71.4154	869.54	15
9898	51.1884	71.4125	1000.89	15
9899	51.1866	71.4154	577.93	15
9900	51.1866	71.4125	614.62	15
9901	51.1866	71.4067	504.3	15
9902	51.1848	71.4038	774.87	15
9903	51.1848	71.4067	484.33	15
9904	51.183	71.4038	397.52	15
9905	51.183	71.4067	445.06	15
9906	51.1848	71.4096	274.21	15
9907	51.183	71.4096	472.41	15
9908	51.1812	71.4096	365.24	15
9909	51.1812	71.4067	704.39	15
9910	51.1812	71.4038	1396.33	15
9911	51.192	71.4154	427.44	15
9912	51.1596	71.4734	220.43	14
9913	51.1578	71.4792	274.83	14
9914	51.156	71.485	568.66	14
9915	51.1722	71.4096	392.51	15
9916	51.1704	71.4096	1507.12	15
9917	51.174	71.4067	901.21	15
9918	51.1758	71.4096	877.94	15
9919	51.174	71.4096	857.35	15
9920	51.1722	71.4067	673.73	15
9921	51.165	71.4125	1205.88	15
9922	51.1668	71.4125	1978	15
9923	51.174	71.4212	517.66	15
9924	51.1758	71.4212	888.8	15
9925	51.1758	71.4183	725.63	15
9926	51.1758	71.4241	473.5	15
9927	51.174	71.427	209.51	16
9928	51.1758	71.427	123.1	16
9929	51.1812	71.4241	545.96	15
9930	51.1812	71.4212	800.08	15
9931	51.183	71.4212	860.45	15
9932	51.1794	71.4212	614.74	15
9933	51.1794	71.4299	773.88	15
9934	51.1776	71.4299	708.5	16
9935	51.1794	71.4328	700.74	15
9936	51.1794	71.4357	698.85	15
9937	51.1812	71.4357	1091.95	15
9938	51.1794	71.427	115.58	15
9939	51.1794	71.4241	570.59	15
9940	51.1776	71.4241	576.4	15
9941	51.1776	71.427	1426.4	15
9942	51.1848	71.4154	779.31	15
9943	51.1866	71.4183	780.29	15
9944	51.1848	71.4183	616.9	15
9945	51.1848	71.4125	1033.9	15
9946	51.183	71.4125	331.1	15
9947	51.183	71.4154	467.73	15
9948	51.183	71.4183	186.07	15
9949	51.1866	71.4212	682.86	15
9950	51.1848	71.4212	745.75	15
9951	51.1812	71.4183	1123.31	15
9952	51.1794	71.4154	721.4	15
9953	51.1794	71.4183	832.6	15
9954	51.1794	71.4125	919.71	15
9955	51.183	71.4241	946.06	15
9956	51.1848	71.4241	1683.68	15
9957	51.1776	71.4125	883.56	15
9958	51.1776	71.4154	1301.51	15
9959	51.1776	71.4183	855.78	15
9960	51.1758	71.4154	859.87	15
9961	51.1758	71.4125	681.04	15
9962	51.1812	71.4125	327.01	15
9963	51.1794	71.4096	705.87	15
9964	51.174	71.4241	1089.7	15
9965	51.1722	71.4241	1056.5	15
9966	51.1776	71.4067	745.81	15
9967	51.1758	71.4067	355.18	15
9968	51.1776	71.4096	620.66	15
9969	51.1776	71.4038	214.51	15
9970	51.1758	71.4038	823.84	15
9971	51.1794	71.4038	433.32	15
9972	51.1812	71.4009	303.95	15
9973	51.174	71.4125	702.37	15
9974	51.1902	71.4183	1118.27	15
9975	51.1902	71.4212	433.07	15
9976	51.1884	71.4183	915.48	15
9977	51.1884	71.4212	751.44	15
9978	51.1938	71.4009	480.53	15
9979	51.1956	71.4009	167.15	15
9980	51.1956	71.4038	572.25	15
9981	51.1938	71.398	200.34	15
9982	51.1974	71.3951	468.74	15
9983	51.1956	71.3922	478.31	15
9984	51.1992	71.3951	235.16	15
9985	51.1992	71.3922	629.98	15
9986	51.1992	71.3893	488.63	15
9987	51.1974	71.3893	679.48	15
9988	51.1992	71.3864	218.73	15
9989	51.201	71.3893	502.58	15
9990	51.1488	71.4763	1786.17	14
9991	51.1938	71.3864	548.53	15
9992	51.1938	71.3893	535.58	15
9993	51.1956	71.3893	2431.07	15
9994	51.1956	71.3864	202.65	15
9995	51.1722	71.4386	444.88	16
9996	51.156	71.4705	1413.15	14
9997	51.1542	71.4444	314.01	16
9998	51.1524	71.4444	207.09	16
9999	51.1542	71.4473	467.76	16
10000	51.1542	71.4502	364.86	16
10001	51.156	71.4502	75.81	16
10002	51.147	71.4618	896.15	14
10003	51.1488	71.4618	294.91	14
10004	51.1488	71.456	510.34	14
10005	51.1488	71.4589	540.36	14
10006	51.147	71.4647	553.5	14
10007	51.1488	71.4647	530.79	14
10008	51.1452	71.4647	628.32	14
10009	51.1452	71.4618	361.89	14
10010	51.1434	71.4647	759.65	14
10011	51.1452	71.4705	485.16	14
10012	51.1452	71.4734	157.34	14
10013	51.1452	71.4676	560.82	14
10014	51.1434	71.4705	272.54	14
10015	51.1434	71.4676	598.43	14
10016	51.1434	71.4734	837.17	14
10017	51.1416	71.4212	351.04	13
10018	51.1398	71.4183	656.82	13
10019	51.1416	71.4183	1284.48	18
10020	51.1434	71.4212	248.63	13
10021	51.1398	71.4212	183.91	13
10022	51.1434	71.4241	205.26	13
10023	51.174	71.456	680.27	16
10024	51.1776	71.456	467.77	16
10025	51.1758	71.456	946.45	16
10026	51.174	71.4473	256.16	16
10027	51.174	71.4531	540	16
10028	51.1722	71.4531	416.81	16
10029	51.1722	71.456	386.4	16
10030	51.174	71.4502	62.28	16
10031	51.1758	71.4531	296.97	16
10032	51.1776	71.4531	148.37	16
10033	51.1632	71.4647	379.33	16
10034	51.1632	71.4676	744.3	16
10035	51.1668	71.4647	561.62	16
10036	51.1686	71.4676	1117.66	16
10037	51.174	71.4038	1510.54	15
10038	51.1668	71.4212	993.81	15
10039	51.1668	71.4183	550.93	15
10040	51.2046	71.4009	377.91	16
10041	51.2064	71.398	195.62	16
10042	51.2046	71.398	201.1	16
10043	51.2028	71.398	27.67	16
10044	51.2064	71.4038	189.59	16
10045	51.156	71.4386	539.28	16
10046	51.1524	71.4357	405.57	16
10047	51.1542	71.4328	384.09	16
10048	51.1218	71.4328	829.36	13
10049	51.1326	71.4299	1904.95	13
10050	51.1272	71.4241	1701.45	13
10051	51.1326	71.427	664.05	13
10052	51.1254	71.4067	560.95	18
10053	51.1524	71.4415	469.74	16
10054	51.1524	71.4386	370.03	16
10055	51.1542	71.4821	619.86	14
10056	51.1542	71.485	686.39	14
10057	51.1542	71.4763	484.78	14
10058	51.156	71.4821	188.36	14
10059	51.156	71.4792	613.57	14
10060	51.1524	71.4821	828.64	14
10061	51.1542	71.4792	261.22	14
10062	51.156	71.4763	520.73	14
10063	51.1578	71.5662	219.45	14
10064	51.1578	71.5691	529.13	14
10065	51.1524	71.485	1260.69	14
10066	51.1506	71.4821	314.08	14
10067	51.1578	71.4879	828.55	14
10068	51.1578	71.485	511.88	14
10069	51.1524	71.4908	15.82	14
10070	51.147	71.5604	127.77	14
10071	51.1452	71.4212	241.88	18
10072	51.1596	71.485	660.03	14
10073	51.1578	71.4821	797.37	14
10074	51.156	71.5604	446.28	14
10075	51.147	71.5662	186.59	14
10076	51.1452	71.5691	284.63	14
10077	51.1452	71.5633	94.17	14
10078	51.147	71.4589	85.41	14
10079	51.1542	71.4386	329.86	16
10080	51.1596	71.4241	352	15
10081	51.1632	71.427	908.12	15
10082	51.1614	71.427	1368.73	15
10083	51.1614	71.4241	1496.25	15
10084	51.1632	71.4241	700.04	15
10085	51.165	71.4241	1050.87	15
10086	51.1596	71.427	1774.85	15
10087	51.1596	71.4299	229.12	16
10088	51.156	71.4299	1436.04	15
10089	51.156	71.427	1241.8	15
10090	51.1506	71.4589	596.37	14
10091	51.1506	71.456	155.73	14
10092	51.1416	71.427	206.14	13
10093	51.2046	71.3661	198.99	15
10094	51.201	71.3661	709.52	15
10095	51.2046	71.3632	539.13	15
10096	51.156	71.4879	690.34	14
10097	51.2028	71.3661	369.18	15
10098	51.1236	71.4647	406.32	17
10099	51.1092	71.4067	2270.68	18
10100	51.1056	71.4067	3565.77	18
10101	51.1866	71.3458	930.23	15
10102	51.1812	71.3748	153.92	15
10103	51.183	71.3835	1050.54	15
10104	51.1866	71.3777	959.91	15
10105	51.0318	71.4705	953.28	13
10106	51.0282	71.4589	467.1	13
10107	51.0336	71.4705	1212.69	13
10108	51.0282	71.4647	2150.53	13
10109	51.0264	71.4618	1616.92	13
10110	51.1578	71.4908	855.41	14
10111	51.1596	71.4879	1089.76	14
10112	51.1614	71.4879	459.93	14
10113	51.1614	71.485	469.9	14
10114	51.1596	71.4821	707.65	14
10115	51.1488	71.5285	851.09	14
10116	51.1506	71.5285	147.94	14
10117	51.1452	71.5285	203.53	14
10118	51.147	71.5256	412.94	14
10119	51.147	71.5285	601.66	14
10120	51.1488	71.5256	302.85	14
10121	51.1524	71.5082	388.32	14
10122	51.1524	71.5053	714.3	14
10123	51.1506	71.5053	982.25	14
10124	51.1542	71.5024	352.61	14
10125	51.1542	71.5053	1112.64	14
10126	51.1488	71.5024	473.36	14
10127	51.1506	71.5024	406.2	14
10128	51.1506	71.4995	690.16	14
10129	51.1524	71.5024	836.29	14
10130	51.1542	71.4995	928.79	14
10131	51.1506	71.4966	278.42	14
10132	51.1524	71.4966	626.56	14
10133	51.1524	71.4995	660.6	14
10134	51.156	71.4995	298.63	14
10135	51.1542	71.4966	587.17	14
10136	51.1758	71.398	257.06	15
10137	51.1542	71.4589	4.38	14
10138	51.192	71.4415	893.48	16
10139	51.201	71.4357	1019.53	16
10140	51.201	71.4386	2196.99	16
10141	51.1992	71.4328	102.55	16
10142	51.201	71.4299	43.05	16
10143	51.1974	71.4299	255.34	16
10144	51.1956	71.4299	355.61	16
10145	51.1956	71.4328	107.12	16
10146	51.1992	71.4299	764.77	16
10147	51.1524	71.4502	1891.37	14
10148	51.1614	71.456	630.03	16
10149	51.1668	71.4589	278.44	16
10150	51.1434	71.4618	715.98	14
10151	51.147	71.4241	379.6	13
10152	51.129	71.4183	1693.51	13
10153	51.129	71.4212	1483.51	13
10154	51.1272	71.427	194.23	13
10155	51.1308	71.427	2467.62	13
10156	51.1974	71.3864	1097.25	15
10157	51.039	71.4705	10.43	13
10158	51.192	71.3893	160.59	15
10159	51.1974	71.3835	129.7	15
10160	51.1254	71.4241	296.27	13
10161	51.1254	71.4212	753.84	13
10162	51.1254	71.4183	175	13
10163	51.1272	71.4183	657.57	13
10164	51.1254	71.427	750.14	13
10165	51.1236	71.427	442.1	13
10166	51.1236	71.4241	889.59	13
10167	51.1254	71.4299	646.38	13
10168	51.129	71.4299	96.84	13
10169	51.1308	71.4386	917.57	13
10170	51.129	71.4154	568.13	13
10171	51.1254	71.4328	567.74	13
10172	51.129	71.4357	1072.38	13
10173	51.1254	71.4357	575.04	13
10174	51.129	71.4444	524.6	13
10175	51.1218	71.4415	8.48	13
10176	51.1236	71.4357	1185.17	13
10177	51.12	71.4328	463.55	13
10178	51.1254	71.4415	583.3	13
10179	51.1308	71.4125	233.69	18
10180	51.12	71.4299	2184.89	13
10181	51.12	71.4212	342.18	13
10182	51.1164	71.4299	3872.33	13
10183	51.1218	71.4241	1617.5	13
10184	51.1218	71.4212	7.82	13
10185	51.1182	71.4357	313.18	13
10186	51.1164	71.427	241.48	13
10187	51.1182	71.4212	1019.55	13
10188	51.1236	71.4212	150.7	13
10189	51.1236	71.4183	997.25	13
10190	51.12	71.4154	1460.19	13
10191	51.12	71.4183	1093.84	13
10192	51.1218	71.4154	1657.87	13
10193	51.1218	71.4183	2712.43	13
10194	51.1182	71.4183	661.92	13
10195	51.1164	71.4154	1613.02	13
10196	51.1164	71.4183	2267.58	13
10197	51.1146	71.4212	1232.07	13
10198	51.1146	71.427	1416.49	13
10199	51.1146	71.4299	1154.27	13
10200	51.1938	71.3922	156.05	15
10201	51.1938	71.3951	228.78	15
10202	51.1542	71.4879	451.87	14
10203	51.1542	71.4908	557.21	14
10204	51.12	71.4096	465.97	18
10205	51.1182	71.4038	118.12	18
10206	51.1164	71.4067	325.1	18
10207	51.1218	71.4096	140.34	18
10208	51.1164	71.4357	941.42	13
10209	51.1164	71.4096	822.21	18
10210	51.1272	71.4908	1302.45	17
10211	51.1272	71.4937	1964.05	17
10212	51.1254	71.4908	2364.51	17
10213	51.12	71.4386	1453.3	13
10214	51.0372	71.4734	21.19	13
10215	51.0372	71.4763	12.95	13
10216	51.0408	71.4734	1.81	13
10217	51.156	71.5082	1940.26	14
10218	51.1578	71.5082	2830.09	14
10219	51.156	71.4966	1101.27	14
10220	51.1578	71.5053	1253.74	14
10221	51.1578	71.5111	1001.21	14
10222	51.1362	71.3661	413.69	18
10223	51.1416	71.398	354.42	18
10224	51.1344	71.369	390.7	18
10225	51.1344	71.3661	600	18
10226	51.1416	71.3951	257.34	18
10227	51.1596	71.5053	2110.3	14
10228	51.1578	71.4966	1186.63	14
10229	51.1326	71.3661	1315.84	18
10230	51.1362	71.369	517.32	18
10231	51.1488	71.3922	274.83	18
10232	51.1488	71.3951	849.63	18
10233	51.1488	71.3893	191.43	18
10234	51.1596	71.5024	1396.6	14
10235	51.1452	71.4096	516.04	18
10236	51.1434	71.3951	215.04	18
10237	51.1452	71.398	301.44	18
10238	51.1434	71.398	376.73	18
10239	51.138	71.4038	624.81	18
10240	51.1452	71.3951	417.32	18
10241	51.1434	71.4096	418.52	18
10242	51.1398	71.4908	160.44	14
10243	51.1272	71.4096	472.02	18
10244	51.1272	71.4125	79.96	18
10245	51.1794	71.4386	273.93	15
10246	51.183	71.427	816.84	15
10247	51.1776	71.4473	246.36	16
10248	51.1758	71.4502	380.96	16
10249	51.1776	71.4502	254.02	16
10250	51.156	71.4908	633.12	14
10251	51.156	71.4937	319.98	14
10252	51.1794	71.4502	328.24	16
10253	51.1794	71.4473	293.34	16
10254	51.1758	71.4473	127.88	16
10255	51.1776	71.4444	93.46	16
10256	51.1722	71.4502	582.48	16
10257	51.1722	71.4589	234.13	16
10258	51.174	71.4589	977.91	16
10259	51.1704	71.4589	501.59	16
10260	51.1704	71.456	126.94	16
10261	51.1704	71.4531	248.85	16
10262	51.1686	71.456	579.3	16
10263	51.1704	71.4473	148.11	16
10264	51.1686	71.4473	1255.68	16
10265	51.1686	71.4502	609.29	16
10266	51.1704	71.4502	162.35	16
10267	51.1776	71.4386	101.82	16
10268	51.1686	71.4531	201.66	16
10269	51.1686	71.4444	210.61	16
10270	51.1758	71.4386	621.32	16
10271	51.1686	71.4415	411.03	16
10272	51.1704	71.4444	202.3	16
10273	51.174	71.4415	72.02	16
10274	51.174	71.4444	103.85	16
10275	51.1722	71.4473	62.26	16
10276	51.1668	71.4444	451.13	16
10277	51.165	71.4502	58.97	16
10278	51.1668	71.4473	163.54	16
10279	51.1668	71.4502	448.07	16
10280	51.165	71.4589	98.49	16
10281	51.1668	71.4618	489	16
10282	51.165	71.4618	135.21	16
10283	51.1686	71.4618	513.78	16
10284	51.1686	71.4647	301.76	16
10285	51.1632	71.4705	189.61	16
10286	51.165	71.4647	163.29	16
10287	51.165	71.4734	408.35	16
10288	51.1632	71.4734	328.84	14
10289	51.165	71.4676	369.7	16
10290	51.1632	71.4618	224.74	16
10291	51.1632	71.456	28.02	16
10292	51.1614	71.4502	409.01	16
10293	51.1632	71.4473	180.74	16
10294	51.1632	71.4502	295.81	16
10295	51.1614	71.4473	213.23	16
10296	51.1632	71.4531	131.83	16
10297	51.165	71.4531	621.87	16
10298	51.1614	71.4531	944.78	16
10299	51.1668	71.4531	126.55	16
10300	51.1758	71.4328	306.56	16
10301	51.1758	71.4357	1879.22	16
10302	51.1686	71.427	145.14	16
10303	51.1686	71.4299	758.91	16
10304	51.1722	71.4299	507.59	16
10305	51.174	71.4299	598.38	16
10306	51.174	71.4357	844.12	16
10307	51.1758	71.4299	105.51	16
10308	51.1722	71.4328	468.84	16
10309	51.174	71.4328	295.24	16
10310	51.1704	71.427	354.71	16
10311	51.1722	71.4357	379.61	16
10312	51.165	71.4386	905.08	16
10313	51.165	71.4444	192.81	16
10314	51.1704	71.4386	351.49	16
10315	51.1668	71.4415	1207.71	16
10316	51.1632	71.4328	133.03	16
10317	51.1632	71.4299	658.88	16
10318	51.1668	71.4299	1160.58	16
10319	51.165	71.4299	733.75	16
10320	51.1668	71.427	573.91	16
10321	51.1614	71.4328	610.79	16
10322	51.1578	71.4357	348.31	16
10323	51.1578	71.4299	347.44	16
10324	51.1578	71.427	275.76	15
10325	51.1578	71.4328	543.65	16
10326	51.1596	71.4328	219.25	16
10327	51.1596	71.4386	303.76	16
10328	51.1614	71.4386	735.15	16
10329	51.1596	71.4357	1145.99	16
10330	51.1542	71.4299	1503.01	15
10331	51.1632	71.4386	1003.53	16
10332	51.1614	71.4299	550.37	16
10333	51.1614	71.4357	388.86	16
10334	51.1542	71.4357	595.87	16
10335	51.156	71.4415	164.91	16
10336	51.1812	71.4299	1088.4	15
10337	51.1812	71.427	614.95	15
10338	51.1578	71.4444	139.29	16
10339	51.1578	71.4415	322.7	16
10340	51.1578	71.4386	520.29	16
10341	51.156	71.4357	416.54	16
10342	51.1578	71.4473	25.48	16
10343	51.156	71.4444	120.79	16
10344	51.1542	71.4415	319.17	16
10345	51.1506	71.4357	156.91	16
10346	51.1506	71.4328	314.82	16
10347	51.1542	71.4531	48.46	16
10348	51.1542	71.456	161.65	14
10349	51.1524	71.4647	886.32	14
10350	51.1506	71.4386	17.65	16
10351	51.1506	71.4618	325.44	14
10352	51.1542	71.4676	240.34	14
10353	51.1524	71.4618	319.05	14
10354	51.1524	71.4531	400.91	14
10355	51.1542	71.4618	708.28	14
10356	51.1398	71.4502	985.48	14
10357	51.1488	71.4676	909.78	14
10358	51.1398	71.4531	1028.3	14
10359	51.147	71.4676	958.8	14
10360	51.1452	71.4473	601.8	14
10361	51.1434	71.4531	514.47	14
10362	51.1452	71.4502	417.31	14
10363	51.1398	71.4473	456.28	14
10364	51.1416	71.4473	799.06	14
10365	51.1416	71.4502	540.85	14
10366	51.147	71.4705	397.1	14
10367	51.1506	71.4647	523.78	14
10368	51.1506	71.4676	427.78	14
10369	51.138	71.4531	84.26	14
10370	51.1416	71.4676	45.44	14
10371	51.1488	71.4705	161.86	14
10372	51.1398	71.4618	215.49	14
10373	51.1398	71.4676	143.82	14
10374	51.1524	71.4676	251.43	14
10375	51.1488	71.4473	218.53	14
10376	51.1506	71.4502	117.22	14
10377	51.1506	71.4473	108.9	14
10378	51.1452	71.4589	977.3	14
10379	51.1488	71.4502	157.91	14
10380	51.1506	71.4444	2.08	16
10381	51.147	71.4502	138.01	14
10382	51.147	71.4531	130.72	14
10383	51.1488	71.4531	250.57	14
10384	51.1506	71.4531	222.96	14
10385	51.1452	71.4531	150.26	14
10386	51.1434	71.456	120.73	14
10387	51.147	71.456	480.35	14
10388	51.1452	71.456	838.19	14
10389	51.1416	71.4734	961.93	14
10390	51.1524	71.4734	295.28	14
10391	51.138	71.4676	832.68	14
10392	51.1506	71.4705	284.03	14
10393	51.1524	71.4705	715.66	14
10394	51.138	71.4705	1646.9	14
10395	51.1398	71.4763	396.83	14
10396	51.1398	71.4705	1510.09	14
10397	51.1398	71.4734	1145.32	14
10398	51.1542	71.4734	473.89	14
10399	51.1542	71.4705	735.39	14
10400	51.147	71.4734	61.52	14
10401	51.1524	71.4792	531.71	14
10402	51.1506	71.4879	154.71	14
10403	51.1506	71.4792	581.6	14
10404	51.1488	71.4821	584.62	14
10405	51.147	71.4792	678.78	14
10406	51.1524	71.4879	630.2	14
10407	51.1506	71.485	357.86	14
10408	51.1416	71.4763	1701.63	14
10409	51.1506	71.4763	600.53	14
10410	51.1506	71.4734	385.23	14
10411	51.147	71.4763	697.96	14
10412	51.147	71.4821	738.31	14
10413	51.1524	71.4763	150.71	14
10414	51.1488	71.4792	1022.13	14
10415	51.1452	71.4763	533.44	14
10416	51.1614	71.4966	973.2	14
10417	51.1614	71.4995	1317.56	14
10418	51.147	71.4966	414.77	14
10419	51.1452	71.4966	298.26	14
10420	51.147	71.4995	181.3	14
10421	51.156	71.5053	3540.43	14
10422	51.1452	71.5024	302.43	14
10423	51.1596	71.4966	272.32	14
10424	51.1434	71.4763	940.99	14
10425	51.1596	71.4995	1057.63	14
10426	51.1596	71.4937	77.26	14
10427	51.1578	71.4995	567.4	14
10428	51.1542	71.5082	3190.78	14
10429	51.1578	71.5024	1372.07	14
10430	51.1614	71.4937	333.86	14
10431	51.1452	71.4995	182.41	14
10432	51.1398	71.4821	1947.06	14
10433	51.1362	71.4676	842.17	14
10434	51.1416	71.485	2037.93	14
10435	51.138	71.4734	783.24	14
10436	51.129	71.4589	2469.18	17
10437	51.138	71.4763	1466.79	14
10438	51.1272	71.4589	1638.51	17
10439	51.1326	71.4676	106.26	14
10440	51.1344	71.4676	903.09	14
10441	51.1308	71.4705	106.53	14
10442	51.1326	71.4705	169.37	14
10443	51.1326	71.4734	214.15	14
10444	51.1308	71.4647	274.8	14
10445	51.1326	71.4647	478.35	14
10446	51.1326	71.4763	287.84	14
10447	51.1308	71.4676	64.38	14
10448	51.1308	71.4821	74.6	14
10449	51.1344	71.4705	101.86	14
10450	51.1362	71.4734	578.75	14
10451	51.1362	71.4705	458.15	14
10452	51.1308	71.4763	96.56	14
10453	51.1308	71.4792	257.2	14
10454	51.1344	71.4734	98.11	14
10455	51.1308	71.4966	1492.44	14
10456	51.1398	71.4792	1167.63	14
10457	51.12	71.4705	2060.27	17
10458	51.1164	71.4386	1087.61	13
10459	51.1128	71.427	2788.54	13
10460	51.12	71.4734	338.84	17
10461	51.1182	71.4618	2919.36	17
10462	51.1146	71.4386	703.24	13
10463	51.138	71.4125	3151.64	18
10464	51.1452	71.4183	889.71	18
10465	51.1416	71.4096	348.44	18
10466	51.1146	71.4154	1888.63	13
10467	51.1434	71.4125	810.04	18
10468	51.1398	71.4096	541.07	18
10469	51.138	71.4096	1062.87	18
10470	51.1362	71.4299	1527.29	13
10471	51.1344	71.4299	512.94	13
10472	51.138	71.4183	322.31	13
10473	51.1344	71.4212	3041.11	13
10474	51.1344	71.4328	1157.5	13
10475	51.1308	71.4009	491.98	18
10476	51.1416	71.4125	1734.68	18
10477	51.1236	71.4096	545.9	18
10478	51.1272	71.4067	1.94	18
10479	51.1362	71.427	1515.51	13
10480	51.1434	71.4154	771.67	18
10481	51.1434	71.4183	520.2	18
10482	51.1452	71.4154	1337.63	18
10483	51.1398	71.4154	981.42	18
10484	51.1344	71.427	732.7	13
10485	51.1488	71.4154	1618.43	18
10486	51.1452	71.4067	262.43	18
10487	51.1488	71.4067	99.22	18
10488	51.1488	71.4096	225.35	18
10489	51.1506	71.4038	324.77	18
10490	51.1398	71.4067	115.67	18
10491	51.147	71.4067	354.94	18
10492	51.147	71.3719	387.4	18
10493	51.1416	71.4038	122.6	18
10494	51.1488	71.4038	122.38	18
10495	51.147	71.4096	287.54	18
10496	51.147	71.4125	115.59	18
10497	51.1416	71.4067	140.95	18
10498	51.1488	71.4125	269.14	18
10499	51.1488	71.3806	531.82	18
10500	51.1506	71.4009	181.97	18
10501	51.1506	71.3893	267.2	18
10502	51.1488	71.3864	867.75	18
10503	51.1452	71.4009	476.74	18
10504	51.1452	71.3748	8.34	18
10505	51.1488	71.4183	65.98	18
10506	51.147	71.4009	170.97	18
10507	51.147	71.369	520.08	18
10508	51.1452	71.4241	413.33	13
10509	51.1488	71.427	1005.98	13
10510	51.1416	71.4241	204.5	13
10511	51.1632	71.4908	582.23	14
10512	51.1452	71.427	161.05	13
10513	51.1596	71.4908	322.4	14
10514	51.147	71.427	804.18	13
10515	51.138	71.4357	399.77	13
10516	51.1506	71.427	365.82	13
10517	51.1614	71.4908	714.37	14
10518	51.1488	71.4241	50.59	13
10519	51.1632	71.4937	284.22	14
10520	51.165	71.4908	136.39	14
10521	51.1236	71.485	837.42	17
10522	51.1434	71.427	172.71	13
10523	51.1632	71.4154	179.03	15
10524	51.1596	71.4038	2025.54	15
10525	51.1614	71.4125	1679.94	15
10526	51.1632	71.4183	499.45	15
10527	51.165	71.4212	63.05	15
10528	51.1578	71.4067	309.76	15
10529	51.1632	71.4212	1632.55	15
10530	51.1614	71.4154	700.59	15
10531	51.1596	71.4125	1493.23	15
10532	51.1614	71.4183	1738.13	15
10533	51.1614	71.4212	710.3	15
10534	51.1596	71.4067	3501.31	15
10535	51.1614	71.4009	1710.77	15
10536	51.165	71.4183	1696.37	15
10537	51.1596	71.4096	2852.32	15
10538	51.1596	71.4154	1152.78	15
10539	51.1668	71.4009	2763.53	15
10540	51.1668	71.398	577.93	15
10541	51.1632	71.4125	642.77	15
10542	51.1686	71.4009	2908.4	15
10543	51.1632	71.4096	267.14	15
10544	51.165	71.427	884.1	15
10545	51.165	71.4096	1478.63	15
10546	51.1686	71.4067	593.54	15
10547	51.1614	71.4038	1869.75	15
10548	51.165	71.398	28.22	15
10549	51.1632	71.4009	2791.99	15
10550	51.165	71.4038	4334.94	15
10551	51.1704	71.4038	1762.34	15
10552	51.1704	71.4009	2054.12	15
10553	51.1704	71.4067	578.26	15
10554	51.1758	71.3922	462.89	15
10555	51.1776	71.3893	829.95	15
10556	51.1776	71.3864	593.25	15
10557	51.174	71.3922	875.06	15
10558	51.1758	71.4009	103.83	15
10559	51.1776	71.3835	236.68	15
10560	51.1704	71.3951	1020.88	15
10561	51.1722	71.4009	1105.74	15
10562	51.1758	71.3951	154.91	15
10563	51.1668	71.3922	1732.05	15
10564	51.174	71.4009	296.61	15
10565	51.1722	71.4038	2735.09	15
10566	51.1794	71.3748	959	15
10567	51.1722	71.3806	1297.15	15
10568	51.1704	71.3864	1130.79	15
10569	51.183	71.3777	1292.02	15
10570	51.1848	71.3806	375.37	15
10571	51.1794	71.3922	578.61	15
10572	51.183	71.3864	126.3	15
10573	51.183	71.3806	731.55	15
10574	51.1704	71.3835	515.76	15
10575	51.1722	71.3835	417.89	15
10576	51.1704	71.3806	732.47	15
10577	51.1704	71.3893	607.7	15
10578	51.1686	71.3893	1428.22	15
10579	51.174	71.3835	761.6	15
10580	51.174	71.3806	1479.55	15
10581	51.1848	71.3748	377.99	15
10582	51.1794	71.3806	144.27	15
10583	51.1794	71.3777	1383.54	15
10584	51.1812	71.3806	1134.92	15
10585	51.1794	71.3719	135.15	15
10586	51.1758	71.3748	174.13	15
10587	51.1686	71.3864	546.28	15
10588	51.1776	71.3777	142.77	15
10589	51.174	71.3719	249.71	15
10590	51.1758	71.3777	50.64	15
10591	51.1758	71.3719	192.35	15
10592	51.1848	71.3777	63.8	15
10593	51.1686	71.3806	651.5	15
10594	51.1812	71.369	160.84	15
10595	51.1848	71.3661	212.34	15
10596	51.1794	71.3893	642.95	15
10597	51.174	71.3748	76.01	15
10598	51.1794	71.3864	648.35	15
10599	51.183	71.3748	257	15
10600	51.1812	71.3922	319.8	15
10601	51.1776	71.3748	173.39	15
10602	51.1758	71.369	195.52	15
10603	51.1668	71.3864	528.69	15
10604	51.1668	71.3893	268.56	15
10605	51.165	71.3864	612.06	15
10606	51.174	71.369	961.92	15
10607	51.1866	71.3748	215.28	15
10608	51.1812	71.3777	539.83	15
10609	51.183	71.3893	77.14	15
10610	51.183	71.3922	46.63	15
10611	51.1812	71.3864	1066.06	15
10612	51.1866	71.3661	343.55	15
10613	51.192	71.3806	368.67	15
10614	51.183	71.369	109.73	15
10615	51.1794	71.4009	683.19	15
10616	51.1686	71.3922	772.61	15
10617	51.1704	71.3922	691.2	15
10618	51.174	71.3864	646.46	15
10619	51.1686	71.4096	952.94	15
10620	51.1812	71.3951	148.77	15
10621	51.1722	71.3893	954.75	15
10622	51.1794	71.4067	1192.47	15
10623	51.1758	71.3835	283.84	15
10624	51.1812	71.398	486.02	15
10625	51.1722	71.3864	303.49	15
10626	51.1758	71.3864	290.08	15
10627	51.1794	71.3951	153.97	15
10628	51.1668	71.4096	415.84	15
10629	51.1668	71.4154	30.17	15
10630	51.1668	71.4241	1017.17	15
10631	51.1632	71.4444	1108.85	16
10632	51.1614	71.4444	259.14	16
10633	51.1614	71.4415	296.08	16
10634	51.1686	71.4241	1048.15	15
10635	51.1632	71.4415	391.04	16
10636	51.1596	71.4444	364.74	16
10637	51.1668	71.4328	314.18	16
10638	51.165	71.4154	710.41	15
10639	51.1524	71.4473	173.6	16
10640	51.156	71.4531	293.04	16
10641	51.1614	71.4821	193.35	14
10642	51.1632	71.4589	854.52	16
10643	51.1614	71.4618	664.29	16
10644	51.1614	71.4589	1065.37	16
10645	51.1578	71.456	298.05	16
10646	51.1596	71.4647	251.31	16
10647	51.1596	71.456	780.1	16
10648	51.1578	71.4589	222.31	16
10649	51.1578	71.4618	183.73	16
10650	51.1596	71.4618	696.61	16
10651	51.1578	71.4763	498.09	14
10652	51.1578	71.4531	628.45	16
10653	51.156	71.4589	218.08	16
10654	51.1596	71.4589	930.33	16
10655	51.1596	71.4531	58.87	16
10656	51.156	71.456	198.06	16
10657	51.1614	71.4647	307.13	16
10658	51.1578	71.4705	1020.26	14
10659	51.1578	71.4502	155.68	16
10660	51.1578	71.4734	530.81	14
10661	51.1596	71.4705	297.18	14
10662	51.1614	71.4676	36.55	16
10663	51.1578	71.4647	218.24	14
10664	51.1722	71.4676	331.5	16
10665	51.1668	71.4763	101.07	16
10666	51.1632	71.4792	830.3	14
10667	51.1542	71.4937	705.91	14
10668	51.1668	71.4734	167.15	16
10669	51.1704	71.4676	234.57	16
10670	51.174	71.4618	1015.66	16
10671	51.1668	71.4705	726.67	16
10672	51.1686	71.4734	261.28	16
10673	51.1614	71.4734	974.06	14
10674	51.1704	71.4763	1037.53	16
10675	51.1596	71.4763	375.61	14
10676	51.1704	71.4734	599.89	16
10677	51.1704	71.4647	423.25	16
10678	51.1668	71.4676	263.01	16
10679	51.1614	71.4705	104.72	16
10680	51.1578	71.4937	939.81	14
10681	51.1686	71.4763	184.19	16
10682	51.1614	71.4763	1018.67	14
10683	51.1704	71.4792	105.05	16
10684	51.1758	71.4618	606.23	16
10685	51.1632	71.4763	450.42	14
10686	51.1686	71.4705	173.73	16
10687	51.1758	71.4589	854.05	16
10688	51.1326	71.4908	108.7	14
10689	51.1434	71.485	183.17	14
10690	51.1452	71.485	162.3	14
10691	51.1452	71.4821	114.84	14
10692	51.1434	71.4792	412	14
10693	51.1416	71.4792	159.94	14
10694	51.1434	71.4821	52.96	14
10695	51.147	71.485	353.85	14
10696	51.1416	71.4821	774.77	14
10697	51.1452	71.4792	96.36	14
10698	51.1326	71.4879	96.8	14
10699	51.1434	71.4879	21.83	14
10700	51.1488	71.4908	127.98	14
10701	51.1434	71.5227	78.88	14
10702	51.1452	71.5227	103.44	14
10703	51.1506	71.514	97.84	14
10704	51.1488	71.4879	147.52	14
10705	51.147	71.5082	82.68	14
10706	51.1452	71.5198	94.58	14
10707	51.1524	71.514	105.17	14
10708	51.147	71.514	93.56	14
10709	51.1434	71.5169	64.31	14
10710	51.1488	71.514	128.23	14
10711	51.1488	71.5053	59.45	14
10712	51.147	71.5227	108.29	14
10713	51.1506	71.5256	104.04	14
10714	51.1434	71.5198	315.88	14
10715	51.1488	71.5082	236.21	14
10716	51.1506	71.5111	270.88	14
10717	51.1452	71.5111	731.57	14
10718	51.1434	71.5256	154.15	14
10719	51.1488	71.5169	226.23	14
10720	51.1506	71.5082	170.68	14
10721	51.147	71.5198	203.08	14
10722	51.147	71.5111	207.7	14
10723	51.1542	71.514	230.16	14
10724	51.1506	71.4908	126.12	14
10725	51.1344	71.4937	168.72	14
10726	51.1506	71.5198	319.43	14
10727	51.138	71.5111	122.17	14
10728	51.1362	71.5053	74.82	14
10729	51.1416	71.5227	134.43	14
10730	51.1506	71.4937	181.34	14
10731	51.1362	71.514	151.02	14
10732	51.1398	71.514	48.21	14
10733	51.138	71.5082	104.59	14
10734	51.1362	71.4995	166.53	14
10735	51.1362	71.5024	106.67	14
10736	51.1398	71.5111	167.5	14
10737	51.1344	71.4966	110.06	14
10738	51.1344	71.4995	110.41	14
10739	51.138	71.5053	85.48	14
10740	51.1416	71.5198	169.67	14
10741	51.147	71.5053	984.61	14
10742	51.1524	71.5111	136.16	14
10743	51.1452	71.5256	45.99	14
10744	51.1416	71.5256	4.99	14
10745	51.1362	71.5227	110.14	17
10746	51.1488	71.4937	68.41	14
10747	51.1488	71.485	1097.58	14
10748	51.1272	71.4879	814.47	14
10749	51.129	71.485	130.22	14
10750	51.1236	71.4763	1059.65	17
10751	51.1254	71.4763	1465.42	17
10752	51.1236	71.4792	1880.29	17
10753	51.1254	71.485	1218.56	17
10754	51.1254	71.4792	994.69	17
10755	51.2064	71.3951	183.69	16
10756	51.1236	71.5198	588.27	17
10757	51.2082	71.3951	181.02	16
10758	51.2082	71.4009	430.99	16
10759	51.1218	71.5198	407.59	17
10760	51.1128	71.4473	119.22	13
10761	51.1362	71.5372	87.37	14
10762	51.1254	71.5227	108.62	17
10763	51.1254	71.5198	150.68	17
10764	51.1326	71.5401	279.1	17
10765	51.1236	71.5227	774.68	17
10766	51.1218	71.5169	126.63	17
10767	51.1236	71.5169	269.04	17
10768	51.1362	71.543	9.1	14
10769	51.2046	71.4125	88.34	16
10770	51.1902	71.34	2889.12	15
10771	51.1902	71.3342	520.92	15
10772	51.201	71.4067	42.81	16
10773	51.2028	71.4067	46.3	16
10774	51.2028	71.4096	55.39	16
10775	51.21	71.4067	95.58	16
10776	51.2028	71.369	118.14	15
10777	51.21	71.4038	55.93	16
10778	51.2046	71.4067	56.31	16
10779	51.2028	71.3632	456.94	15
10780	51.1956	71.3632	145.75	15
10781	51.1974	71.3661	124.82	15
10782	51.1956	71.3342	88.08	15
10783	51.1974	71.3342	121.59	15
10784	51.1938	71.3342	111.77	15
10785	51.192	71.3284	140.06	15
10786	51.201	71.3603	111.75	15
10787	51.201	71.3632	118.84	15
10788	51.192	71.3371	3473.08	15
10789	51.1938	71.3632	131.54	15
10790	51.201	71.4096	27.72	16
10791	51.1974	71.3632	116.12	15
10792	51.192	71.34	174.11	15
10793	51.1938	71.3371	145.5	15
10794	51.201	71.4038	82.73	16
10795	51.1956	71.3603	102.26	15
10796	51.192	71.3313	3.41	15
10797	51.192	71.4183	434.05	15
10798	51.1884	71.3922	170.08	15
10799	51.192	71.4125	174.85	15
10800	51.1902	71.4241	280.3	15
10801	51.183	71.4299	1371.42	15
10802	51.2028	71.3864	120.61	15
10803	51.201	71.3864	317.58	15
10804	51.1866	71.4009	161.77	15
10805	51.201	71.3922	404.07	15
10806	51.1848	71.3922	55.03	15
10807	51.1902	71.3951	184.58	15
10808	51.1866	71.4241	607.33	15
10809	51.1974	71.4009	464.53	15
10810	51.1866	71.3922	115.03	15
10811	51.1884	71.398	134.04	15
10812	51.1866	71.3951	43.25	15
10813	51.1866	71.398	137.41	15
10814	51.1776	71.4212	356.16	15
10815	51.1812	71.4328	428.72	15
10816	51.183	71.4386	831.47	15
10817	51.1452	71.4299	134.11	13
10818	51.1398	71.4241	234.71	13
10819	51.1398	71.427	224.9	13
10820	51.147	71.4299	144.22	13
10821	51.1434	71.4299	173.48	13
10822	51.1416	71.4299	172.74	13
10823	51.1398	71.4299	142.67	13
10824	51.138	71.4328	202.86	13
10825	51.1416	71.4328	165.63	13
10826	51.138	71.427	181.22	13
10827	51.1398	71.4328	88.06	13
10828	51.138	71.4299	106.53	13
10829	51.1452	71.4328	318.91	13
10830	51.138	71.4212	155.07	13
10831	51.1452	71.4357	196.55	13
10832	51.1434	71.4328	144.09	13
10833	51.147	71.4357	447.41	13
10834	51.1488	71.4299	305.85	13
10835	51.1488	71.4328	98.91	13
10836	51.147	71.4328	209.55	13
10837	51.1434	71.4357	79.38	13
10838	51.1794	71.4676	405.43	16
10839	51.1812	71.4705	239.29	16
10840	51.1848	71.4502	165.5	16
10841	51.1866	71.4531	338.89	16
10842	51.1794	71.4647	170.72	16
10843	51.1812	71.4879	194.96	16
10844	51.183	71.4531	161.4	16
10845	51.1812	71.4618	192.96	16
10846	51.183	71.4734	483.68	16
10847	51.1812	71.4647	293.4	16
10848	51.183	71.456	80.11	16
10849	51.183	71.4589	297	16
10850	51.1812	71.4908	253.89	16
10851	51.1848	71.4647	13.77	16
10852	51.1884	71.4531	16.37	16
10853	51.1776	71.4879	212.22	16
10854	51.183	71.4647	351.81	16
10855	51.1812	71.4734	435.21	16
10856	51.1794	71.4879	48.74	16
10857	51.1758	71.4763	420.72	16
10858	51.1884	71.4734	278.36	16
10859	51.1812	71.4676	761.06	16
10860	51.1866	71.4966	43.69	16
10861	51.1866	71.4618	367.19	16
10862	51.1866	71.4763	179.02	16
10863	51.1848	71.4473	14.15	16
10864	51.1848	71.4531	174.68	16
10865	51.1866	71.4502	141.75	16
10866	51.1794	71.4908	146.78	16
10867	51.183	71.4618	158.41	16
10868	51.1848	71.4937	611.7	16
10869	51.1938	71.4357	110.72	16
10870	51.1686	71.4879	942.01	14
10871	51.1956	71.4386	87.04	16
10872	51.1956	71.4415	79.18	16
10873	51.1974	71.4386	101.89	16
10874	51.1956	71.456	169.58	16
10875	51.1974	71.4618	258.86	16
10876	51.1974	71.456	64.74	16
10877	51.1884	71.4415	136.34	16
10878	51.1902	71.4618	119.27	16
10879	51.1668	71.4879	145.69	14
10880	51.1902	71.4386	321.91	16
10881	51.2046	71.4444	961.24	16
10882	51.192	71.4589	38.92	16
10883	51.1956	71.4357	80.57	16
10884	51.1902	71.4415	234.64	16
10885	51.1956	71.4676	328.65	16
10886	51.1884	71.4473	397.38	16
10887	51.1974	71.4328	8.86	16
10888	51.1686	71.4792	4.36	16
10889	51.1974	71.4589	179.94	16
10890	51.1956	71.4531	224.95	16
10891	51.1938	71.4647	219.83	16
10892	51.1866	71.4473	53.02	16
10893	51.1974	71.4357	20.64	16
10894	51.1938	71.4328	37.25	16
10895	51.156	71.4734	286.86	14
10896	51.1812	71.4154	2035.4	15
10897	51.165	71.4473	88.84	16
10898	51.165	71.4357	1344.28	16
10899	51.183	71.3951	278.33	15
10900	51.1848	71.3893	102.69	15
10901	51.1542	71.4183	1319.92	18
10902	51.156	71.5111	204.74	14
10903	51.156	71.4328	17.95	16
10904	51.1416	71.4618	25.18	14
10905	51.138	71.4647	520.54	14
10906	51.1524	71.4589	88.88	14
10907	51.1308	71.456	266.8	14
10908	51.1812	71.4444	46.81	16
10909	51.1128	71.4212	1533.02	13
10910	51.1398	71.4009	96.1	18
10911	51.1452	71.3893	215.69	18
10912	51.1398	71.4038	133.69	18
10913	51.1416	71.4009	143.31	18
10914	51.1362	71.4183	340.09	13
10915	51.1398	71.398	207.47	18
10916	51.1434	71.3922	106	18
10917	51.1434	71.4038	230.3	18
10918	51.1434	71.3893	484.74	18
10919	51.1434	71.4009	374.03	18
10920	51.138	71.4067	548.45	18
10921	51.1416	71.3922	331.22	18
10922	51.1398	71.3951	695.44	18
10923	51.111	71.4212	1359.58	13
10924	51.1308	71.4444	11.38	13
10925	51.1506	71.3835	19.65	18
10926	51.1488	71.4009	216.85	18
10927	51.1506	71.398	75.19	18
10928	51.1488	71.398	89.86	18
10929	51.1506	71.3951	552	18
10930	51.1506	71.4067	57.52	18
10931	51.147	71.398	43.73	18
10932	51.1452	71.3922	576.19	18
10933	51.1488	71.3835	9.2	18
10934	51.1434	71.4067	106.81	18
10935	51.1524	71.4067	272.37	18
10936	51.1506	71.4096	117.88	18
10937	51.147	71.4038	115.21	18
10938	51.1524	71.4038	73.76	18
10939	51.147	71.3951	150.41	18
10940	51.1452	71.4038	605.66	18
10941	51.1506	71.3922	29	18
10942	51.1506	71.3864	19.2	18
10943	51.1524	71.398	219.26	18
10944	51.1524	71.4009	128.76	18
10945	51.147	71.3922	582.42	18
10946	51.1362	71.4241	674.49	13
10947	51.138	71.4241	171.81	13
10948	51.1398	71.4357	181.32	13
10949	51.1416	71.4357	139.1	13
10950	51.1398	71.4386	298.37	13
10951	51.1362	71.4212	2854.5	13
10952	51.1362	71.4328	269.41	13
10953	51.1398	71.4966	120.13	14
10954	51.138	71.4908	73.98	14
10955	51.1416	71.4966	92.13	14
10956	51.1308	71.4937	623.12	14
10957	51.1344	71.5024	90.11	14
10958	51.138	71.4879	110.12	14
10959	51.138	71.485	68	14
10960	51.1362	71.4763	136.95	14
10961	51.1416	71.4908	159.65	14
10962	51.1362	71.4937	228.35	14
10963	51.1344	71.4763	159.76	14
10964	51.1362	71.4908	167.53	14
10965	51.1362	71.4821	122.07	14
10966	51.138	71.4966	207.93	14
10967	51.1362	71.4589	207.05	14
10968	51.1308	71.4879	160.65	14
10969	51.1344	71.4908	106.28	14
10970	51.1398	71.5024	367.89	14
10971	51.1326	71.4937	134.53	14
10972	51.1308	71.485	98.83	14
10973	51.138	71.514	100.73	14
10974	51.1344	71.5053	71.34	14
10975	51.1416	71.4879	70.4	14
10976	51.1434	71.4937	222.29	14
10977	51.1326	71.4995	798.32	14
10978	51.1326	71.4966	75.52	14
10979	51.1362	71.4879	195.99	14
10980	51.129	71.4821	70.74	14
10981	51.138	71.4937	118.06	14
10982	51.138	71.5024	88.4	14
10983	51.1398	71.4995	461.75	14
10984	51.1362	71.5111	69.63	14
10985	51.1362	71.4966	143.38	14
10986	51.138	71.5169	66.9	14
10987	51.1326	71.4821	96.84	14
10988	51.1398	71.456	466.78	14
10989	51.1434	71.4966	360.52	14
10990	51.1362	71.485	99.49	14
10991	51.1344	71.4879	206.12	14
10992	51.129	71.4879	646.93	14
10993	51.1398	71.4937	127.91	14
10994	51.1326	71.485	118.84	14
10995	51.1344	71.4821	91.06	14
10996	51.1344	71.485	112.88	14
10997	51.1308	71.4908	83.81	14
10998	51.1398	71.485	118.54	14
10999	51.1416	71.4531	217.98	14
11000	51.1434	71.4502	331.67	14
11001	51.1416	71.4937	82.47	14
11002	51.138	71.4792	426.27	14
11003	51.138	71.4821	59.46	14
11004	51.1398	71.5082	684.54	14
11005	51.1344	71.5082	202.51	14
11006	51.1398	71.4879	68.78	14
11007	51.1362	71.4792	75.05	14
11008	51.1416	71.4995	864.91	14
11009	51.1326	71.5024	152.61	14
11010	51.1344	71.4589	40.79	14
11011	51.138	71.4995	153.73	14
11012	51.1326	71.5053	116.38	14
11013	51.1398	71.5053	59.02	14
11014	51.1362	71.5082	140.49	14
11015	51.1362	71.456	106.37	14
11016	51.1344	71.456	165.58	14
11017	51.138	71.4589	378.77	14
11018	51.138	71.456	137.36	14
11019	51.1434	71.4473	493.07	14
11020	51.1308	71.5198	100.67	17
11021	51.1308	71.5169	152.95	17
11022	51.1272	71.514	98	17
11023	51.1326	71.4792	251.24	14
11024	51.1272	71.5082	694.33	17
11025	51.129	71.5082	943.91	17
11026	51.1344	71.5198	97.91	17
11027	51.138	71.5198	65.24	14
11028	51.1344	71.5111	85.57	14
11029	51.1344	71.5227	100.69	17
11030	51.1344	71.514	72.56	14
11031	51.1254	71.5111	252.03	17
11032	51.1326	71.514	287.25	17
11033	51.1326	71.5169	94.74	17
11034	51.1326	71.5082	40.58	14
11035	51.1308	71.5082	149.81	17
11036	51.129	71.514	187.78	17
11037	51.1308	71.514	131.28	17
11038	51.129	71.4792	117.26	14
11039	51.1308	71.5111	91.61	17
11040	51.1326	71.5198	87.58	17
11041	51.129	71.5169	167.07	17
11042	51.1362	71.5198	32.67	14
11043	51.1254	71.514	91.94	17
11044	51.1344	71.5169	45.86	17
11045	51.129	71.5111	117.64	17
11046	51.1272	71.5169	83.85	17
11047	51.1344	71.4792	206.19	14
11048	51.1326	71.5111	310.8	17
11049	51.1362	71.5169	76.26	14
11050	51.129	71.5198	104.25	17
11051	51.1272	71.5111	158.69	17
11052	51.1236	71.5111	474.12	17
11053	51.1308	71.5053	235.07	17
11054	51.1272	71.4792	29.99	14
11055	51.129	71.4763	89.24	14
11056	51.165	71.4879	444.99	14
11057	51.1254	71.4096	314.81	18
11058	51.1254	71.4125	64.91	18
11059	51.1308	71.4038	297.37	18
11060	51.1632	71.4879	106.45	14
11061	51.12	71.4067	212.21	18
11062	51.1218	71.4067	98.53	18
11063	51.1614	71.4792	194.96	14
11064	51.1146	71.4067	252.41	18
11065	51.1722	71.3661	988.55	15
11066	51.1254	71.5024	408	17
11067	51.1272	71.5053	1404.86	17
11068	51.1272	71.5024	1480.86	17
11069	51.1236	71.4038	276.8	18
11070	51.1722	71.3719	1030.54	15
11071	51.1632	71.4821	183.99	14
11072	51.1254	71.4995	786.49	17
11073	51.1272	71.4821	473.21	14
11074	51.1236	71.4067	848.46	18
11075	51.1236	71.5024	1249.89	17
11076	51.1308	71.4995	658.54	14
11077	51.1254	71.5053	506.29	17
11078	51.1614	71.4067	1815.43	15
11079	51.1218	71.5053	789.9	17
11080	51.1236	71.5053	894.66	17
11081	51.1632	71.485	128.71	14
11082	51.1236	71.5082	261.13	17
11083	51.1434	71.4444	261.05	14
11084	51.1416	71.4444	31.15	14
11085	51.1488	71.4966	30.61	14
11086	51.147	71.4937	74.85	14
11087	51.1488	71.4995	61.36	14
11088	51.1578	71.4676	94.65	14
11089	51.0912	71.4386	68.52	13
11090	51.0894	71.4299	76.6	13
11091	51.0894	71.4328	80.63	13
11092	51.093	71.4415	95.09	13
11093	51.0894	71.4357	173.36	13
11094	51.093	71.4386	170.14	13
11095	51.0894	71.4386	217.54	13
11096	51.0912	71.4328	104.81	13
11097	51.0912	71.4357	100.77	13
11098	51.0876	71.4386	289.35	13
11099	51.0948	71.4299	304.59	13
11100	51.0912	71.4299	84.66	13
11101	51.0894	71.4444	193.75	13
11102	51.0912	71.4415	111.19	13
11103	51.0876	71.4328	280.18	13
11104	51.0948	71.4328	789.05	13
11105	51.0912	71.4473	36.39	13
11106	51.0876	71.4357	188.85	13
11107	51.093	71.4328	244.36	13
11108	51.093	71.4299	82.03	13
11109	51.0912	71.4444	158.96	13
11110	51.0894	71.4415	133	13
11111	51.093	71.4444	190.77	13
11112	51.093	71.4357	266.03	13
11113	51.0768	71.4212	485.57	13
11114	51.147	71.3806	177.35	18
11115	51.1452	71.3806	1550.06	18
11116	51.147	71.3777	210.06	18
11117	51.147	71.3835	1288.7	18
11118	51.1452	71.3777	712.75	18
11119	51.1434	71.3748	2239.84	18
11120	51.147	71.3893	416.76	18
11121	51.147	71.3864	953.92	18
11122	51.1974	71.4241	173.53	16
11123	51.1992	71.4241	39.76	16
11124	51.1992	71.427	192.25	16
11125	51.1974	71.4212	134.32	16
11126	51.1956	71.427	72.2	16
11127	51.2064	71.3632	430.41	15
11128	51.1794	71.34	317.37	15
11129	51.1776	71.3371	842.4	15
11130	51.1974	71.3371	635.04	15
11131	51.1992	71.3429	228.77	15
11132	51.2046	71.3516	227.4	15
11133	51.1992	71.3545	152.11	15
11134	51.2028	71.3516	101.27	15
11135	51.1794	71.3487	363.53	15
11136	51.2046	71.3574	130.54	15
11137	51.201	71.3574	296.33	15
11138	51.2082	71.3603	71.93	15
11139	51.201	71.3545	233.41	15
11140	51.1902	71.3429	674.68	15
11141	51.1848	71.3458	197.2	15
11142	51.2028	71.3545	164.02	15
11143	51.1992	71.3458	98.91	15
11144	51.2028	71.3603	687.03	15
11145	51.2082	71.3661	214.08	15
11146	51.1992	71.3487	535.62	15
11147	51.2208	71.34	10.66	15
11148	51.2046	71.3603	79.36	15
11149	51.201	71.3516	70.18	15
11150	51.1974	71.3574	67.31	15
11151	51.2028	71.3342	39.4	15
11152	51.1848	71.3603	20.59	15
11153	51.2064	71.3574	113.49	15
11154	51.1812	71.3516	265.22	15
11155	51.2082	71.3545	332.94	15
11156	51.174	71.3458	712.71	15
11157	51.1812	71.3342	375.84	15
11158	51.1758	71.3458	434.96	15
11159	51.2064	71.3661	1420.21	15
11160	51.1902	71.3458	158.93	15
11161	51.1974	71.3545	15.75	15
11162	51.2064	71.3719	84.29	15
11163	51.1812	71.3487	1074.62	15
11164	51.2028	71.3574	45.54	15
11165	51.2064	71.3545	520.08	15
11166	51.1776	71.3487	81.15	15
11167	51.1848	71.3429	281.48	15
11168	51.1758	71.34	171.42	15
11169	51.1992	71.3632	62.92	15
11170	51.1776	71.34	36.2	15
11171	51.1758	71.3371	20.67	15
11172	51.183	71.3255	189.68	15
11173	51.1974	71.3458	465.72	15
11174	51.183	71.3487	305.94	15
11175	51.1866	71.3429	113.08	15
11176	51.1848	71.3545	116.61	15
11177	51.1812	71.3313	264.92	15
11178	51.174	71.3429	298.88	15
11179	51.1794	71.3371	267.3	15
11180	51.201	71.34	71.31	15
11181	51.1938	71.3284	1431.22	15
11182	51.1452	71.4386	218.54	13
11183	51.147	71.4473	945.97	14
11184	51.1506	71.4125	410.42	18
11185	51.1506	71.3777	135.77	18
11186	51.1506	71.3748	63.37	18
11187	51.1344	71.4357	23.32	13
11188	51.1524	71.4125	58.53	18
11189	51.1488	71.3777	343.6	18
11190	51.1362	71.4357	133.56	13
11191	51.1488	71.3748	117.39	18
11192	51.1974	71.4183	86.46	16
11193	51.1308	71.5024	757.73	14
11194	51.1488	71.5227	110.3	14
11195	51.156	71.514	75.04	14
11196	51.1434	71.5024	17.81	14
11197	51.1488	71.5198	85.12	14
11198	51.1524	71.5198	96.75	14
11199	51.1506	71.5227	116.32	14
11200	51.1524	71.5227	140.96	14
11201	51.1488	71.5111	77.82	14
11202	51.1416	71.5169	343.65	14
11203	51.1524	71.5256	20.15	14
11204	51.1434	71.5082	101.08	14
11205	51.1416	71.514	92.13	14
11206	51.1434	71.5111	198.83	14
11207	51.1398	71.5198	60.66	14
11208	51.1452	71.5053	111.48	14
11209	51.1542	71.5169	111.21	14
11210	51.1542	71.5198	281.16	14
11211	51.1254	71.5169	173.43	17
11212	51.1416	71.5082	1569.82	14
11213	51.1452	71.514	174.61	14
11214	51.1506	71.5169	41.87	14
11215	51.1452	71.5169	79.64	14
11216	51.147	71.5024	130.09	14
11217	51.1524	71.5169	140.57	14
11218	51.1452	71.5082	519.73	14
11219	51.1416	71.5111	93.4	14
11220	51.1434	71.5053	80.4	14
11221	51.1398	71.5169	87.61	14
11222	51.1398	71.5227	37.38	14
11223	51.147	71.5169	172.3	14
11224	51.1236	71.514	177.97	17
11225	51.1272	71.5198	175.47	17
11226	51.1542	71.5111	151.98	14
11227	51.138	71.5227	6.91	17
11228	51.156	71.5169	242.27	14
11229	51.1434	71.514	296.62	14
11230	51.183	71.3545	67.14	15
11231	51.1776	71.369	686.27	15
11232	51.1776	71.3719	168.83	15
11233	51.183	71.3574	311.92	15
11234	51.183	71.3603	96.27	15
11235	51.1848	71.3574	34.28	15
11236	51.2082	71.3777	22.47	16
11237	51.219	71.3835	202.94	16
11238	51.2226	71.3835	304.09	16
11239	51.1794	71.4589	622.75	16
11240	51.1776	71.4589	936.7	16
11241	51.2244	71.4067	143.7	16
11242	51.2226	71.3864	180.21	16
11243	51.2226	71.4038	789.69	16
11244	51.2172	71.3806	146.12	16
11245	51.1434	71.4908	57.8	14
11246	51.1452	71.4937	116.97	14
11247	51.1992	71.4502	109.88	16
11248	51.201	71.4502	45.68	16
11249	51.0372	71.4299	33.48	13
11250	51.0372	71.427	8.37	13
11251	51.039	71.427	153.3	13
11252	51.039	71.4299	96.89	13
11253	51.039	71.4241	77.2	13
11254	51.1326	71.5227	83.91	17
11255	51.138	71.5256	147.19	17
11256	51.1308	71.5227	101.18	17
11257	51.129	71.5227	91.01	17
11258	51.1272	71.5227	188.54	17
11259	51.1362	71.5256	75.85	17
11260	51.1344	71.5285	113.35	17
11261	51.1344	71.5256	189.59	17
11262	51.1308	71.5256	108.78	17
11263	51.1326	71.5256	179.32	17
11264	51.129	71.5256	166.26	17
11265	51.1326	71.5285	121.36	17
11266	51.1272	71.5256	79.38	17
11267	51.1218	71.514	99.72	17
11268	51.1182	71.4647	1377.74	17
11269	51.1218	71.485	594.63	17
11270	51.201	71.4763	333.32	16
11271	51.201	71.4792	162.95	16
11272	51.1992	71.3284	76.08	15
11273	51.1992	71.3313	107.56	15
11274	51.201	71.3313	23.72	15
11275	51.1974	71.3284	122.22	15
11276	51.1848	71.3632	5.19	15
11277	51.1866	71.3574	7.65	15
11278	51.1416	71.3284	131.19	18
11279	51.1434	71.3342	88.82	18
11280	51.1434	71.3371	58.74	18
11281	51.1488	71.3603	10.79	18
11282	51.1722	71.369	252.07	15
11283	51.1776	71.3661	192.34	15
11284	51.165	71.456	13.43	16
11285	51.1668	71.456	583.82	16
11286	51.1344	71.3632	116.17	18
11287	51.1686	71.4589	919.82	16
11288	51.1722	71.4618	765.35	16
11289	51.1704	71.4618	1025.7	16
11290	51.1722	71.4647	321.69	16
11291	51.1794	71.4531	218.24	16
11292	51.1812	71.4531	79.3	16
11293	51.174	71.4647	798.19	16
11294	51.1812	71.456	137.67	16
11295	51.1794	71.456	772.65	16
11296	51.1776	71.4618	296.2	16
11297	51.1758	71.4647	382.09	16
11298	51.1794	71.4618	383.6	16
11299	51.1308	71.4096	2.66	18
11300	51.1812	71.4502	368.28	16
11301	51.1812	71.4473	301.2	16
11302	51.183	71.4473	304.8	16
11303	51.174	71.4676	150.3	16
11304	51.1776	71.4647	6.25	16
11305	51.156	71.5024	80.01	14
11306	51.165	71.485	995.05	14
11307	51.1668	71.4821	132.69	14
11308	51.165	71.4821	296.37	14
11309	51.1668	71.485	35.03	14
11310	51.174	71.4763	16.41	16
11311	51.1722	71.4763	502.23	16
11312	51.165	71.4705	707.39	16
11313	51.1704	71.4705	148.71	16
11314	51.1722	71.4705	361.63	16
11315	51.1722	71.4792	269.36	16
11316	51.1524	71.4937	170.77	14
11317	51.174	71.4705	188.18	16
11318	51.03	71.4676	819.88	13
11319	51.0264	71.456	350.48	13
11320	51.0372	71.4792	124.19	13
11321	51.0264	71.4589	67.57	13
11322	51.021	71.4589	3.87	13
11323	51.0336	71.4676	487.97	13
11324	51.03	71.4618	11.36	13
11325	51.0264	71.4531	82.65	13
11326	51.0318	71.4734	138.63	13
11327	51.0318	71.4618	127.09	13
11328	51.03	71.4647	181.18	13
11329	51.0318	71.4676	904	13
11330	51.0426	71.4792	4.39	13
11331	51.0318	71.4647	801.25	13
11332	51.0354	71.4676	177.96	13
11333	51.0408	71.4937	1.81	13
11334	51.0336	71.4734	385.85	13
11335	51.0372	71.4676	42.39	13
11336	51.0156	71.4502	7.51	13
11337	51.0426	71.4763	4.89	13
11338	51.03	71.4821	3.33	13
11339	51.0228	71.4531	538.38	13
11340	51.0354	71.4792	8.06	13
11341	51.0444	71.4792	2.07	13
11342	51.0336	71.4618	115.16	13
11343	51.0354	71.4763	185.8	13
11344	51.0354	71.4705	96.84	13
11345	51.0336	71.4647	9.2	13
11346	51.0192	71.4531	68.03	13
11347	51.039	71.4734	184.65	13
11348	51.0408	71.4328	13.69	13
11349	51.048	71.4386	162.56	13
11350	51.21	71.2762	15.77	15
11351	51.2118	71.282	15.82	15
11352	51.21	71.2791	93.98	15
11353	51.21	71.282	19.29	15
11354	51.2172	71.2733	11.69	15
11355	51.219	71.2733	144.27	15
11356	51.2082	71.2791	9.74	15
11357	51.2172	71.2762	93.03	15
11358	51.2082	71.282	112.74	15
11359	51.0444	71.4241	206.35	13
11360	51.0426	71.4241	30.02	13
11361	51.0462	71.4212	80.39	13
11362	51.0462	71.4241	324.62	13
11363	51.0462	71.427	232.17	13
11364	51.0426	71.4328	387.8	13
11365	51.0426	71.4212	32.05	13
11366	51.0408	71.4212	515.97	13
11367	51.0444	71.4212	149.3	13
11368	51.0444	71.427	202.03	13
11369	51.0444	71.4357	478.4	13
11370	51.0444	71.4299	188.85	13
11371	51.0426	71.4357	689.9	13
11372	51.0426	71.4299	622.25	13
11373	51.0444	71.4328	37.83	13
11374	51.1326	71.4125	8.3	18
11375	51.1326	71.4154	13.23	13
11376	51.1254	71.4154	388.66	13
11377	51.1344	71.4183	1740.28	13
11378	51.1308	71.4357	9.91	13
11379	51.129	71.4328	319.97	13
11380	51.129	71.4386	273.38	13
11381	51.0678	71.3951	7.76	13
11382	51.165	71.3951	8.84	15
11383	51.1236	71.4328	259.57	13
11384	51.1524	71.4328	62.04	16
11385	51.1776	71.4676	92.63	16
11386	51.174	71.4792	25.42	16
11387	51.1758	71.4734	27.95	16
11388	51.1776	71.4734	76.81	16
11389	51.1758	71.4792	175.41	16
11390	51.1758	71.4705	1.39	16
11391	51.1722	71.4879	4.93	16
11392	51.1722	71.485	147.02	16
11393	51.1722	71.4821	2.71	16
11394	51.1776	71.4705	393.74	16
11395	51.1794	71.4937	748.72	16
11396	51.1776	71.4908	5.86	16
11397	51.1758	71.4821	370.31	16
11398	51.1812	71.4937	512.54	16
11399	51.183	71.4937	157.68	16
11400	51.1794	71.4966	237.59	16
11401	51.1776	71.4937	569.41	16
11402	51.1776	71.485	1173.3	16
11403	51.1776	71.4821	427.25	16
11404	51.1776	71.4792	339.29	16
11405	51.1758	71.485	75.57	16
11406	51.1794	71.485	164.55	16
11407	51.1794	71.4792	565.29	16
11408	51.1776	71.4763	87.42	16
11409	51.1812	71.4763	581.35	16
11410	51.1794	71.4763	80.27	16
11411	51.1794	71.4821	483.35	16
11412	51.1812	71.4792	604.57	16
11413	51.183	71.4792	517.29	16
11414	51.1848	71.4763	711.07	16
11415	51.1794	71.4705	378.17	16
11416	51.1794	71.4734	82.69	16
11417	51.183	71.4763	88.19	16
11418	51.1812	71.4821	37.97	16
11419	51.1092	71.4415	89.19	13
11420	51.102	71.4328	343.26	13
11421	51.102	71.4386	1548.68	13
11422	51.1074	71.4415	97.1	13
11423	51.102	71.4357	83.8	13
11424	51.1056	71.4386	380.73	13
11425	51.111	71.4415	124.32	13
11426	51.1074	71.4444	1784.34	13
11427	51.1038	71.4386	70.3	13
11428	51.1074	71.4386	947.6	13
11429	51.1092	71.4444	429.36	13
11430	51.1002	71.4357	216.27	13
11431	51.1038	71.4357	276.57	13
11432	51.111	71.4386	688.75	13
11433	51.1056	71.4357	315.03	13
11434	51.1038	71.4415	928.41	13
11435	51.1038	71.4328	112.34	13
11436	51.111	71.4444	4.25	13
11437	51.1002	71.4386	415.32	13
11438	51.1092	71.4386	412.47	13
11439	51.174	71.485	114.96	16
11440	51.1758	71.4879	123.28	16
11441	51.174	71.4821	6.43	16
11442	51.183	71.4821	75.18	16
11443	51.1884	71.4908	1075.92	16
11444	51.1848	71.4908	82.24	16
11445	51.1866	71.485	194.1	16
11446	51.183	71.4966	281.77	16
11447	51.1974	71.4763	293.09	16
11448	51.183	71.4908	121.29	16
11449	51.1956	71.4763	342.15	16
11450	51.1956	71.4734	172.64	16
11451	51.1938	71.4763	278.27	16
11452	51.1848	71.4792	398.02	16
11453	51.183	71.4995	234.11	16
11454	51.1866	71.4879	1455.55	16
11455	51.1848	71.4821	140.41	16
11456	51.1848	71.4705	175.12	16
11457	51.1866	71.4908	346.64	16
11458	51.1866	71.4792	1419.03	16
11459	51.1866	71.4937	311.37	16
11460	51.1848	71.4879	251.51	16
11461	51.1938	71.4676	1372.87	16
11462	51.1884	71.4937	373.05	16
11463	51.1902	71.4937	201.74	16
11464	51.1902	71.4908	408.3	16
11465	51.1884	71.485	321.77	16
11466	51.1866	71.4734	402.72	16
11467	51.1902	71.4879	15.52	16
11468	51.1884	71.4792	714.91	16
11469	51.1848	71.4618	449.98	16
11470	51.1848	71.4995	353.3	16
11471	51.1866	71.4705	374.34	16
11472	51.183	71.4705	242.53	16
11473	51.1866	71.4647	580.8	16
11474	51.1884	71.4879	345.86	16
11475	51.192	71.4763	89.5	16
11476	51.192	71.4792	1156.82	16
11477	51.183	71.4879	226.98	16
11478	51.1812	71.485	81.02	16
11479	51.1938	71.4821	200.27	16
11480	51.1902	71.4763	1239.4	16
11481	51.1866	71.4676	385.53	16
11482	51.1884	71.4821	2326.49	16
11483	51.1542	71.398	24.71	18
11484	51.1578	71.4009	2.38	18
11485	51.1542	71.4009	4.86	18
11486	51.156	71.4009	11.22	18
11487	51.2496	71.3719	119.42	16
11488	51.2586	71.3835	6.52	16
11489	51.1182	71.6358	417.27	17
11490	51.1146	71.6445	112.47	17
11491	51.1164	71.6416	413.05	17
11492	51.1164	71.6445	222.32	17
11493	51.1182	71.6387	272.35	17
11494	51.1182	71.6416	347.68	17
11495	51.12	71.6387	843.8	17
11496	51.1164	71.456	995	17
11497	51.1164	71.4531	698.53	17
11498	51.1164	71.4647	299.31	17
11499	51.111	71.4676	167.99	17
11500	51.12	71.456	2108.38	17
11501	51.1902	71.5053	1176.99	16
11502	51.1596	71.5198	446.68	14
11503	51.165	71.5285	1798.62	14
11504	51.1794	71.5169	416.88	14
11505	51.1578	71.5604	194.57	14
11506	51.1866	71.5111	86.83	16
11507	51.192	71.5198	643.24	16
11508	51.156	71.5285	109.56	14
11509	51.1668	71.5256	204.77	14
11510	51.1578	71.5227	127.51	14
11511	51.1812	71.5285	320.67	16
11512	51.192	71.5169	178.61	16
11513	51.1884	71.514	59.26	16
11514	51.1776	71.5082	991.73	14
11515	51.1668	71.5285	4675.59	14
11516	51.1848	71.514	274.36	16
11517	51.1794	71.5198	104.34	14
11518	51.1632	71.5372	1944.35	14
11519	51.1884	71.5169	221.11	16
11520	51.1812	71.514	372.3	14
11521	51.1578	71.5256	18	14
11522	51.1578	71.5198	14.92	14
11523	51.1776	71.4966	128.51	16
11524	51.1848	71.5227	348.95	16
11525	51.183	71.5227	42.87	16
11526	51.1902	71.5111	2102.12	16
11527	51.1866	71.514	821.76	16
11528	51.129	71.5894	515.91	17
11529	51.129	71.5923	126.09	17
11530	51.2514	71.3777	234.34	16
11531	51.2514	71.3806	108	16
11532	51.1074	71.427	737.38	13
11533	51.1434	71.4386	188.66	13
11534	51.1002	71.4879	13.41	17
11535	51.1038	71.4705	393.06	13
11536	51.102	71.4908	416.94	17
11537	51.102	71.4734	4.26	13
11538	51.1002	71.4705	168.92	13
11539	51.102	71.4879	310.05	17
11540	51.2622	71.369	65.84	16
11541	51.2604	71.369	4.62	16
11542	51.264	71.369	2.26	16
11543	51.1992	71.4763	10.12	16
11544	51.246	71.3806	14.69	16
11545	51.2352	71.3545	1.54	16
11546	51.237	71.3545	1.72	16
11547	51.2226	71.3313	2.56	15
11548	51.2064	71.3516	135.91	15
11549	51.2208	71.3371	17.06	15
11550	51.21	71.34	35.64	15
11551	51.21	71.3516	253.03	15
11552	51.2082	71.3429	33.62	15
11553	51.2082	71.3458	347.27	15
11554	51.21	71.3458	12.51	15
11555	51.219	71.34	170.26	15
11556	51.2136	71.3545	134.16	15
11557	51.2172	71.3458	11.88	15
11558	51.2082	71.3168	411.12	15
11559	51.201	71.3429	445.99	15
11560	51.201	71.3284	38.95	15
11561	51.1956	71.3139	177.64	15
11562	51.192	71.3139	43	15
11563	51.1902	71.311	10.14	15
11564	51.1848	71.3023	1.01	15
11565	51.2028	71.3052	1.65	15
11566	51.2388	71.5517	3.22	16
11567	51.2352	71.5517	0.49	16
11568	51.2226	71.5575	2.7	16
11569	51.2172	71.5227	2.73	16
11570	51.2136	71.5169	2.16	16
11571	51.2154	71.5169	3.8	16
11572	51.219	71.5227	2.25	16
11573	51.2172	71.5198	0.82	16
11574	51.2154	71.5198	1.38	16
11575	51.2082	71.5024	2.37	16
11576	51.192	71.5285	9.52	16
11577	51.2064	71.4908	67.97	16
11578	51.2118	71.5053	2.1	16
11579	51.2136	71.5082	6.98	16
11580	51.2064	71.4937	16.09	16
11581	51.2136	71.5053	7	16
11582	51.2082	71.4995	52.41	16
11583	51.2082	71.4966	161.01	16
11584	51.2046	71.4908	13.86	16
11585	51.2046	71.4937	35.81	16
11586	51.21	71.4821	60.55	16
11587	51.2136	71.4415	75.92	16
11588	51.2028	71.4821	275.92	16
11589	51.201	71.4821	94.41	16
11590	51.129	71.3777	1764.46	18
11591	51.129	71.3806	1435.74	18
11592	51.1974	71.4531	120.67	16
11593	51.1722	71.4444	163.08	16
11594	51.201	71.3835	184.43	15
11595	51.183	71.3516	178.29	15
11596	51.1812	71.3429	146.45	15
11597	51.183	71.3458	156.61	15
11598	51.1812	71.3458	255.36	15
11599	51.1866	71.3719	396.09	15
11600	51.1812	71.3545	283.79	15
11601	51.1794	71.3429	199.06	15
11602	51.1884	71.369	501.23	15
11603	51.1884	71.3719	371.34	15
11604	51.1866	71.369	351.55	15
11605	51.1812	71.3371	173.59	15
11606	51.1848	71.4386	498.59	15
11607	51.183	71.4357	707.73	15
11608	51.183	71.4415	526.61	15
11609	51.1848	71.4357	353.24	15
11610	51.183	71.4444	1299.49	15
11611	51.1848	71.4328	2345.62	15
11612	51.1848	71.4415	478.89	15
11613	51.1812	71.4386	414.43	15
11614	51.1848	71.427	887.22	15
11615	51.1794	71.4415	55.31	16
11616	51.1812	71.4415	105.11	15
11617	51.1758	71.4444	119.74	16
11618	51.1182	71.4241	612.87	13
11619	51.1866	71.4096	197.59	15
11620	51.2514	71.3719	8.53	16
11621	51.2514	71.369	80.08	16
11622	51.2298	71.3777	206.76	16
11623	51.228	71.3777	87.38	16
11624	51.2496	71.369	109.59	16
11625	51.2298	71.3806	320.85	16
11626	51.2298	71.3835	139.51	16
11627	51.2316	71.3777	192.5	16
11628	51.2316	71.3806	256.65	16
11629	51.1632	71.4067	2244.79	15
11630	51.1308	71.4241	1162.7	13
11631	51.3324	71.6764	0.45	16
11632	51.2136	71.3777	54.97	16
11633	51.2118	71.3777	42.56	16
11634	51.21	71.3835	49.87	16
11635	51.2064	71.3806	13.3	16
11636	51.1848	71.369	231.86	15
11637	51.2028	71.3835	157.7	15
11638	51.1002	71.4328	1030.97	13
11639	51.2262	71.2472	13.41	15
11640	51.201	71.4676	370.92	16
11641	51.2658	71.369	1.09	16
11642	51.1632	71.4357	682.04	16
11643	51.2892	71.3603	20.14	16
11644	51.1938	71.3255	616.9	15
11645	51.1038	71.7141	8.16	17
11646	51.102	71.717	17.6	17
11647	51.111	71.688	25.91	17
11648	51.2316	71.3835	114.79	16
11649	51.21	71.4444	46.9	16
11650	51.2082	71.4444	2764.21	16
11651	51.2082	71.4415	62.7	16
11652	51.2064	71.4386	2226.04	16
11653	51.2262	71.3922	149.19	16
11654	51.2694	71.369	4.28	16
11655	51.192	71.369	99.2	15
11656	51.1992	71.3603	101.21	15
11657	51.2064	71.3603	202.54	15
11658	51.1992	71.3574	128.85	15
11659	51.192	71.3719	123.99	15
11660	51.1902	71.3719	126.44	15
11661	51.1974	71.369	474.43	15
11662	51.1974	71.4038	202.11	15
11663	51.201	71.369	144.3	15
11664	51.1938	71.3458	137.61	15
11665	51.1956	71.3458	887.84	15
11666	51.1992	71.3661	95.13	15
11667	51.1848	71.34	266.88	15
11668	51.183	71.34	280.82	15
11669	51.1902	71.3197	339.97	15
11670	51.2028	71.4908	601.2	16
11671	51.201	71.4908	382.52	16
11672	51.2028	71.4879	40.07	16
11673	51.1704	71.4937	729.16	14
11674	51.1686	71.5024	828.92	14
11675	51.2046	71.3806	53.37	15
11676	51.1686	71.3951	655.66	15
11677	51.2712	71.369	89.17	16
11678	51.291	71.3603	1.7	16
11679	51.1236	71.6126	172.89	17
11680	51.1236	71.4444	8.87	13
11681	51.1272	71.5894	213.86	17
11682	51.1272	71.5865	489.16	17
11683	51.1272	71.5952	153.9	17
11684	51.21	71.3806	66.41	16
11685	51.2082	71.3806	42.77	16
11686	51.2082	71.3835	53.7	16
11687	51.2118	71.3835	46.74	16
11688	51.2136	71.3806	44.23	16
11689	51.2118	71.3864	46.47	16
11690	51.21	71.3864	68.39	16
11691	51.2118	71.3806	31.45	16
11692	51.1272	71.601	32.34	17
11693	51.1308	71.5894	54.58	17
11694	51.1452	71.543	229.43	14
11695	51.1452	71.5459	447.93	14
11696	51.1434	71.5459	10.12	14
11697	51.1434	71.543	13.27	14
11698	51.12	71.5227	257.79	17
11699	51.1236	71.2762	116.85	18
11700	51.1218	71.2762	21.18	18
11701	51.1218	71.2704	181.73	18
11702	51.1218	71.2733	461.89	18
11703	51.1236	71.2733	244.69	18
11704	51.12	71.2704	124.8	18
11705	51.1614	71.5401	441.22	14
11706	51.1614	71.543	98.51	14
11707	51.1344	71.4647	534.07	14
11708	51.1344	71.4618	371.82	14
11709	51.1362	71.4647	657.9	14
11710	51.1614	71.4096	210.32	15
11711	51.192	71.4995	24.91	16
11712	51.1434	71.3777	901.15	18
11713	51.1416	71.3835	1272.91	18
11714	51.111	71.4357	239.76	13
11715	51.1092	71.4357	387.98	13
11716	51.0858	71.3951	175.83	18
11717	51.0822	71.3777	1225.81	18
11718	51.084	71.3777	386.6	18
11719	51.129	71.3661	172.38	18
11720	51.1344	71.5778	1.93	14
11721	51.129	71.5024	1222.59	17
11722	51.1272	71.4966	851.58	17
11723	51.1272	71.4995	228.12	17
11724	51.1254	71.4966	874.07	17
11725	51.12	71.5053	955.09	17
11726	51.1254	71.4937	689.02	17
11727	51.1254	71.5082	970.82	17
11728	51.1236	71.4966	779.98	17
11729	51.1236	71.4995	824.89	17
11730	51.1884	71.3806	2454.08	15
11731	51.1884	71.3777	152.75	15
11732	51.1902	71.3748	136.22	15
11733	51.1902	71.3777	113.62	15
11734	51.0876	71.4212	344.54	13
11735	51.0786	71.3951	1368.53	18
11736	51.0894	71.4212	354.29	13
11737	51.0606	71.3864	982.03	18
11738	51.0768	71.3951	821.52	18
11739	51.0588	71.3893	2095.83	18
11740	51.0786	71.3893	10.51	18
11741	51.1182	71.4096	454.8	18
11742	51.1038	71.4038	367.29	18
11743	51.0948	71.3922	2023.43	18
11744	51.1164	71.4038	1270.66	18
11745	51.1056	71.4038	250.69	18
11746	51.1038	71.4067	138.49	18
11747	51.066	71.3922	4.87	18
11748	51.0696	71.3951	87.71	18
11749	51.0858	71.398	495.28	18
11750	51.0858	71.3893	97.78	18
11751	51.0894	71.3951	1633.61	18
11752	51.138	71.4154	57.91	18
11753	51.1164	71.4415	539.25	13
11754	51.1164	71.4792	425.64	17
11755	51.1182	71.456	482.46	17
11756	51.1146	71.456	948.17	17
11757	51.1128	71.4589	729.13	17
11758	51.1128	71.456	444.54	17
11759	51.1272	71.485	832.72	14
11760	51.0966	71.4241	1046.2	13
11761	51.1092	71.4328	847.29	13
11762	51.111	71.4183	459.88	13
11763	51.1056	71.4299	611.25	13
11764	51.1038	71.4299	924.01	13
11765	51.093	71.4241	1696.26	13
11766	51.129	71.4937	670.26	14
11767	51.12	71.4763	1657.64	17
11768	51.0966	71.4212	535.47	13
11769	51.1146	71.4125	2098.55	13
11770	51.0984	71.4212	856.64	13
11771	51.1038	71.427	125.57	13
11772	51.1218	71.4879	638.64	17
11773	51.1218	71.4299	263.05	13
11774	51.102	71.427	1236.55	13
11775	51.0984	71.4299	1487.89	13
11776	51.0948	71.427	801.02	13
11777	51.1074	71.4299	197.38	13
11778	51.0984	71.4241	559.23	13
11779	51.1236	71.4908	1832.34	17
11780	51.1254	71.4821	1194.29	17
11781	51.1092	71.4299	1316.33	13
11782	51.1002	71.4241	1946.32	13
11783	51.1182	71.4299	1238.43	13
11784	51.1146	71.4328	71.49	13
11785	51.1416	71.4386	400.87	13
11786	51.1146	71.4096	1015.11	18
11787	51.0876	71.398	350.34	18
11788	51.1092	71.427	1867.25	13
11789	51.102	71.398	3651.22	18
11790	51.093	71.398	238.58	18
11791	51.1182	71.4386	17.82	13
11792	51.1146	71.4357	625.64	13
11793	51.1128	71.4357	3492.14	13
11794	51.0894	71.398	291.9	18
11795	51.12	71.4647	1665.23	17
11796	51.12	71.4676	430.31	17
11797	51.1182	71.4763	1498.56	17
11798	51.1164	71.4763	1267.66	17
11799	51.1272	71.4647	236.42	17
11800	51.129	71.4676	12.11	14
11801	51.129	71.4705	25.53	14
11802	51.1182	71.4821	899.43	17
11803	51.111	71.4705	111.19	17
11804	51.1272	71.4676	6528.8	17
11805	51.1182	71.4734	1432.5	17
11806	51.0624	71.4212	239.27	13
11807	51.0948	71.4444	1994.27	13
11808	51.093	71.4473	1660.41	13
11809	51.0948	71.4386	880.79	13
11810	51.0588	71.4183	296.74	13
11811	51.057	71.4241	541.95	13
11812	51.0588	71.4212	368.23	13
11813	51.0606	71.4212	106.99	13
11814	51.0588	71.4241	135.98	13
11815	51.1362	71.4618	704.62	14
11816	51.0606	71.4183	339.7	13
11817	51.138	71.4618	742.72	14
11818	51.174	71.3893	533.65	15
11819	51.1812	71.3719	85.31	15
11820	51.1758	71.3893	539.66	15
11821	51.2118	71.3574	284.89	15
11822	51.0786	71.3922	187.59	18
11823	51.0768	71.3922	717.24	18
11824	51.0876	71.3951	2242.13	18
11825	51.1146	71.4183	900.08	13
11826	51.1164	71.4125	398.21	13
11827	51.0912	71.3951	429.26	18
11828	51.1164	71.4241	730.31	13
11829	51.093	71.3951	576.43	18
11830	51.0948	71.398	270.76	18
11831	51.1146	71.4241	238.02	13
11832	51.165	71.4328	1107.74	16
11833	51.1632	71.5285	1193.22	14
11834	51.1596	71.5256	1083.68	14
11835	51.1578	71.5314	2088.52	14
11836	51.1488	71.4734	10.83	14
11837	51.1632	71.543	135.72	14
11838	51.1614	71.5256	1194.77	14
11839	51.1596	71.5343	173.07	14
11840	51.1596	71.5401	194.96	14
11841	51.1668	71.5372	718.03	14
11842	51.1686	71.5372	383.12	14
11843	51.156	71.5314	87.8	14
11844	51.165	71.5372	2401.22	14
11845	51.1704	71.398	944.56	15
11846	51.1686	71.398	331.84	15
11847	51.129	71.3603	1518.91	18
11848	51.1308	71.3603	199.52	18
11849	51.1326	71.3603	156.68	18
11850	51.084	71.4038	203.86	13
11851	51.1506	71.4241	439.25	18
11852	51.1524	71.4096	855.2	18
11853	51.1506	71.4183	609.48	18
11854	51.1596	71.4212	189.08	18
11855	51.1542	71.4067	161.49	18
11856	51.1524	71.4183	376.37	18
11857	51.1542	71.4096	439.18	18
11858	51.156	71.4096	13.25	18
11859	51.1542	71.4038	4.29	18
11860	51.156	71.4154	404.89	18
11861	51.1686	71.3748	512.86	15
11862	51.1704	71.3719	847.03	15
11863	51.1686	71.3777	207.42	15
11864	51.1686	71.3719	328.06	15
11865	51.1668	71.3777	217.31	15
11866	51.165	71.3806	337.3	15
11867	51.129	71.369	1809.03	18
11868	51.1182	71.4154	18.84	13
11869	51.1884	71.3429	64.65	15
11870	51.1488	71.3632	585.15	18
11871	51.147	71.3661	411.42	18
11872	51.1488	71.3661	408.08	18
11873	51.1272	71.398	200.05	18
11874	51.1722	71.3777	534.54	15
11875	51.1218	71.398	1507.76	18
11876	51.1434	71.572	54.08	14
11877	51.093	71.4212	707.37	13
11878	51.0912	71.4212	354.45	13
11879	51.093	71.4125	1467.24	13
11880	51.129	71.4241	1.34	13
11881	51.111	71.4067	1141.98	18
11882	51.1254	71.4386	41.32	13
11883	51.1326	71.4038	2866.42	18
11884	51.1326	71.4009	304.33	18
11885	51.1146	71.6967	4.62	14
11886	51.0894	71.4096	190.62	13
11887	51.1902	71.3255	115.58	15
11888	51.1002	71.4212	354.06	13
11889	51.0822	71.4154	7.78	13
11890	51.156	71.4473	127.38	16
11891	51.1758	71.4415	96.51	16
11892	51.1794	71.4444	65.03	16
11893	51.1776	71.4415	62.43	16
11894	51.1722	71.4415	311.13	16
11895	51.174	71.4386	36.3	16
11896	51.1776	71.4328	80.89	16
11897	51.1146	71.4995	615.6	17
11898	51.1146	71.4966	308.8	17
11899	51.1128	71.4995	368.31	17
11900	51.1128	71.5024	1564.43	17
11901	51.183	71.4502	16.36	16
11902	51.165	71.4415	157.03	16
11903	51.1848	71.4299	2749.86	15
11904	51.1902	71.427	51.33	15
11905	51.1884	71.427	142.87	15
11906	51.192	71.4241	38.86	16
11907	51.1866	71.427	651.35	15
11908	51.1884	71.4299	113.27	15
11909	51.1866	71.4386	225.2	15
11910	51.1722	71.398	1179.72	15
11911	51.174	71.398	344.4	15
11912	51.174	71.3951	232.84	15
11913	51.1722	71.3951	184.66	15
11914	51.1686	71.3835	545.62	15
11915	51.1632	71.398	128.57	15
11916	51.1848	71.398	124.3	15
11917	51.1848	71.3951	96.15	15
11918	51.183	71.398	144.45	15
11919	51.1848	71.4009	151.97	15
11920	51.1776	71.398	359.69	15
11921	51.1794	71.398	173.68	15
11922	51.1776	71.4009	104.14	15
11923	51.192	71.3864	162.33	15
11924	51.1902	71.3864	155.7	15
11925	51.1884	71.3835	105.42	15
11926	51.1866	71.3835	195.06	15
11927	51.1866	71.3806	74.68	15
11928	51.1812	71.3835	36.98	15
11929	51.1848	71.3835	186.76	15
11930	51.1848	71.3864	185.64	15
11931	51.1866	71.3864	141.99	15
11932	51.1884	71.3864	211.71	15
11933	51.1866	71.3893	163.47	15
11934	51.1902	71.3893	149.48	15
11935	51.1884	71.3893	138.65	15
11936	51.1902	71.3922	180.91	15
11937	51.192	71.3922	153.32	15
11938	51.192	71.3951	174.32	15
11939	51.192	71.398	41.72	15
11940	51.1902	71.398	168.22	15
11941	51.1884	71.3951	170.3	15
11942	51.1812	71.3893	38.48	15
11943	51.1902	71.369	106.94	15
11944	51.1884	71.3661	41.95	15
11945	51.1848	71.3719	145.15	15
11946	51.183	71.3719	163.06	15
11947	51.183	71.3661	80.57	15
11948	51.1938	71.3835	108.28	15
11949	51.192	71.3835	123.01	15
11950	51.1902	71.3835	95.56	15
11951	51.1902	71.3806	131.34	15
11952	51.1884	71.3748	185.15	15
11953	51.192	71.3748	153.65	15
11954	51.192	71.3777	61.24	15
11955	51.1938	71.3777	103.1	15
11956	51.1938	71.3806	114.82	15
11957	51.1956	71.3806	108.66	15
11958	51.1956	71.3835	114.28	15
11959	51.1992	71.3835	74.68	15
11960	51.1974	71.3603	132.02	15
11961	51.1956	71.3574	21.53	15
11962	51.1956	71.3661	109.04	15
11963	51.1938	71.3661	117.91	15
11964	51.1938	71.369	120.59	15
11965	51.1956	71.369	81.42	15
11966	51.1938	71.3719	101.7	15
11967	51.1992	71.3719	101.81	15
11968	51.201	71.3719	87.3	15
11969	51.1974	71.3719	27.22	15
11970	51.1992	71.369	125.21	15
11971	51.1956	71.3719	110.02	15
11972	51.1992	71.3748	98.12	15
11973	51.1956	71.3748	121.98	15
11974	51.1974	71.3777	43.42	15
11975	51.1974	71.3748	67.55	15
11976	51.1956	71.3777	142.8	15
11977	51.1992	71.3806	65.52	15
11978	51.201	71.3806	139.77	15
11979	51.2028	71.3806	122.18	15
11980	51.2046	71.3835	4.5	16
11981	51.201	71.3748	36.59	15
11982	51.2028	71.3748	95.5	15
11983	51.2028	71.3777	100.74	15
11984	51.2046	71.3777	90.95	15
11985	51.2046	71.3748	150.65	15
11986	51.2028	71.3719	85.78	15
11987	51.1956	71.3226	449.79	15
11988	51.1938	71.3226	98.69	15
11989	51.1974	71.34	99.57	15
11990	51.1974	71.3429	63.33	15
11991	51.1956	71.3429	60.59	15
11992	51.1956	71.34	124.62	15
11993	51.1956	71.3371	107.64	15
11994	51.1938	71.34	83.83	15
11995	51.1938	71.3429	78.58	15
11996	51.1992	71.3371	62.9	15
11997	51.201	71.3371	71.97	15
11998	51.1992	71.3342	114.95	15
11999	51.1974	71.3313	95.86	15
12000	51.1956	71.3313	95.96	15
12001	51.1956	71.3284	94.35	15
12002	51.1974	71.3255	99.93	15
12003	51.1992	71.3255	96.65	15
12004	51.201	71.3255	23.65	15
12005	51.1974	71.3226	5.84	15
12006	51.1956	71.3255	395.21	15
12007	51.1938	71.3313	573.79	15
12008	51.1974	71.3487	30.31	15
12009	51.1956	71.3487	12.28	15
12010	51.192	71.3458	130.02	15
12011	51.192	71.3429	229.83	15
12012	51.201	71.3458	890.06	15
12013	51.1992	71.34	90.36	15
12014	51.201	71.3342	79.82	15
12015	51.201	71.3951	85.41	16
12016	51.1974	71.4067	13.84	16
12017	51.1992	71.398	19.75	15
12018	51.1794	71.3603	126.3	15
12019	51.1794	71.3632	152.55	15
12020	51.1794	71.3661	162.35	15
12021	51.1794	71.369	147.72	15
12022	51.1812	71.3632	148.29	15
12023	51.1812	71.3603	329.02	15
12024	51.1812	71.3574	277.25	15
12025	51.1812	71.3661	77.39	15
12026	51.183	71.3632	102.54	15
12027	51.1758	71.3574	138.48	15
12028	51.1776	71.3574	138.2	15
12029	51.1776	71.3603	133.23	15
12030	51.1758	71.3603	141.87	15
12031	51.1758	71.3632	143.98	15
12032	51.1758	71.3661	101.21	15
12033	51.174	71.3661	12.79	15
12034	51.174	71.3632	103.93	15
12035	51.174	71.3603	167.81	15
12036	51.174	71.3574	442.96	15
12037	51.1722	71.3603	89.17	15
12038	51.1758	71.3545	102.77	15
12039	51.1758	71.3516	2.22	15
12040	51.1776	71.3545	65.12	15
12041	51.1794	71.3574	449.48	15
12042	51.1794	71.3545	49.91	15
12043	51.1776	71.3632	165.44	15
12044	51.183	71.3429	263.08	15
12045	51.1812	71.34	220.16	15
12046	51.1794	71.3458	504.53	15
12047	51.1848	71.3487	289.81	15
12048	51.1848	71.3516	88.98	15
12049	51.1866	71.3516	38.44	15
12050	51.1794	71.3516	6.78	15
12051	51.1758	71.3487	60.22	15
12052	51.174	71.3487	25.43	15
12053	51.1722	71.3487	52.99	15
12054	51.1722	71.3458	53.11	15
12055	51.1704	71.3516	21.08	15
12056	51.1686	71.3487	69.84	18
12057	51.1686	71.3574	161.99	15
12058	51.1686	71.3545	93.64	15
12059	51.1668	71.3516	70.98	18
12060	51.1668	71.3545	40.34	15
12061	51.1704	71.3574	172.88	15
12062	51.1722	71.3574	463.23	15
12063	51.1704	71.3603	60.01	15
12064	51.1704	71.3545	29.81	15
12065	51.1848	71.3342	67.55	15
12066	51.1866	71.3342	143.94	15
12067	51.1866	71.3313	103.03	15
12068	51.1884	71.3313	114.76	15
12069	51.1866	71.3284	105.48	15
12070	51.1848	71.3313	11.1	15
12071	51.1848	71.3284	98.38	15
12072	51.183	71.3284	13.78	15
12073	51.1848	71.3255	112.05	15
12074	51.1866	71.3255	70.9	15
12075	51.1884	71.3284	116.92	15
12076	51.1866	71.3371	119.38	15
12077	51.1848	71.3371	161.73	15
12078	51.192	71.3226	20.72	15
12079	51.1902	71.3226	187.47	15
12080	51.1902	71.3284	135.52	15
12081	51.192	71.3255	108.67	15
12082	51.1902	71.3313	124.66	15
12083	51.1884	71.3342	109.78	15
12084	51.1902	71.3371	16.89	15
12085	51.1884	71.3371	120.89	15
12086	51.1884	71.34	128.91	15
12087	51.1866	71.34	150.95	15
12088	51.1812	71.3255	370.09	15
12089	51.1812	71.3284	90.51	15
12090	51.183	71.3342	119.29	15
12091	51.183	71.3371	126.35	15
12092	51.1794	71.3342	93.24	15
12093	51.1794	71.3313	132.73	15
12094	51.1794	71.3284	99.39	15
12095	51.1776	71.3284	73.41	15
12096	51.1776	71.3313	120.99	15
12097	51.1776	71.3342	84.65	15
12098	51.1866	71.3487	127.41	15
12099	51.1884	71.3052	95.57	15
12100	51.1902	71.3081	31.65	15
12101	51.1902	71.3052	74.6	15
12102	51.1866	71.3081	103.07	15
12103	51.1848	71.3081	67.58	15
12104	51.1848	71.311	50.82	15
12105	51.1884	71.311	62.31	15
12106	51.1884	71.3168	216.11	15
12107	51.1866	71.3168	79.45	15
12108	51.1866	71.311	107.56	15
12109	51.1884	71.3139	101.98	15
12110	51.1866	71.3139	157.02	15
12111	51.1848	71.3139	173.22	15
12112	51.183	71.3139	22.3	15
12113	51.1848	71.3168	94.1	15
12114	51.1848	71.3197	93.55	15
12115	51.1848	71.3226	152.54	15
12116	51.1866	71.3197	101.98	15
12117	51.1884	71.3197	530.99	15
12118	51.1884	71.3226	94.12	15
12119	51.1866	71.3226	113.42	15
12120	51.1308	71.3922	398.98	18
12121	51.1308	71.3893	1001.21	18
12122	51.1308	71.3864	23.92	18
12123	51.147	71.3632	510.91	18
12124	51.1704	71.3777	345.87	15
12125	51.1542	71.3458	206.85	18
12126	51.1542	71.3429	513.77	18
12127	51.1974	71.427	35.85	16
12128	51.1992	71.4183	90.52	16
12129	51.1992	71.4212	27.89	16
12130	51.1974	71.4154	15.59	16
12131	51.1956	71.4241	78.29	16
12132	51.1956	71.4212	54.29	16
12133	51.1938	71.4212	16.09	16
12134	51.1956	71.4183	19.58	16
12135	51.1956	71.4154	6.94	16
12136	51.1938	71.4241	50.35	16
12137	51.1938	71.427	87.54	16
12138	51.192	71.427	48.14	16
12139	51.192	71.4357	92.71	16
12140	51.1938	71.4299	20.45	16
12141	51.192	71.4328	44.99	16
12142	51.192	71.4299	26.69	16
12143	51.1902	71.4299	15.04	16
12144	51.1902	71.4328	21.24	16
12145	51.192	71.4386	26.13	16
12146	51.1902	71.4357	437.7	16
12147	51.1884	71.4357	14.46	16
12148	51.1884	71.4386	63.62	16
12149	51.1884	71.4444	190.72	16
12150	51.1866	71.4415	58.53	16
12151	51.1866	71.4444	133.66	16
12152	51.2046	71.4502	83.66	16
12153	51.2028	71.4502	115.37	16
12154	51.2046	71.4531	337.8	16
12155	51.2064	71.4502	37.45	16
12156	51.2064	71.4473	83.44	16
12157	51.1974	71.4473	308.2	16
12158	51.1992	71.4473	63.21	16
12159	51.1956	71.4444	35.79	16
12160	51.1938	71.4386	49.25	16
12161	51.1974	71.4415	46.81	16
12162	51.1938	71.4415	93.42	16
12163	51.1974	71.4502	39.76	16
12164	51.1956	71.4502	54.01	16
12165	51.1956	71.4473	19.58	16
12166	51.1938	71.4444	22.87	16
12167	51.1938	71.4502	161.01	16
12168	51.1938	71.4531	40.86	16
12169	51.192	71.4502	155.72	16
12170	51.192	71.4531	22.69	16
12171	51.1884	71.4502	47.87	16
12172	51.192	71.4473	41.84	16
12173	51.1902	71.4444	138.75	16
12174	51.192	71.4444	36.15	16
12175	51.1902	71.4473	216.65	16
12176	51.1902	71.4502	83.1	16
12177	51.1902	71.4531	71.28	16
12178	51.192	71.456	105.62	16
12179	51.2028	71.456	82.71	16
12180	51.201	71.456	87.77	16
12181	51.201	71.4531	48.8	16
12182	51.1992	71.4531	52.34	16
12183	51.1992	71.456	48.52	16
12184	51.1974	71.4734	29.15	16
12185	51.1956	71.4618	97.67	16
12186	51.1956	71.4589	238.16	16
12187	51.192	71.4618	35.44	16
12188	51.1938	71.4618	66.43	16
12189	51.1938	71.4589	31.87	16
12190	51.1956	71.4647	61.78	16
12191	51.1992	71.4647	477.4	16
12192	51.1884	71.456	162.84	16
12193	51.1974	71.4647	1950.01	16
12194	51.1974	71.4676	113.8	16
12195	51.1974	71.4705	135.37	16
12196	51.2046	71.4328	12.42	16
12197	51.2064	71.4299	5.56	16
12198	51.2046	71.4299	26.89	16
12199	51.2046	71.4241	24.12	16
12200	51.2046	71.4212	36.72	16
12201	51.1992	71.4067	155.62	16
12202	51.1992	71.4096	20.83	16
12203	51.201	71.4183	82.03	16
12204	51.201	71.4125	110.45	16
12205	51.201	71.4154	116.03	16
12206	51.1992	71.4125	22.68	16
12207	51.201	71.4241	48.59	16
12208	51.201	71.4212	209.55	16
12209	51.2028	71.4241	25.6	16
12210	51.2028	71.427	73.69	16
12211	51.2028	71.4299	133.07	16
12212	51.2028	71.4328	104.72	16
12213	51.2028	71.4357	55	16
12214	51.2046	71.4357	15	16
12215	51.2064	71.4444	29.12	16
12216	51.2064	71.4415	125.08	16
12217	51.2028	71.4473	17.13	16
12218	51.2028	71.4444	8.91	16
12219	51.201	71.4473	81.61	16
12220	51.201	71.4444	33.89	16
12221	51.201	71.4415	143.71	16
12222	51.2028	71.4415	124.8	16
12223	51.2046	71.4386	174.26	16
12224	51.2046	71.4415	157.76	16
12225	51.2046	71.427	149.31	16
12226	51.2028	71.4038	83.9	16
12227	51.2046	71.4038	39.67	16
12228	51.2028	71.4009	93.63	16
12229	51.201	71.4009	33.35	16
12230	51.2064	71.4067	66.69	16
12231	51.2082	71.4067	40.11	16
12232	51.2082	71.4038	52.81	16
12233	51.2064	71.4096	82.79	16
12234	51.2046	71.4096	48.63	16
12235	51.2064	71.4125	33.04	16
12236	51.2028	71.4125	91.16	16
12237	51.2064	71.4154	4.54	16
12238	51.2046	71.4154	68.97	16
12239	51.2046	71.4183	16.28	16
12240	51.2028	71.4154	57.64	16
12241	51.2136	71.3719	12.77	16
12242	51.2118	71.3719	46.1	16
12243	51.2118	71.369	22.33	16
12244	51.21	71.369	17.7	16
12245	51.21	71.3719	56.25	16
12246	51.2118	71.3748	61.69	16
12247	51.21	71.3748	81.87	16
12248	51.21	71.3777	46.78	16
12249	51.2082	71.3748	67.32	16
12250	51.2082	71.3719	28.36	16
12251	51.2064	71.3748	37.37	15
12252	51.2064	71.3777	33.8	16
12253	51.2064	71.3835	26.21	16
12254	51.2082	71.3864	33.96	16
12255	51.2064	71.3864	156.05	16
12256	51.2064	71.3893	62.3	16
12257	51.2046	71.3864	38.26	16
12258	51.2046	71.3893	199.13	16
12259	51.2046	71.3922	9.6	16
12260	51.2028	71.3951	47.87	16
12261	51.2028	71.3922	44.71	16
12262	51.2154	71.3893	51.34	16
12263	51.2154	71.3864	41.9	16
12264	51.2154	71.3835	43.94	16
12265	51.2136	71.3864	59.21	16
12266	51.2118	71.3893	74.64	16
12267	51.2136	71.3835	42.71	16
12268	51.2172	71.3835	43.3	16
12269	51.2208	71.3893	138.33	16
12270	51.2208	71.3922	246.97	16
12271	51.2226	71.3922	29.12	16
12272	51.2208	71.3835	98.57	16
12273	51.2226	71.3777	69.63	16
12274	51.2208	71.3719	15.29	16
12275	51.2154	71.3748	15.48	16
12276	51.21	71.3893	87.48	16
12277	51.2118	71.3922	53.41	16
12278	51.2082	71.3893	42.61	16
12279	51.21	71.3922	61.58	16
12280	51.2082	71.3922	95.44	16
12281	51.2064	71.3922	86.98	16
12282	51.21	71.3951	59.94	16
12283	51.2082	71.369	67.71	15
12284	51.2064	71.369	223.46	15
12285	51.2046	71.3951	26.57	16
12286	51.2064	71.4009	43.45	16
12287	51.21	71.4009	128.07	16
12288	51.21	71.398	48.32	16
12289	51.2082	71.398	61.63	16
12290	51.2118	71.4038	210	16
12291	51.2136	71.4009	96.27	16
12292	51.2136	71.398	45.09	16
12293	51.2154	71.3951	90.44	16
12294	51.2136	71.3922	39.3	16
12295	51.2136	71.3893	45.44	16
12296	51.2172	71.3951	117.12	16
12297	51.2172	71.3922	172.58	16
12298	51.1848	71.4676	89.05	16
12299	51.1884	71.4589	46.95	16
12300	51.1884	71.4618	277.32	16
12301	51.1902	71.4589	176.46	16
12302	51.1848	71.4589	244.11	16
12303	51.1866	71.4589	124.89	16
12304	51.1848	71.456	167.02	16
12305	51.1866	71.456	71.34	16
12306	51.1308	71.5343	224.82	17
12307	51.129	71.5343	1100.42	17
12308	51.1272	71.5372	987.31	17
12309	51.1272	71.5343	284.62	17
12310	51.129	71.5372	106.72	17
12311	51.1308	71.5401	89.34	17
12312	51.129	71.5401	46.29	17
12313	51.1326	71.5372	84.1	17
12314	51.1308	71.5372	83.8	17
12315	51.1254	71.5256	102.02	17
12316	51.129	71.5285	65.03	17
12317	51.1308	71.5285	119.62	17
12318	51.1272	71.5285	42.77	17
12319	51.1254	71.5285	9.75	17
12320	51.1236	71.5256	40.31	17
12321	51.1218	71.5227	673.4	17
12322	51.12	71.514	61.46	17
12323	51.12	71.5169	1129.01	17
12324	51.12	71.5198	51.02	17
12325	51.1182	71.5198	19.53	17
12326	51.1578	71.4096	6.2	15
12327	51.147	71.5575	218.77	14
12328	51.1164	71.572	129.51	17
12329	51.111	71.5575	22.01	17
12330	51.111	71.5604	36.47	17
12331	51.1092	71.5633	36.03	17
12332	51.1074	71.5604	17.28	17
12333	51.1074	71.5575	17.51	17
12334	51.0984	71.4125	8.22	13
12335	51.1182	71.398	2603.73	18
12336	51.1218	71.4009	1038.04	18
12337	51.12	71.4009	656.55	18
12338	51.0948	71.4212	1453.6	13
12339	51.0912	71.4241	25.3	13
12340	51.0966	71.4154	446.87	13
12341	51.0948	71.4154	693.05	13
12342	51.093	71.4154	89.25	13
12343	51.0948	71.4125	707.74	13
12344	51.0966	71.4125	700.65	13
12345	51.0966	71.4096	1193.27	13
12346	51.0948	71.4096	1343.99	13
12347	51.0966	71.4067	1100.25	13
12348	51.0948	71.4067	1183.97	13
12349	51.093	71.4067	1480.11	13
12350	51.0912	71.4067	1544.06	13
12351	51.093	71.4096	473.96	13
12352	51.0912	71.4038	291.12	13
12353	51.0894	71.4067	2875.24	13
12354	51.1542	71.5488	134.78	14
12355	51.1524	71.5459	41.4	14
12356	51.1506	71.5517	90.82	14
12357	51.1524	71.5488	51.18	14
12358	51.1488	71.5517	84.64	14
12359	51.1488	71.5546	80.64	14
12360	51.1488	71.5575	72.05	14
12361	51.1524	71.5633	100.76	14
12362	51.1524	71.5604	20.1	14
12363	51.1506	71.5604	101.25	14
12364	51.1506	71.5575	24.65	14
12365	51.1488	71.5604	136.82	14
12366	51.1506	71.5633	254.42	14
12367	51.1488	71.5633	92.3	14
12368	51.147	71.5633	133.96	14
12369	51.1488	71.5662	64.2	14
12370	51.1506	71.5662	84.05	14
12371	51.1488	71.5691	36.66	14
12372	51.1506	71.5691	15.01	14
12373	51.1488	71.5749	103.72	14
12374	51.1488	71.5778	60.79	14
12375	51.147	71.5749	101.15	14
12376	51.147	71.5778	42.29	14
12377	51.147	71.572	49.75	14
12378	51.147	71.5807	79.6	14
12379	51.1452	71.5778	61.62	14
12380	51.1452	71.5807	18.69	14
12381	51.1434	71.5836	61.48	14
12382	51.1434	71.5807	75.98	14
12383	51.1434	71.5778	30.16	14
12384	51.1452	71.5749	92.68	14
12385	51.1434	71.5749	53.92	14
12386	51.1452	71.572	77.07	14
12387	51.147	71.5691	160.16	14
12388	51.1452	71.5662	168.36	14
12389	51.1434	71.5662	82.04	14
12390	51.1434	71.5691	56.91	14
12391	51.1416	71.5749	73.74	14
12392	51.1416	71.5778	72.37	14
12393	51.1416	71.5807	109.51	14
12394	51.1452	71.5604	58.3	14
12395	51.147	71.5546	106.5	14
12396	51.147	71.5517	140.07	14
12397	51.1452	71.5517	2.46	14
12398	51.1452	71.5546	36.76	14
12399	51.1452	71.5575	31.55	14
12400	51.1434	71.5633	28.79	14
12401	51.1416	71.5691	36.8	14
12402	51.1416	71.572	17.21	14
12403	51.1416	71.5836	51.82	14
12404	51.1398	71.5807	40.29	14
12405	51.1416	71.5865	31.86	14
12406	51.1938	71.5053	50.27	16
12407	51.1956	71.5053	118.53	16
12408	51.1938	71.5082	62.65	16
12409	51.1992	71.4966	213.5	16
12410	51.1974	71.4966	37.53	16
12411	51.1956	71.4966	34.11	16
12412	51.1974	71.4937	78.02	16
12413	51.1956	71.4937	19.76	16
12414	51.201	71.4966	37.46	16
12415	51.1254	71.5952	214.67	17
12416	51.1164	71.5807	25.3	17
12417	51.129	71.5865	160.05	17
12418	51.1272	71.5923	59.93	17
12419	51.1254	71.5981	53.99	17
12420	51.1236	71.601	86.64	17
12421	51.1218	71.601	46.68	17
12422	51.1254	71.5923	61.23	17
12423	51.1236	71.5865	27.06	17
12424	51.1254	71.5865	133.97	17
12425	51.1272	71.5836	3.14	17
12426	51.12	71.5778	63.65	17
12427	51.12	71.5807	41.73	17
12428	51.1128	71.572	26.1	17
12429	51.1128	71.5749	39.22	17
12430	51.1092	71.6822	13.1	17
12431	51.1128	71.688	2.72	14
12432	51.1056	71.688	2.39	17
12433	51.1038	71.6909	9.07	17
12434	51.1038	71.688	44.25	17
12435	51.1038	71.6851	57.33	17
12436	51.1074	71.6822	67.97	17
12437	51.1074	71.6793	61.49	17
12438	51.1056	71.6822	68.99	17
12439	51.1056	71.6793	188.23	17
12440	51.1092	71.6735	25.84	17
12441	51.1056	71.6764	8.08	17
12442	51.1074	71.6764	7.11	17
12443	51.1038	71.6793	25.01	17
12444	51.1038	71.6822	66.08	17
12445	51.102	71.6822	13.83	17
12446	51.1056	71.6851	46.97	17
12447	51.1074	71.6851	44.15	17
12448	51.1092	71.6503	34.1	17
12449	51.111	71.6474	68.89	17
12450	51.111	71.6503	61.47	17
12451	51.111	71.6445	69.75	17
12452	51.1092	71.6474	57.19	17
12453	51.1128	71.6445	153.19	17
12454	51.1146	71.6503	41.04	17
12455	51.1164	71.6503	2.84	17
12456	51.1146	71.6619	44.98	17
12457	51.111	71.659	49.44	17
12458	51.111	71.6561	47.41	17
12459	51.111	71.6532	37.29	17
12460	51.1128	71.6532	140.5	17
12461	51.1146	71.6532	202.76	17
12462	51.1128	71.6474	42.75	17
12463	51.1146	71.6474	98.79	17
12464	51.1164	71.6474	39.9	17
12465	51.1182	71.6445	91.04	17
12466	51.1182	71.6474	12.62	17
12467	51.12	71.6474	54.02	17
12468	51.12	71.6445	60.16	17
12469	51.1218	71.6445	19.25	17
12470	51.1218	71.6474	17.6	14
12471	51.1236	71.6329	145.31	17
12472	51.1326	71.3081	31.49	18
12473	51.12	71.282	6.08	18
12474	51.1218	71.2849	5.59	18
12475	51.1128	71.4125	1229.87	13
12476	51.102	71.4589	60.3	13
12477	51.1038	71.4589	40.55	13
12478	51.102	71.4618	88.02	13
12479	51.102	71.4647	156.01	13
12480	51.1002	71.4676	75.75	13
12481	51.1002	71.4647	161.43	13
12482	51.1002	71.4618	71.69	13
12483	51.093	71.4792	58.91	13
12484	51.093	71.4821	68.76	13
12485	51.0948	71.4821	65.04	13
12486	51.0948	71.4879	52.54	13
12487	51.0948	71.4908	145.38	13
12488	51.0966	71.4879	144.81	13
12489	51.0966	71.485	47.45	13
12490	51.0948	71.485	60.36	13
12491	51.0966	71.4908	23.23	13
12492	51.0966	71.4937	42.3	13
12493	51.1002	71.4937	16.6	13
12494	51.0984	71.4908	30.63	13
12495	51.0984	71.4937	125.35	13
12496	51.093	71.4908	37.36	13
12497	51.093	71.4879	57.52	13
12498	51.0912	71.4821	172.38	13
12499	51.093	71.4763	51.7	13
12500	51.0948	71.4763	247.26	13
12501	51.0948	71.4734	269.86	13
12502	51.0948	71.4792	63.37	13
12503	51.0966	71.4792	32.57	13
12504	51.0966	71.4821	57.36	13
12505	51.147	71.4908	30.29	14
12506	51.0408	71.4386	497.6	13
12507	51.0408	71.4357	34.03	13
12508	51.0606	71.4328	195.37	13
12509	51.0606	71.4299	137.55	13
12510	51.0624	71.4299	207.66	13
12511	51.0624	71.4241	116.26	13
12512	51.0624	71.427	152.79	13
12513	51.0606	71.427	148.33	13
12514	51.0606	71.4241	158.5	13
12515	51.0588	71.427	157.52	13
12516	51.0588	71.4299	149.53	13
12517	51.057	71.427	136.97	13
12518	51.0642	71.4241	297.47	13
12519	51.0642	71.427	55.15	13
12520	51.0858	71.4386	129.81	13
12521	51.0858	71.4357	124.4	13
12522	51.0858	71.4328	229.95	13
12523	51.0876	71.4444	111.32	13
12524	51.0876	71.4415	125.96	13
12525	51.0858	71.4444	85.05	13
12526	51.084	71.4415	1618.88	13
12527	51.0858	71.4415	146.34	13
12528	51.1956	71.4995	94.44	16
12529	51.1938	71.4995	756.17	16
12530	51.1902	71.4966	290.03	16
12531	51.1848	71.4966	131.9	16
12532	51.1866	71.4299	279.13	15
12533	51.1704	71.4966	61.35	14
12534	51.1686	71.4966	11.49	14
12535	51.174	71.4995	508.7	14
12536	51.1722	71.4995	97.68	14
12537	51.174	71.5198	587.22	14
12538	51.1722	71.514	111.15	14
12539	51.1722	71.5169	120.5	14
12540	51.1668	71.5082	663.99	14
12541	51.1686	71.5053	124.35	14
12542	51.1704	71.4908	8.14	14
12543	51.1704	71.4879	61.07	14
12544	51.1056	71.4415	90.01	13
12545	51.237	71.369	42.77	16
12546	51.237	71.3632	5.19	16
12547	51.2406	71.3603	211.27	16
12548	51.2388	71.3603	109.56	16
12549	51.237	71.3603	11.95	16
12550	51.2352	71.3719	1.2	16
12551	51.1326	71.4357	6.45	13
12552	51.129	71.4067	143.18	18
12553	51.1146	71.2414	53.36	18
12554	51.129	71.2501	87.03	18
12555	51.1254	71.2733	156.36	18
12556	51.1254	71.2704	32.66	18
12557	51.1074	71.5082	97.19	17
12558	51.1092	71.4995	112.13	17
12559	51.1092	71.4966	111.47	17
12560	51.1056	71.4908	100.12	17
12561	51.1056	71.4879	75.76	17
12562	51.1164	71.4734	648.18	17
12563	51.1146	71.4734	1222.33	17
12564	51.1218	71.4763	1581.32	17
12565	51.1182	71.4589	2276.37	17
12566	51.2442	71.2646	105.1	15
12567	51.2442	71.2617	107.54	15
12568	51.2424	71.2617	20.77	15
12569	51.1776	71.3806	37.64	15
12570	51.1452	71.3864	639.17	18
12571	51.1434	71.3864	1142.26	18
12572	51.1416	71.3893	743.96	18
12573	51.1398	71.3922	694	18
12574	51.138	71.4009	551.51	18
12575	51.0966	71.427	39.3	13
12576	51.0966	71.4299	93.26	13
12577	51.0948	71.4415	1676.28	13
12578	51.084	71.4357	230.18	13
12579	51.0336	71.3922	141.67	13
12580	51.0336	71.3951	90.46	13
12581	51.0318	71.3951	4.38	13
12582	51.0318	71.3922	25.45	13
12583	51.0318	71.3893	3.19	13
12584	51.0336	71.3893	10.53	13
12585	51.0354	71.3922	6.53	13
12586	51.1038	71.4241	563.27	13
12587	51.0984	71.4328	501.02	13
12588	51.0948	71.4357	961.92	13
12589	51.1416	71.4154	964.63	18
12590	51.111	71.4299	1023.43	13
12591	51.111	71.427	1870.4	13
12592	51.2496	71.3835	30.59	16
12593	51.2622	71.398	218.21	16
12594	51.2514	71.3835	24.75	16
12595	51.2496	71.3806	57.9	16
12596	51.1254	71.4734	582.19	17
12597	51.1254	71.4705	20.65	17
12598	51.1884	71.4676	131.79	16
12599	51.1902	71.4705	214.84	16
12600	51.1884	71.4647	71.69	16
12601	51.2154	71.3574	173.5	15
12602	51.2136	71.3603	46.78	15
12603	51.2136	71.3574	32.06	15
12604	51.2118	71.3603	73.82	15
12605	51.21	71.3632	62.74	15
12606	51.2118	71.3545	21.35	15
12607	51.2064	71.3226	41.96	15
12608	51.1776	71.3429	41.39	15
12609	51.1758	71.3429	34.97	15
12610	51.2262	71.4009	103.85	16
12611	51.1362	71.5575	264.76	17
12612	51.138	71.5575	136.4	14
12613	51.2208	71.5256	3.38	16
12614	51.0732	71.3893	134.67	18
12615	51.2604	71.5981	5.08	16
12616	51.1002	71.717	30.55	17
12617	51.2118	71.4096	46.72	16
12618	51.2118	71.4067	236.15	16
12619	51.1956	71.4125	72.99	16
12620	51.183	71.514	13.59	16
12621	51.183	71.5169	7.23	16
12622	51.1776	71.514	7.25	14
12623	51.1794	71.514	51.06	14
12624	51.1776	71.5053	80.9	14
12625	51.183	71.5053	417.48	14
12626	51.1812	71.5053	312.26	14
12627	51.174	71.5343	24.96	14
12628	51.1524	71.5517	20.76	14
12629	51.156	71.5198	352.13	14
12630	51.156	71.5227	115.83	14
12631	51.1542	71.5227	579.17	14
12632	51.1452	71.5314	220.17	14
12633	51.1452	71.5343	200.49	14
12634	51.1434	71.5285	521.46	14
12635	51.1812	71.4589	34.6	16
12636	51.2082	71.3574	33.92	15
12637	51.2082	71.3632	53.01	15
12638	51.2046	71.3545	266.99	15
12639	51.2046	71.3719	206.23	15
12640	51.2046	71.369	40.86	15
12641	51.201	71.398	4.39	16
12642	51.2028	71.3893	25.51	16
12643	51.2154	71.3806	58.38	16
12644	51.228	71.3864	2.51	16
12645	51.2154	71.4009	178.2	16
12646	51.1128	71.4183	362.56	13
12647	51.1182	71.3951	1105.96	18
12648	51.1128	71.4009	992.95	18
12649	51.1128	71.4038	325.02	18
12650	51.1128	71.4067	1214.74	18
12651	51.1146	71.4038	306.98	18
12652	51.1218	71.4705	10.06	17
12653	51.0984	71.4357	920.95	13
12654	51.0948	71.4241	232.99	13
12655	51.093	71.427	916.26	13
12656	51.0966	71.4415	1372.26	13
12657	51.0966	71.4444	1066.26	13
12658	51.0822	71.4183	15.58	13
12659	51.084	71.4096	80.25	13
12660	51.0822	71.4125	263.9	13
12661	51.1002	71.427	883.44	13
12662	51.1992	71.4038	6.64	16
12663	51.2082	71.4096	1.66	16
12664	51.1596	71.4009	845.93	15
12665	51.1974	71.4096	88.59	16
12666	51.1974	71.4125	3.26	16
12667	51.1578	71.4212	14.91	18
12668	51.1578	71.4183	6.37	18
12669	51.1578	71.4154	18.81	18
12670	51.1794	71.5111	221.8	14
12671	51.1812	71.5024	117.37	16
12672	51.1776	71.5024	829.94	14
12673	51.1722	71.5024	4.5	14
12674	51.1704	71.4995	10.34	14
12675	51.1704	71.5024	10	14
12676	51.1722	71.4937	139.24	14
12677	51.1722	71.5256	1.6	14
12678	51.174	71.5285	1.89	14
12679	51.174	71.5256	1305.26	14
12680	51.0246	71.456	184.4	13
12681	51.0174	71.4473	725.63	13
12682	51.0156	71.4473	574.1	13
12683	51.0192	71.4502	945.02	13
12684	51.1938	71.456	23.13	16
12685	51.1992	71.4415	16.66	16
12686	51.1992	71.4386	37.26	16
12687	51.0408	71.4821	136.48	13
12688	51.0408	71.485	308.16	13
12689	51.039	71.485	666.3	13
12690	51.0282	71.456	4.71	13
12691	51.2136	71.5111	30.4	16
12692	51.2118	71.5082	75.95	16
12693	51.201	71.485	115.83	16
12694	51.201	71.4879	88.55	16
12695	51.1992	71.4879	41.3	16
12696	51.1992	71.485	185.93	16
12697	51.1956	71.4705	346.52	16
12698	51.192	71.4676	32.48	16
12699	51.1902	71.4647	28.36	16
12700	51.192	71.4647	313.27	16
12701	51.2046	71.4821	65.5	16
12702	51.1362	71.4531	4.59	14
12703	51.1218	71.456	18.29	17
12704	51.1326	71.5343	102.65	17
12705	51.1344	71.5343	95.48	17
12706	51.1938	71.4908	95.57	16
12707	51.192	71.4705	106.61	16
12708	51.1938	71.4734	16.55	16
12709	51.1902	71.4734	204.72	16
12710	51.1884	71.4705	79.49	16
12711	51.1884	71.4763	132.42	16
12712	51.1902	71.4792	71.32	16
12713	51.1902	71.4821	34.9	16
12714	51.1956	71.4821	34.13	16
12715	51.1938	71.4792	44.79	16
12716	51.1866	71.4821	10.78	16
12717	51.1722	71.3748	22.4	15
12718	51.1542	71.5575	117.56	14
12719	51.1542	71.5546	133.77	14
12720	51.1686	71.514	98.09	14
12721	51.156	71.4647	4.73	14
12722	51.1218	71.5256	10.5	17
12723	51.1236	71.5488	46.33	17
12724	51.1254	71.5488	81.75	17
12725	51.1344	71.5401	3.85	17
12726	51.1434	71.5343	96.83	14
12727	51.1416	71.5343	152.64	14
12728	51.1416	71.5633	78.06	14
12729	51.1434	71.5604	27.89	14
12730	51.1236	71.5807	17.6	17
12731	51.129	71.5981	50.89	17
12732	51.1236	71.5285	262.71	17
12733	51.1254	71.5343	198.17	17
12734	51.1254	71.5314	76.83	17
12735	51.1236	71.5343	263.52	17
12736	51.1218	71.5285	196.65	17
12737	51.1182	71.4792	998.73	17
12738	51.1308	71.5923	20.27	17
12739	51.156	71.5343	8.54	14
12740	51.1416	71.5488	7.52	14
12741	51.1398	71.5488	16.47	14
12742	51.1416	71.5517	29.29	14
12743	51.1398	71.5517	53.92	14
12744	51.138	71.5517	256.86	14
12745	51.138	71.5546	94.32	14
12746	51.1416	71.5575	209.26	14
12747	51.1398	71.5546	363.89	14
12748	51.138	71.5459	834.4	14
12749	51.1416	71.5459	29.46	14
12750	51.1416	71.543	342.79	14
12751	51.1434	71.5401	133.55	14
12752	51.1362	71.5401	61.71	14
12753	51.138	71.5401	202.26	14
12754	51.138	71.5343	77.91	14
12755	51.138	71.5372	131.44	14
12756	51.1128	71.6503	260.74	17
12757	51.1092	71.6793	10.26	17
12758	51.111	71.6764	19.21	17
12759	51.1128	71.6851	2.69	14
12760	51.111	71.6851	5.96	17
12761	51.1308	71.3661	1317.6	18
12762	51.1308	71.369	1652.08	18
12763	51.1272	71.3806	1188.21	18
12764	51.1272	71.3748	944.31	18
12765	51.129	71.3748	716.75	18
12766	51.1254	71.3661	1207.62	18
12767	51.1254	71.3632	945.22	18
12768	51.1254	71.3603	780.69	18
12769	51.1308	71.3719	632.04	18
12770	51.1272	71.3661	1495.79	18
12771	51.1272	71.369	339.34	18
12772	51.1308	71.3632	952.09	18
12773	51.1434	71.34	206.25	18
12774	51.1452	71.34	48.91	18
12775	51.1416	71.3313	55.44	18
12776	51.1416	71.3255	12.75	18
12777	51.1362	71.3313	367.15	18
12778	51.1524	71.3893	87.32	18
12779	51.156	71.3922	47.57	18
12780	51.1578	71.3922	48.93	18
12781	51.1416	71.3777	474.14	18
12782	51.129	71.398	669.42	18
12783	51.1308	71.398	1060.65	18
12784	51.1272	71.3922	330.16	18
12785	51.1668	71.3574	28.81	15
12786	51.1668	71.3806	147.56	15
12787	51.1668	71.3951	9.98	15
12788	51.0984	71.4763	33.44	13
12789	51.0984	71.4792	41.16	13
12790	51.1002	71.4792	10.87	13
12791	51.1002	71.4821	67.42	13
12792	51.0966	71.4734	104.06	13
12793	51.0966	71.4705	8.31	13
12794	51.0984	71.4705	17.66	13
12795	51.102	71.4676	13.85	13
12796	51.0966	71.4618	57.94	13
12797	51.0966	71.4589	190.14	13
12798	51.0948	71.4589	60.55	13
12799	51.0984	71.4589	1084.86	13
12800	51.0984	71.4618	131.81	13
12801	51.0966	71.4647	55.19	13
12802	51.0984	71.4647	12.95	13
12803	51.1002	71.4589	1.92	13
12804	51.1038	71.4676	29.79	13
12805	51.0984	71.4821	8.96	13
12806	51.1074	71.4937	67.97	17
12807	51.1074	71.5024	127.18	17
12808	51.1074	71.5053	60.6	17
12809	51.1092	71.5053	157.76	17
12810	51.1128	71.4705	76.76	17
12811	51.111	71.4589	405.01	17
12812	51.1308	71.4734	914.51	14
12813	51.1092	71.5024	58.77	17
12814	51.111	71.4618	1516.95	17
12815	51.1182	71.4705	1762.38	17
12816	51.1218	71.4792	445.9	17
12817	51.1236	71.4734	6.17	17
12818	51.1218	71.4908	1087.07	17
12819	51.129	71.4966	321.24	14
12820	51.093	71.4038	254.21	18
12821	51.0912	71.4096	339.32	13
12822	51.1182	71.5169	754.86	17
12823	51.075	71.4299	961.64	13
12824	51.0894	71.4009	6.6	18
12825	51.0876	71.3922	93.91	18
12826	51.0894	71.4502	1320.57	13
12827	51.0912	71.4502	2050.57	13
12828	51.1002	71.485	3.02	13
12829	51.1434	71.5314	90.61	14
12830	51.1416	71.5285	22.55	14
12831	51.1416	71.5314	262.51	14
12832	51.1398	71.5285	9.39	14
12833	51.1704	71.543	536.52	14
12834	51.174	71.5459	230.98	14
12835	51.165	71.5459	439.7	14
12836	51.1722	71.543	340.72	14
12837	51.174	71.543	764.69	14
12838	51.0966	71.3951	453.91	18
12839	51.1524	71.4241	1944.41	18
12840	51.21	71.4415	262.83	16
12841	51.1074	71.4357	2423.72	13
12842	51.0768	71.3835	17.05	18
12843	51.0768	71.3806	119.2	18
12844	51.2622	71.5981	3.68	16
12845	51.1164	71.3951	1667.75	18
12846	51.1056	71.398	566.6	18
12847	51.093	71.4009	122.29	18
12848	51.0912	71.3922	39.62	18
12849	51.1002	71.4125	714.58	13
12850	51.075	71.3922	212.95	18
12851	51.0714	71.3893	144.55	18
12852	51.0696	71.3864	1145.28	18
12853	51.0678	71.3864	296.65	18
12854	51.1596	71.4415	1116.46	16
12855	51.12	71.4357	3.61	13
12856	51.1218	71.4357	0.96	13
12857	51.1236	71.4821	1176.97	17
12858	51.1128	71.4763	45.03	17
12859	51.165	71.4067	828.36	15
12860	51.1686	71.4038	2341.83	15
12861	51.1506	71.4299	317.69	13
12862	51.147	71.4154	6.15	18
12863	51.2154	71.34	235.37	15
12864	51.2172	71.34	250.02	15
12865	51.2226	71.3429	48.55	15
12866	51.2208	71.3429	92.62	15
12867	51.12	71.5256	118.97	17
12868	51.1344	71.5372	1.9	17
12869	51.1236	71.5314	337.97	17
12870	51.1272	71.5314	88.16	17
12871	51.1308	71.5314	9.18	17
12872	51.1272	71.5517	2.91	17
12873	51.147	71.5314	441.89	14
12874	51.147	71.5343	98.11	14
12875	51.147	71.5372	387.14	14
12876	51.1398	71.5314	116.15	14
12877	51.0966	71.4473	990.35	13
12878	51.2478	71.3748	465.96	16
12879	51.2496	71.3777	16.6	16
12880	51.2478	71.3777	85.19	16
12881	51.2424	71.3748	47.65	16
12882	51.228	71.3893	112.75	16
12883	51.2262	71.3893	54.08	16
12884	51.228	71.3922	59.27	16
12885	51.2262	71.398	311.3	16
12886	51.228	71.3951	431	16
12887	51.2262	71.3951	80.25	16
12888	51.2244	71.4009	103.36	16
12889	51.2244	71.398	164.69	16
12890	51.2226	71.3951	69.43	16
12891	51.2244	71.3922	212.31	16
12892	51.2244	71.3835	6.64	16
12893	51.2226	71.4067	230.82	16
12894	51.2208	71.4067	60.21	16
12895	51.2136	71.4444	135.06	16
12896	51.2136	71.4473	450.48	16
12897	51.1974	71.4792	339.29	16
12898	51.084	71.4183	14.88	13
12899	51.1326	71.3835	372.65	18
12900	51.1398	71.3806	729.48	18
12901	51.1452	71.369	8.1	18
12902	51.1398	71.3893	425.08	18
12903	51.1416	71.3864	1478.58	18
12904	51.1524	71.3719	552.59	18
12905	51.1488	71.3719	616.66	18
12906	51.1578	71.3951	134.58	18
12907	51.1596	71.3951	80.17	18
12908	51.1596	71.3922	15.17	18
12909	51.1578	71.3893	132	18
12910	51.1452	71.3545	244.4	18
12911	51.1488	71.3487	91.52	18
12912	51.147	71.3487	228.83	18
12913	51.1452	71.3458	491.28	18
12914	51.1542	71.3632	188.66	18
12915	51.1506	71.3632	608.41	18
12916	51.1452	71.3603	107.62	18
12917	51.1236	71.2907	255.03	18
12918	51.0912	71.427	1126.27	13
12919	51.102	71.4531	837.88	13
12920	51.1002	71.4531	362.33	13
12921	51.0984	71.4531	361.76	13
12922	51.0966	71.4531	371.73	13
12923	51.0948	71.4531	361.39	13
12924	51.093	71.4502	362.98	13
12925	51.093	71.4531	362.71	13
12926	51.0894	71.4531	1071.46	13
12927	51.192	71.3197	0.9	15
12928	51.1938	71.3139	3.08	15
12929	51.192	71.3168	16.25	15
12930	51.2118	71.2791	4.28	15
12931	51.1938	71.4154	258.55	15
12932	51.1992	71.4009	4.44	16
12933	51.1974	71.3516	105.99	15
12934	51.1992	71.3516	193.41	15
12935	51.2172	71.3545	107.76	15
12936	51.2172	71.3429	251.95	15
12937	51.2046	71.34	229.38	15
12938	51.2064	71.3429	4.06	15
12939	51.2028	71.3458	517.32	15
12940	51.2028	71.3429	23.14	15
12941	51.2082	71.3371	761.85	15
12942	51.192	71.3342	482.42	15
12943	51.228	71.2472	57.14	15
12944	51.1236	71.4125	346.18	18
12945	51.2136	71.4096	4.07	16
12946	51.2136	71.3632	6.15	16
12947	51.2154	71.3603	5.93	16
12948	51.2046	71.4879	431.96	16
12949	51.093	71.4734	427.72	13
12950	51.183	71.4676	44.26	16
12951	51.1812	71.4966	148.23	16
12952	51.1794	71.4995	158.41	16
12953	51.174	71.4879	1.15	16
12954	51.0282	71.4618	12.78	13
12955	51.2208	71.4096	6.07	16
12956	51.21	71.4299	258.84	16
12957	51.2136	71.4328	98.53	16
12958	51.2136	71.4357	8.29	16
12959	51.21	71.4357	107.94	16
12960	51.2082	71.4473	68.94	16
12961	51.2046	71.485	211.97	16
12962	51.1362	71.3168	3.04	18
12963	51.2262	71.3284	176.3	15
12964	51.2244	71.3342	44.73	15
12965	51.2244	71.3313	42.67	15
12966	51.2262	71.2501	128.67	15
12967	51.2478	71.3603	30.24	16
12968	51.2478	71.5952	16.85	16
12969	51.2478	71.5807	7.3	16
12970	51.2478	71.5894	30.03	16
12971	51.2478	71.5923	26.02	16
12972	51.2478	71.5865	16.46	16
12973	51.0372	71.4531	7.52	13
12974	51.0408	71.4241	127.84	13
12975	51.1002	71.3951	745.76	18
12976	51.111	71.4096	11.34	18
12977	51.129	71.4009	1990.68	18
12978	51.0894	71.4183	94.41	13
12979	51.1092	71.4241	1758.02	13
12980	51.192	71.4212	73.21	15
12981	51.1596	71.6039	24.76	14
12982	51.1596	71.6068	74.01	14
12983	51.1722	71.6184	10.95	14
12984	51.1866	71.601	3.99	14
12985	51.2388	71.572	42.05	16
12986	51.2406	71.5691	7.6	16
12987	51.264	71.4647	3.97	16
12988	51.2658	71.4676	7.43	16
12989	51.2622	71.4647	18.28	16
12990	51.2586	71.456	17.45	16
12991	51.2604	71.4415	7.21	16
12992	51.2604	71.4386	8.44	16
12993	51.1434	71.6358	2.39	14
12994	51.1416	71.6358	13.67	14
12995	51.048	71.4792	1.73	13
12996	51.12	71.4995	1714.64	17
12997	51.1164	71.5227	624.96	17
12998	51.1398	71.5633	6.71	14
12999	51.1398	71.5662	99.55	14
13000	51.1434	71.5546	143.11	14
13001	51.1398	71.5372	113.23	14
13002	51.1272	71.4357	14.11	13
13003	51.1254	71.3806	1055.85	18
13004	51.1254	71.3951	1469.07	18
13005	51.1308	71.3835	361.67	18
13006	51.1326	71.3806	2360.88	18
13007	51.111	71.3922	466.58	18
13008	51.1092	71.4009	7.34	18
13009	51.2298	71.3719	12.65	16
13010	51.1812	71.5111	885.3	14
13011	51.1236	71.6068	10.14	17
13012	51.1218	71.5082	536.28	17
13013	51.1092	71.5082	1047.57	17
13014	51.1074	71.4995	28.05	17
13015	51.147	71.4183	9.16	18
13016	51.1848	71.5198	28.36	16
13017	51.1866	71.5285	151.17	16
13018	51.1866	71.5256	246	16
13019	51.1758	71.4908	898.69	16
13020	51.2046	71.4966	0.67	16
13021	51.2064	71.4966	55.27	16
13022	51.2028	71.485	24.36	16
13023	51.2028	71.4995	16	16
13024	51.1992	71.4937	28.75	16
13025	51.1974	71.4908	345.64	16
13026	51.1974	71.4879	91.29	16
13027	51.1992	71.4908	253.8	16
13028	51.1848	71.4734	22.36	16
13029	51.2154	71.398	34.92	16
13030	51.2172	71.398	13.79	16
13031	51.2262	71.369	89.54	16
13032	51.2208	71.3864	15.27	16
13033	51.2226	71.4009	7.02	16
13034	51.0606	71.4125	16.61	13
13035	51.0624	71.4154	11.64	13
13036	51.084	71.4386	62.74	13
13037	51.084	71.4328	1435.69	13
13038	51.0858	71.427	956.21	13
13039	51.084	71.427	1634.18	13
13040	51.0732	71.427	164.5	13
13041	51.246	71.369	162.08	16
13042	51.2532	71.3661	7.85	16
13043	51.2514	71.3574	25.8	16
13044	51.1668	71.3835	22.63	15
13045	51.1974	71.4444	6.7	16
13046	51.1722	71.3632	14.28	15
13047	51.1164	71.4328	4.44	13
13048	51.2478	71.3574	32.23	16
13049	51.246	71.3603	14.88	16
13050	51.246	71.3661	191.19	16
13051	51.2442	71.3661	12.43	16
13052	51.2424	71.3661	2.86	16
13053	51.2478	71.369	2.37	16
13054	51.246	71.3748	15.43	16
13055	51.2442	71.3748	6.41	16
13056	51.228	71.398	282.59	16
13057	51.2586	71.3806	8.73	16
13058	51.1218	71.3951	677.73	18
13059	51.21	71.3603	353.45	15
13060	51.2154	71.4183	15.2	16
13061	51.2154	71.4154	31.18	16
13062	51.2154	71.4125	79.91	16
13063	51.2154	71.4038	130.9	16
13064	51.219	71.3951	129.31	16
13065	51.1776	71.4357	262.57	16
13066	51.2676	71.3487	15.05	16
13067	51.2676	71.3458	7.52	16
13068	51.2604	71.3719	3.44	16
13069	51.0894	71.427	1515.43	13
13070	51.0426	71.4444	176.09	13
13071	51.0462	71.4444	122.06	13
13072	51.0462	71.4415	163.22	13
13073	51.0462	71.4473	11.4	13
13074	51.1182	71.5227	863.76	17
13075	51.12	71.5314	930.89	17
13076	51.1182	71.5401	27.36	17
13077	51.1398	71.3864	1345.73	18
13078	51.138	71.398	2.44	18
13079	51.1362	71.4038	440.21	18
13080	51.1416	71.3806	130.51	18
13081	51.1218	71.4995	1969.08	17
13082	51.1344	71.5314	199.47	17
13083	51.1182	71.5082	778.39	17
13084	51.12	71.5082	192.2	17
13085	51.1182	71.5256	1291.96	17
13086	51.2064	71.4821	282.04	16
13087	51.2208	71.4009	9.86	16
13088	51.2226	71.4096	103.84	16
13089	51.2028	71.4386	207.22	16
13090	51.228	71.3806	7.51	16
13091	51.2334	71.3777	61.73	16
13092	51.2334	71.369	51.14	16
13093	51.2352	71.369	224.35	16
13094	51.2244	71.3748	43.79	16
13095	51.2244	71.3777	55.45	16
13096	51.237	71.3835	5.38	16
13097	51.2478	71.3806	22.68	16
13098	51.2442	71.3719	464.88	16
13099	51.2388	71.369	5.24	16
13100	51.2388	71.3661	23.14	16
13101	51.2478	71.3661	2.88	16
13102	51.0246	71.3922	266.9	13
13103	51.0246	71.3951	295.94	13
13104	51.075	71.2414	14.28	18
13105	51.0624	71.4067	5.22	13
13106	51.0624	71.4096	9.93	13
13107	51.0624	71.4038	634.78	13
13108	51.0606	71.4038	153.55	13
13109	51.0624	71.4009	19.72	13
13110	51.0786	71.3806	24.88	18
13111	51.0822	71.3661	3.92	18
13112	51.0822	71.369	10.62	18
13113	51.0822	71.4096	484.82	13
13114	51.0822	71.4067	146.72	13
13115	51.0696	71.4212	21.48	13
13116	51.0768	71.4241	5.61	13
13117	51.0822	71.4328	36.34	13
13118	51.084	71.4299	177.05	13
13119	51.0858	71.4299	419.44	13
13120	51.084	71.4444	202.47	13
13121	51.0984	71.4415	546.32	13
13122	51.0948	71.4473	85.12	13
13123	51.0894	71.456	257.33	13
13124	51.0912	71.456	1214.72	13
13125	51.0966	71.4357	1190.18	13
13126	51.0966	71.4328	875.71	13
13127	51.0948	71.4502	850.97	13
13128	51.093	71.4589	138.15	13
13129	51.0912	71.4531	1284.52	13
13130	51.084	71.4212	689.18	13
13131	51.0984	71.4154	54.85	13
13132	51.0984	71.427	115.07	13
13133	51.102	71.4154	621.3	13
13134	51.1182	71.4125	80.09	13
13135	51.111	71.4125	112.52	13
13136	51.12	71.427	5.86	13
13137	51.183	71.3313	137.67	15
13138	51.2352	71.3661	5.15	16
13139	51.237	71.3661	2.81	16
13140	51.2118	71.3429	464.81	15
13141	51.2154	71.3371	370.79	15
13142	51.2136	71.34	465.16	15
13143	51.2154	71.3284	415.52	15
13144	51.1542	71.5662	142.68	14
13145	51.1182	71.4009	63.94	18
13146	51.1092	71.5401	1570.81	17
13147	51.1128	71.5372	722.51	17
13148	51.1218	71.427	796.83	13
13149	51.1164	71.3893	567.59	18
13150	51.1146	71.398	299.77	18
13151	51.1236	71.2704	320.01	18
13152	51.12	71.2588	216.78	18
13153	51.12	71.2559	125.3	18
13154	51.1182	71.2617	81.67	18
13155	51.1164	71.2617	8.51	18
13156	51.1164	71.253	131.74	18
13157	51.1254	71.2472	44.77	18
13158	51.1056	71.6909	4.01	17
13159	51.1038	71.6938	13.8	17
13160	51.102	71.6851	15.5	17
13161	51.1218	71.5865	65.4	17
13162	51.1236	71.5836	61.59	17
13163	51.1218	71.5836	70.14	17
13164	51.12	71.5836	65.58	17
13165	51.12	71.5865	114.95	17
13166	51.12	71.5894	19.07	17
13167	51.1182	71.5894	17.49	17
13168	51.1182	71.5865	29.07	17
13169	51.1182	71.5836	18.03	17
13170	51.1164	71.5749	40.91	17
13171	51.1182	71.5749	28.81	17
13172	51.2154	71.5285	5.14	16
13173	51.2154	71.5256	106.34	16
13174	51.1524	71.5662	80.05	14
13175	51.2064	71.4212	46.91	16
13176	51.2712	71.3313	53.89	16
13177	51.1182	71.514	612.54	17
13178	51.1164	71.5169	190.71	17
13179	51.1218	71.5024	1767.48	17
13180	51.1218	71.4966	508.18	17
13181	51.1128	71.5111	789.71	17
13182	51.1272	71.456	0.94	17
13183	51.2424	71.3777	119.16	16
13184	51.2406	71.3806	4.94	16
13185	51.2406	71.3777	167.09	16
13186	51.2064	71.4531	286.13	16
13187	51.1992	71.4676	259.79	16
13188	51.2064	71.4879	673.09	16
13189	51.2082	71.4879	88.13	16
13190	51.1398	71.369	1172.73	18
13191	51.138	71.3806	1651.36	18
13192	51.1596	71.3719	20.64	18
13193	51.138	71.3864	921.24	18
13194	51.1452	71.3835	422.48	18
13195	51.0876	71.4502	607.97	13
13196	51.0876	71.4531	249.52	13
13197	51.1308	71.3777	1364.16	18
13198	51.0876	71.427	662.84	13
13199	51.0876	71.4299	2197.63	13
13200	51.0768	71.427	200.34	13
13201	51.075	71.4212	1074.1	13
13202	51.1326	71.4618	283.15	14
13203	51.102	71.4299	126.34	13
13204	51.1056	71.4328	836.7	13
13205	51.1056	71.427	582.51	13
13206	51.1128	71.4154	59.19	13
13207	51.111	71.4154	277.73	13
13208	51.102	71.4241	1087.5	13
13209	51.039	71.4328	21.12	13
13210	51.0426	71.427	468.74	13
13211	51.039	71.4212	1078.45	13
13212	51.1128	71.4647	798.11	17
13213	51.1164	71.4589	126.62	17
13214	51.1038	71.4531	345.97	13
13215	51.0966	71.4386	702.02	13
13216	51.1074	71.4473	732.6	13
13217	51.129	71.3632	133.65	18
13218	51.1272	71.3632	1768.25	18
13219	51.1362	71.3719	1916.08	18
13220	51.1434	71.369	98.78	18
13221	51.1416	71.3632	600.55	18
13222	51.1398	71.3632	330.65	18
13223	51.1434	71.3661	931.55	18
13224	51.1434	71.3603	1268.85	18
13225	51.1308	71.3806	1355.05	18
13226	51.075	71.3893	625.85	18
13227	51.0966	71.3922	672.27	18
13228	51.102	71.3951	299.24	18
13229	51.0984	71.3922	847.06	18
13230	51.1002	71.4038	2468.72	18
13231	51.0984	71.4386	329.35	13
13232	51.138	71.3835	2064.02	18
13233	51.1542	71.4125	102.88	18
13234	51.1128	71.4618	718.61	17
13235	51.1092	71.4734	494.41	17
13236	51.1236	71.3951	489.41	18
13237	51.1182	71.3922	333.81	18
13238	51.1146	71.3893	826.57	18
13239	51.1146	71.3951	1158.65	18
13240	51.111	71.4038	2615.33	18
13241	51.111	71.4009	1999.31	18
13242	51.1002	71.398	1217.86	18
13243	51.1002	71.4009	2743.61	18
13244	51.1002	71.4067	3155.09	13
13245	51.1038	71.3951	1834.82	18
13246	51.102	71.4067	1394.03	18
13247	51.1236	71.4879	990.65	17
13248	51.1254	71.4879	6.4	17
13249	51.129	71.5053	239.58	17
13250	51.1182	71.5024	810.98	17
13251	51.12	71.4792	786.34	17
13252	51.1164	71.4821	1586.5	17
13253	51.129	71.4734	236.08	14
13254	51.1362	71.5285	10.19	17
13255	51.138	71.5314	620.65	14
13256	51.1182	71.5285	280.91	17
13257	51.1074	71.5401	369.87	17
13258	51.1164	71.5372	985.24	17
13259	51.1218	71.5372	170.68	17
13260	51.1398	71.4125	230.05	18
13261	51.1434	71.3719	181.62	18
13262	51.156	71.3748	335.34	18
13263	51.1578	71.3748	194.33	18
13264	51.1506	71.3719	183.94	18
13265	51.1524	71.3748	82.65	18
13266	51.156	71.398	1.86	18
13267	51.1416	71.369	1879.75	18
13268	51.1398	71.3835	1405.79	18
13269	51.1434	71.3806	892.8	18
13270	51.1398	71.4647	129.08	14
13271	51.1398	71.4589	620.7	14
13272	51.1146	71.543	547.13	17
13273	51.1236	71.5372	82.73	17
13274	51.1218	71.5343	171.94	17
13275	51.1218	71.5314	147.72	17
13276	51.129	71.5546	888.57	17
13277	51.1632	71.4038	609.23	15
13278	51.1236	71.3748	466.39	18
13279	51.1236	71.3777	1011.62	18
13280	51.12	71.3777	630.84	18
13281	51.102	71.3922	1186.08	18
13282	51.1038	71.3835	865.54	18
13283	51.1326	71.3719	392.07	18
13284	51.1452	71.4908	0.79	14
13285	51.1524	71.543	10.25	14
13286	51.1398	71.5343	17.19	14
13287	51.156	71.5256	89.62	14
13288	51.1542	71.5401	161.28	14
13289	51.1614	71.5053	72.28	14
13290	51.1686	71.4995	1381.71	14
13291	51.1992	71.3777	69.56	15
13292	51.2082	71.3516	10.12	15
13293	51.2046	71.3429	192.28	15
13294	51.2082	71.3487	170.1	15
13295	51.1956	71.3197	6.68	15
13296	51.1884	71.3255	207.85	15
13297	51.1776	71.3458	111.86	15
13298	51.174	71.3545	441.19	15
13299	51.1776	71.3516	3.79	15
13300	51.1902	71.3168	6.53	15
13301	51.2118	71.34	39.63	15
13302	51.2136	71.3429	742.73	15
13303	51.2118	71.3458	450.49	15
13304	51.192	71.4879	76.88	16
13305	51.1974	71.4821	71.75	16
13306	51.1956	71.5169	134.72	16
13307	51.183	71.5314	6.71	16
13308	51.1812	71.5314	6.46	16
13309	51.1794	71.5256	11.75	16
13310	51.1794	71.5285	120.18	16
13311	51.1758	71.5314	14.89	14
13312	51.1776	71.5314	64.12	14
13313	51.1758	71.5343	295.94	14
13314	51.1686	71.5314	858.85	14
13315	51.1686	71.5343	176.9	14
13316	51.1668	71.5343	4.36	14
13317	51.1668	71.543	4.3	14
13318	51.165	71.543	106.57	14
13319	51.1704	71.5343	595.34	14
13320	51.1704	71.5372	125.42	14
13321	51.1722	71.5343	228.1	14
13322	51.1704	71.5314	416.05	14
13323	51.1704	71.5169	303.45	14
13324	51.174	71.5169	494.87	14
13325	51.1722	71.5082	15.28	14
13326	51.1686	71.5169	7.67	14
13327	51.1668	71.514	29.86	14
13328	51.1668	71.5227	136.62	14
13329	51.1614	71.5227	441.92	14
13330	51.1812	71.4995	66.57	16
13331	51.1902	71.4676	135.29	16
13332	51.1884	71.4995	69.58	16
13333	51.1956	71.5024	164.21	16
13334	51.1938	71.5024	12.67	16
13335	51.2082	71.4937	9.95	16
13336	51.1542	71.572	8.73	14
13337	51.1938	71.5169	54.64	16
13338	51.1866	71.5227	23.04	16
13339	51.1884	71.5256	16.5	16
13340	51.1902	71.514	49.54	16
13341	51.1308	71.5981	214.81	14
13342	51.12	71.601	24.28	17
13343	51.1092	71.572	72.77	17
13344	51.1092	71.5749	21.08	17
13345	51.1236	71.5894	38.37	17
13346	51.1236	71.6039	7.45	17
13347	51.0984	71.4676	126.05	13
13348	51.1668	71.3603	67.36	15
13349	51.1758	71.3313	13.63	15
13350	51.1416	71.5546	237.55	14
13351	51.2316	71.2501	7.69	15
13352	51.1236	71.2878	290.94	18
13353	51.1218	71.2878	246.86	18
13354	51.129	71.5952	48.05	17
13355	51.12	71.4589	1958.7	17
13356	51.1272	71.4212	1346.35	13
13357	51.1002	71.4154	341.66	13
13358	51.1272	71.4618	2263.08	17
13359	51.1146	71.4415	1288.85	13
13360	51.0462	71.4096	19.12	13
13361	51.0462	71.4125	46.64	13
13362	51.0444	71.4154	78.64	13
13363	51.0444	71.4125	2.8	13
13364	51.0552	71.4096	44.65	13
13365	51.0552	71.4125	80.72	13
13366	51.057	71.4125	60.85	13
13367	51.057	71.4096	58.33	13
13368	51.0588	71.4096	35.47	13
13369	51.0534	71.4096	37.36	13
13370	51.0534	71.4125	56.68	13
13371	51.0552	71.4154	70.87	13
13372	51.0516	71.4125	85.01	13
13373	51.0534	71.4154	80.78	13
13374	51.0516	71.4096	54.67	13
13375	51.048	71.4096	31.31	13
13376	51.0498	71.4154	67.07	13
13377	51.0498	71.4125	56.86	13
13378	51.048	71.4154	50.47	13
13379	51.0462	71.4154	38.53	13
13380	51.048	71.4183	73.84	13
13381	51.0426	71.4183	27.19	13
13382	51.0444	71.4183	90.51	13
13383	51.0498	71.4096	58.23	13
13384	51.048	71.4125	66.92	13
13385	51.0498	71.4067	1.81	13
13386	51.048	71.4067	1.53	13
13387	51.0462	71.4183	77.8	13
13388	51.0534	71.4183	69.57	13
13389	51.0498	71.4212	72.55	13
13390	51.0498	71.4183	63.58	13
13391	51.0516	71.4212	53.96	13
13392	51.0516	71.4183	76.14	13
13393	51.0516	71.4154	77.31	13
13394	51.048	71.4212	91.76	13
13395	51.0498	71.4241	99.68	13
13396	51.048	71.4241	108.28	13
13397	51.048	71.427	113.95	13
13398	51.0498	71.427	57.39	13
13399	51.048	71.4299	66.96	13
13400	51.0516	71.4241	47.74	13
13401	51.0534	71.4241	5.33	13
13402	51.0534	71.4212	57.98	13
13403	51.0552	71.4183	72.08	13
13404	51.057	71.4183	2.53	13
13405	51.057	71.4154	30.62	13
13406	51.0588	71.4125	30.52	13
13407	51.0462	71.4299	50.22	13
13408	51.0804	71.3951	664.16	18
13409	51.0822	71.3951	21.16	18
13410	51.0804	71.398	12.32	18
13411	51.0822	71.3893	1.35	18
13412	51.0804	71.3922	4.14	18
13413	51.0822	71.3922	23.31	18
13414	51.0822	71.398	3.71	18
13415	51.084	71.3951	15.16	18
13416	51.147	71.3458	219.87	18
13417	51.1488	71.3545	29.86	18
13418	51.147	71.3545	412.14	18
13419	51.147	71.3574	332.14	18
13420	51.1488	71.3574	903.91	18
13421	51.156	71.3603	40.33	18
13422	51.1578	71.3806	17.76	18
13423	51.1578	71.3835	53.28	18
13424	51.1596	71.3835	55.36	18
13425	51.1596	71.3806	56.24	18
13426	51.1614	71.3806	20.72	18
13427	51.1614	71.3835	61.07	18
13428	51.1596	71.3864	35.99	18
13429	51.1578	71.3864	38.48	18
13430	51.1614	71.3951	35.44	18
13431	51.1614	71.3922	66.71	18
13432	51.1632	71.3922	2.62	15
13433	51.1596	71.3893	31.27	18
13434	51.1614	71.3893	54.21	18
13435	51.1614	71.3864	70.89	18
13436	51.1632	71.3864	18.76	18
13437	51.1632	71.3893	14.59	18
13438	51.1632	71.3835	2.96	18
13439	51.156	71.3835	44.41	18
13440	51.1542	71.3806	23.68	18
13441	51.156	71.3806	23.69	18
13442	51.0912	71.4009	7.28	18
13443	51.0912	71.398	9.21	18
13444	51.0912	71.4705	70.76	13
13445	51.093	71.4705	162.66	13
13446	51.093	71.4676	207.77	13
13447	51.0912	71.4676	41.44	13
13448	51.0948	71.4705	132.49	13
13449	51.1092	71.4038	342.87	18
13450	51.0858	71.4212	623.56	13
13451	51.1164	71.4009	293.59	18
13452	51.0786	71.3835	390.06	18
13453	51.2244	71.3719	23.87	16
13454	51.0516	71.4502	2.62	13
13455	51.0516	71.4473	99.93	13
13456	51.0534	71.4473	139.48	13
13457	51.0516	71.4444	85.51	13
13458	51.1614	71.5633	351.66	14
13459	51.1614	71.5604	68.41	14
13460	51.1596	71.5633	346.59	14
13461	51.1614	71.5662	799.71	14
13462	51.1686	71.5517	149.68	14
13463	51.1722	71.5488	235.91	14
13464	51.1722	71.5459	205.19	14
13465	51.1758	71.5459	300.03	14
13466	51.1164	71.6271	1.42	17
13467	51.1326	71.398	1054.13	18
13468	51.111	71.5024	1017.96	17
13469	51.111	71.5082	225.58	17
13470	51.1164	71.485	546.22	17
13471	51.1146	71.485	427.4	17
13472	51.1146	71.4879	670.66	17
13473	51.1362	71.3835	674.85	18
13474	51.1128	71.3922	397.99	18
13475	51.1128	71.3951	622.06	18
13476	51.1146	71.3922	844.83	18
13477	51.111	71.3951	643.86	18
13478	51.1272	71.4763	9.13	14
13479	51.12	71.485	638.11	17
13480	51.12	71.4821	653.03	17
13481	51.1218	71.4821	353.69	17
13482	51.1038	71.4879	136.29	17
13483	51.1164	71.514	162.68	17
13484	51.1146	71.5053	68.14	17
13485	51.1128	71.5053	616.69	17
13486	51.0876	71.4241	173.57	13
13487	51.0822	71.4386	512.04	13
13488	51.0822	71.4357	82.97	13
13489	51.0858	71.4241	781.51	13
13490	51.084	71.4241	1708.23	13
13491	51.0858	71.4502	150.35	13
13492	51.0858	71.4473	340.88	13
13493	51.0786	71.4212	963.36	13
13494	51.057	71.4299	148.64	13
13495	51.057	71.4328	113.62	13
13496	51.0588	71.4328	133.99	13
13497	51.0696	71.4183	667.79	13
13498	51.075	71.4241	467.01	13
13499	51.075	71.427	164.51	13
13500	51.075	71.4357	210.2	13
13501	51.075	71.4415	214.74	13
13502	51.0732	71.4386	3.43	13
13503	51.0696	71.4386	38.63	13
13504	51.0714	71.4386	99.79	13
13505	51.0804	71.4444	391.84	13
13506	51.0786	71.398	202.14	18
13507	51.0768	71.398	417.91	18
13508	51.0498	71.4357	286.92	13
13509	51.0354	71.4154	948.26	13
13510	51.1452	71.4444	190.63	14
13511	51.1128	71.4734	135.55	17
13512	51.0984	71.4502	2410.16	13
13513	51.0966	71.4502	651.68	13
13514	51.1056	71.4473	1568.83	13
13515	51.1038	71.3922	1.23	18
13516	51.1146	71.3864	80.62	18
13517	51.129	71.4096	9.4	18
13518	51.1236	71.4154	1122.69	13
13519	51.1254	71.398	353.48	18
13520	51.1236	71.4009	655.08	18
13521	51.1182	71.4067	284.72	18
13522	51.1002	71.2269	2.43	18
13523	51.1524	71.456	1.02	14
13524	51.1416	71.456	498.25	14
13525	51.0948	71.4009	5.47	18
13526	51.0732	71.4328	425.12	13
13527	51.0714	71.4357	116.61	13
13528	51.0732	71.4357	55.44	13
13529	51.0858	71.4096	35.58	13
13530	51.0858	71.4125	88.36	13
13531	51.12	71.4415	110.79	13
13532	51.0876	71.4908	473.89	13
13533	51.0948	71.4647	8.03	13
13534	51.0948	71.4676	18.24	13
13535	51.0912	71.4734	447.29	13
13536	51.0894	71.4734	6.14	13
13537	51.1002	71.4966	166.49	13
13538	51.1074	71.4966	39.19	17
13539	51.1056	71.4937	32.13	17
13540	51.0894	71.4821	146.82	13
13541	51.0912	71.4589	71.66	13
13542	51.0948	71.4618	49.45	13
13543	51.093	71.4618	8.64	13
13544	51.12	71.5024	694.71	17
13545	51.1164	71.5285	257.27	17
13546	51.1092	71.5343	361.49	17
13547	51.1074	71.5343	363.76	17
13548	51.1092	71.5372	206.02	17
13549	51.1128	71.5227	1688	17
13550	51.0462	71.4908	486.13	13
13551	51.0462	71.485	2.53	13
13552	51.0444	71.4879	9.91	13
13553	51.0444	71.4908	1.89	13
13554	51.0462	71.4879	410.29	13
13555	51.1722	71.3545	433.2	15
13556	51.129	71.3719	1150.33	18
13557	51.1506	71.3574	155.45	18
13558	51.1506	71.3545	23.04	18
13559	51.1452	71.3516	643.4	18
13560	51.1452	71.3487	819.43	18
13561	51.1416	71.3661	1009.64	18
13562	51.138	71.369	1089.26	18
13563	51.1524	71.3632	74.3	18
13564	51.1488	71.3516	98.65	18
13565	51.1344	71.3603	2.68	18
13566	51.138	71.3632	78.49	18
13567	51.1542	71.3719	5.28	18
13568	51.1488	71.3458	44.75	18
13569	51.1326	71.3951	2086.66	18
13570	51.1272	71.3951	725.26	18
13571	51.1254	71.4009	783.71	18
13572	51.1146	71.4009	577.81	18
13573	51.111	71.5372	200.27	17
13574	51.1128	71.5169	1091.85	17
13575	51.1218	71.3777	916.24	18
13576	51.0498	71.3864	7.02	18
13577	51.0534	71.3893	8.58	18
13578	51.0678	71.3922	5.49	18
13579	51.0642	71.3893	11.32	18
13580	51.0624	71.3893	3.9	18
13581	51.0624	71.3864	181.35	18
13582	51.066	71.3719	114.54	18
13583	51.0714	71.3922	4.18	18
13584	51.0732	71.3922	335.41	18
13585	51.0426	71.4125	1.98	13
13586	51.0426	71.4154	15.24	13
13587	51.0552	71.4299	116.61	13
13588	51.0552	71.4328	44.83	13
13589	51.0552	71.427	401.84	13
13590	51.0516	71.427	4.48	13
13591	51.1074	71.5285	718.36	17
13592	51.1146	71.5256	699.68	17
13593	51.1182	71.5111	1472.58	17
13594	51.1218	71.5111	1215.42	17
13595	51.1884	71.3458	12.63	15
13596	51.201	71.3487	585.48	15
13597	51.2028	71.3284	340.49	15
13598	51.1938	71.3748	108.4	15
13599	51.1974	71.3806	96.81	15
13600	51.1938	71.3603	10.06	15
13601	51.2118	71.3516	303.12	15
13602	51.2136	71.3487	415.41	15
13603	51.2226	71.3255	753.65	15
13604	51.2226	71.3371	11.54	15
13605	51.201	71.3777	35.04	15
13606	51.183	71.4009	291.03	15
13607	51.1776	71.3951	311.39	15
13608	51.1776	71.3922	15.59	15
13609	51.165	71.4009	224.24	15
13610	51.1722	71.3922	66.04	15
13611	51.1416	71.4647	8.08	14
13612	51.156	71.4676	285.54	14
13613	51.1344	71.4415	4.27	13
13614	51.1344	71.4386	1.89	13
13615	51.1182	71.4531	1.2	17
13616	51.1128	71.4879	1095.36	17
13617	51.1128	71.4908	741.61	17
13618	51.1128	71.4937	424.48	17
13619	51.111	71.4937	1045.81	17
13620	51.1146	71.5024	7.82	17
13621	51.1146	71.5111	495.38	17
13622	51.1164	71.5082	307.2	17
13623	51.1128	71.514	1207.51	17
13624	51.0768	71.3893	276.79	18
13625	51.0804	71.3893	268.66	18
13626	51.1038	71.398	1536.94	18
13627	51.1272	71.4154	1.73	13
13628	51.1362	71.4154	0.94	18
13629	51.1326	71.4212	27.86	13
13630	51.1326	71.4241	77.81	13
13631	51.1344	71.4241	77.79	13
13632	51.1308	71.4299	8.89	13
13633	51.0984	71.4067	674.33	13
13634	51.1002	71.4096	348.62	13
13635	51.147	71.3429	116.07	18
13636	51.1452	71.3429	89	18
13637	51.1362	71.3139	9.91	18
13638	51.1362	71.398	1858.79	18
13639	51.1362	71.4009	620.44	18
13640	51.1398	71.3777	772.14	18
13641	51.1362	71.3864	2039.84	18
13642	51.138	71.3777	567.54	18
13643	51.1344	71.3835	646.88	18
13644	51.1344	71.3806	2401.66	18
13645	51.1326	71.369	2200.35	18
13646	51.1398	71.3661	684.04	18
13647	51.138	71.3661	1088.14	18
13648	51.1254	71.3748	590.59	18
13649	51.1254	71.3922	215.61	18
13650	51.1182	71.3893	445.92	18
13651	51.1056	71.3922	1379.53	18
13652	51.1398	71.3748	907.64	18
13653	51.1344	71.3719	928.39	18
13654	51.1506	71.369	10.24	18
13655	51.1614	71.3748	13.29	18
13656	51.1596	71.3748	687.49	18
13657	51.1542	71.4212	12.85	18
13658	51.156	71.4212	3.13	18
13659	51.156	71.4183	9.68	18
13660	51.147	71.4415	251.81	14
13661	51.0822	71.4415	1006.47	13
13662	51.0714	71.4328	4.15	13
13663	51.0822	71.4038	176.01	13
13664	51.0858	71.4038	919.01	13
13665	51.1254	71.4038	279.31	18
13666	51.12	71.3922	469.74	18
13667	51.1056	71.4009	1217.12	18
13668	51.1074	71.4009	188	18
13669	51.1344	71.398	1416.7	18
13670	51.1326	71.3922	200.7	18
13671	51.1794	71.2849	0.7	18
13672	51.2064	71.3168	78.84	15
13673	51.0912	71.4763	29.25	13
13674	51.0912	71.4792	27.27	13
13675	51.0876	71.4792	303.88	13
13676	51.0876	71.4821	602.15	13
13677	51.0894	71.4705	79.76	13
13678	51.1002	71.4763	163.36	13
13679	51.093	71.456	178.57	13
13680	51.0948	71.456	175.14	13
13681	51.0966	71.456	79.86	13
13682	51.0984	71.456	1017.08	13
13683	51.1074	71.4328	752.67	13
13684	51.156	71.3951	7.4	18
13685	51.1326	71.4328	220.78	13
13686	51.156	71.4618	0.88	14
13687	51.12	71.4618	7.72	17
13688	51.1218	71.4589	10.33	17
13689	51.1236	71.4937	348.18	17
13690	51.12	71.5111	355.05	17
13691	51.1434	71.4589	1243.26	14
13692	51.1488	71.5372	98.21	14
13693	51.1488	71.5343	171.54	14
13694	51.1326	71.543	701.1	17
13695	51.1398	71.5401	185.74	14
13696	51.1128	71.5401	505.91	17
13697	51.111	71.4821	45.75	17
13698	51.1164	71.4618	15.86	17
13699	51.1164	71.4676	82.96	17
13700	51.1146	71.4705	336.67	17
13701	51.1146	71.5082	27.7	17
13702	51.1128	71.5082	57.03	17
13703	51.0228	71.3922	2.37	13
13704	51.0516	71.4357	131.07	13
13705	51.0606	71.4154	6.62	13
13706	51.0462	71.4328	169.98	13
13707	51.0552	71.4212	5.69	13
13708	51.0588	71.4154	2.61	13
13709	51.0606	71.4096	1.35	13
13710	51.0426	71.4821	81.35	13
13711	51.0138	71.4444	11.07	13
13712	51.0156	71.4444	1.08	13
13713	51.0192	71.4473	82.74	13
13714	51.021	71.4502	868.28	13
13715	51.138	71.4444	2.83	14
13716	51.1236	71.2443	134.76	18
13717	51.129	71.2559	122.18	18
13718	51.1254	71.2559	248.82	18
13719	51.1254	71.2588	152.22	18
13720	51.1236	71.2559	319.42	18
13721	51.12	71.2617	335.24	18
13722	51.1236	71.2646	177.7	18
13723	51.1236	71.2617	306.9	18
13724	51.1218	71.2617	293.83	18
13725	51.1218	71.2646	193.4	18
13726	51.1344	71.2704	11.32	18
13727	51.129	71.2965	1.68	18
13728	51.1326	71.2791	64.34	18
13729	51.1344	71.311	179	18
13730	51.1326	71.311	262.55	18
13731	51.1272	71.2994	8.88	18
13732	51.1254	71.2907	71.18	18
13733	51.1272	71.2936	155.67	18
13734	51.1254	71.2936	392.76	18
13735	51.1308	71.3081	10.97	18
13736	51.1362	71.3023	2.13	18
13737	51.1362	71.2994	14.45	18
13738	51.1308	71.2907	271.6	18
13739	51.1344	71.2994	86.81	18
13740	51.1092	71.688	2.24	17
13741	51.1092	71.6851	2.24	17
13742	51.1128	71.7054	6.46	17
13743	51.111	71.7054	2.15	17
13744	51.111	71.7083	6.46	17
13745	51.1128	71.7083	17.22	17
13746	51.111	71.7112	10.76	17
13747	51.1254	71.7112	5.66	14
13748	51.1614	71.5024	99.02	14
13749	51.111	71.572	9.55	17
13750	51.111	71.5749	246.06	17
13751	51.111	71.5778	31.77	17
13752	51.1236	71.6097	1.87	17
13753	51.1326	71.5952	45.59	14
13754	51.138	71.5691	1.6	14
13755	51.1434	71.5575	373.57	14
13756	51.1398	71.5691	2.22	14
13757	51.1506	71.572	285.06	14
13758	51.1488	71.572	6.92	14
13759	51.1506	71.5749	14.65	14
13760	51.1488	71.5807	19.82	14
13761	51.1452	71.5836	203.75	14
13762	51.1398	71.5836	1.19	14
13763	51.1578	71.5459	7.34	14
13764	51.156	71.543	7.46	14
13765	51.156	71.5488	11.37	14
13766	51.156	71.5459	7.43	14
13767	51.1506	71.5459	10.09	14
13768	51.1902	71.5401	7.44	16
13769	51.1758	71.5256	1.56	14
13770	51.1686	71.5401	625.31	14
13771	51.1722	71.5372	192.2	14
13772	51.165	71.5488	73.99	14
13773	51.1632	71.5488	92.32	14
13774	51.1668	71.5488	118.02	14
13775	51.1686	71.5459	19.53	14
13776	51.1686	71.5488	114.86	14
13777	51.1758	71.543	84.81	14
13778	51.1794	71.5314	90.38	14
13779	51.174	71.5314	161.58	14
13780	51.1776	71.5285	1.56	14
13781	51.1812	71.5227	81.85	16
13782	51.1812	71.5256	4.41	16
13783	51.183	71.5285	22.91	16
13784	51.1992	71.5053	1.19	16
13785	51.1974	71.5053	2.37	16
13786	51.1974	71.5082	4.74	16
13787	51.183	71.5256	7.26	16
13788	51.1848	71.5256	84.63	16
13789	51.1866	71.5198	3.36	16
13790	51.1848	71.5314	64.47	16
13791	51.1884	71.5227	110.24	16
13792	51.1902	71.5256	8.53	16
13793	51.1902	71.5227	78.72	16
13794	51.1884	71.5198	5.59	16
13795	51.192	71.5227	5.96	16
13796	51.1956	71.5111	3.59	16
13797	51.1938	71.5111	94.28	16
13798	51.192	71.5111	1.61	16
13799	51.192	71.5082	15.18	16
13800	51.1956	71.4908	12.8	16
13801	51.1956	71.4879	12.49	16
13802	51.2028	71.4792	48.33	16
13803	51.1992	71.4821	2.59	16
13804	51.1992	71.4792	66.39	16
13805	51.1938	71.4966	14.89	16
13806	51.1938	71.4937	6.14	16
13807	51.1992	71.4995	80.02	16
13808	51.2082	71.485	43.54	16
13809	51.2028	71.4966	61.86	16
13810	51.2064	71.4995	6.49	16
13811	51.21	71.4995	4.5	16
13812	51.2118	71.5024	88.61	16
13813	51.219	71.5053	431.52	16
13814	51.219	71.5024	8.68	16
13815	51.2172	71.5053	1.53	16
13816	51.2172	71.5024	0.72	16
13817	51.2172	71.514	0.72	16
13818	51.2172	71.5111	404.23	16
13819	51.2154	71.5053	306.36	16
13820	51.2154	71.5082	0.72	16
13821	51.2118	71.5111	62.9	16
13822	51.21	71.5082	3.76	16
13823	51.2118	71.514	7.31	16
13824	51.2172	71.5256	71.88	16
13825	51.2154	71.5227	4.06	16
13826	51.2226	71.5256	208.68	16
13827	51.1236	71.5778	45.7	17
13828	51.1146	71.5749	70.57	17
13829	51.1146	71.5778	43.69	17
13830	51.1254	71.5836	26.34	17
13831	51.1146	71.572	17.72	17
13832	51.1128	71.5662	3.12	17
13833	51.1074	71.5633	8.82	17
13834	51.1308	71.5546	307.05	17
13835	51.1308	71.5575	377.13	17
13836	51.1308	71.5604	145.03	17
13837	51.1272	71.5575	146.71	17
13838	51.129	71.5575	272.69	17
13839	51.1272	71.5546	5.74	17
13840	51.1254	71.5517	7.68	17
13841	51.1218	71.6329	2.86	17
13842	51.1182	71.6503	8.9	17
13843	51.1488	71.5488	215.62	14
13844	51.147	71.5488	158.78	14
13845	51.0966	71.3893	859.43	18
13846	51.0984	71.3893	2418.94	18
13847	51.0804	71.4212	41.48	13
13848	51.084	71.4154	83.94	13
13849	51.0678	71.4183	515.68	13
13850	51.0642	71.4009	3.35	13
13851	51.0642	71.4038	4.2	13
13852	51.084	71.398	2.89	18
13853	51.0822	71.3835	428.71	18
13854	51.0822	71.3806	491.37	18
13855	51.084	71.3806	76.89	18
13856	51.0786	71.3777	4.63	18
13857	51.0624	71.3922	21.17	18
13858	51.0606	71.3893	5.11	18
13859	51.0588	71.3864	960.44	18
13860	51.084	71.4705	429.93	13
13861	51.084	71.4676	1141.14	13
13862	51.0768	71.4792	7.39	13
13863	51.0768	71.4821	2.64	13
13864	51.0768	71.4734	2.64	13
13865	51.0768	71.4763	5.1	13
13866	51.0786	71.4763	7.91	13
13867	51.0786	71.4734	5.1	13
13868	51.0732	71.4763	4.93	13
13869	51.075	71.4792	12.32	13
13870	51.075	71.4763	14.79	13
13871	51.075	71.4734	7.7	13
13872	51.0732	71.4734	5.13	13
13873	51.075	71.4676	122.08	13
13874	51.0768	71.4676	31.13	13
13875	51.0768	71.4647	2.83	13
13876	51.075	71.4647	14.15	13
13877	51.0786	71.4937	365.17	13
13878	51.0768	71.4937	1078.44	13
13879	51.075	71.4908	505.72	13
13880	51.0768	71.4908	716.37	13
13881	51.1092	71.4908	73.39	17
13882	51.1074	71.4908	80.15	17
13883	51.1092	71.4937	70.63	17
13884	51.1074	71.4879	44.14	17
13885	51.1092	71.4879	38.81	17
13886	51.111	71.4908	27.3	17
13887	51.1074	71.485	63.58	17
13888	51.1056	71.485	20.83	17
13889	51.1092	71.485	66.68	17
13890	51.111	71.4879	335.5	17
13891	51.111	71.485	48.28	17
13892	51.1074	71.4821	18.64	17
13893	51.1128	71.485	4.38	17
13894	51.1092	71.4821	39.02	17
13895	51.111	71.4792	96.69	17
13896	51.1092	71.4792	51.38	17
13897	51.1092	71.4763	9.79	17
13898	51.111	71.4763	135.13	17
13899	51.1128	71.4792	10.59	17
13900	51.111	71.4734	49.19	17
13901	51.1128	71.4676	82.08	17
13902	51.1092	71.4676	62.42	17
13903	51.111	71.4647	71.58	17
13904	51.1236	71.5981	68.88	17
13905	51.2172	71.3864	28.74	16
13906	51.219	71.3806	18.11	16
13907	51.2208	71.3806	59.55	16
13908	51.2226	71.3806	6.6	16
13909	51.219	71.3748	112.15	16
13910	51.219	71.3864	40.91	16
13911	51.219	71.3893	20.56	16
13912	51.2244	71.3893	75.33	16
13913	51.2262	71.4067	3.26	16
13914	51.2208	71.3951	79.34	16
13915	51.2226	71.398	92.99	16
13916	51.2208	71.398	13.38	16
13917	51.2208	71.4038	57.74	16
13918	51.2262	71.4038	8.12	16
13919	51.228	71.4009	44.63	16
13920	51.2298	71.3864	29.16	16
13921	51.2316	71.3864	102.76	16
13922	51.2298	71.3893	125.01	16
13923	51.2352	71.3777	67.17	16
13924	51.2352	71.3748	11.36	16
13925	51.2334	71.3806	5.57	16
13926	51.2334	71.3748	2.1	16
13927	51.2334	71.3719	298.46	16
13928	51.2388	71.3632	1.56	16
13929	51.2442	71.369	3.19	16
13930	51.2514	71.3661	17.34	16
13931	51.246	71.3719	84.51	16
13932	51.2478	71.3835	6.25	16
13933	51.2496	71.3864	5.13	16
13934	51.2514	71.3864	5.13	16
13935	51.2424	71.2675	12.18	15
13936	51.2424	71.2646	44.19	15
13937	51.2442	71.2588	35.42	15
13938	51.2136	71.4038	78.13	16
13939	51.2172	71.4038	305.04	16
13940	51.1992	71.4357	284.16	16
13941	51.2118	71.3951	60.7	16
13942	51.1542	71.3661	24.86	18
13943	51.1524	71.369	17.08	18
13944	51.1524	71.3661	50.42	18
13945	51.1506	71.3661	33.61	18
13946	51.1542	71.369	50.56	18
13947	51.156	71.369	401.57	18
13948	51.156	71.3661	27.94	18
13949	51.156	71.3632	21.62	18
13950	51.1578	71.3719	5.6	18
13951	51.1578	71.369	27.07	18
13952	51.1578	71.3661	22.16	18
13953	51.1596	71.369	19.23	18
13954	51.1614	71.3719	0.83	18
13955	51.1614	71.369	12.73	18
13956	51.1542	71.3603	270.91	18
13957	51.1524	71.3574	65.12	18
13958	51.1524	71.3603	15.08	18
13959	51.1542	71.3574	42.52	18
13960	51.156	71.3574	31.55	18
13961	51.1542	71.3545	2.69	18
13962	51.156	71.3545	22.46	18
13963	51.1524	71.3545	13.26	18
13964	51.1524	71.3516	2.21	18
13965	51.1578	71.3545	13.71	18
13966	51.1578	71.3632	20.37	18
13967	51.1596	71.3661	16.96	18
13968	51.1614	71.3661	41.02	18
13969	51.1632	71.3661	20.51	18
13970	51.1614	71.3632	18.44	18
13971	51.1614	71.3603	27.76	18
13972	51.1632	71.3632	13.51	18
13973	51.1632	71.3603	20.24	18
13974	51.1632	71.3574	23	18
13975	51.1614	71.3574	14.44	18
13976	51.1578	71.3574	20.83	18
13977	51.1596	71.3574	18.73	18
13978	51.1596	71.3603	12.06	18
13979	51.156	71.3516	316.8	18
13980	51.1596	71.3545	24.72	18
13981	51.1614	71.3545	24.39	18
13982	51.1632	71.3545	28.56	18
13983	51.1632	71.3516	2.54	18
13984	51.1614	71.3516	11.75	18
13985	51.1704	71.3661	18.66	15
13986	51.1668	71.3632	23.31	15
13987	51.1668	71.3661	2.91	15
13988	51.1686	71.3661	14.57	15
13989	51.1686	71.3632	55.37	15
13990	51.1686	71.3603	119.48	15
13991	51.1704	71.3632	17.48	15
13992	51.165	71.3516	4.89	18
13993	51.1668	71.3487	20.4	18
13994	51.1686	71.3458	58.27	18
13995	51.1668	71.3458	15.68	18
13996	51.165	71.3458	5.22	18
13997	51.1704	71.3487	2.35	15
13998	51.1704	71.3458	88.16	18
13999	51.1686	71.3429	22.43	18
14000	51.1704	71.3429	100.07	18
14001	51.1704	71.34	12.69	18
14002	51.1722	71.3429	67.84	18
14003	51.1902	71.3139	9.66	15
14004	51.2136	71.3516	510.15	15
14005	51.2154	71.3487	100.17	15
14006	51.2154	71.3429	84.36	15
14007	51.21	71.3342	136.19	15
14008	51.2082	71.3342	303.41	15
14009	51.2046	71.3284	922.14	15
14010	51.1884	71.4966	6.43	16
14011	51.1992	71.4705	2.33	16
14012	51.1992	71.4444	100.86	16
14013	51.201	71.4328	12.44	16
14014	51.2046	71.4473	492.45	16
14015	51.2028	71.4531	356.07	16
14016	51.2046	71.456	34.54	16
14017	51.1164	71.5053	159.42	17
14018	51.1668	71.5401	809.25	14
14019	51.1758	71.4937	4.06	16
14020	51.174	71.4908	99.07	16
14021	51.1686	71.5198	338.95	14
14022	51.1686	71.5256	119.35	14
14023	51.1668	71.5314	210.06	14
14024	51.1704	71.369	479.1	15
14025	51.147	71.3516	1116.16	18
14026	51.1452	71.3371	4.24	18
14027	51.1866	71.4328	411.96	15
14028	51.1758	71.3806	360.2	15
14029	51.138	71.5488	306.54	14
14030	51.1254	71.5778	1.88	17
14031	51.12	71.4531	2.11	17
14032	51.2208	71.3313	406.81	15
14033	51.2208	71.3284	678.28	15
14034	51.2226	71.3284	8.38	15
14035	51.2226	71.3342	15	15
14036	51.2208	71.3342	11.19	15
14037	51.219	71.3284	153.18	15
14038	51.219	71.3255	202.98	15
14039	51.2208	71.3226	13.97	15
14040	51.2496	71.3748	152.5	16
14041	51.246	71.3574	70.63	16
14042	51.2496	71.3661	7.38	16
14043	51.255	71.3661	1.04	16
14044	51.2532	71.3632	87.44	16
14045	51.2514	71.3603	77.19	16
14046	51.2604	71.3835	85.03	16
14047	51.2568	71.3661	1.5	16
14048	51.12	71.4502	4.04	17
14049	51.12	71.6416	4.54	17
14050	51.1074	71.5749	100.33	17
14051	51.1056	71.5749	1.03	17
14052	51.1074	71.5459	3.48	17
14053	51.2064	71.3487	131.06	15
14054	51.1866	71.3052	173.99	15
14055	51.1866	71.3023	20.97	15
14056	51.1938	71.3197	10.6	15
14057	51.2046	71.3458	171.98	15
14058	51.2028	71.3313	9.14	15
14059	51.2136	71.3313	3.18	15
14060	51.2136	71.3342	5.17	15
14061	51.2118	71.3487	195.18	15
14062	51.2154	71.3458	105.46	15
14063	51.219	71.3429	14.04	15
14064	51.219	71.3487	205.73	15
14065	51.2172	71.3574	16.59	15
14066	51.2172	71.3516	96.22	15
14067	51.2262	71.3255	3.95	15
14068	51.21	71.3197	1.84	15
14069	51.21	71.3487	129.47	15
14070	51.2172	71.3284	3.59	15
14071	51.2154	71.3255	94.05	15
14072	51.2082	71.34	345.56	15
14073	51.21	71.3429	138.37	15
14074	51.2136	71.3458	128.04	15
14075	51.219	71.3371	10.69	15
14076	51.2172	71.3371	13.37	15
14077	51.2172	71.3313	7.39	15
14078	51.1056	71.5633	3.44	17
14079	51.174	71.34	8.01	18
14080	51.1542	71.4154	1.37	18
14081	51.1524	71.4154	0.91	18
14082	51.192	71.4734	5	16
14083	51.2046	71.4792	91.23	16
14084	51.1866	71.5082	11.29	16
14085	51.1884	71.5082	55.99	16
14086	51.1758	71.5053	1.26	14
14087	51.1758	71.5082	59.99	14
14088	51.1776	71.5111	894.17	14
14089	51.1794	71.5082	632.8	14
14090	51.21	71.4792	10.76	16
14091	51.21	71.485	75.41	16
14092	51.2118	71.485	63.6	16
14093	51.2118	71.4821	55.16	16
14094	51.192	71.485	56.41	16
14095	51.192	71.4821	1.72	16
14096	51.1956	71.4792	106.1	16
14097	51.2064	71.485	4.89	16
14098	51.1902	71.4995	5.36	16
14099	51.201	71.4937	127.03	16
14100	51.1956	71.485	124.83	16
14101	51.1848	71.5053	112.82	16
14102	51.1848	71.5082	123.77	16
14103	51.1614	71.6068	101.79	14
14104	51.1236	71.5633	862.07	17
14105	51.1236	71.5662	252.28	17
14106	51.129	71.5488	199.56	17
14107	51.1254	71.369	1504.52	18
14108	51.1236	71.369	126.62	18
14109	51.1272	71.3835	571.34	18
14110	51.1362	71.3806	1005.27	18
14111	51.1362	71.3777	1405.9	18
14112	51.1362	71.3748	1142.65	18
14113	51.1398	71.3226	147.97	18
14114	51.1452	71.3661	402.47	18
14115	51.147	71.34	6.96	18
14116	51.1506	71.3487	10.83	18
14117	51.1686	71.3516	2.57	15
14118	51.2154	71.3545	3.13	15
14119	51.2226	71.3719	1.85	16
14120	51.2172	71.3487	9.72	15
14121	51.2352	71.3632	106.02	16
14122	51.237	71.3719	2.68	16
14123	51.093	71.5981	13.73	13
14124	51.0984	71.5952	0.67	17
14125	51.0246	71.3313	24.68	18
14126	51.0246	71.3284	3.45	18
14127	51.1092	71.6967	15.32	14
14128	51.1002	71.7199	3.68	17
14129	51.2244	71.5633	105.86	16
14130	51.246	71.5894	67.49	16
14131	51.2496	71.5865	3.49	16
14132	51.2514	71.5952	5.66	16
14133	51.2514	71.5923	7.54	16
14134	51.2496	71.5923	2.77	16
14135	51.2496	71.5894	4.27	16
14136	51.2496	71.5836	7.14	16
14137	51.2496	71.5807	8.81	16
14138	51.0948	71.4937	65.44	13
14139	51.0948	71.4966	504.41	13
14140	51.093	71.4937	18.63	13
14141	51.102	71.4966	6.54	13
14142	51.102	71.4995	19.6	13
14143	51.0984	71.4879	112.76	13
14144	51.0858	71.4792	8.44	13
14145	51.0894	71.4937	35.92	13
14146	51.0912	71.485	2.34	13
14147	51.093	71.485	38.11	13
14148	51.0912	71.4879	6.52	13
14149	51.1128	71.543	113.74	17
14150	51.1146	71.4676	435.22	17
14151	51.1146	71.4647	11.15	17
14152	51.1128	71.5198	301.49	17
14153	51.1128	71.5256	133.12	17
14154	51.1056	71.5024	536.3	17
14155	51.1056	71.5082	1.23	17
14156	51.1056	71.5053	10.14	17
14157	51.111	71.4995	926.43	17
14158	51.111	71.4966	283.23	17
14159	51.1038	71.4908	9.75	17
14160	51.1056	71.4966	2.01	17
14161	51.1164	71.5691	8.87	17
14162	51.1164	71.5778	2.9	17
14163	51.1128	71.5778	13.34	17
14164	51.1128	71.5691	51.02	17
14165	51.1092	71.5575	18.97	17
14166	51.1092	71.5604	38.05	17
14167	51.1056	71.5604	5.3	17
14168	51.1074	71.2211	3.84	18
14169	51.1128	71.224	10.39	18
14170	51.1344	71.2791	76.96	18
14171	51.1362	71.2791	49	18
14172	51.1362	71.2762	39.88	18
14173	51.1344	71.2762	34.58	18
14174	51.1362	71.282	18.15	18
14175	51.1344	71.282	66.08	18
14176	51.1326	71.282	53.09	18
14177	51.1326	71.2849	56.51	18
14178	51.1308	71.282	50.71	18
14179	51.1308	71.2849	56.07	18
14180	51.129	71.2849	65.47	18
14181	51.129	71.2878	46.71	18
14182	51.1272	71.2878	18.3	18
14183	51.1272	71.2849	48.55	18
14184	51.1254	71.2878	39.96	18
14185	51.1362	71.2849	37.15	18
14186	51.1344	71.2849	58.35	18
14187	51.1344	71.2878	22.26	18
14188	51.1326	71.2878	47.04	18
14189	51.1308	71.2878	76.04	18
14190	51.129	71.2907	10.9	18
14191	51.138	71.282	0.86	18
14192	51.1362	71.2878	2.13	18
14193	51.1326	71.2907	67.53	18
14194	51.1344	71.2907	45.91	18
14195	51.1362	71.2907	9.58	18
14196	51.1362	71.2936	16.4	18
14197	51.1344	71.2936	113.26	18
14198	51.1326	71.2936	66.96	18
14199	51.1308	71.2936	51.73	18
14200	51.129	71.2936	18.79	18
14201	51.1308	71.2965	54.3	18
14202	51.1344	71.2965	79.57	18
14203	51.1326	71.2965	71.21	18
14204	51.1308	71.2994	10.34	18
14205	51.1326	71.2994	33.4	18
14206	51.1362	71.2965	6.56	18
14207	51.1344	71.3023	3.95	18
14208	51.1218	71.2443	56.91	18
14209	51.12	71.2443	148.54	18
14210	51.12	71.2472	46.83	18
14211	51.1182	71.2443	117.57	18
14212	51.1182	71.2472	55.99	18
14213	51.1164	71.2472	217.72	18
14214	51.1164	71.2501	51.42	18
14215	51.1146	71.2501	131.57	18
14216	51.1218	71.2472	32.41	18
14217	51.1128	71.253	57.95	18
14218	51.1146	71.253	58.41	18
14219	51.111	71.253	13.18	18
14220	51.1128	71.2559	26.69	18
14221	51.1128	71.2588	3.37	18
14222	51.1146	71.2559	55.47	18
14223	51.1146	71.2588	39.2	18
14224	51.12	71.2501	28.2	18
14225	51.1182	71.2501	51.58	18
14226	51.1182	71.253	47.04	18
14227	51.1164	71.2559	51.36	18
14228	51.1182	71.2559	251.46	18
14229	51.1164	71.2588	49.42	18
14230	51.12	71.253	24.07	18
14231	51.1218	71.253	10.63	18
14232	51.1218	71.2501	86.74	18
14233	51.1272	71.2414	78.47	18
14234	51.1254	71.2414	73.85	18
14235	51.1236	71.2414	40.14	18
14236	51.1254	71.2443	57.22	18
14237	51.1272	71.2443	65.32	18
14238	51.1236	71.2472	32.89	18
14239	51.1254	71.2385	45.14	18
14240	51.1272	71.2385	54.24	18
14241	51.129	71.2385	15.18	18
14242	51.129	71.2414	58.37	18
14243	51.129	71.2443	78.77	18
14244	51.1308	71.2443	23.07	18
14245	51.1308	71.2414	4.77	18
14246	51.129	71.2472	78.93	18
14247	51.1308	71.2472	45.28	18
14248	51.1308	71.2501	69.11	18
14249	51.1308	71.253	70.25	18
14250	51.129	71.253	7.15	18
14251	51.1272	71.2472	30.41	18
14252	51.1236	71.2501	9.54	18
14253	51.1254	71.2501	65.59	18
14254	51.1272	71.2501	29.24	18
14255	51.1272	71.253	43.52	18
14256	51.1254	71.253	59.81	18
14257	51.1272	71.2588	28.08	18
14258	51.1272	71.2559	40.52	18
14259	51.1308	71.2559	59.62	18
14260	51.1326	71.253	26.77	18
14261	51.1326	71.2559	45.89	18
14262	51.1326	71.2501	2.23	18
14263	51.1344	71.2559	6.69	18
14264	51.1344	71.253	26.41	18
14265	51.1362	71.253	46.83	18
14266	51.1362	71.2559	6.69	18
14267	51.138	71.253	15.61	18
14268	51.138	71.2501	6.69	18
14269	51.1398	71.2501	8.92	18
14270	51.1362	71.2501	7	18
14271	51.138	71.2559	2.23	18
14272	51.1398	71.253	7.01	18
14273	51.12	71.2327	42.08	18
14274	51.1218	71.2559	11.98	18
14275	51.1236	71.253	25.7	18
14276	51.1236	71.2588	41.78	18
14277	51.1254	71.2617	30.95	18
14278	51.1254	71.2646	12.67	18
14279	51.1326	71.2617	57.02	18
14280	51.129	71.2675	15.19	18
14281	51.1308	71.2646	30.37	18
14282	51.1326	71.2588	61.26	18
14283	51.1308	71.2617	64.63	18
14284	51.1308	71.2588	90.22	18
14285	51.129	71.2588	37.71	18
14286	51.129	71.2617	40.4	18
14287	51.1272	71.2675	20.72	18
14288	51.129	71.2646	41.49	18
14289	51.1344	71.2617	6.18	18
14290	51.1326	71.2646	13.46	18
14291	51.1272	71.2617	5.39	18
14292	51.1326	71.2675	2.09	18
14293	51.1272	71.2733	25.86	18
14294	51.1272	71.2704	52.39	18
14295	51.129	71.2704	18.22	18
14296	51.1254	71.2675	20.5	18
14297	51.1218	71.2791	40.68	18
14298	51.12	71.2762	362.59	18
14299	51.12	71.2791	368	18
14300	51.1236	71.2791	15.14	18
14301	51.1182	71.2791	103.31	18
14302	51.1182	71.2762	273.21	18
14303	51.1326	71.2733	28.31	18
14304	51.1308	71.2733	43.21	18
14305	51.1326	71.2704	2.28	18
14306	51.1308	71.2704	13.66	18
14307	51.129	71.2733	38.71	18
14308	51.129	71.2762	33.65	18
14309	51.1308	71.2762	27.19	18
14310	51.1254	71.2762	45.24	18
14311	51.1272	71.2762	45.24	18
14312	51.1254	71.2791	68.66	18
14313	51.1272	71.2791	73.24	18
14314	51.1254	71.282	38.46	18
14315	51.1272	71.282	122.53	18
14316	51.129	71.2791	27.14	18
14317	51.129	71.282	52.02	18
14318	51.1362	71.2733	20.7	18
14319	51.1344	71.2733	23.92	18
14320	51.1326	71.2762	67.23	18
14321	51.1308	71.2791	29.57	18
14322	51.1254	71.2849	6.78	18
14323	51.1182	71.2298	15.46	18
14324	51.12	71.2298	13.97	18
14325	51.12	71.2356	72.43	18
14326	51.1218	71.2356	67.42	18
14327	51.12	71.2385	78.08	18
14328	51.12	71.2414	62.64	18
14329	51.1218	71.2414	70	18
14330	51.1218	71.2385	69.56	18
14331	51.1236	71.2385	80.88	18
14332	51.1236	71.2356	26.26	18
14333	51.1254	71.2356	2.51	18
14334	51.1218	71.2327	7.9	18
14335	51.1182	71.2414	62.73	18
14336	51.1182	71.2356	53.28	18
14337	51.1146	71.2385	30.26	18
14338	51.1128	71.2414	51.89	18
14339	51.1164	71.2414	48.76	18
14340	51.1182	71.2385	72.44	18
14341	51.1164	71.2385	62.76	18
14342	51.1164	71.2356	12.97	18
14343	51.1128	71.2385	2.16	18
14344	51.111	71.2414	8.65	18
14345	51.1146	71.2472	37.98	18
14346	51.1146	71.2443	62.12	18
14347	51.111	71.2443	10.46	18
14348	51.1128	71.2443	41.99	18
14349	51.1128	71.2472	41.84	18
14350	51.111	71.2472	39.33	18
14351	51.111	71.2501	42.57	18
14352	51.1128	71.2501	159	18
14353	51.1254	71.5894	85.06	17
14354	51.1272	71.5981	48.72	17
14355	51.1308	71.5952	224.76	17
14356	51.129	71.601	30.64	17
14357	51.129	71.6039	3.61	17
14358	51.1254	71.6039	8.73	17
14359	51.1254	71.601	124.21	17
14360	51.1218	71.5894	22.28	17
14361	51.1218	71.5923	46.16	17
14362	51.1218	71.5952	7.77	17
14363	51.1236	71.5952	53.14	17
14364	51.1236	71.5923	48.39	17
14365	51.1218	71.5981	11.7	17
14366	51.1218	71.6039	51.08	17
14367	51.1272	71.6039	11.57	17
14368	51.1182	71.601	277.01	17
14369	51.1218	71.6068	60.56	17
14370	51.12	71.6068	43.93	17
14371	51.12	71.6039	11.17	17
14372	51.12	71.6097	117.84	17
14373	51.1218	71.6097	41.44	17
14374	51.12	71.6126	16.18	17
14375	51.1182	71.6097	73.51	17
14376	51.1254	71.5662	132.64	17
14377	51.1398	71.5749	4.13	14
14378	51.138	71.5749	2.59	14
14379	51.138	71.5778	1.57	14
14380	51.1362	71.5807	14.29	14
14381	51.1362	71.572	1223.39	14
14382	51.1326	71.5894	9.76	14
14383	51.1326	71.5923	14.04	14
14384	51.1308	71.5865	177.72	17
14385	51.1254	71.5807	3.82	17
14386	51.1254	71.5749	69.57	17
14387	51.1182	71.572	38.55	17
14388	51.1182	71.5691	1.85	17
14389	51.1182	71.5778	4.48	17
14390	51.1218	71.5807	13.08	17
14391	51.12	71.5749	53.48	17
14392	51.12	71.572	26.82	17
14393	51.1218	71.5778	31.01	17
14394	51.1218	71.5749	40.36	17
14395	51.1218	71.572	14.44	17
14396	51.1236	71.5749	41.74	17
14397	51.1362	71.5459	3.1	14
14398	51.1362	71.5517	256.47	14
14399	51.1362	71.5546	374.21	17
14400	51.1434	71.5372	169.12	14
14401	51.1416	71.5401	2.58	14
14402	51.1992	71.4618	40.68	16
14403	51.1992	71.4589	63.81	16
14404	51.201	71.4589	87.74	16
14405	51.201	71.4618	65.78	16
14406	51.201	71.4647	11.07	16
14407	51.2028	71.4589	205.73	16
14408	51.2028	71.4618	8.78	16
14409	51.2046	71.4589	5.43	16
14410	51.2064	71.4647	318.4	16
14411	51.0966	71.5488	4.15	13
14412	51.0966	71.5517	7.42	13
14413	51.0948	71.5517	1.06	13
14414	51.1578	71.4125	6.87	18
14415	51.1038	71.5198	31.61	17
14416	51.111	71.5343	1.31	17
14417	51.2208	71.4415	188.05	16
14418	51.2208	71.4444	41.65	16
14419	51.2154	71.4415	19.14	16
14420	51.2082	71.4386	77.75	16
14421	51.2118	71.4328	2.52	16
14422	51.2118	71.4299	13.27	16
14423	51.21	71.4328	14.98	16
14424	51.2082	71.4241	4.02	16
14425	51.21	71.427	549.38	16
14426	51.21	71.4241	8.06	16
14427	51.21	71.4212	1675.92	16
14428	51.2118	71.4009	17.17	16
14429	51.2136	71.4067	123.1	16
14430	51.2154	71.4067	64.14	16
14431	51.2172	71.4009	57.62	16
14432	51.2136	71.4183	2.34	16
14433	51.2136	71.4212	4.35	16
14434	51.2154	71.4212	21.51	16
14435	51.2136	71.4125	2.71	16
14436	51.2136	71.4154	126.6	16
14437	51.2172	71.4183	2.19	16
14438	51.2172	71.4125	4.81	16
14439	51.2244	71.4096	65	16
14440	51.219	71.4038	52.94	16
14441	51.219	71.398	7.51	16
14442	51.2244	71.3951	91.05	16
14443	51.2172	71.3748	24.83	16
14444	51.2172	71.3777	27.08	16
14445	51.219	71.3777	40.39	16
14446	51.2208	71.3777	42.1	16
14447	51.2208	71.3748	20.93	16
14448	51.2226	71.3748	3.75	16
14449	51.2244	71.3806	9.24	16
14450	51.2298	71.369	2.49	16
14451	51.2316	71.3719	1.17	16
14452	51.2388	71.3806	2.22	16
14453	51.2334	71.3632	2.72	16
14454	51.228	71.3574	1.48	16
14455	51.2352	71.3603	2.2	16
14456	51.2406	71.3632	1.24	16
14457	51.2316	71.3922	47.89	16
14458	51.228	71.4038	3.27	16
14459	51.1164	71.4705	2.05	17
14460	51.1092	71.4647	1.29	17
14461	51.2154	71.3777	40.76	16
14462	51.2118	71.398	50.4	16
14463	51.2136	71.3951	43.14	16
14464	51.2154	71.3922	33.61	16
14465	51.2172	71.3893	29.17	16
14466	51.102	71.4792	0.88	17
14467	51.129	71.4531	0.86	17
14468	51.1164	71.3922	975.96	18
14469	51.1272	71.4328	15.01	13
14470	51.1272	71.2907	1.41	18
14471	51.1092	71.4212	0.97	13
14472	51.1146	71.4618	336.2	17
14473	51.1488	71.4444	88.62	14
14474	51.147	71.4444	115.6	14
14475	51.1272	71.4038	447.27	18
14476	51.129	71.4038	1210.11	18
14477	51.12	71.4241	986.32	13
14478	51.165	71.3835	15.3	15
14479	51.1002	71.4299	88.56	13
14480	51.1704	71.5401	684.15	14
14481	51.1146	71.6416	10.54	17
14482	51.1092	71.6532	176.47	17
14483	51.1128	71.659	4.23	17
14484	51.1092	71.6619	75.84	17
14485	51.1092	71.659	2.63	17
14486	51.1686	71.5285	124.36	14
14487	51.165	71.5314	10.11	14
14488	51.165	71.5401	199.75	14
14489	51.1632	71.5401	182.98	14
14490	51.165	71.5198	83.14	14
14491	51.1614	71.5169	5.58	14
14492	51.1632	71.5169	2.15	14
14493	51.1632	71.5198	287.04	14
14494	51.1596	71.5227	95.42	14
14495	51.1578	71.5285	3.34	14
14496	51.1596	71.5285	2.35	14
14497	51.1632	71.5314	91.2	14
14498	51.1614	71.5314	3.51	14
14499	51.1614	71.5285	16.3	14
14500	51.1632	71.5256	100.85	14
14501	51.1632	71.5227	71.23	14
14502	51.1434	71.5865	1.81	14
14503	51.1398	71.5865	2.26	14
14504	51.1398	71.5778	10.29	14
14505	51.0606	71.4357	78.75	13
14506	51.0624	71.4357	10.46	13
14507	51.0588	71.4357	75.32	13
14508	51.0624	71.4328	101.86	13
14509	51.0498	71.4299	3.38	13
14510	51.1074	71.5314	483.18	17
14511	51.1038	71.5227	19.91	17
14512	51.1038	71.5256	8.09	17
14513	51.1056	71.5256	24.99	17
14514	51.1038	71.5285	4.21	17
14515	51.1038	71.5314	6.78	17
14516	51.1056	71.5314	370.18	17
14517	51.1056	71.5285	6.1	17
14518	51.1056	71.5227	27.53	17
14519	51.1056	71.5198	21.46	17
14520	51.1074	71.5227	10.83	17
14521	51.1074	71.5198	8.06	17
14522	51.1074	71.5169	15.53	17
14523	51.1074	71.514	16.42	17
14524	51.1056	71.514	30.12	17
14525	51.1056	71.5169	34.51	17
14526	51.1056	71.5111	463.73	17
14527	51.1038	71.5169	19.41	17
14528	51.1038	71.514	24.73	17
14529	51.1038	71.5111	472.48	17
14530	51.102	71.5169	9.6	17
14531	51.102	71.514	10.84	17
14532	51.1074	71.5111	977.27	17
14533	51.1092	71.5169	11.32	17
14534	51.1092	71.514	215.3	17
14535	51.1092	71.5111	269.95	17
14536	51.1092	71.5256	430.68	17
14537	51.111	71.5256	990.76	17
14538	51.111	71.5227	863.1	17
14539	51.111	71.5169	27.03	17
14540	51.111	71.5198	23.04	17
14541	51.1092	71.5198	0.76	17
14542	51.111	71.514	18.95	17
14543	51.111	71.5111	1.62	17
14544	51.1074	71.4125	90.63	13
14545	51.1218	71.4734	16.77	17
14546	51.0984	71.3864	258.83	18
14547	51.0966	71.3864	60.39	18
14548	51.0858	71.514	202.95	13
14549	51.0858	71.5169	193.05	13
14550	51.0876	71.5169	17.76	13
14551	51.0876	71.514	4.99	13
14552	51.2298	71.3603	1487.34	16
14553	51.0228	71.4502	109.45	13
14554	51.1038	71.4009	196.95	18
14555	51.1182	71.2588	161.34	18
14556	51.1218	71.2588	106.11	18
14557	51.1146	71.4908	1219.16	17
14558	51.1398	71.3719	2015.26	18
14559	51.1002	71.4502	2895.95	13
14560	51.0858	71.3864	844.01	18
14561	51.1002	71.3893	1132.75	18
14562	51.102	71.3893	1614.72	18
14563	51.12	71.4879	737.4	17
14564	51.12	71.4908	156.08	17
14565	51.1182	71.5053	421.09	17
14566	51.102	71.4096	2092.45	13
14567	51.1308	71.5459	369.87	17
14568	51.0354	71.4589	2178.39	13
14569	51.039	71.4647	1736.24	13
14570	51.0786	71.4328	2061.12	13
14571	51.2586	71.3893	4.88	16
14572	51.2046	71.3255	22.68	15
14573	51.1488	71.4415	124	16
14574	51.0768	71.4154	2.99	13
14575	51.0786	71.4183	1.99	13
14576	51.075	71.4125	1	13
14577	51.0732	71.4154	2	13
14578	51.075	71.4154	1	13
14579	51.075	71.4183	2.99	13
14580	51.0804	71.4067	9.39	13
14581	51.0732	71.4067	1.09	13
14582	51.0714	71.4067	37.01	13
14583	51.1272	71.4705	15.99	17
14584	51.0714	71.4241	2066.49	13
14585	51.0732	71.4241	981.39	13
14586	51.0732	71.4212	345.75	13
14587	51.1272	71.4415	33.79	13
14588	51.1254	71.4676	810.9	17
14589	51.129	71.4618	760.95	14
14590	51.138	71.3748	1108.08	18
14591	51.0804	71.4299	1773.27	13
14592	51.0822	71.4299	166.82	13
14593	51.0786	71.427	4.86	13
14594	51.0804	71.4241	4.55	13
14595	51.0768	71.4299	6.67	13
14596	51.0804	71.4473	233.13	13
14597	51.0822	71.4502	334.3	13
14598	51.1038	71.4444	760.36	13
14599	51.1056	71.4444	1439.21	13
14600	51.102	71.4415	1311.08	13
14601	51.0912	71.4154	78.32	13
14602	51.0912	71.4125	1.73	13
14603	51.0894	71.4125	2.38	13
14604	51.1146	71.4937	2984.58	17
14605	51.1128	71.4966	232.2	17
14606	51.1146	71.4821	207.47	17
14607	51.1128	71.4821	611.84	17
14608	51.1146	71.4763	1536.04	17
14609	51.1092	71.5285	915.71	17
14610	51.1182	71.4995	367.05	17
14611	51.1164	71.4995	651.73	17
14612	51.1164	71.5111	438.11	17
14613	51.1596	71.398	236.45	18
14614	51.1416	71.4589	235.72	14
14615	51.0984	71.4473	1256.72	13
14616	51.1236	71.3806	471.49	18
14617	51.1236	71.3835	1101.45	18
14618	51.1254	71.3777	1596.97	18
14619	51.1272	71.3777	1040.42	18
14620	51.1254	71.3864	499.02	18
14621	51.1254	71.3835	386.01	18
14622	51.1236	71.3864	102.92	18
14623	51.1218	71.3806	690.94	18
14624	51.1218	71.3835	411.4	18
14625	51.129	71.3835	385.08	18
14626	51.1416	71.3603	491.72	18
14627	51.129	71.4995	529.72	17
14628	51.138	71.3922	778.18	18
14629	51.1344	71.3951	484.52	18
14630	51.1326	71.3864	464.16	18
14631	51.1344	71.3864	584.79	18
14632	51.1326	71.4183	89.66	13
14633	51.1218	71.4502	447.68	17
14634	51.1038	71.4502	1222.04	13
14635	51.1218	71.4937	277.81	17
14636	51.102	71.3864	507.47	18
14637	51.102	71.3835	80.16	18
14638	51.1668	71.3748	1837.36	15
14639	51.1668	71.3719	1584.86	15
14640	51.165	71.3719	883.36	15
14641	51.165	71.369	247.71	15
14642	51.1668	71.369	2005.78	15
14643	51.1002	71.5082	312.5	13
14644	51.0876	71.4676	767.06	13
14645	51.0876	71.4705	147.85	13
14646	51.0894	71.4676	140.98	13
14647	51.0876	71.4647	871.97	13
14648	51.0732	71.3951	1168.49	18
14649	51.1632	71.3951	549.1	15
14650	51.1056	71.4763	529.03	17
14651	51.0336	71.4125	1377.33	13
14652	51.0336	71.4096	610.04	13
14653	51.0318	71.4125	335.32	13
14654	51.0318	71.4096	339.1	13
14655	51.0318	71.4154	246.28	13
14656	51.039	71.4183	264.22	13
14657	51.0804	71.4357	1.76	13
14658	51.1236	71.398	594.36	18
14659	51.1056	71.4241	1492.88	13
14660	51.0858	71.4647	1541.14	13
14661	51.1164	71.5314	131.2	17
14662	51.1344	71.4096	4.26	18
14663	51.0786	71.4241	1012.37	13
14664	51.0966	71.3835	747.26	18
14665	51.0966	71.3806	488.63	18
14666	51.1056	71.3951	759.3	18
14667	51.1164	71.4937	1040.06	17
14668	51.0732	71.3835	5.18	18
14669	51.075	71.3835	4686.37	18
14670	51.1308	71.601	218.3	14
14671	51.1326	71.5981	1199.11	14
14672	51.1326	71.601	2420.52	14
14673	51.102	71.4125	885.42	13
14674	51.2676	71.369	6.35	16
14675	51.0912	71.4183	9.52	13
14676	51.156	71.5546	234.6	14
14677	51.102	71.4212	0.64	13
14678	51.1074	71.3951	1342.05	18
14679	51.1074	71.3922	635.08	18
14680	51.1056	71.3864	201.24	18
14681	51.1128	71.3864	183.54	18
14682	51.111	71.3864	232.95	18
14683	51.1092	71.3864	297.1	18
14684	51.1056	71.3516	589.7	18
14685	51.1038	71.3574	488.92	18
14686	51.111	71.398	761.16	18
14687	51.0858	71.4676	564.75	13
14688	51.0858	71.4618	548.47	13
14689	51.12	71.3603	153.9	18
14690	51.1272	71.3603	616.43	18
14691	51.1254	71.3719	1100.67	18
14692	51.1272	71.3719	1788.33	18
14693	51.147	71.3603	1318.65	18
14694	51.0786	71.4357	513.08	13
14695	51.129	71.4415	3.32	13
14696	51.0714	71.3864	576.37	18
14697	51.1146	71.5401	318.34	17
14698	51.111	71.5401	157.77	17
14699	51.1092	71.5314	184.47	17
14700	51.165	71.5227	1011.91	14
14701	51.1704	71.5488	79.21	14
14702	51.0876	71.4038	409.85	13
14703	51.1218	71.3719	556.63	18
14704	51.12	71.3748	399.38	18
14705	51.1092	71.5227	704.46	17
14706	51.1506	71.3516	239.61	18
14707	51.1524	71.5314	157.12	14
14708	51.1236	71.3719	765.45	18
14709	51.2586	71.5981	85.02	16
14710	51.0804	71.3835	274.46	18
14711	51.0804	71.3806	536.43	18
14712	51.0822	71.4676	357.42	13
14713	51.0858	71.4183	74.9	13
14714	51.1524	71.5285	5.8	14
14715	51.1542	71.5285	2.9	14
14716	51.1704	71.5227	731.78	14
14717	51.0876	71.4067	64.22	13
14718	51.0984	71.4444	179.1	13
14719	51.102	71.4444	4.48	13
14720	51.102	71.4502	670.19	13
14721	51.0858	71.3835	6.42	18
14722	51.0822	71.3719	9.04	18
14723	51.0552	71.3864	97.11	18
14724	51.0732	71.4821	334.55	13
14725	51.0732	71.4792	64.25	13
14726	51.066	71.427	83.52	13
14727	51.066	71.4212	9.5	13
14728	51.0858	71.4763	6.64	13
14729	51.1542	71.5517	98.68	14
14730	51.156	71.5517	115.15	14
14731	51.1578	71.5546	1.94	14
14732	51.1542	71.5633	6.11	14
14733	51.156	71.5662	9.73	14
14734	51.1596	71.5604	8.32	14
14735	51.1614	71.572	234.51	14
14736	51.1596	71.572	9.4	14
14737	51.1524	71.5575	27.82	14
14738	51.1524	71.5546	6.53	14
14739	51.1398	71.543	395.41	14
14740	51.1398	71.5459	1.96	14
14741	51.129	71.5517	662.78	17
14742	51.129	71.5459	168.3	17
14743	51.1218	71.369	1.66	18
14744	51.1398	71.3603	299.11	18
14745	51.1434	71.3574	13.19	18
14746	51.156	71.3429	113.49	18
14747	51.156	71.3458	5.21	18
14748	51.138	71.3284	102.46	18
14749	51.1398	71.3284	118.36	18
14750	51.1398	71.3313	115.04	18
14751	51.1416	71.3342	222.34	18
14752	51.1398	71.3342	362.86	18
14753	51.138	71.3342	229.37	18
14754	51.138	71.3313	10.25	18
14755	51.1398	71.3255	7.36	18
14756	51.1344	71.3284	0.92	18
14757	51.1254	71.2965	88.09	18
14758	51.0408	71.427	1.16	13
14759	51.1074	71.3835	126.2	18
14760	51.0984	71.3951	158.2	18
14761	51.0966	71.398	130.33	18
14762	51.0876	71.3864	2.78	18
14763	51.0876	71.3835	3.28	18
14764	51.1416	71.3748	2.14	18
14765	51.0372	71.4067	1.49	13
14766	51.1002	71.3835	574.49	18
14767	51.1182	71.5314	367.88	17
14768	51.1416	71.5053	328.07	14
14769	51.0732	71.3574	11.2	18
\.


--
-- Data for Name: core_railstation; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.core_railstation (id, name, name_en, kind, lat, lon, district_id) FROM stdin;
49	Сороковая	Сороковая	rail	51.1435205	71.5626741	14
50	Астана-1	Astana-1	rail	51.1958965	71.4099867	16
51	разъезд 41	разъезд 41	rail	51.1134699	71.6972643	14
52	Разъезд 101	Разъезд 101	rail	51.14181	71.6359775	14
53	Әуежай	Airport	lrt	51.0279968	71.4587785	13
54	Атамекен	Atameken	lrt	51.0413113	71.4422022	13
55	Есіл	Yesil	lrt	51.0490296	71.4298587	13
56	Нұра	Nura	lrt	51.0810888	71.4000384	13
57	Мәңгілік Ел	Mangilik El	lrt	51.0559087	71.4187007	13
58	Жекпе Жек Сарайы	Martial Arts Centre	lrt	51.1145576	71.4115955	13
59	Астана Арена	Astana Arena	lrt	51.1061543	71.4090286	13
60	Ұлы Дала	Uly Dala	lrt	51.0999545	71.4068165	13
61	Университет	University	lrt	51.0887774	71.4027945	13
62	Астана Жұлдызы	Astana Zhuldyzy	lrt	51.0751328	71.3979377	13
63	Нұрлы Жол	Nurly Zhol	lrt	51.1119775	71.5288523	17
64	Жібек Жолы	Zhibek Zholy	lrt	51.1094568	71.5160697	17
65	Мыңжылдық Аллеясы	Mynjyldyk Alley	lrt	51.1123362	71.4982979	17
66	Театр	Theatre	lrt	51.1150038	71.4812028	17
67	Ұлттық Мұражай	National Museum	lrt	51.1170129	71.4683846	17
68	Министрліктер Үйі	House of Ministries	lrt	51.1221296	71.4374673	13
69	Бәйтерек	Baiterek	lrt	51.1232099	71.4287898	13
70	Сығанақ	Syganak	lrt	51.1220385	71.413127	13
71	Астана Нұрлы-Жол	Астана Нұрлы-Жол	rail	51.1124516	71.5317705	17
\.


--
-- Data for Name: core_transportscenario; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.core_transportscenario (id, data, updated_at) FROM stdin;
1	{"costs": {"bus": {"setup_kzt": 85000000.0, "setup_measure": "money", "maintenance_period": "month", "maintenance_measure": "money", "maintenance_kzt_month": 1200000.0}, "train": {"setup_kzt": 5000000000.0, "setup_measure": "money", "maintenance_period": "month", "maintenance_measure": "money", "maintenance_kzt_month": 35000000.0}, "bus_stop": {"setup_kzt": 4500000.0, "setup_measure": "money", "maintenance_period": "month", "maintenance_measure": "money", "maintenance_kzt_month": 45000.0}, "rail_station": {"setup_kzt": 2000000000.0, "setup_measure": "money", "maintenance_period": "month", "maintenance_measure": "money", "maintenance_kzt_month": 12000000.0}}, "goals": {"bus_coverage": 90.0, "rail_coverage": 50.0, "stops_per_10k": 7.0}, "distances": {"bus": 500, "rail": 1000}, "new_buses": {"10": 0, "12": 0, "46": 0}, "new_stops": [], "new_trains": 0, "existing_override": {"bus_stops": null, "rail_stations": null}}	2026-09-23 10:00:22.183647+00
\.


--
-- Data for Name: django_admin_log; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.django_admin_log (id, action_time, object_id, object_repr, action_flag, change_message, content_type_id, user_id) FROM stdin;
\.


--
-- Data for Name: django_content_type; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.django_content_type (id, app_label, model) FROM stdin;
1	admin	logentry
2	auth	group
3	auth	permission
4	auth	user
5	contenttypes	contenttype
6	sessions	session
7	core	location
8	core	metric
9	core	waitlistsignup
10	core	budgetplan
11	core	exchangerates
12	core	busroute
13	core	busstop
14	core	district
15	core	populationcell
16	core	railstation
17	core	transportscenario
\.


--
-- Data for Name: django_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.django_migrations (id, app, name, applied) FROM stdin;
1	contenttypes	0001_initial	2026-09-23 07:09:10.556529+00
2	auth	0001_initial	2026-09-23 07:09:10.604182+00
3	admin	0001_initial	2026-09-23 07:09:10.611536+00
4	admin	0002_logentry_remove_auto_add	2026-09-23 07:09:10.615764+00
5	admin	0003_logentry_add_action_flag_choices	2026-09-23 07:09:10.617614+00
6	contenttypes	0002_remove_content_type_name	2026-09-23 07:09:10.621671+00
7	auth	0002_alter_permission_name_max_length	2026-09-23 07:09:10.623876+00
8	auth	0003_alter_user_email_max_length	2026-09-23 07:09:10.625809+00
9	auth	0004_alter_user_username_opts	2026-09-23 07:09:10.627549+00
10	auth	0005_alter_user_last_login_null	2026-09-23 07:09:10.629442+00
11	auth	0006_require_contenttypes_0002	2026-09-23 07:09:10.629806+00
12	auth	0007_alter_validators_add_error_messages	2026-09-23 07:09:10.631473+00
13	auth	0008_alter_user_username_max_length	2026-09-23 07:09:10.636011+00
14	auth	0009_alter_user_last_name_max_length	2026-09-23 07:09:10.638338+00
15	auth	0010_alter_group_name_max_length	2026-09-23 07:09:10.641172+00
16	auth	0011_update_proxy_permissions	2026-09-23 07:09:10.642773+00
17	auth	0012_alter_user_first_name_max_length	2026-09-23 07:09:10.644958+00
18	core	0001_initial	2026-09-23 07:09:10.653112+00
19	core	0002_seed_demo_data	2026-09-23 07:09:10.658999+00
20	sessions	0001_initial	2026-09-23 07:09:10.664403+00
21	core	0003_budget_planner	2026-09-23 09:11:38.284454+00
22	core	0004_transport	2026-09-23 09:44:55.78047+00
\.


--
-- Data for Name: django_session; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.django_session (session_key, session_data, expire_date) FROM stdin;
\.


--
-- Name: auth_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.auth_group_id_seq', 1, false);


--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.auth_group_permissions_id_seq', 1, false);


--
-- Name: auth_permission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.auth_permission_id_seq', 68, true);


--
-- Name: auth_user_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.auth_user_groups_id_seq', 1, false);


--
-- Name: auth_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.auth_user_id_seq', 1, false);


--
-- Name: auth_user_user_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.auth_user_user_permissions_id_seq', 1, false);


--
-- Name: core_budgetplan_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.core_budgetplan_id_seq', 1, true);


--
-- Name: core_busroute_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.core_busroute_id_seq', 9, true);


--
-- Name: core_busstop_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.core_busstop_id_seq', 3006, true);


--
-- Name: core_district_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.core_district_id_seq', 18, true);


--
-- Name: core_exchangerates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.core_exchangerates_id_seq', 1, true);


--
-- Name: core_populationcell_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.core_populationcell_id_seq', 14769, true);


--
-- Name: core_railstation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.core_railstation_id_seq', 71, true);


--
-- Name: core_transportscenario_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.core_transportscenario_id_seq', 1, true);


--
-- Name: django_admin_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.django_admin_log_id_seq', 1, false);


--
-- Name: django_content_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.django_content_type_id_seq', 17, true);


--
-- Name: django_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.django_migrations_id_seq', 22, true);


--
-- Name: auth_group auth_group_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_name_key UNIQUE (name);


--
-- Name: auth_group_permissions auth_group_permissions_group_id_permission_id_0cd325b0_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_permission_id_0cd325b0_uniq UNIQUE (group_id, permission_id);


--
-- Name: auth_group_permissions auth_group_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_pkey PRIMARY KEY (id);


--
-- Name: auth_group auth_group_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_pkey PRIMARY KEY (id);


--
-- Name: auth_permission auth_permission_content_type_id_codename_01ab375a_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_codename_01ab375a_uniq UNIQUE (content_type_id, codename);


--
-- Name: auth_permission auth_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_pkey PRIMARY KEY (id);


--
-- Name: auth_user_groups auth_user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_pkey PRIMARY KEY (id);


--
-- Name: auth_user_groups auth_user_groups_user_id_group_id_94350c0c_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_user_id_group_id_94350c0c_uniq UNIQUE (user_id, group_id);


--
-- Name: auth_user auth_user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_user
    ADD CONSTRAINT auth_user_pkey PRIMARY KEY (id);


--
-- Name: auth_user_user_permissions auth_user_user_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_pkey PRIMARY KEY (id);


--
-- Name: auth_user_user_permissions auth_user_user_permissions_user_id_permission_id_14a6b632_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_user_id_permission_id_14a6b632_uniq UNIQUE (user_id, permission_id);


--
-- Name: auth_user auth_user_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_user
    ADD CONSTRAINT auth_user_username_key UNIQUE (username);


--
-- Name: core_budgetplan core_budgetplan_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_budgetplan
    ADD CONSTRAINT core_budgetplan_pkey PRIMARY KEY (id);


--
-- Name: core_busroute core_busroute_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_busroute
    ADD CONSTRAINT core_busroute_pkey PRIMARY KEY (id);


--
-- Name: core_busstop core_busstop_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_busstop
    ADD CONSTRAINT core_busstop_pkey PRIMARY KEY (id);


--
-- Name: core_district core_district_osm_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_district
    ADD CONSTRAINT core_district_osm_id_key UNIQUE (osm_id);


--
-- Name: core_district core_district_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_district
    ADD CONSTRAINT core_district_pkey PRIMARY KEY (id);


--
-- Name: core_exchangerates core_exchangerates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_exchangerates
    ADD CONSTRAINT core_exchangerates_pkey PRIMARY KEY (id);


--
-- Name: core_populationcell core_populationcell_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_populationcell
    ADD CONSTRAINT core_populationcell_pkey PRIMARY KEY (id);


--
-- Name: core_railstation core_railstation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_railstation
    ADD CONSTRAINT core_railstation_pkey PRIMARY KEY (id);


--
-- Name: core_transportscenario core_transportscenario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_transportscenario
    ADD CONSTRAINT core_transportscenario_pkey PRIMARY KEY (id);


--
-- Name: django_admin_log django_admin_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_pkey PRIMARY KEY (id);


--
-- Name: django_content_type django_content_type_app_label_model_76bd3d3b_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_app_label_model_76bd3d3b_uniq UNIQUE (app_label, model);


--
-- Name: django_content_type django_content_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_pkey PRIMARY KEY (id);


--
-- Name: django_migrations django_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_migrations
    ADD CONSTRAINT django_migrations_pkey PRIMARY KEY (id);


--
-- Name: django_session django_session_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_session
    ADD CONSTRAINT django_session_pkey PRIMARY KEY (session_key);


--
-- Name: auth_group_name_a6ea08ec_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_group_name_a6ea08ec_like ON public.auth_group USING btree (name varchar_pattern_ops);


--
-- Name: auth_group_permissions_group_id_b120cbf9; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_group_permissions_group_id_b120cbf9 ON public.auth_group_permissions USING btree (group_id);


--
-- Name: auth_group_permissions_permission_id_84c5c92e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_group_permissions_permission_id_84c5c92e ON public.auth_group_permissions USING btree (permission_id);


--
-- Name: auth_permission_content_type_id_2f476e4b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_permission_content_type_id_2f476e4b ON public.auth_permission USING btree (content_type_id);


--
-- Name: auth_user_groups_group_id_97559544; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_user_groups_group_id_97559544 ON public.auth_user_groups USING btree (group_id);


--
-- Name: auth_user_groups_user_id_6a12ed8b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_user_groups_user_id_6a12ed8b ON public.auth_user_groups USING btree (user_id);


--
-- Name: auth_user_user_permissions_permission_id_1fbb5f2c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_user_user_permissions_permission_id_1fbb5f2c ON public.auth_user_user_permissions USING btree (permission_id);


--
-- Name: auth_user_user_permissions_user_id_a95ead1b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_user_user_permissions_user_id_a95ead1b ON public.auth_user_user_permissions USING btree (user_id);


--
-- Name: auth_user_username_6821ab7c_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_user_username_6821ab7c_like ON public.auth_user USING btree (username varchar_pattern_ops);


--
-- Name: core_busstop_district_id_b862811f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_busstop_district_id_b862811f ON public.core_busstop USING btree (district_id);


--
-- Name: core_populationcell_district_id_9c890c6e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_populationcell_district_id_9c890c6e ON public.core_populationcell USING btree (district_id);


--
-- Name: core_railstation_district_id_2c6685d0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_railstation_district_id_2c6685d0 ON public.core_railstation USING btree (district_id);


--
-- Name: django_admin_log_content_type_id_c4bce8eb; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX django_admin_log_content_type_id_c4bce8eb ON public.django_admin_log USING btree (content_type_id);


--
-- Name: django_admin_log_user_id_c564eba6; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX django_admin_log_user_id_c564eba6 ON public.django_admin_log USING btree (user_id);


--
-- Name: django_session_expire_date_a5c62663; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX django_session_expire_date_a5c62663 ON public.django_session USING btree (expire_date);


--
-- Name: django_session_session_key_c0390e0f_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX django_session_session_key_c0390e0f_like ON public.django_session USING btree (session_key varchar_pattern_ops);


--
-- Name: auth_group_permissions auth_group_permissio_permission_id_84c5c92e_fk_auth_perm; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissio_permission_id_84c5c92e_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_group_permissions auth_group_permissions_group_id_b120cbf9_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_b120cbf9_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_permission auth_permission_content_type_id_2f476e4b_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_2f476e4b_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_groups auth_user_groups_group_id_97559544_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_group_id_97559544_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_groups auth_user_groups_user_id_6a12ed8b_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_user_id_6a12ed8b_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_user_permissions auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_user_permissions auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_busstop core_busstop_district_id_b862811f_fk_core_district_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_busstop
    ADD CONSTRAINT core_busstop_district_id_b862811f_fk_core_district_id FOREIGN KEY (district_id) REFERENCES public.core_district(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_populationcell core_populationcell_district_id_9c890c6e_fk_core_district_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_populationcell
    ADD CONSTRAINT core_populationcell_district_id_9c890c6e_fk_core_district_id FOREIGN KEY (district_id) REFERENCES public.core_district(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_railstation core_railstation_district_id_2c6685d0_fk_core_district_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_railstation
    ADD CONSTRAINT core_railstation_district_id_2c6685d0_fk_core_district_id FOREIGN KEY (district_id) REFERENCES public.core_district(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_admin_log django_admin_log_content_type_id_c4bce8eb_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_content_type_id_c4bce8eb_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_admin_log django_admin_log_user_id_c564eba6_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_user_id_c564eba6_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- PostgreSQL database dump complete
--

\unrestrict ZW2Wulpz7lq9qk9OXKhApPicSTcBY4jgLa8gSNcsBcBx18cvD8rYamlGgHRmF1G


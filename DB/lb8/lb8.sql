drop database COVID;
create database COVID;
use covid;

set sql_safe_updates = 0;

create table if not exists patients
(
p_id integer not null auto_increment primary key,
p_name varchar(30),
p_surname varchar(50),
p_age integer,
p_emale varchar(50),
p_test bool
);

create table if not exists patient_past_card
(
p_id integer primary key,
p_history text,
constraint cn1 foreign key(p_id) references patients(p_id) on delete cascade
);

create table if not exists analises
(
an_id integer auto_increment,
p_id integer,
p_analis varchar(100),
an_value integer,
primary key(an_id,p_id),
constraint cn2 foreign key(p_id) references patients(p_id) on delete cascade
);
update analises set an_value = 5 where p_id = 4 ;
select* from analises;
create table if not exists vacines
(
v_id integer primary key auto_increment,
v_name varchar(50),
v_formula varchar(50)
);

create table if not exists vac_patient
(
v_date date,
v_id integer not null,
p_id integer not null,
primary key(v_id,p_id,v_date),
constraint cn3 foreign key (v_id) references vacines(v_id) on delete cascade,
constraint cn4 foreign key (p_id) references patients(p_id)on delete cascade
);


create table if not exists death
(
p_id integer,
p_death_reason varchar(100),
constraint cn10 foreign key (p_id) references patient_past_card(p_id)on delete cascade
);

create table if not exists survived
(
p_id integer,
id_vacines integer,
date_of_add datetime default current_timestamp,
primary key(p_id,date_of_add),
constraint cn5 foreign key (p_id) references patients(p_id)on delete cascade,
constraint cn6 foreign key(id_vacines) references vacines(v_id)on delete cascade,
constraint cn11 foreign key (p_id) references patient_past_card(p_id)on delete cascade
);

create table if not exists patient_daily_diary
(
d_id integer auto_increment primary key,
p_id integer,
p_date date,
p_dairy text
);

create table if not exists symptoms
(
p_id integer,
pat_symptoms text,
id_vacine int,
symptoms_date datetime default current_timestamp,
primary key (p_id,symptoms_date),
constraint cn8 foreign key (p_id) references patients(p_id)on delete cascade,
constraint cn9 foreign key(id_vacine) references vacines(v_id)on delete cascade
);
select tb1.v_name ,count(tb1.v_name) from (select vacines.v_id,vacines.v_name ,vacines.v_formula,vac_patient.p_id from vacines left join vac_patient
on vacines.v_id = vac_patient.v_id) as tb1 inner join survived on survived.p_id = tb1.p_id where tb1.v_name = 'COVID-19 Vaccine1';

select tb1.v_name, count(tb1.v_name) from (select vacines.v_id,vacines.v_name ,vacines.v_formula,vac_patient.p_id from vacines left join vac_patient
on vacines.v_id = vac_patient.v_id) as tb1 inner join survived on survived.p_id = tb1.p_id where tb1.v_name = 'COVID-19 Vaccine1'
           
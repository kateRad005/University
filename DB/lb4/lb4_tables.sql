use mmf2025;

create table if not exists studs
(
st_id int primary key auto_increment,
st_name varchar(30) not null,
st_surname varchar(30) not null,
st_group int,
st_course int,
st_semestr int,
speciality enum("KM","Ped","Mechanic","Proizvod"),
st_form enum("budget",'paid'),
st_scholarship float,
st_value float,
st_fee float
);
delete from studs;
insert into studs(st_name,st_surname,st_group,st_course,st_semestr,speciality,st_form,st_scholarship,st_value) 
values("Name","Sur",4,2,3,"KM",'budget',201,8.9),("Name2","Sur2",5,3,5,"KM",'budget',200,5.1),("Name3","Su3r",5,2,3,"KM",'paid',201,8.9);
create table if not exists teachers
 (
 t_id integer primary key auto_increment,
 t_name varchar(30),
 t_surname varchar(30),
 t_email varchar(50)
 );
 insert into teachers(t_name,t_surname,t_email) values("TName","TSur","TEmail");
  insert into teachers(t_name,t_surname,t_email) values("TName2","TSur2","TEmail2");

create table if not exists subjects
(
sub_id int primary key auto_increment,
sub_name varchar(50) not null,
sub_teacher integer not null,
sub_hours int,
constraint cn15 foreign key(sub_teacher) references teachers(t_id) on update cascade on delete cascade
);
insert into subjects(sub_name,sub_teacher,sub_hours) values("Sub",1,10),("Sub2",2,10),("Sub3",1,10),("Sub4",2,10),("Sub5",1,10),("Sub6",2,10);

create table if not exists exams
(
exam_id int not null primary key auto_increment,
t_id integer,
ref_sub_id int not null,
ref_st_id int not null,
exam_date datetime,
exam_mark int,
exam_attempt int,
constraint cn1 foreign key(ref_st_id) references studs(st_id)on delete cascade on update cascade,
constraint cn2 foreign key(ref_sub_id) references subjects(sub_id)on delete cascade on update cascade,
constraint cn14 foreign key(t_id) references teachers(t_id)on delete cascade on update cascade
);

create table if not exists class
(
 cl_id integer auto_increment primary key,
 sub_id integer,
 t_id integer,
 groupp integer,
 course integer,
 cl_date date,
 cl_start_time time,
 cl_end_time time,
 constraint cn11 foreign key(sub_id) references subjects(sub_id) on delete cascade on update cascade,
  constraint cn12 foreign key(t_id) references teachers(t_id) on delete cascade on update cascade
);

-- 2. Модифицируйте учебную БД mmf2025 до следующих возможностей. 
-- 2.1. Хранение информации о всех оценках студента в семестре.
create table if not exists marks
(
mark_id integer primary key auto_increment,
st_id integer,
cl_id integer,
semestr integer,
mark integer,
constraint cn3 foreign key(st_id) references studs(st_id)on delete cascade on update cascade,
constraint cn4 foreign key(cl_id) references class(cl_id) on delete cascade on update cascade
);
drop table attendance;
-- 2.2. Хранение информации о посещаемости студента на каждом занятии.
create table if not exists attendance
(
att_id integer auto_increment primary key,
st_id integer,
sub_id integer,
sub_gr int,
sub_course int,
attend bool,
att_date date,
att_mark int,
constraint cn5 foreign key(st_id) references studs(st_id)on delete cascade on update cascade,
constraint cn6 foreign key(sub_id) references subjects(sub_id) on delete cascade on update cascade
);
create table if not exists activity
(
act_id integer auto_increment primary key,
st_id integer,
act_name varchar(50),
act_date date,
act_hours int,
constraint cn7 foreign key(st_id) references studs(st_id) on delete cascade on update cascade
);

-- 2.5. Хранение информации о здоровье студента.
create table if not exists health
(
h_id integer not null primary key,
st_id int,
st_health_group int,
constraint cn8 foreign key(st_id) references studs(st_id) on delete cascade on update cascade
);

-- 3. Добавьте в БД раздельные концепции зачётов и экзаменов

create table if not exists small_exams
(
sm_id int not null primary key auto_increment,
st_id integer,
sub_id integer,
sm_teacher integer,
sm_date datetime,
sm_mark integer,
sm_att integer,
constraint cn9 foreign key(st_id) references studs(st_id)on delete cascade on update cascade,
constraint cn10 foreign key(sub_id) references subjects(sub_id) on delete cascade on update cascade,
constraint cn13 foreign key(sm_teacher) references teachers(t_id) on update cascade on delete cascade
);
-- drop database mmf2025;
create database if not exists mmf2025;
use mmf2025;
set sql_safe_updates = 0;
set global log_bin_trust_function_creators = 1;

describe studs;
select* from studs;
select* from teachers;
select* from subjects;
select* from exams;
select* from small_exams;
select* from attendance;

show tables;

drop trigger if exists att_check;
-- ------------ ДОП не своя группа ////////////////////////////////////////////////////////////////////////////////////////////////
DELIMITER // 
create trigger att_check before insert on attendance
for each row
begin
declare s_gr int;
declare s_c int;
declare att bool;
select st_group into s_gr from studs where st_id = NEW.st_id order by new.att_id desc limit 1;
select st_course into s_c from studs where st_id = NEW.st_id order by new.att_id desc limit 1;
if s_gr<>NEW.sub_gr or s_c <> NEW.sub_course then 
	SIGNAL SQLSTATE '45000' 
	set message_text = "you cant take this classes";
else if dayofweek(NEW.att_date) = 1 then  
SIGNAL SQLSTATE '45000' 
	set message_text = "you cant take this classes on sunday";
else if( new.att_mark is not null )and new.attend = 0 then
	SIGNAL SQLSTATE '45000' 
	set message_text = "you cant have a mark for class ypu didnt attend";
    end if;
end if;
end if;
end//
DELIMITER ;

select* from studs;
select* from attendance;
select* from teachers;
select* from subjects;
insert into attendance(st_id, sub_id,sub_gr,sub_course ,attend, att_date,att_mark)  values
(34,1,5,2,1,"2024-12-29",5);
insert ignore into attendance(st_id, sub_id,sub_gr,sub_course ,attend, att_date)  values
(34,1,5,2,1,"2024-12-20");
insert ignore into attendance(st_id, sub_id,sub_gr,sub_course ,attend, att_date,att_mark)  values
(34,1,4,2,0,"2024-12-20",5);
insert ignore into attendance(st_id, sub_id,sub_gr,sub_course ,attend, att_date,att_mark)  values
(34,1,4,2,1,"2024-12-20",5);
select* from attendance;
select* from teachers;
select* from subjects;

-- ДОП с пересдачами//////////////////////////////////////////////////////////////////////////////////////////////////
drop trigger exam_check;
DELIMITER //
create  trigger exam_check before insert on exams
for each row 
begin
declare attempt integer;
declare sub int;
select exam_attempt into attempt from exams  where ref_sub_id = NEW.ref_sub_id and ref_st_id = NEW.ref_st_id order by exam_id desc limit 1;
if (attempt is null) then set attempt = 0;
end if;
set NEW.exam_attempt = attempt + 1  ;
if  attempt = 3 and NEw.exam_mark < 4 then 
	SIGNAL SQLSTATE '45000' 
	set message_text = "bye bye";
else if attempt > 2 then
	SIGNAL SQLSTATE '45000' 
	set message_text = "you cant pass exams more then 3 times";
end if;
end if;
end//
DELIMITER ;

drop trigger exam_delete;
DELIMITER //
create  trigger exam_delete after insert on exams
for each row 
begin
declare attempt integer;
select exam_attempt into attempt from exams  where ref_sub_id = NEW.ref_sub_id and ref_st_id = NEW.ref_st_id order by exam_id desc limit 1;
if  attempt = 3 and NEw.exam_mark < 4 then 
delete from studs where st_id = NEW.ref_st_id;
end if;
end//
DELIMITER ;
select* from exams;
drop trigger exam_check_peresd;
DELIMITER //
create  trigger exam_check_peresd before insert on exams
for each row 
begin
declare mark int;
select exam_mark into mark from exams where ref_sub_id = new.ref_sub_id and ref_st_id = NEW.ref_st_id order by exam_id desc limit 1 ;
if mark > 3 then 
	SIGNAL SQLSTATE '45000' 
	set message_text = "you already had good grade, move on";
end if;
end//
DELIMITER ;

drop trigger small_exam_check;
DELIMITER //
create  trigger small_exam_check before insert on small_exams
for each row 
begin
declare attempt integer;
declare sub int;
select sm_att into attempt from small_exams  where sub_id = NEW.sub_id and st_id = NEW.st_id order by sm_id desc limit 1;
if (attempt is null) then set attempt = 0;
end if;
set NEW.sm_att = attempt + 1  ;
if  attempt = 3 and NEw.sm_mark < 4 then 
	SIGNAL SQLSTATE '45000' 
	set message_text = "bye bye";
else if attempt > 3 then
	SIGNAL SQLSTATE '45000' 
	set message_text = "you cant pass exams more then 3 times";
end if;
end if;
end//
DELIMITER ;


drop trigger small_exam_delete;
DELIMITER //
create  trigger small_exam_delete after insert on small_exams
for each row 
begin
declare attempt integer;
select sm_att into attempt from small_exams  where sub_id = new.sub_id and st_id = NEW.st_id order by sm_id desc limit 1;	
if  attempt = 3 and NEw.sm_mark < 4 then 
delete from studs where st_id = NEW.st_id;
end if;
end//
DELIMITER ;

drop trigger small_exam_check_peresd;
DELIMITER //
create  trigger small_exam_check_peresd before insert on small_exams
for each row 
begin
declare mark int;
select sm_mark into mark from small_exams where sub_id = new.sub_id and st_id = NEW.st_id order by sm_id desc limit 1 ;
if mark > 3 then 
	SIGNAL SQLSTATE '45000' 
	set message_text = "you already had good grade, move on";
end if;
end//
DELIMITER ;

drop table small_exams;
insert into studs(st_name,st_surname,st_group,st_course,st_semestr,speciality,st_form,st_scholarship,st_value) 
values("Name","Sur",4,2,3,"KM",'budget',201,8.9),("Name2","Sur2",5,3,5,"KM",'budget',200,5.1);
insert into studs(st_name,st_surname,st_group,st_course,st_semestr,speciality,st_form,st_scholarship,st_value) 
values("Name3","Su3r",5,2,3,"KM",'paid',201,8.9);
select* from studs;
select* from exams;
select* from small_exams;
select* from subjects;
insert into exams(t_id, ref_sub_id, ref_st_id, exam_date, exam_mark) values(34,1,21,"2020-10-12",4);
insert into small_exams(st_id,sub_id,sm_teacher,sm_date,sm_mark) values(36,1,1,"2020-10-12",4);

-- ДОП обновление стипендии /////////////////////////////////////////////////////////////////////////////////
drop trigger new_val;

DELIMITER // 
create trigger new_val after insert on exams
for each row
begin
update studs set st_value = (select avg(exam_mark) from exams where exam_mark > 3)
    where st_id = new.ref_st_id ;
    end//
DELIMITER ;
select* from studs;
select* from exams;
insert into exams(t_id,ref_sub_id,ref_st_id,exam_date,exam_mark) values(1,2,35,'2021-10-14',9);

drop trigger change_scholarsip;

DELIMITER //
create trigger change_scholarsip before update on studs
for each row
begin 
set NEW.st_scholarship = case 
	when NEW.st_value < 5 and NEW.st_form = 'budget' then 0
	when NEW.st_value between 5 and 5.99 and NEW.st_form = 'budget' then 140
	when NEW.st_value between 6 and 7.99 and NEW.st_form = 'budget' then 180
	when NEW.st_value between 8 and 8.99 and NEW.st_form = 'budget' then 210
	when NEW.st_value between 9 and 10 and NEW.st_form = 'budget' then  240
    else null end;
end//
DELIMITER ;
select* from studs;
select* from small_exams;
select* from exams;
insert into exams(t_id,ref_sub_id,ref_st_id,exam_date,exam_mark) values(1,3,36,'2021-10-14',10);
insert into small_exams(st_id,sub_id,sm_teacher,sm_date,sm_mark) values(2,1,36,"2020-10-12",5);

-- 5. посчитать курсором кол-во букв в именах и фамилиях.(сколько раз встречалась каждая буква)


-- Нельзя сдать экзамен без зачета
DELIMITER //
create  trigger exam_check before insert on exams
for each row 
begin
declare mark integer;
select count(sm_mark) into mark from small_exams;
if mark = 0 then 
	SIGNAL SQLSTATE '45000' 
	set message_text = "you cant pass exams before tests";
end if;
end//
DELIMITER ;
select* from exams;
describe exams;



-- ДОП с пересдачами------------------------------------------------------------------------------------------------
drop trigger exam_check;
DELIMITER //
create  trigger exam_check before insert on exams
for each row 
begin
declare attempt integer;
declare sub int;
select exam_attempt into attempt from exams  where ref_sub_id = NEW.ref_sub_id and ref_st_id = NEW.ref_st_id order by exam_id desc limit 1;
if (attempt is null) then set attempt = 0;
end if;
set NEW.exam_attempt = attempt + 1  ;
if  attempt = 3 and NEw.exam_mark < 4 then 
	SIGNAL SQLSTATE '45000' 
	set message_text = "bye bye";
else if attempt > 2 then
	SIGNAL SQLSTATE '45000' 
	set message_text = "you cant pass exams more then 3 times";
end if;
end if;
end//
DELIMITER ;

drop trigger exam_delete;
DELIMITER //
create  trigger exam_delete after insert on exams
for each row 
begin
declare attempt integer;
select exam_attempt into attempt from exams  where ref_sub_id = NEW.ref_sub_id and ref_st_id = NEW.ref_st_id order by exam_id desc limit 1;
if  attempt = 3 and NEw.exam_mark < 4 then 
delete from studs where st_id = NEW.ref_st_id;
end if;
end//
DELIMITER ;


drop trigger small_exam_check;
DELIMITER //
create  trigger small_exam_check before insert on small_exams
for each row 
begin
declare attempt integer;
declare sub int;
select sm_att into attempt from small_exams  where sub_id = NEW.sub_id and st_id = NEW.st_id order by sm_id desc limit 1;
if (attempt is null) then set attempt = 0;
end if;
set NEW.sm_att = attempt + 1  ;
if  attempt = 3 and NEw.sm_mark < 4 then 
	SIGNAL SQLSTATE '45000' 
	set message_text = "bye bye";
else if attempt > 3 then
	SIGNAL SQLSTATE '45000' 
	set message_text = "you cant pass exams more then 3 times";
end if;
end if;
end//
DELIMITER ;


drop trigger small_exam_delete;
DELIMITER //
create  trigger small_exam_delete after insert on small_exams
for each row 
begin
declare attempt integer;
select sm_att into attempt from small_exams  where sub_id = new.sub_id and st_id = NEW.st_id order by sm_id desc limit 1;
if  attempt = 3 and NEw.sm_mark < 4 then 
delete from studs where st_id = NEW.st_id;
end if;
end//
DELIMITER ;

drop table small_exams;
insert into studs(st_name,st_surname,st_group,st_course,st_semestr,speciality,st_form,st_scholarship,st_value) 
values("Name","Sur",4,2,3,"KM",'budget',201,8.9),("Name2","Sur2",5,3,5,"KM",'budget',200,5.1);
insert into studs(st_name,st_surname,st_group,st_course,st_semestr,speciality,st_form,st_scholarship,st_value) 
values("Name3","Su3r",5,2,3,"KM",'paid',201,8.9);
select* from studs;
select* from exams;
select* from small_exams;
select* from subjects;
insert into exams(t_id, ref_sub_id, ref_st_id, exam_date, exam_mark) values(1,1,4,"2020-10-12",3);


drop trigger new_val;
DELIMITER // 
create trigger new_val after insert on exams
for each row
begin
update studs set st_value = (select avg(exam_mark) from exams)
    where st_id = new.ref_st_id ;
    end//
DELIMITER ;
select* from studs;
select* from exams;
insert into exams(t_id,ref_sub_id,ref_st_id,exam_date,exam_mark) values(1,2,3,'2021-10-14',9);
describe exams;




-- Лишение стипендии
DELIMITER //
create trigger scholarship_check after insert on exams
for each row 
begin
declare ex int;
select new.exam_mark into ex;
update studs set st_scholarship = (case when ex < 4 then 0 else st_scholarship end) where studs.st_id = new.ref_st_id;
end//
DELIMITER ;

select* from studs;
select* from exams;
insert into exams(t_id,ref_sub_id,ref_st_id,exam_date,exam_mark) values(1,1,1,'2021-10-14',3);
insert into exams(t_id,ref_sub_id,ref_st_id,exam_date,exam_mark) values(1,1,2,'2021-10-14',5);

-- стипендия и платка
DELIMITER //
create trigger scholarship_form_check before insert on studs
for each row 
begin
set new.st_scholarship = 
(case NEW.st_form
	when 'paid' then null
    else new.st_scholarship
   end);
set New.st_fee = 
(case NEW.st_form
	when 'budget' then null
    else 300
   end);
end//
DELIMITER ;

select* from studs;
insert into studs(st_name,st_surname,st_group,st_course,st_semestr,speciality,st_form,st_scholarship,st_value) 
values("Name","Sur",4,2,3,"KM",'budget',150,8.9),("Name2","Sur2",5,3,5,"KM",'paid',200,5.1);

-- рассчет среднего баллa после сессии----------------------------------------------------------------
DELIMITER //
create function avg_mark(id int)
returns float
begin
	declare av_mark float;
    select avg(exam_mark) into av_mark from exams
    where ref_st_id = id;
    return av_mark;
end//
DELIMITER ;



-- рассчет стипендии по среднему баллу
DELIMITER //
create function scholarship_exams_check(id int)
returns int
begin
declare val float;
declare form varchar(20);
declare res int;
select st_value into val from studs where st_id = id;
select st_form into form from studs where st_id = id;
set res = case 
	when val < 5 and form = 'budget' then 0
	when val between 5 and 5.99 and form = 'budget' then 140
	when val between 6 and 7.99 and form = 'budget' then 180
	when val between 8 and 8.99 and form = 'budget' then 210
	when val between 9 and 10 and form = 'budget' then  240
    else null end;
return res;
end//
DELIMITER ;
select* from studs;
insert into small_exams(st_id,sub_id,sm_teacher,sm_date,sm_mark) values(2,1,1,"2020-10-12",3);

insert into exams(t_id,ref_sub_id,ref_st_id,exam_date,exam_mark) values(1,1,5,'2021-10-14',3);
insert into exams(t_id,ref_sub_id,ref_st_id,exam_date,exam_mark) values(1,1,2,'2021-10-14',5);

select* from exams;
select scholarship_exams_check(2);
select scholarship_exams_check(1);

set @ex_fails = 0;
DELIMITER //
create trigger fail_count after insert on exams
for each row 
begin
if NEW.exam_mark < 4 then set @ex_fails = @ex_fails+1;
   end if;
end//
DELIMITER ;


DELIMITER //
create trigger m_check before insert on exams
for each row 
begin
if NEW.exam_mark < 0 then set NEW.exam_mark = 0;
	end if;
if NEW.exam_mark > 10  then set NEW.exam_mark = 0;
    end if;
end//
DELIMITER ;

DELIMITER //
create procedure value_update()
begin
	declare avg_m float;
    declare id integer;
    declare done int default 0;
    declare studscur cursor for select st_id from studs;
    declare continue handler for not found set done = 1;
    open studscur;
	curs: loop
		fetch studscur into id;
        if done then
			leave curs;
		end if;
        update studs set st_value = (select avg_mark(id)) where studs.st_id = id; 
	end loop curs;
    close studscur;
    end//
DELIMITER ;

Call value_update;
select* from studs;


-- 4.1. Процедура для повышения всех стипендий на некоторое количество процентов.

DELIMITER //
create procedure up_scholarship(in pers int)
begin
    update studs set st_scholarship = st_scholarship*(1+0.01*pers);
	end//
DELIMITER ;

call up_scholarship(10);
select* from studs; 

# 4.2. Функция, вычисляющая среднюю оценку на экзамене у определённго преподавателя
DELIMITER //
create function find_avg_mark_teacher(t_id varchar(50))
returns float
begin 
	declare av_mark float;
    select avg(exam_mark) into av_mark from exams
    where exams.t_id = t_id;
    return av_mark;
end//
DELIMITER ;

select* from exams;
insert into exams(t_id,ref_sub_id,ref_st_id,exam_date,exam_mark) values(2,1,1,'2021-10-14',5);
select find_avg_mark_teacher(2);

-- 4.3. Процедура для начисления надбавок общественно активным студентам. Критерий
-- начисления надбавок, должен быть привязан к некоторому числовому параметру.
describe activity;
DELIMITER //
create procedure up_scholarship_activity()
begin
	declare id integer;
    declare done int default 0;
    declare activet integer;
    declare scholar integer;
    declare studscur cursor for select studs.st_id,studs.st_scholarship,sum(activity.act_hours) from studs inner join activity on studs.st_id = activity.st_id group by studs.st_id;
    declare continue handler for not found set done = 1;
    open studscur;
	curs: loop
		fetch studscur into id,scholar,activet;
        if done then
			leave curs;
		end if;
        update studs set st_scholarship = case 
        when scholar = 0 then scholar + 5*activet
        else scholar*(1+0.05*activet) end where studs.st_id = id; 
	end loop curs;
    close studscur;
	end//
DELIMITER ;

insert into activity(st_id,act_name,act_date,act_hours) values(1,"act","2012-12-12",2),(1,"act","2012-12-13",2);
insert into activity(st_id,act_name,act_date,act_hours) values(2,"act","2012-12-12",2),(2,"act","2012-12-13",2);
insert into activity(st_id,act_name,act_date,act_hours) values(2,"act","2012-12-12",2),(2,"act","2012-12-13",2);

call  up_scholarship_activity();
select* from  studs;


-- 4.4. Процедуры для вывода топ-5 самых успешных студентов факультета, топ-5 «двоечников»,
-- топ-5 самых активных. Результаты курсором записать в новые таблицы

create table if not exists top_5_best_stud 
(
best_id integer,
best_name varchar(30),
best_surname varchar(30),
valuee float
);
DELIMITER //
create procedure top_5_best()
begin
	declare n,sn varchar(30);
    declare id integer;
    declare is_end int default 0;
    declare val float;
    declare studscur cursor for select st_id,st_name,st_surname,st_value from studs order by st_value desc limit 5;
    declare continue handler for not found set is_end = 1;
    open studscur;
	curs: loop
		fetch studscur into id,n,sn,val;
        if is_end then
			leave curs;
		end if;
        insert into top_5_best_stud values(id,n,sn,val);
	end loop curs;
    close studscur;
    end//
DELIMITER ;
call top_5_best;
select* from top_5_best_stud;

create table if not exists top_5_worst_stud 
(
worst_id integer,
worst_name varchar(30),
worst_surname varchar(30),
valuee float
);

DELIMITER //
create procedure top_5_worst()
begin
	declare n,sn varchar(30);
    declare st_id integer;
	declare val float;
    declare is_end int default 0;
    declare studscur cursor for select st_id,st_name,st_surname,st_value from studs order by st_value asc limit 5;
    declare continue handler for not found set is_end = 1;
    open studscur;
	curs: loop
		fetch studscur into st_id,n,sn,val;
        if is_end then
			leave curs;
		end if;
        insert into top_5_worst_stud values(st_id,n,sn,val);
	end loop curs;
    close studscur;
    end//
DELIMITER ;
call top_5_worst;
select* from top_5_worst_stud;


create table if not exists top_5_active_stud 
(
act_id integer,
act_name varchar(30),
act_surname varchar(30),
act_hors integer 
);

DELIMITER //
create procedure top_5_active()
begin
	declare n,sn varchar(30);
    declare id,a_pm integer;
    declare is_end int default 0;
    declare studscur cursor for select studs.st_id,studs.st_name,studs.st_surname,sum(activity.act_hours) as hours
		from studs 
		inner join activity
		on studs.st_id = activity.st_id
        group by studs.st_id
        order by sum(activity.act_hours) desc limit 5;
    declare continue handler for not found set is_end = 1;
    open studscur;
	curs: loop
		fetch studscur into id,n,sn,a_pm;
        if is_end then
			leave curs;
		end if;
        insert into top_5_active_stud values(id,n,sn,a_pm);
	end loop curs;
    close studscur;
    end//
DELIMITER ;

call top_5_active;
select* from top_5_active_stud; 

-- 4.5. Процедура для отчисления проблемных студентов. Подумайте о проверке условий отчисления. 
describe small_exams;
 DELIMITER //
create procedure expel(in id int)
begin
	if (select count(exam_mark) from exams where ref_st_id = id and exam_mark<4) > 3 then delete from studs where st_id = id;
    end if;
    if (select count(sm_mark) from small_exams where st_id = id and sm_mark < 4) > 3 then delete from studs where st_id = id;
    end if;
end//
DELIMITER ;

insert into exams(t_id,ref_sub_id,ref_st_id,exam_date,exam_mark) values(1,1,1,'2021-10-14',3),(1,1,1,'2021-10-14',3),(1,1,1,'2021-10-14',3);
select* from studs;
select* from exams;
call expel(1);

DELIMITER //
create procedure expel_loop()
begin
declare is_end int default 0;
declare id int;
declare cur cursor for select st_id from studs;
declare continue handler for not found set is_end = 1;
open cur;
curs: loop
	fetch cur into id;
    if is_end then 
		leave curs;
	end if;
    call expel(id);
end loop curs;
close cur;
end//
DELIMITER ;

insert into small_exams(st_id,sub_id,sm_teacher,sm_date,sm_mark) values(2,1,1,"2020-10-12",3);
insert into exams(t_id,ref_sub_id,ref_st_id,exam_date,exam_mark) values(1,1,2,'2021-10-14',3),(1,1,2,'2021-10-14',3),(1,1,2,'2021-10-14',3);

select* from exams;
select* from studs;
call expel_loop;

-- 4.6. Функция вычисляющую самую популярную оценку на факультете (в группе).
DELIMITER //
create function popular_markss_fac()
returns int
begin 
	declare b_mark int;
    select exam_mark into b_mark from exams
    group by exam_mark
    order by count(exam_mark) desc limit 1;
    return b_mark;
end//
DELIMITER ;


select* from exams;
select popular_markss_fac();

DELIMITER //
create function popular_marks_group(gr int,course int)
returns int
begin 
	declare b_mark int;
    select exam_mark into b_mark from exams
    inner join studs
    on studs.st_id = exams.ref_st_id
    where studs.st_group = gr and studs.st_course = course
    group by exam_mark
    order by count(exam_mark) desc limit 1;
    return b_mark;
end//
DELIMITER ;
select* from exams;
select* from studs;
select popular_marks_group(5,3);

-- 4.7. Процедура для вычисления процента пропущенных занятий для студентов определённой группы.

DELIMITER //
create procedure stud_skips(in st_group int,in st_course int)
begin
declare c_att integer;
select count(attend) into c_att from attendance inner join studs on  attendance.st_id = studs.st_id 
where studs.st_group = st_group and studs.st_course = st_course;
select c_att /count(att_id) as att from attendance inner join studs on  attendance.st_id = studs.st_id ;
end//
DELIMITER ;


insert into class (sub_id, t_id,  cl_date, cl_start_time, cl_end_time) values
((select sub_id from subjects where sub_teacher = 1 limit 1), 1,  '2023-10-01', '10:00:00', '11:00:00'),
( (select sub_id from subjects where sub_teacher = 2 limit 1), 2, '2023-10-02', '11:00:00', '12:00:00'),
( (select sub_id from subjects where sub_teacher = 2 limit 1), 2, '2023-10-03', '12:00:00', '13:00:00'),
( (select sub_id from subjects where sub_teacher = 1 limit 1), 1, '2023-10-04', '13:00:00', '14:00:00'),
( (select sub_id from subjects where sub_teacher = 2 limit 1), 2, '2023-10-05', '14:00:00', '15:00:00');
select* from attendance;
select* from studs;
insert into attendance(st_id, sub_id, attend, att_date)  values
(3,1,1,"2023-10-10"),(2,1,1,"2023-10-10");
insert into attendance(st_id, sub_id, attend, att_date)  values
(3,1,0,"2023-10-10"),(2,1,1,"2023-10-10");

call stud_skips(5,3);

-- 4.8. Процедура для вычисления самых лояльных и предвзятых преподавателей на факультете.
-- drop procedure top_teachers;
DELIMITER //
create procedure top_teachers()
begin
declare w_t int;
declare b_t int;
select studs.st_id,studs.st_value,exams.t_id,exams.exam_mark from studs
    inner join exams on studs.st_id = exams.ref_st_id;
set w_t = (select t_id from (select count(tb1.st_value) as bad_grades,tb1.t_id from
    (select studs.st_id,studs.st_value,exams.t_id,exams.exam_mark from studs
    inner join exams on studs.st_id = exams.ref_st_id) as tb1
    where tb1.exam_mark < tb1.st_value group by t_id order by bad_grades desc limit 1) as tb2);
set b_t = (select t_id from (select count(tb1.st_value) as bad_grades,tb1.t_id from
    (select studs.st_id,studs.st_value,exams.t_id,exams.exam_mark from studs
    inner join exams on studs.st_id = exams.ref_st_id) as tb1
    where tb1.exam_mark >= tb1.st_value group by t_id order by bad_grades desc limit 1) as tb2);
select w_t as worst_teacher,b_t as best_teacher;
     end//
DELIMITER ;
select* from exams;
call top_teachers;
select* from studs;
insert into studs(st_name,st_surname,st_group,st_course,st_semestr,speciality,st_form,st_scholarship,st_value) 
value("Name","Sur",4,2,3,"KM",'budget',201,8.9);
insert into exams(t_id,ref_sub_id,ref_st_id,exam_date,exam_mark) values
(2,1,3,'2021-10-14',2),(2,1,2,'2021-10-14',10)
,(2,1,2,'2021-10-14',9),(2,1,2,'2021-10-14',5),(2,1,5,'2021-10-14',7);
select* from exams;

alter table studs add column st_bday date;
-- drop procedure  stud_plus;
DELIMITER //
create procedure stud_plus(in d1 date,in d2 date)
begin
declare is_end int default 0;
declare id int;
declare age int;
declare d3 date;
declare d4 date;
declare cur cursor for select st_id,TIMESTAMPDIFF(YEAR, st_bday, CURDATE()) from studs;
declare continue handler for not found set is_end = 1;
set d3 = case when datediff(d1,d2) < 0 then d1 else  d2 end;
set d4 = case when datediff(d1,d2) < 0 then d2 else  d1 end;
set d1 = d3;
set d2 = d4;
open cur;
curs: loop
	fetch cur into id,age;
    if is_end then 
		leave curs;
	end if;
   update studs set st_scholarship = 
   case when st_bday between d1 and d2 then st_scholarship*(1+0.01*age) else st_scholarship end where st_id = id;
end loop curs;
close cur;
end//
DELIMITER ;
insert into studs(st_name,st_surname,st_group,st_course,st_semestr,speciality,st_form,st_scholarship,st_value,st_bday) 
values("Name","Sur",4,2,3,"KM",'budget',150,8.9,"2005-12-08"),("Name2","Sur2",5,3,5,"KM",'budget',200,5.1,"2004-10-12");
call stud_plus("2003-12-10","2006-10-10");
select* from studs;
call stud_plus("2006-12-10","2003-10-10");
call stud_plus("2006-12-10","2007-10-10");

-- 5.1. Триггер для автоматического изменения размера стипендии в зависимости от успеваемости.
drop trigger update_val;
DELIMITER //
create trigger update_val after insert on exams
for each row
begin
 call value_update;
end//
DELIMITER ;




-- Триггер для автоматического снижения оплаты при успешной успеваемости. 
drop trigger degrade_fee;
DELIMITER //
create trigger degrade_fee before update on studs
for each row
begin
set NEW.st_fee = case 
	when NEW.st_value < 5 and NEW.st_form = 'paid' then NEW.st_fee
	when NEW.st_value between 5 and 5.99 and NEW.st_form = 'paid' then NEW.st_fee - 10
	when NEW.st_value between 6 and 7.99 and NEW.st_form = 'paid' then NEW.st_fee - 20
	when NEW.st_value between 8 and 8.99 and NEW.st_form = 'paid' then NEW.st_fee - 50
	when NEW.st_value between 9 and 10 and NEW.st_form = 'paid' then NEW.st_fee- 100
    else null end;
end//
DELIMITER ;

select* from studs;

insert into exams(t_id,ref_sub_id,ref_st_id,exam_date,exam_mark) values(1,1,4,'2021-10-14',4);
insert into exams(t_id,ref_sub_id,ref_st_id,exam_date,exam_mark) values(2,1,4,'2021-10-14',10),(2,1,4,'2021-10-14',9),(2,1,4,'2021-10-14',7);
insert into small_exams(st_id,sub_id,sm_teacher,sm_date,sm_mark) values(3,1,1,"2020-10-12",3);
insert into exams(t_id,ref_sub_id,ref_st_id,exam_date,exam_mark) values(1,1,5,'2021-10-14',4);

-- Триггер помечающий потенциально проблемных студентов специальным модификатором. 
-- --------------------------------- ДОП проблематичные /////////////////////////////////////////////////////////////

alter table studs modify column problematic int default 0;

drop trigger prob_exams;
DELIMITER //
create trigger prob_exams after insert on exams
for each row
begin
declare val_ex float;
declare val_sm float;
select avg(exam_mark) into val_ex from exams where ref_st_id = new.ref_st_id;
select avg(sm_mark) into val_sm from small_exams where st_id = new.ref_st_id;
update studs set problematic  = case 
		when val_ex < 5 then 3
        when val_sm < 5 then 4 end
        where st_id = new.ref_st_id;
end//
DELIMITER ;
select* from studs;


drop trigger prob_class;
DELIMITER //
create trigger prob_class before insert on attendance 
for each row
begin
declare c_att int;
declare att float;
declare val_class float;
if (select count(att_id) from attendance where st_id = new.st_id) > 0 then 
	select count(attend) into c_att from attendance where attend = 1 and  st_id = new.st_id order by att_id desc limit 1;
select c_att/count(att_id) into att from attendance  where st_id = new.st_id order by att_id desc limit 1;
select avg(att_mark) into val_class from attendance where st_id = new.st_id;

update studs set problematic  = case 
		when att < 0.5 then 1
        when val_class < 5 then 2 end
        where st_id = new.st_id;
	end if;
end//
DELIMITER ;

select* from small_exams;
insert into small_exams(st_id,sub_id,sm_teacher,sm_date,sm_mark) values(31,6,1,"2020-10-12",3);

insert into exams(t_id,ref_sub_id,ref_st_id,exam_date,exam_mark) values(1,3,31,'2021-10-14',10);
insert into attendance(st_id, sub_id, attend, att_date)  values
(28,1,0,"2023-10-10"),(28,1,0,"2023-10-10"),
(28,1,0,"2023-10-10"),(28,1,0,"2023-10-10");
insert into attendance(st_id, sub_id, attend, att_date,att_mark)  values
(29,1,1,"2023-10-10",3),(29,1,1,"2023-10-10",5),
(29,1,1,"2023-10-10",3),(29,1,1,"2023-10-10",2);
select* from attendance;
select* from studs;
select avg(sm_mark) from small_exams where st_id = 26;
select count(att_id) from attendance where st_id = 1;
select* from exams where ref_st_id = 30;

delete from attendance;

delete from studs;
select 5%3;
select* from health;

-- 5.6. Триггер, не допускающий перевода на следующий курс студента с проблемами по линиb sздоровья.
select count(distinct ref_sub_id) from exams where ref_st_id =12 group by ref_sub_id;
drop trigger perevod_course_drop_exams;

DELIMITER //
create trigger perevod_course_drop_exams after update on studs
for each row
begin
declare ex_count int;
select count(distinct ref_sub_id) into ex_count from exams where ref_st_id = new.st_id group by ref_st_id ;
delete from exams where new.st_id = ref_st_id and ex_count > 2;
end//
DELIMITER ;

DELIMITER //
create trigger perevod_course before insert on exams
for each row
begin
if (select count(distinct ref_sub_id) from exams where ref_st_id = new.ref_st_id group by ref_st_id) > 2 then
	if (select st_health_group  from health where new.ref_st_id = st_id) = 3 then 
		SIGNAL SQLSTATE '45000' 
		set message_text = "you are not healthy";
	else
		if (select st_semestr%2 from studs where new.ref_st_id = st_id) = 0 then
			update studs set st_course =  st_course+1 where new.ref_st_id = st_id;
			update studs set st_semestr =  st_semestr+1 where new.ref_st_id = st_id;
			delete from small_exams where new.ref_st_id = st_id;
		else update studs set st_semestr = st_semestr+1  where new.ref_st_id = st_id;
			delete from small_exams where new.ref_st_id = st_id;
		end if;
	end if;
end if;
end//
DELIMITER ;

select* from subjects;
select* from exams;
insert into exams(t_id,ref_sub_id,ref_st_id,exam_date,exam_mark) values(1,5,37,'2021-10-14',5);
select* from studs;
select* from health;
delete from health;
insert into health(h_id,st_id, st_health_group) value(1,37,3);
insert into health(h_id,st_id, st_health_group) value(1,36,2);








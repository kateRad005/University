drop database bank22DB;
create database if not exists bank22DB;
use bank22DB;

set sql_safe_updates = 0;
set autocommit = 0;

create table if not exists person
(
person_id int primary key auto_increment,
person_name varbinary(225),
person_surname varbinary(225),
person_adress varbinary(225),
person_status enum('loh','ne loh'),
person_date date
);

select* from person;
drop table account;
create table if not exists account
(
p_id integer,
acc_type enum('open','closed'),
acc_balance double,
acc_number varbinary(225) primary key,
acc_start_date datetime,
constraint cn1 foreign key(p_id) references person(person_id)
);

create table if not exists operations 
(
op_id int primary key auto_increment,
op_type enum('cash withdrawal','money transfer','receipt of funds','payment')
);

create table if not exists appointment
(
app_id int primary key auto_increment,
app_op int,
app_sender varbinary(225),
app_recipient varbinary(224),
app_time datetime,
app_value double,
app_contr_number double,
op_id integer,
acc_num varbinary(225),
constraint cn2 foreign key(op_id) references operations(op_id),
constraint cn3 foreign key(acc_num) references account(acc_number) 
);
select* from appointment;

select* from account;
select* from person;


DELIMITER // 
create trigger encrypt_person before insert on person
for each row
begin
set new.person_name = aes_encrypt(new.person_name,'key');
set new.person_surname = aes_encrypt(new.person_surname, 'key');
set new.person_adress = aes_encrypt(new.person_adress,'key');
end //
DELIMITER ;

DELIMITER // 
create trigger encrypt_acc before insert on account
for each row
begin
set new.acc_number = aes_encrypt(new.acc_number,'key');
end //
DELIMITER ;
insert into person (person_name, person_surname, person_adress, person_status, person_date) values
('Иван', 'Иванов', 'Москва, ул. Ленина, д. 1', 'loh', '2023-01-15'),
('Петр', 'Петров', 'Санкт-Петербург, ул. Пушкина, д. 2', 'ne loh', '2023-02-20'),
('Светлана', 'Сидорова', 'Екатеринбург, ул. Чехова, д. 3', 'loh', '2023-03-10'),
('Анна', 'Антонова', 'Казань, ул. Горького, д. 4', 'ne loh', '2023-04-05'),
('Дмитрий', 'Дмитриев', 'Новосибирск, ул. Маяковского, д. 5', 'loh', '2023-05-25');
insert into account (p_id, acc_type, acc_balance, acc_number, acc_start_date) values
(1, 'open', 1500.75, '9111 0001 4578 1111', '2023-01-15 10:00:00'),
(2, 'closed', 2500.00, '9111 0001 4578 2222', '2022-05-20 14:30:00'),
(3, 'open', 3200.50, '9111 0001 4578 3333', '2023-03-10 09:15:00'),
(1, 'open', 500.00, '9111 0001 4578 4444', '2023-02-01 11:45:00'),
(2, 'closed', 0.00, '9111 0001 4578 5555', '2021-12-31 16:00:00');

select* from account;
select* from person;


start transaction;
update account set acc_balance = acc_balance - 100
where acc_number = aes_encrypt('9111 0001 4578 1111','key');
commit;

-- Транзакция проходила без проверки на то, что отправляющий станет бомжом 
drop procedure `transfer1`;
DELIMITER //
create procedure `transfer1` (in sender varbinary(225),in rec varbinary(225),in sum double)
begin
start transaction;
update account 
set acc_balance = acc_balance - sum
where acc_number = sender;
if (select acc_balance from account where acc_number = sender) < 0
then rollback;
signal sqlstate '45000'
	set message_text = 'Transaction rolled back: Insufficient funds';
else
if row_count()>0
	then
    update account 
    set acc_balance = acc_balance + sum
    where acc_number = rec;
    if row_count() > 0
		then 
        insert into appointment
		(app_op, app_sender, app_recipient, app_time, app_value, app_contr_number)
        values (3,sender,rec,now(),sum,rand(10));
        commit;
	else rollback;
end if;
else rollback;
end if;
end if;
end//
DELIMITER ;

call transfer1(aes_encrypt('9111 0001 4578 1111','key'),aes_encrypt('9111 0001 4578 2222','key'),1500);
select* from account;

-- 1.2. Создайте аналогичные транзактные методы для пополнения счёта и снятия средств со счёта. 

drop procedure `rec_of_funds`;
DELIMITER //
create procedure `rec_of_funds` (in rec varbinary(225),in sum double)
begin
start transaction;
update account 
set acc_balance = acc_balance + sum
where acc_number = rec;
    if row_count() > 0
		then 
        insert into appointment
		(app_op, app_recipient, app_time, app_value, app_contr_number)
        values (1,rec,now(),sum,rand(10));
        commit;
	else rollback;
end if;
end//
DELIMITER ;
select* from account;
call rec_of_funds(aes_encrypt('9111 0001 4578 1111','key'),100);


drop procedure `reduce`;

DElIMITER //
create procedure `reduce` (in sender varbinary(225),in sum double)
begin
start transaction;
update account 
set acc_balance = acc_balance - sum
where acc_number = sender;
if (select acc_balance from account where acc_number = sender) < 0
then rollback;
signal sqlstate '45000'
	set message_text = 'Transaction rolled back: Insufficient funds';
else
    if row_count() > 0
		then 
        insert into appointment
		(app_op, app_sender, app_time, app_value, app_contr_number)
        values (2,sender,now(),sum,rand(10));
        commit;
	else rollback;
end if;
end if;
end//
DELIMITER ;

call reduce(aes_encrypt('9111 0001 4578 1111','key'),200);
call reduce((select acc_number from account where p_id = 3),300);
select* from account;

-- --------кредиты------------------------------
create table if not exists credit
(
client_id int,
credit_type enum ('diff','anuent'),
credit_sum double,
credit_month int,
precents int,
first_pay_day date,
constraint cn4 foreign key(client_id) references person(person_id)
);

create table credit_graph
(
client_id int,
cl_month int,
credit_sum double,
constraint cn5 foreign key(client_id) references person(person_id)
);


drop procedure credit_graph;
DELIMITER //
create procedure credit_graph(in id int)
begin
declare id int;
declare sums double;
declare dates int;
declare dates2 int;
declare f_date date;
declare typec enum ('diff','anuent'); 
declare done int default 0;
declare rest double;
declare pers int;
declare cur cursor for select client_id,credit_type,credit_sum,credit_month,first_pay_day,precents from credit;
declare continue handler for not found set done = 1;
set done = dates;
open cur;
curs:loop
	fetch cur into id,typec,sums,dates,f_date,pers;
	if done then 
		leave curs;
    end if;
    set dates2 = dates;
    if typec = 'diff' then
        insert into credit_graph values(id,date_add(f_date, interval 1 month),sums/dates+sums*0.01*pers/dates2);
		set f_date = date_add(f_date, interval 1 month);
        select f_date;
        select sums - sums / dates into rest;
        set dates2 = dates2 - 1;
        select dates2;
	else if typec = 'anuent' then
    begin 
    declare done2 int default 0;
	declare continue handler for not found set done2 = 1;
    cred:loop
		if done2 then
			leave cred;
		end if;
        insert into credit_graph values(id,date_add(f_date, interval 1 month),((0.01*pers *(1+dates)^dates)/((1+0.01*pers)^dates-1))*sums);
        set f_date = date_add(f_date, interval 1 month);
        select f_date;
		select sums - sums / dates into rest;
        set dates2 = dates2 - 1;
	end loop;
    end;
    end if;
    end if;
end loop;
close cur;
end//
DElIMITER ;
select* from credit;
select* from person;
insert into credit(client_id, credit_type, credit_sum, credit_month, precents, first_pay_day) 
value(1,'diff',1000,12,7,'2020-10-13');
call credit_graph;
select* from credit_graph;
select date_add('2020-12-13' , interval 1 month);
    
select* from account;
start transaction;
update account set acc_balance = 1200 where p_id = 3;







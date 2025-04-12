drop database if exists shop;
create database if not exists shop;
use shop;

create table if not exists shop(
id int auto_increment primary key,
address varchar(30)
);


create table if not exists worker(
id int auto_increment primary key,
w_name varchar(30),
w_surname varchar(30),
shop_id int,
constraint cn1 foreign key (shop_id) references shop(id)
);

create table if not exists warehouse(
id int auto_increment primary key,
address varchar(30)
);

create table if not exists product(
id int auto_increment primary key,
pr_name varchar(30),
price float
);

create table if not exists products_warehouse(
pr_id int,
w_id int,
amount int,
primary key(pr_id, w_id),
constraint cn2 foreign key (pr_id) references product(id),
constraint cn3 foreign key (w_id) references warehouse(id)
);

create table if not exists shop_prod(
shop_id int,
pr_id int,
amount int,
primary key(shop_id, pr_id),
constraint cn4 foreign key (pr_id) references product(id),
constraint cn5 foreign key (shop_id) references shop(id)
);

create table if not exists customer(
id int auto_increment primary key,
cust_name varbinary(30),
cust_surname varbinary(30),
cust_address varbinary(30),
bonus float default 0
);

create table if not exists sells(
id int auto_increment primary key,
shop_id int,
cust_id int,
w_id int,
pr_id int,
amount int,
total_price float,
sell_date datetime,
constraint cn6 foreign key (pr_id) references product(id),
constraint cn7 foreign key (shop_id) references shop(id),
constraint cn8 foreign key (w_id) references worker(id),
constraint cn9 foreign key (cust_id) references customer(id)
);


insert into shop (address) values ("Minsk"), ("Gomel");
insert into warehouse (address) values ("Add1"),("Addd2");
insert into worker (w_name, shop_id) values ("Nastya", 1), ("Artem", 1), ("Duben",2);
insert into product (pr_name, price) values ("watermelon", 10),("melon",9),("apple",10);
insert into products_warehouse (pr_id, w_id, amount) values (1,1,100), (1,2,40), (2,1,120), (3,2,10);
insert into shop_prod (pr_id, shop_id, amount) values (1,1,13),(2,1,10),(3,2,1);
insert into customer (cust_name) values ("Mile"), ("Maymayaha");
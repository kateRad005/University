-- вариант 7
use world;
set sql_safe_updates = 0; 
describe city;
describe country;
describe countrylanguage;
-- 1. Выведите все города мира, в которых можно услышать французский язык.
select city.Name, countrylanguage.Language
from city
left join countrylanguage
on  city.CountryCode = countrylanguage.CountryCode
where countrylanguage.Language = "French";


-- 2. Какой процент населения планеты проживает в странах с ВНП ниже 10000?
select 100*tb1.summ/big.bigSum Pers
from (select sum(Population) as summ  from (select Population from country where GNP < 10000 )sub) as tb1,
(select Sum(Population) as bigSum from country) as big;

select 100*tb1.summ/big.bigSum Pers
from (select sum(Population) as summ  from (select Population from country where GNP >= 10000 )sub) as tb1,
(select Sum(Population) as bigSum from country) as big;

-- 3. Выведите языки мира, занимающие по числу стран использования в мире позиции с 20 по 27.
select Language,id from (select Language, lang, row_number() over() as id 
from(select Language, count(Language) as lang from countrylanguage as tb1
group by Language order by lang desc) as tb2) as tb3 where id between 20 and 27;
 
 select Language, count(Language) as lang from countrylanguage as tb1
group by Language order by lang desc;

select country.Name, countrylanguage.Language
from country
left join countrylanguage
on country.Code = countrylanguage.CountryCode
where countrylanguage.Language = 'Belorussian';

-- 4. Сколько городов Украины имеют население превосходящее число людей,говорящих в Украине на русском.
select country.Name, countrylanguage.Language,countrylanguage.Percentage
from country
left join countrylanguage
on country.Code = countrylanguage.CountryCode
where country.Name  = 'Ukraine';

select country.Name, city.Name, pop from country,city,
(select country.Name, countrylanguage.CountryCode, country.Population *0.01*countrylanguage.Percentage
 as pop from country, countrylanguage
 where country.Name = 'Ukraine' and  countrylanguage.CountryCode = 'UKR' and countrylanguage.Language = "Russian") as tb1 where city.Population > pop and country.Name = 'Ukraine'  ;

select country.Name,city.Name, countrylanguage.Language, city.Population
from country
left join city
on country.Code = city.CountryCode
left join countrylanguage
on  city.CountryCode = countrylanguage.CountryCode
where country.Name = "Ukraine" and city.Population > 16600024;


-- 5. Выведите города России, в которых проживает не более 100000 человек. 

select country.Name,city.Name,city.Population
from city
left join country
on country.Code = city.CountryCode
where country.Name = 'Russian Federation' and city.Population <= 100000;

#select country.Name,city.Name,city.Population
#into outfile 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\lb3.txt secure-file-priv2.txt'
#fields terminated by ','
#from city
#ileft join country
#on country.Code = city.CountryCode
#where country.Name = 'Russian Federation' and city.Population <= 100000; 

#SHOW VARIABLES LIKE "secure_file_priv";


use lb1_bar;


-- 1.1. Запрос к 4 –ем таблицам одновременно.
select product_name,employee_name,sell_amount,quantity 
from products_sells
left join sells
on sells.sell_id = products_sells.sell_id
left join products
on products.product_id = products_sells.product_id
left join staff
on staff.employee_id = sells.sell_id;

-- 1.2. 5 запросов на группировку.
select products.product_name,count(products_sells.quantity) as counts
from products
left join products_sells
on products.product_id = products_sells.product_id
group by products.product_name;

select staff.employee_name,avg(contracts.salary) as salary 
from staff
left join contracts
on contracts.employee_id = staff.employee_id
group by staff.employee_name;

select staff.employee_name,max(contracts.salary) as salary 
from staff
left join contracts
on contracts.employee_id = staff.employee_id
group by staff.employee_name having max(contracts.salary)>=1500;

select staff.employee_name,min(sells.sell_date) 
from staff
left join sells
on staff.employee_id = sells.sell_id
group by staff.employee_name;

select staff.employee_name,min(sells.sell_date),avg(contracts.salary)
from staff
left join sells
on staff.employee_id = sells.sell_id
left join contracts
on contracts.employee_id = staff.employee_id
group by staff.employee_name having min(contracts.salary)>1500;

-- 1.3. 3 вложенных запроса.

select product_name,counts
from (select products.product_name,count(products_sells.quantity) as counts
from products
left join products_sells
on products.product_id = products_sells.product_id
group by products.product_name) as tb1;

select employee_name,average from
(select staff.employee_name,min(sells.sell_date),avg(contracts.salary) as average
from staff
left join sells
on staff.employee_id = sells.sell_id
left join contracts
on contracts.employee_id = staff.employee_id
group by staff.employee_name having min(contracts.salary)>=1500) as tb2
group by employee_name;

select employee_name, min(dates) as d from
(select staff.employee_name,min(sells.sell_date) as dates
from staff
left join sells
on staff.employee_id = sells.sell_id
group by staff.employee_name) as tb3
group by employee_name;

-- 1.4. Запрос с использованием операций над множествами.
select employee_name from staff union all select sell_date from sells union all select employee_id from staff;
select employee_id from  staff except select sell_id from sells;

select employee_id from  staff intersect select sell_id from sells;

select employee_id from  staff intersect select sell_amount from sells;

select employee_id from  staff except select sell_amount from sells;

-- 1.5. Обновление таблиц с использованием оператора соединения.
update products 
set product_name = 
(select min(staff.employee_id) 
from staff
left join contracts
on staff.employee_id = contracts.employee_id
group by staff.employee_name limit 1);
  
select* from products;

-- 1.6. Запрос с использованием оконных функций.

select*,row_number() over (partition by product_name order by product_type desc) as ord from products;

select*,rank() over (partition by product_name order by product_type desc) as ord from products;

select*,rank() over (partition by product_type order by product_id) as ord from products;

select*, avg(product_price) over (order by product_type rows between 2 preceding and current row) as ord from products;


-- 3. Создайте представления для различных участников проекта из ЛР1. (Администратора,
-- продавца, рабочего…). Преобразуйте данные необходимым образом. Учитывайте
-- уровень и степень доступа к данным. 
use LB1_chem;

create or replace view client_view (product_name,formula,dangerous,effect,price,avaibility) as select
product_name,formula,dangerous,effect,price,avaibility from product;
select* from client_view;

create or replace view client_order_view (product_name,order_date,quantity) as
select product.product_name,orders.order_date,orders.quantity
from product
left join orders
on product.product_id = orders.prod_id;

select* from client_order_view;

create or replace view shop_admin_view(product_name,price,avaibility,adress,quantity) as 
select  product.product_name,product.price,product.avaibility,warehouse.adress,warehouse_prod.quantity
from warehouse_prod
left join product
on  warehouse_prod.prod_id = product.product_id
left join warehouse
on warehouse_prod.ware_id = warehouse.warehouse_id;

select* from shop_admin_view;

create or replace view order_collector_view(product_name,quantity,order_date,client_name,client_surname,client_number,adress) as 
select product.product_name,orders.quantity,orders.order_date,clients.client_name,clients.client_surname,clients.phone_number,clients.adress
from orders
left join product
on product.product_id = orders.prod_id
left join clients
on clients.client_id = orders.client_id;


use world;
select* from order_collector_view;
describe countrylanguage;
-- ля каждого континента вывести количество  официальных языкоа ДОПИСАТЬ

select count(countrylanguage.Language),country.Continent
from country
left join countrylanguage
on country.Code = countrylanguage.CountryCode group by country.Continent;

-- Найти страны в которых население второго по величине городу 
-- по населению в два раза больше чем население столицы каких-то других стран 
-- (страны для которых это выполняется вывести в груп конкат рядом в ячейке)
describe city;

select city.ID,city.Name, city.Population
from country
left join city
on country.Capital = city.ID;

select S_name,Population from (select city.Name as S_name ,city.Population, 
Rank() over(partition by CountryCode order by city.Population desc) as r from city) as tb1 where r = 2;


select Con_name,S_name,Population,group_concat(C_name separator ', ') as Contries,group_concat(Pop separator ', ') as Populations from (select city.ID as c_ID,city.Name as S_name ,city.Population, 
Rank() over(partition by CountryCode order by city.Population desc) as r , country.Name as Con_name from 
city left join country on country.Code = city.CountryCode) as tb2,
(select country.Name as C_name, city.Population as Pop,city.Name as cap_city,city.ID
from country
left join city
on country.Capital = city.ID) as tbS where r = 2 and Population > Pop group by Con_name, S_name,Population;

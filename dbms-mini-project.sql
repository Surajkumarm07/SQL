create database mini_project;
use mini_project;
select * from cust_dimen;
select * from market_fact;
select * from orders_dimen;
select * from prod_dimen;
select * from shipping_dimen;

-- Question 1: Find the top 3 customers who have the maximum number of orders

select * from
(select *,dense_rank()over( order by no_of_orders desc) rnk from
(select cd.cust_id,cd.customer_name,count(mf.ord_id) as no_of_orders
from cust_dimen cd join market_fact mf
on cd.Cust_id=mf.Cust_id
group by cd.cust_id)t)t1
where rnk<=3;
 

-- Question 2: Create a new column DaysTakenForDelivery that contains the date difference between Order_Date and Ship_Date.
select * from
(select sd.order_id,od.Order_Date,sd.ship_date,
datediff(str_to_date(sd.ship_date,"%d-%m-%Y"),str_to_date(od.order_date,"%d-%m-%Y")) DaysTakenForDelivery
from orders_dimen od join shipping_dimen sd
on od.Order_ID=sd.Order_ID
group by sd.order_id)t
order by DaysTakenForDelivery desc ;

-- we get null values without converting str to date

-- Question 3: Find the customer whose order took the maximum time to get delivered.
select * from
(select cd.cust_id,cd.customer_name,sd.order_id,od.Order_Date,sd.ship_date,
datediff(str_to_date(sd.ship_date,"%d-%m-%Y"),str_to_date(od.order_date,"%d-%m-%Y")) DaysTakenForDelivery
from orders_dimen od join shipping_dimen sd
on od.Order_ID=sd.Order_ID
join market_fact mf 
on od.Ord_ID=mf.Ord_id
join cust_dimen cd
on mf.Cust_id=cd.Cust_id
group by sd.order_id)t
order by DaysTakenForDelivery desc limit 10 ;
select * from market_fact;

-- Question 4: Retrieve total sales made by each product from the data (use Windows function)
select * from
(select distinct prod_id,sum(sales)over(partition by prod_id ) total_sales from market_fact)t
order by total_sales desc;


-- Question 5: Retrieve the total profit made from each product from the data (use windows function)
select * from
(select distinct prod_id,sum(profit)over(partition by prod_id) total_profit from market_fact)t
order by total_profit desc;

-- Question 6: Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011

 -- Count the total number of unique customers in January
select count(distinct cust_id)  uniq_cust_jan
from market_fact mf join orders_dimen od
on mf.Ord_id=od.Ord_id 
where month(str_to_date(order_date,"%d-%m-%Y"))=01 and year(str_to_date(order_date,"%d-%m-%Y"))=2011;

-- how many of them came back every month over the entire year in 2011
select month(str_to_date(order_date,"%d-%m-%Y")) months ,count(distinct cust_id) uni_customers
from market_fact mf join orders_dimen od
on mf.Ord_id=od.Ord_id 
where (month(str_to_date(order_date,"%d-%m-%Y")) between 01 and 12) and year(str_to_date(order_date,"%d-%m-%Y"))=2011 and cust_id in 
(select distinct cust_id from market_fact mf join orders_dimen od
on mf.Ord_id=od.Ord_id where month(str_to_date(order_date,"%d-%m-%Y"))=01 and year(str_to_date(order_date,"%d-%m-%Y"))=2011)
group by  month(str_to_date(order_date,"%d-%m-%Y")) ;

# ---------------------------------
# part--2


create database mini_project_2;
use mini_project_2;

select * from geoplaces2;
select * from userprofile;

-- Question 1: - We need to find out the total visits to all restaurants under all alcohol categories available.
select count(up.userid),alcohol total_visits
from userprofile up join rating_final rf
on up.userid=rf.userid
join geoplaces2 gp
on gp.placeid=rf.placeid
group by alcohol;

select * from rating_final;
-- Question 2: -Let's find out the average rating according to alcohol and price 
-- so that we can understand the rating in respective price categories as well.
select avg(rf.rating) rtng,gp.alcohol,gp.price 
from geoplaces2 gp join rating_final rf
on gp.placeid=rf.placeid
group by gp.alcohol,gp.price
order by avg(rf.rating) desc;


-- Question 3:  Let’s write a query to quantify that what are the parking availability as well in different alcohol categories
-- along with the total number of restaurants.
select * from chefmozparking; 
select cp.parking_lot,gp.alcohol,count(gp.placeid)
from chefmozparking cp join geoplaces2 gp
on cp.placeid=gp.placeid
group by alcohol,parking_lot
order by parking_lot;

-- Question 4: -Also take out the percentage of different cuisine in each alcohol type.
select * from chefmozcuisine;
select *,(cnt_cuisine/cnt_alcohol)*100 percent from
(select gp.alcohol,cc.rcuisine,count(cc.rcuisine)over(partition by cc.rcuisine) cnt_cuisine,
count(gp.alcohol)over(partition by gp.alcohol) cnt_alcohol
from chefmozcuisine cc join geoplaces2 gp
on cc.placeid=gp.placeid)t
group by alcohol,rcuisine;



-- Let us now look at a different prospect of the data to check state-wise rating.


-- Questions 5: - let’s take out the average rating of each state.
select avg(rf.rating) st_ise_rating,gp.state
from rating_final rf join geoplaces2 gp
on rf.placeid=gp.placeid
group by state
order by avg(rating) desc;


-- Questions 6: -' Tamaulipas' Is the lowest average rated state. Quantify the reason 
-- why it is the lowest rated by providing the summary on the basis of State, alcohol, and Cuisine.
select rf.placeid,gp.name,gp.alcohol,gp.price,gp.area,cc.rcuisine,gp.smoking_area,gp.accessibility,cp.parking_lot,rf.rating
from geoplaces2 gp join chefmozcuisine cc
on gp.placeid=cc.placeid 
join rating_final rf
on gp.placeid=rf.placeID
join chefmozparking cp
on rf.placeID=cp.placeID
where gp.state="Tamaulipas"
order by rf.rating;

select * from geoplaces2;
-- Question 7:  - Find the average weight, food rating, and service rating of the customers 
-- who have visited KFC and tried Mexican or Italian types of cuisine, and also their budget level is low.
-- We encourage you to give it a try by not using joins.

select up.userid,avg(up.weight),rf.food_rating,rf.service_rating,gp.name,uc.rcuisine,up.budget
from userprofile up join rating_final rf
on up.userid = rf.userID
join usercuisine uc
on up.userID=uc.userid
join geoplaces2 gp
on rf.placeID=gp.placeID
where gp.name="KFC" and up.budget="low"  and (uc.Rcuisine="Mexican" or "Italian")
group by up.userid,uc.Rcuisine,up.budget;


select userid,weight from userprofile where budget="low" and userid in 
(select userID from usercuisine where (Rcuisine="Mexican" or "Italian") and userID in
(select userid from rating_final where placeid in
(select placeID from geoplaces2 where name="Kfc")));


# ---------
# part--3

create database students;
create table Student_details 
(student_id int not null primary key,
student_name varchar(20),
mail_id varchar(20),
mobile_no varchar(20));

create table Student_details_backup
(student_id int not null,
student_name varchar(20),
mail_id varchar(20),
mobile_no varchar(20),
foreign key (student_id) references Student_details(student_id));

create trigger aft_insert after insert
on student_details for each row 
insert into student_details_backup values 
(new.student_id, new.student_name, new.mail_id, new.mobile_no);

insert into student_details values 
(101, 'ABC', 'pqr@gmail.com', '9887900988');

insert into student_details values 
(102, 'DEF', 'stu@gmail.com', '8393848899'),
(103, 'GHI', 'xyz@gmail.com', '7446788539');

select * from student_details;
select * from student_details_backup;




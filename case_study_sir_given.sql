create schema e_commerce;
create table customer(
customer_id int primary key,
customer_name varchar(40),
city varchar(20),
customer_segment varchar(30),
signup_date date);
insert into customer values(
001,"Amit sharma","Delhi","Premium",'2024-01-10'),
(002,"Priya verma ","Mumbai","Regular","2024-01-15"),
(003,"Rahul Mehta","Delhi","Premium","2024-02-01"),
(004,"Sneha kapoor","Banglore","Regular", "2024-02-10"),
(005,"Vikash singh","Mumbai","Premium","2024-02-15"),
(006,"Neha Gupta","Delhi","Regular","2024-03-01"),
(007,"Rohit jain","Banglore","Premium","2024-03-05"),
(008,"Pooja Agrawal","Mumbai","Regular","2024-03-10"),
(009,"Karan Malhotra","Delhi","Regular","2024-03-15"),
(110,"Anjali Nair","Banglore","Premium","2024-03-20");
select *from customer;
create table product(
Product_id int primary key,
Product_name varchar(30),
Category varchar(30),
unit_price int,
cost_price int);
insert into product values(
101,"laptop","Electronics",60000,45000),
(102,"Smartphone","Electronics",30000,22000),
(103,"Headphones","Electronics",2500,1500),
(104,"Office chair","Furniture",8000,5000),
(105,"Study table","Furniture",12000,8000),
(106,"Keyboard","Accesories",1800,1000),
(107,"Mouse","Accesories",1200,600),
(108,"Monitor","Electronics",15000,11000),
(109,"Backpack","Bag",3000,1800),
(110,"Smart watch", "Electronics",7000,4500);
select *from product;
create table order_details(
order_id int primary key,
customer_id int,
product_id int,
order_date date,
quantity int,
discount_pct int);
insert into order_details values(
01001,001,101,"2024-04-01",1,5),
(01002,002,102,"2024-04-02",1,10),
(01003,001,103,"2024-04-05",2,0),
(01004,003,104,"2024-04-06",1,5),
(01005,004,105,"2024-04-10",1,15),
(01006,002,106,"2024-04-12",3,0),
(01007,005,107,"2024-04-15",4,5),
(01008,001,108,"2024-04-24",1,10),
(01009,003,109,"2024-04-22",2,0),
(01010,002,110,"2024-04-25",2,5);
select *from order_details;
/* 1. CUSTOMER REVENUE AND PROFITABILITY ANALYSIS
The Sales Director wants a complete analysis of customer performance. Prepare a customer-level report by 
combining information from all three tables. For every customer who has placed at least one order, 
calculate the total number of orders placed, total units purchased, gross revenue generated, total discount given, 
net revenue generated, and total profit generated for the company. Along with these metrics, include the customer's
 name, city, and customer segment.

The final report should help management identify which customers are generating the highest business value. 
Sort the report so that the customer generating the highest net revenue appears first.

Concepts being tested:
Multi-table JOIN, calculated fields, COUNT, SUM, GROUP BY, and business metric calculation.*/
select *
from  customer c 
join order_details o 
	on c.customer_id=o.customer_id 
join product p 
	on p.product_id = o.product_id;
select c.customer_id,
	c.customer_name,
    c.city,
    c.customer_segment,
    count(o.order_id) as total_order,
    sum(o.quantity) as total_unit_purchased,
    sum(o.quantity * p.unit_price) as total_revenue,
    sum((o.quantity*p.unit_price) * o.discount_pct/100) as total_discount,
    sum((o.quantity *p.unit_price) - (o.quantity*p.unit_price) * o.discount_pct/100) as net_revenue,
    sum((o.quantity *p.unit_price) - (o.quantity*p.unit_price) * o.discount_pct/100 -
    (p.cost_price * o.quantity)) as Total_profit
    from customer c
    join order_details o 
    on c.customer_id=o.customer_id
    join product p 
    on p.product_id=o.product_id
    group by
    c.customer_id,
    c.customer_name,
    c.city,
    c.customer_segment;
/*QUESTION 2: CATEGORY PERFORMANCE AND PRODUCT CONTRIBUTION
============================================================

The Product Management team wants to evaluate category-level performance. Create a report that shows the
 performance of every product category after joining the transaction and product data. For each category, 
 calculate the number of unique products sold, total quantity sold, total gross revenue, total discount amount, 
 net revenue, and total profit.

However, management does not want to see every category blindly. Only include categories that have generated 
a net revenue of more than ₹10,000. Finally, rank the categories based on their total net revenue, 
with the highest revenue-generating category ranked first.

The key objective is to identify the categories that are contributing the most to the company's business.

Concepts being tested:
JOIN, aggregation, GROUP BY, HAVING, and ranking using a window function.*/
/* Q2 Using the joined data, calculate the Gross Revenue for every order using the formula:
 Gross Revenue = Unit Price × Quantity. Display the order ID, product name, quantity, unit price, and gross revenue.*/
 select c.customer_id,
	c.customer_name,
    c.city,
    c.customer_segment,
    sum(o.quantity * p.unit_price) as total_revenue
    from customer c
    join order_details o 
    on c.customer_id=o.customer_id
    join product p 
    on p.product_id=o.product_id
    group by
    c.customer_id,
    c.customer_name,
    c.city,
    c.customer_segment;
    /* Q3. Calculate the Discount Amount for every order using the discount percentage available 
    in the Order_Details table. Display the order ID, gross revenue, discount percentage, and discount amount.*/
    select o.order_id,
		o.discount_pct AS discount_percentage,
        sum(o.quantity * p.unit_price) as gross_revenue,
        ((o.quantity * p.unit_price)*o.discount_pct/100) as discount_amount
       from customer c
		join order_details o 
		on c.customer_id=o.customer_id
		join product p 
		on p.product_id=o.product_id
		group by
        o.order_id,
        o.discount_pct,
		o.quantity,
		p.unit_price;
/*4. Calculate the Net Revenue for every order after applying the discount. 
Display the order ID, product name, gross revenue, discount amount, and net revenue.*/
select order_id,
		product_name,
        (o.quantity * p.unit_price) as gross_revenue,
        ((o.quantity * p.unit_price)*o.discount_pct/100) as discount_amount,
        ((o.quantity *p.unit_price) - (o.quantity*p.unit_price) * o.discount_pct/100) as net_revenue
        from customer c
		join order_details o 
		on c.customer_id=o.customer_id
		join product p 
		on p.product_id=o.product_id;
	/* Q5.Calculate the Profit generated from every order using the formula: 
Profit = Net Revenue − Total Cost, where Total Cost = Cost Price × Quantity. 
Display the order ID, product name, net revenue, total cost, and profit.*/
select o.order_id,
		p.product_name,
		((o.quantity * p.unit_price)
		- ((o.quantity * p.unit_price) * o.discount_pct / 100)
		- (o.quantity * p.cost_price)
		) AS profit,
        (o.quantity* cost_price) as Total_cost,
        ((o.quantity *p.unit_price) - (o.quantity*p.unit_price) * o.discount_pct/100) as net_revenue
        from customer c
		join order_details o 
		on c.customer_id=o.customer_id
		join product p 
		on p.product_id=o.product_id;
	/* Q6.Find the total number of orders placed by each customer. 
		Display the customer name and total number of orders.*/
        select c.customer_name,
				count(o.order_id) as total_order
                from customer c
		join order_details o 
		on c.customer_id=o.customer_id
		join product p 
		on p.product_id=o.product_id
        group by 
        customer_name;
	/* Q7.Find the total quantity of products purchased by each customer. 
Display the customer name and total quantity purchased.*/
	select c.customer_name,
			sum(o.quantity) as Total_quantity
            from customer c
		join order_details o 
		on c.customer_id=o.customer_id
		join product p 
		on p.product_id=o.product_id
        group by 
        customer_name;
/* Q8.Calculate the total Net Revenue generated by each customer. 
Display the customer name, city, customer segment, and total net revenue. 
Sort the result from highest to lowest net revenue.*/
		select c.customer_name,
				c.city,
                c.customer_segment,
                sum(
                (o.quantity * p.unit_price) -((o.quantity*p.unit_price)*o.discount_pct /100))as Total_net_revenue 
                from customer c 
		join order_details o 
		on c.customer_id=o.customer_id
		join product p 
		on p.product_id=o.product_id
        group by 
        customer_name,
        city,
        customer_segment
        order by Total_net_revenue desc ;
/* Q9. Calculate the total Profit generated by each customer. 
Display the customer name and total profit. Show the most profitable customer first.*/
		select customer_name,
        sum(
        (o.quantity*p.unit_price)-(o.quantity*p.unit_price)*discount_pct/100 - (o.quantity*p.cost_price)) as Total_profit
        from customer c 
		join order_details o 
		on c.customer_id=o.customer_id
		join product p 
		on p.product_id=o.product_id
        group by 
        customer_name
        order by total_profit desc;
/*Q10.Calculate the total quantity sold and total net revenue for each product category. 
Display the category, total quantity sold, and total net revenue.*/
select p.category,
		sum(quantity) as Total_quantity,
        sum(
			(o.quantity * p.unit_price) -((o.quantity*p.unit_price)*o.discount_pct /100))as Total_net_revenue 
                from customer c 
		join order_details o 
		on c.customer_id=o.customer_id
		join product p 
		on p.product_id=o.product_id
        group by 
        Category;
/* Q11. Show only those product categories whose total net revenue is greater than ₹10,000.
 Display the category and total net revenue.*/
 select p.category,
		sum(
        (o.quantity *p.unit_price) - ((o.quantity *p.unit_price)*o.discount_pct/100)) as Total_net_revenue
        from customer c
        join order_details o
        on c.customer_id=o.customer_id
		join product p 
		on p.product_id=o.product_id
        group by 
        Category
        Having Total_net_revenue > 10000;
/* Q12. Calculate the total net revenue generated by each product category and assign a
 rank based on total net revenue, where the category with the highest revenue receives
 Rank 1.*/
 with category_revenue as(
	select p.category,
		sum(
        (o.quantity * p.unit_price)-(o.quantity * p.unit_price)*o.discount_pct/100) as total_net_revenue
        from customer c
        join order_details o
        on c.customer_id=o.customer_id
		join product p 
		on p.product_id=o.product_id
        group by 
        Category)
        select 
        category,
        total_net_revenue,
        rank() over (order by total_net_revenue desc) as revenue_rank 
        from category_revenue;
/* Q13. Calculate the running total of net revenue for every customer based on their
 order date. Display the customer name, order date, order ID, net revenue for that order,
 and cumulative net revenue. The running total must restart separately for each customer.*/
 with cumulation_net_revenue as 
 (select c.customer_name,
		o.order_date,
        o.order_id,
		(o.quantity * p.unit_price ) - (o.quantity *p.unit_price)* o.discount_pct /100 as net_revenue
        from customer c
        join order_details o
        on c.customer_id=o.customer_id
		join product p 
		on p.product_id=o.product_id)
        select
        customer_name,
        order_date,
        order_id,
        net_revenue,
        sum(net_revenue) over (
        partition by customer_name
        order by order_date, order_id
        ) as cumulation_net_revenue
        from cumulation_net_revenue;
/*Q14. Calculate the total net revenue generated by every customer and rank customers 
within their respective cities based on total net revenue. Display the city, 
customer name, total net revenue, and rank within the city.*/
with rank_within_city as (
select c.customer_name,
		c.city,
        sum((o.quantity*p.unit_price)-(o.quantity*p.unit_price)*o.discount_pct/100) as net_revenue
        from customer c
        join order_details o
        on c.customer_id=o.customer_id
		join product p 
		on p.product_id=o.product_id
        group by 
        c.customer_name,
        c.city)
        select 
        customer_name,
        city,
        net_revenue,
        rank() over 
        (partition by city
        order by 
        net_revenue desc)
        as rank_within_city
        from  rank_within_city;
        
/* Q15.Calculate the total net revenue generated by every product. Then calculate the 
average product revenue within each category. Display the product name, category,
 total net revenue, category average revenue, and classify each product as Above Average,
 Below Average, or Equal to Average based on its comparison with the category average. 
Also rank the products b*/
with classify_product as(
select p.product_name,
		p.category,
        sum((o.quantity*p.unit_price) -(o.quantity*p.unit_price)*o.discount_pct/100) as total_net_revenue
        from customer c
        join order_details o
        on c.customer_id=o.customer_id
		join product p 
		on p.product_id=o.product_id
        group by 
        p.product_name,
        p.Category),
        category_avg as (select
		product_name, 
        category,
        total_net_revenue,
        avg (total_net_revenue) over
        ( partition by category) as 
        category_avg_revenue
        from classify_product )
        select product_name,
        category,
        total_net_revenue,
        category_avg_revenue,
        case when  total_net_revenue> category_avg_revenue
			then "Above avg"
		when total_net_revenue<category_avg_revenue
			then "Below avg"
		when total_net_revenue=category_avg_revenue
			then "Equal to avg"
            End as performance ,
            rank() over (partition by category order by total_net_revenue desc) as product_rank
            from category_avg;
        
		
        
        
            
        
        
        
        
		
                
        
        
        
        
        





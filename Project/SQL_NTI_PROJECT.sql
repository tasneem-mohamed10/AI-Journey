
/*=================================
			Products 
===================================*/

-- Q1.What are the top 10 products by revenue?
select top 10 StockCode,Description, sum(Quantity) as total_quantity,
sum(Quantity * Price ) as total_revenue
from NTI_cleaned
group by StockCode , Description
order by total_revenue desc, total_quantity desc
----------------------------------------------------------------------------------------------
-- Q2.What are products that have less revenue?
select top 20 StockCode,Description, sum(Quantity) as total_quantity,
sum(Quantity * Price ) as total_revenue
from NTI_cleaned
group by StockCode , Description
order by total_revenue asc , total_quantity asc
--------------------------------------------------------------------------------------------
--Q3. Which products generate high revenue despite low Quantity?
select StockCode,Description,
sum(Quantity) as Total_Quantity,
sum(Quantity * Price) as Total_Revenue
from NTI_cleaned
group by StockCode, Description
order by Total_Revenue desc, Total_Quantity asc
-----------------------------------------------------------------------------------------------
--Q4. Which products have high  Quantity but low revenue?
select StockCode, Description,
sum(Quantity) as Total_Quantity,
sum(Quantity *Price) as Total_Revenue
from NTI_cleaned
group by StockCode, Description
order by Total_Quantity desc, Total_Revenue asc;
----------------------------------------------------------------------------------------------------
--Q5.Which products are canceled most frequently and what is the percentage?
select StockCode,Description,
count(*) AS Cancel_Count, 
round( count(*) * 100.0 /
(SELECT count(*) from NTI_canceled ),2) as Cancel_Percentage
from NTI_canceled
group by StockCode, Description
order by Cancel_Count desc;
----------------------------------------------------------------------------------------------------
--Q6. Which pairs of products are most commonly purchased together?
select Top 1000 a.Description as Product1,b. Description as Product2,count(*) as TimesPurchasedTogether
from NTI_cleaned a
join NTI_cleaned b
    on a.Invoice = b.Invoice
    and a.StockCode < b.StockCode
group by  a.Description, b.Description
order by TimesPurchasedTogether desc;


/*=================================
			Customers 
===================================*/

---------------------------------------------------------------------------------------------
--Q7. Which customers order most frequently, and what is their average order value? 
select Customer_ID,count(distinct Invoice) as NumberOfOrders,
sum(Quantity * Price) / count(distinct Invoice) as AverageOrderValue
from NTI_cleaned
where Customer_ID <> -1
group by Customer_ID
order by NumberOfOrders desc;
---------------------------------------------------------------------------------------------
-- Q8. When did each customer place their last order?
select Customer_ID,max(InvoiceDate) as LastOrderDate
from NTI_cleaned
where Customer_ID <> -1
group by Customer_ID
order by LastOrderDate desc;   

------------------------------------------------------------------------------------------------

--Q9. Segment customers by (RFM) — who are the high-value, at-risk, and new customers?

select Customer_ID,
max(InvoiceDate) as LastOrderDate,
datediff(day, max(InvoiceDate), (select max(InvoiceDate) from NTI_cleaned)) as Recency,
count(distinct Invoice) as Frequency,
sum(Quantity * Price) as Monetary,
case
when datediff(day, max(InvoiceDate), (select max(InvoiceDate) from NTI_cleaned)) <= 30
and count(distinct Invoice) >= 10 then 'High-Value'
when count(distinct Invoice) = 1 then 'New'
else 'At-Risk' end as CustomerSegment
from NTI_cleaned where Customer_ID <> -1 
group by Customer_ID order by Monetary desc;

--------------------------------------------------------------------------

/*=================================
			Month / Year 
===================================*/

-- Q10.How does monthly revenue trend over the two years? 
select
year(InvoiceDate) as year,
month(InvoiceDate) as month,
sum(Quantity * Price) as MonthlyRevenue
from NTI_cleaned
group by year(InvoiceDate), month(InvoiceDate)
order by year,month;
---------------------------------------------------------------------------------------------
-- Q11. Which day of the week generates the highest revenue
select datename(weekday, InvoiceDate) as day_name,
sum(Quantity * Price) as total_revenue
from NTI_cleaned
group by datename(weekday, InvoiceDate)
order by total_revenue desc;

-------------------------------------------------------------------------------------------------

/*=================================
			Country 
===================================*/

-- Q12.Which countries generate the most revenue, and how concentrated is it? 
select Country,sum(Quantity * Price) as total_revenue ,
round(sum(Quantity * Price) * 100.0 /(select sum(Quantity * Price) from NTI_cleaned), 2 ) as Revenue_Percentage
from NTI_cleaned group by Country
order by total_revenue desc;

--[United Kingdom] have 86% from total .

---------------------------------------------------------------------------------------------

--Q13.Which country has the highest average quantity per order?
select Country, AVG(TotalQuantity) as AverageQuantityPerOrder from 
(select Country,Invoice, SUM(Quantity) AS TotalQuantity from NTI_cleaned group by Country, Invoice) as Orders
group by Country
order by AverageQuantityPerOrder desc;

-- Denmark has the highest numbers of order but United Kingdom has the highest revenue

------------------------------------------------

/*=================================
			Revenue 
===================================*/

--Q14.NET revenue after removing discounts

select sum(Quantity * Price) as TotalDiscount
from NTI_cleaned
where StockCode = 'D';

select sum (Quantity * Price) as Revenue
from NTI_cleaned;

select (select sum(Quantity * Price) from NTI_cleaned)
-
(select abs(sum(Quantity * Price)) from NTI_cleaned where StockCode = 'D') as Revenue;

------------------------------------------------
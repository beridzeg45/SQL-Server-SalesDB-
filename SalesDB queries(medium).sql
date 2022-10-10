-- which salesperson has the most sales by value

use salesdb;
with t1 as
(select SalesPersonID, sum(Quantity*Price) as amount
from sales s
join Products p on s.ProductID=p.ProductID
group by SalesPersonID)
,t2 as
(select concat(FirstName,' ',LastName) as Salesperson, Amount
from t1
join Employees e on t1.SalesPersonID=e.EmployeeID)
select Salesperson, format(amount,'c0') as Amount
from t2
order by amount desc;


--find customers that have dealt with more than 10 salesperson

with t1 as 
(select CustomerID, count(distinct SalesPersonID) as SalesPersons
from sales
group by CustomerID
having count(distinct SalesPersonID)>10)
select concat(FirstName,' ',LastName) as Customer,SalesPersons
from t1
join Customers c on t1.CustomerID=c.CustomerID;

--find customers that have dealt with more than 10 salesperson
-- group the salespersons by customerIDs

with t1 as 
(select CustomerID, count(distinct SalesPersonID) as SalesPersons
from sales
group by CustomerID
having count(distinct SalesPersonID)>10)
,t2 as 
(select t1.CustomerID,concat(FirstName,' ',LastName) as Customer,SalesPersons
from t1
join Customers c on t1.CustomerID=c.CustomerID)
,t3 as
(select CustomerID, STRING_AGG(CONVERT(NVARCHAR(max),Employee),', ' )  as SalesPersons
from (select CustomerID,SalesPersonID,concat(FirstName,' ',LastName) as employee from sales join Employees on sales.SalesPersonID=Employees.EmployeeID group by CustomerID,SalesPersonID,concat(FirstName,' ',LastName)) as a
where CustomerID in (select CustomerID from t2)
group by CustomerID)
select concat(FirstName,' ',LastName) as Customer, SalesPersons
from t3 
join Customers c on t3.CustomerID=c.CustomerID
order by Customer;


--Find customers who contribute to more than one percent of total customer order value

with t1 as 
(select CustomerID, sum(Quantity*Price) as Amount,
concat(sum(Quantity*Price)/(select sum(Quantity*Price) from Sales s join Products p on s.ProductID=p.ProductID)*100,' %') as PercentOfTotalAmount
from sales s
join Products p on s.ProductID=p.ProductID
group by CustomerID)
select CONCAT(FirstName,' ',LastName) as Customer, format(Amount,'C0') as Amount, PercentOfTotalAmount
from t1 
join Customers c on t1.CustomerID=c.CustomerID
where PercentOfTotalAmount>'1'
order by t1.Amount desc;


-- find 10 products that have the biggest share by order value

with t1 as 
(select s.ProductID, sum(Quantity*Price) as Amount
from Sales s
join Products p on s.ProductID=p.ProductID
group by s.ProductID)
,t2 as
(select Name,Amount
from t1 
join Products p on t1.ProductID=p.ProductID)
select top 10 Name, format(Amount,'C0') as Amount$, concat(round(Amount/(select sum(Amount) from t1)*100,2),' %') as 'Percent'
from t2
order by Amount desc

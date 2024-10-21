-- Table Creation
Create table customers ( 
          customer_id INT PRIMARY KEY, 
  	      customer_name NVARCHAR(50) NOT NULL,
  		  email_address NVARCHAR(100) NOT NULL,
  		  country NVARCHAR(50),
  		  birth_date DATE,
  		  registration_date DATE,
  		  preffered_language NVARCHAR(3)
) ;

Create table products (
  		  product_id INT PRIMARY KEY,
  		  product_name NVARCHAR(40) NOT NULL,
  		  price DECIMAL(10,2) NOT NULL,
  		  category NVARCHAR(20) 
) ;

Create table sales_transactions (
 		  Transaction_id INT PRIMARY key,
  		  customer_id INT,
  		  product_id INT,
  		  purchase_date DATE,
  	      quantity_purchased INT
) ;

Create table shipping_details (
 	      shipping_id INT PRIMARY KEY,
  		  transaction_id INT NOT NULL,
  		  shipping_date DATE,
   	      shipping_address NVARCHAR(50) NOT NULL,
		  country NVARCHAR(50) NOT NULL,
  	      city NVARCHAR(50) NOT NULL,
          is_delivered INT
) ;

-- Foreign Key constraints
 
ALTER TABLE sales_transactions 
ADD CONSTRAINT Fk_customer 
FOREIGN key ( customer_id ) REFERENCES customers( customer_id ); 

ALTER TABLE sales_transactions 
ADD CONSTRAINT Fk_product 
FOREIGN KEY ( product_id ) REFERENCES products ( product_id );

ALTER TABLE shipping_details 
ADD CONSTRAINT Fk_shippings
FOREIGN KEY ( transaction_id ) REFERENCES sales_transactions( transaction_id ) ;

-- ### I dont know if this is relevant to the task at hand, but shipping_details is not in 3rd Normal Form. 
-- # In 3NF, it would require extra table and some changes. 

ALTER table shipping_details drop column shipping_address, country, city;
		
ALTER table shipping_details add shipping_address_id INT;

CREATE table shipping_addresses (
		address_id INT PRIMARY KEY,
		address_desc NVARCHAR(50),
		country NVARCHAR(50),
		city NVARCHAR(50)
)

ALTER table sales_transactions 
ADD CONSTRAINT Fk_shipping_id
FOREIGN KEY ( address_id ) REFERENCES shipping_addresses ;

-- ### This was just a suggestion, Im still going to follow the requirements
-- # SQL Query Task : 

--#1 - would be a simple query :

	  Select format(s.purchase_date,'yyyy-MM') as Month,
			 sum(s.quantity_purchased) as Number_of_items,
			 count(s.transaction_id) as Transactions,
			 sum(p.price) as Amount
		from sales_transactions s
		join products p 
		  on p.product_id = s.product_id
	   group by format(s.purchase_date,'yyyy-MM') ;


-- #2 - To avoid self join, I will use window functions for these calculations :


		Select Month,
			   Number_of_items,
			   Transactions,
			   Amount,
			   sum(ISNULL(Amount,0) + ISNULL(Sys_minus_1_amount,0) + ISNULL(Sys_minus_2_amount,0)) / 3 as Moving_avg
		  from (



					   Select a.Month, 
							  a.Number_of_items,
							  a.Transactions,
							  a.Amount,
							  Lag(Amount) over ( Order by Month ) as Sys_minus_1_amount,
							  Lag(Amount,2) over ( Order by Month ) as Sys_minus_2_amount
						 from ( 
						  Select format(s.purchase_date,'yyyy-MM') as Month,
								 sum(s.quantity_purchased) as Number_of_items,
								 count(s.transaction_id) as Transactions,
								 sum(p.price) as Amount
							from sales_transactions s
							join products p 
							  on p.product_id = s.product_id
						   group by format(s.purchase_date,'yyyy-MM') 
						 ) a 
	 
	 ) d Group by Month,
		    	  Number_of_items,
		 		  Transactions,
			      Amount

--insert into customers ( customer_id, customer_name, email_address, country, birth_date, registration_date, preffered_language ) values 
--					  ( 1, 'Tamaz Kitiashvili', 'tazokitiashvili@gmail.com', 'Georgia', '2000-12-28', '2020-10-08', 'GE' ),
--					  ( 2, 'Elon Musk', 'emusk@tesla.com', 'USA', '1971-07-28', '2021-11-28', 'US' ),
--					  ( 3, 'Jeff Bezos', 'jbezos@amazon.com', 'USA','1964-01-12', '2023-01-22', 'US' ) ;

					  

--insert into products (product_id, product_name, price, category) values 
--				     ( 200, 'Tesla share', 110.62, 'STOCK'),
--					 ( 300, 'Amazon share', 82.31, 'STOCK'),
--					 ( 400, 'Microsoft share', 192.30, 'STOCK'),
--					 ( 505, 'Jameson 1L',13.3,'ALCOHOL'),
--					 ( 508, 'Hankey Banister 0.7L',9.3, 'ALCOHOL'),
--					 ( 509, 'Khvanchkara 1L', 12.5, 'ALCOHOL'),
--					 ( 515, 'Hennessy 1L',30.9,'ALCOHOL'),
--					 ( 518, 'Gray Goose', 17.5,'ALCOHOL')


--insert into sales_transactions ( transaction_id, customer_id, product_id, purchase_date, quantity_purchased ) values 
--							   ( 33992, 1, 300, '2024-04-01',5 ),
--							   ( 33993, 1, 200, '2024-05-20',7 ),
--							   ( 33994, 1, 400, '2024-05-11',12 ),
--							   ( 33939, 1, 505, '2024-07-21',1 ),
--							   ( 33930, 1, 505, '2024-07-23',2 ),
--							   ( 40211, 1, 518, '2024-06-30',2 ),
--							   ( 23112, 2, 200, '2024-04-02',120 ),
--							   ( 23113, 2, 200, '2024-04-06',20 ),
--							   ( 23114, 2, 200, '2024-04-30',190 ),
--							   ( 23115, 2, 200, '2024-05-02',80 ),
--							   ( 23116, 2, 300, '2024-07-02',122 ),							   
--							   ( 23117, 2, 300, '2024-07-12',100 ),
--							   ( 44210, 3, 300, '2024-05-01',50 ),
--							   ( 44211, 3, 300, '2024-05-04',10 ),
--							   ( 44212, 3, 200, '2024-05-06',140 ),
--							   ( 44213, 3, 400, '2024-05-12',150 ,
--							   ( 44214, 3, 200, '2024-05-16',250 ),
--							   ( 44215, 3, 518, '2024-05-30',1 ),
--							   ( 44216, 3, 509, '2024-06-18',10 ),
--							   ( 44217, 3, 200, '2024-06-11',70 ),
--							   ( 44218, 3, 515, '2024-07-21',7 )

--select * from shipping_details
--Insert into shipping_details ( shipping_id, transaction_id, shipping_date, shipping_address, country, city, status ) values 
--					         ( 9211, 33992, '2024-04-03', 'Pekini Avenue 21', 'Georgia', 'Tbilisi', 'Delivered'),
--							 ( 2136, 33993,	'2024-05-24', 'Pekini Avenue 21', 'Georgia', 'Tbilisi', 'Delivered'),
--							 ( 4324, 33994,	'2024-05-12', 'Pekini Avenue 21', 'Georgia', 'Tbilisi', 'Delivered'),
--							 ( 3939, 33939,	'2024-07-23', 'Pekini Avenue 21', 'Georgia', 'Tbilisi', 'Delivered'),
--							 ( 3393, 33930,	'2024-07-24', 'Pekini Avenue 21', 'Georgia', 'Tbilisi', 'Delivered'),
--							 ( 4021, 40211,	'2024-07-01', 'Pekini Avenue 21', 'Georgia', 'Tbilisi', 'Delivered'),
--							 ( 2311, 23112,	'2024-04-05', 'Philadelphia', 'USA', 'PH', 'Delivered'),
--							 ( 2531, 23113,	'2024-04-07', 'Philadelphia', 'USA', 'PH', 'Delivered'),
--							 ( 2631, 23114,	'2024-05-01', 'Philadelphia', 'USA', 'PH', 'Delivered'),
--							 ( 2731, 23115,	'2024-05-10', 'Philadelphia', 'USA', 'PH', 'Delivered'),
--							 ( 2831, 23116,	'2024-07-09', 'Philadelphia', 'USA', 'PH', 'Delivered'),
--							 ( 2131, 23117,	'2024-07-14', 'Philadelphia', 'USA', 'PH', 'Delivered'),
--							 ( 4242, 44210,	'2024-05-03', 'akbequerque, New mexico', 'USA', 'NM','Delivered'),
--							 ( 4442, 44211,	'2024-05-06', 'akbequerque, New mexico', 'USA', 'NM','Delivered'),
--							 ( 4452, 44212,	'2024-05-09', 'akbequerque, New mexico', 'USA', 'NM','Delivered'),
--							 ( 4842, 44213,	'2024-05-14', 'akbequerque, New mexico', 'USA', 'NM','Delivered'),
--							 ( 5121, 44214,	'2024-05-17', 'akbequerque, New mexico', 'USA', 'NM','Delivered'),
--							 ( 5221, 44215,	'2024-06-03', 'akbequerque, New mexico', 'USA', 'NM','Delivered'),
--							 ( 3421, 44216,	'2024-06-19', 'akbequerque, New mexico', 'USA', 'NM','Delivered'),
--							 ( 1321, 44217,	'2024-06-12', 'akbequerque, New mexico', 'USA', 'NM','Delivered'),
--							 ( 3221, 44218,	'2024-07-25', 'akbequerque, New mexico', 'USA', 'NM','Delivered')



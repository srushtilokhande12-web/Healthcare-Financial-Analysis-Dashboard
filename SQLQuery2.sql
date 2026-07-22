select * 
from dbo.members;

select *
from dbo.claims;


create table dbo.claims_cleaned
(
	claim_id int,
	member_id int,
	provider_id nvarchar(255),
	claim_date date,
	claim_type nvarchar(255),
	cpt_code nvarchar(255),
	icd_code nvarchar(255),
	billed_amount float,
	paid_amount float
);

insert into dbo.claims_cleaned
select claim_id, member_id, provider_id, claim_date, claim_type, cpt_code, icd_code, billed_amount, paid_amount
from dbo.claims;

select *
from dbo.claims_cleaned;

select claim_id,
coalesce(member_id, 0) as member_id
from dbo.claims_cleaned;

update dbo.claims_cleaned
set member_id = coalesce(member_id, 0);
 
select claim_type,
upper(claim_type) as claim_type
from dbo.claims_cleaned;

update dbo.claims_cleaned
set claim_type = upper(claim_type);

select billed_amount,paid_amount,
cast(billed_amount as decimal(10,2)) as billed_amount,		
cast(paid_amount as decimal(10,2)) as paid_amount	
from dbo.claims_cleaned;

update dbo.claims_cleaned
set billed_amount = cast(billed_amount as decimal(10,2)),
paid_amount = cast(paid_amount as decimal(10,2));
	
UPDATE dbo.claims_cleaned
SET 
    billed_amount = CAST(billed_amount AS DECIMAL(10,2)),
    paid_amount = CAST(paid_amount AS DECIMAL(10,2));

ALTER TABLE dbo.claims_cleaned 
ALTER COLUMN billed_amount DECIMAL(10,2);

ALTER TABLE dbo.claims_cleaned
ALTER COLUMN paid_amount DECIMAL(10,2);

select * 
from dbo.claims_cleaned;


select billed_amount,paid_amount,
(billed_amount - paid_amount) as lost_money
from dbo.claims_cleaned;

alter table dbo.claims_cleaned
add lost_money as (billed_amount - paid_amount);

select claim_type,sum(paid_amount) as total_paid
from dbo.claims_cleaned
group by claim_type
order by total_paid desc;


select top 10 cpt_code, sum(paid_amount) as total_spent
from dbo.claims_cleaned	
group by cpt_code
order by total_spent desc;

select top 10 icd_code,sum(paid_amount) as total_spent
from dbo.claims_cleaned	
group by icd_code
order by total_spent desc;

select *
from dbo.members;


create table dbo.members_cleaned
(
	member_id int,
	member_age int,
	member_gender nvarchar(255),
	plan_type nvarchar(255),
	enrollment_start_date date,
	enrollment_end_date date	
	);

	insert into dbo.members_cleaned
	select member_id, member_age, member_gender	
	, plan_type, enrollment_start_date, enrollment_end_date	
	from dbo.members;

	select *
	from dbo.members_cleaned;


	update dbo.members_cleaned
	set member_gender = case
	when member_gender = 'M' then 'Male'
	when member_gender = 'F' then'Female'
	else member_gender 
	end;
	
	select *
	from members_cleaned
	order by member_age asc;

	select top 10
	c.member_id,c.plan_type,
			sum(m.paid_amount) as total_member_cost
			from dbo.members_cleaned c
			join dbo.claims_cleaned m
			on c.member_id = m.member_id	
			group by c.member_id,c.plan_type
			order by total_member_cost desc;

select * 
from dbo.members_cleaned; 
select *
	from dbo.claims_cleaned;


SELECT 
    SUM(billed_amount) AS total_billed,
    SUM(paid_amount) AS total_paid,
    SUM(billed_amount) - SUM(paid_amount) AS total_savings,
    (SUM(paid_amount) / SUM(billed_amount)) * 100 AS payment_percentage
FROM claims_cleaned;



CREATE VIEW dashboard_data AS
SELECT 
    c.*, 
    m.member_age, 
    m.member_gender, 
    m.plan_type,
    (c.billed_amount - c.paid_amount) AS savings
FROM claims_cleaned c
LEFT JOIN members_cleaned m ON c.member_id = m.member_id;
/*
Authors: Davis Cho, Xi Yu
email: d2cho@ucsd.edu
Date: 6/8/17
ASSIGNMENT: CSE135 PROJECT 3 SQL FILE
 */

--Indices to use excluding precomputed, including potentially beneficial ones--
create index ind0 ON shopping_cart(person_id);
create index ind1 ON products_in_cart(cart_id);
create index ind2 ON shopping_cart(is_purchased);
create index ind3 ON product(product_name);
create index ind4 ON product(category_id);
create index ind5 ON products_in_cart(product_id);
create index ind6 ON state(state_name);
create index ind7 on person(state_id);

----------PRECOMPUTED TABLE----------
----------create statement----------
CREATE TABLE precomputed AS
with overall_table as
(select pc.product_id,c.state_id,sum(pc.price*pc.quantity) as amount
 	from products_in_cart pc
 	inner join shopping_cart sc on (sc.id = pc.cart_id and sc.is_purchased = true)
 	inner join product p on (pc.product_id = p.id) -- add category filter if any
 	inner join person c on (sc.person_id = c.id)
 	group by pc.product_id,c.state_id
),
top_state as
(select state_id, sum(amount) as dollar from (
	select state_id, amount from overall_table
	UNION ALL
	select id as state_id, 0.0 as amount from state
	) as state_union
 group by state_id order by dollar desc --limit 20  --offset 20
),
top_n_state as
(select row_number() over(order by dollar desc) as state_order, state_id, dollar from top_state
),
top_prod as
(select product_id, sum(amount) as dollar from (
	select product_id, amount from overall_table
	UNION ALL
	select id as product_id, 0.0 as amount from product
	) as product_union
group by product_id order by dollar desc--limit 10 --offset 20
),
top_n_prod as
(select row_number() over(order by dollar desc) as product_order, product_id, dollar from top_prod
)
select ts.state_id, s.state_name, tp.product_id, pr.product_name, pr.category_id, COALESCE(ot.amount, 0.0) as cell_sum, ts.dollar as state_sum, tp.dollar as product_sum
	from top_n_prod tp CROSS JOIN top_n_state ts
	LEFT OUTER JOIN overall_table ot
	ON ( tp.product_id = ot.product_id and ts.state_id = ot.state_id)
	inner join state s ON ts.state_id = s.id
	inner join product pr ON tp.product_id = pr.id
	order by ts.state_order, tp.product_order;

----------PRECOMPUTED TABLE INDICES----------
--Indices to use on precomputed, including potentially beneficial ones--
CREATE INDEX ind8 ON precomputed(product_name);
CREATE INDEX ind9 ON precomputed(state_name);
CREATE INDEX ind10 ON precomputed(category_id);
CREATE INDEX ind11 ON precomputed(cell_sum);
CREATE INDEX ind12 ON precomputed(state_sum);
CREATE INDEX ind13 ON precomputed(product_sum);

--ON RUN, PUSH LOG CHANGES TO PRECOMPUTED TABLE--
----------Update cell_sum----------
WITH added_totals AS(
		SELECT state_id, state_name, product_id, product_name, SUM(added) AS added FROM logs
			GROUP BY state_id, state_name, product_id, product_name)
UPDATE precomputed pre
	SET cell_sum=(cell_sum+l.added)
	FROM added_totals l
	WHERE pre.state_id=l.state_id
	AND pre.product_id=l.product_id;
----------Update state_sum----------
WITH T AS(
		SELECT state_id, sum(added) AS total
		FROM logs GROUP BY state_id )
UPDATE precomputed pre
	SET state_sum=(state_sum+T.total)
	FROM T
	WHERE pre.state_id=T.state_id;
----------Update product_sum----------
WITH T AS(
		SELECT product_id, sum(added) AS total
		FROM logs GROUP BY product_id )
UPDATE precomputed pre
	SET product_sum=(product_sum+T.total)
	FROM T
	WHERE pre.product_id=T.product_id;
----------Empty the Log----------
DELETE FROM logs WHERE true;


----------Log Table----------
CREATE TABLE logs(
  state_id      INTEGER,
  state_name    TEXT,
  product_id    INTEGER,
  product_name  TEXT,
  added         INTEGER CHECK(added>=0)
);

----------Add Trigger on Insert of products_in_cart----------
----------Creating the function----------
CREATE OR REPLACE FUNCTION log_cart() RETURNS trigger AS $log_cart$
    BEGIN
      INSERT INTO logs SELECT p.state_id, s.state_name, pic.product_id, pd.product_name,(pic.price*sum(pic.quantity)) AS added
        FROM person p, state s, shopping_cart sc, products_in_cart pic, product pd
        WHERE p.id=sc.person_id
        AND p.state_id=s.id
        AND pic.cart_id=sc.id
        AND pd.id=pic.product_id
        AND pic.id=NEW.id
        GROUP BY state_id, s.state_name, pic.product_id, pd.product_name, pic.price ORDER BY added DESC;
			RAISE NOTICE 'Adding to log%', NEW.product_id;
      RETURN NULL;
    END;
$log_cart$ LANGUAGE plpgsql;
----------Creating the Trigger----------
CREATE TRIGGER logging AFTER INSERT OR UPDATE ON products_in_cart
  FOR EACH ROW
  EXECUTE PROCEDURE log_cart();

--DROP TRIGGER logging ON products_in_cart;
--DROP FUNCTION log_cart();
--DROP TABLE logs;

--SELECT * FROM logs;

----------RUN ON REFRESH, Log+Precomputed View----------
--Correct One
WITH state_added AS (
    SELECT state_id,state_name,SUM(added) AS added FROM logs GROUP BY state_id, state_name
),
  product_added AS (
    SELECT product_id,product_name,SUM(added) AS added FROM logs GROUP BY product_id, product_name
), added_totals AS(
		SELECT state_id, state_name, product_id, product_name, SUM(added) AS added FROM logs
			GROUP BY state_id, state_name, product_id, product_name
), new_totals AS (
  SELECT p.state_id, p.state_name, p.product_id, p.product_name, p.category_id,
    (p.cell_sum+l.added) AS cell_sum, (p.state_sum+sa.added) AS state_sum, (p.product_sum+pa.added) AS product_sum
  FROM precomputed p, added_totals l, state_added sa, product_added pa
  WHERE (l.state_id, l.product_id)=(p.state_id,p.product_id) AND p.state_id=sa.state_id AND p.product_id=pa.product_id
)
  SELECT * FROM new_totals UNION SELECT * FROM precomputed p WHERE (p.state_id,p.product_id) NOT IN (
    SELECT nt.state_id, nt.product_id FROM new_totals nt)
  ORDER BY state_sum DESC, product_sum DESC ;

--Old one that didn't aggregate the log table
WITH state_added AS (
    SELECT state_id,state_name,SUM(added) AS added FROM logs GROUP BY state_id, state_name
),
  product_added AS (
    SELECT product_id,product_name,SUM(added) AS added FROM logs GROUP BY product_id, product_name
), new_totals AS (
  SELECT p.state_id, p.state_name, p.product_id, p.product_name, p.category_id,
    (p.cell_sum+l.added) AS cell_sum, (p.state_sum+sa.added) AS state_sum, (p.product_sum+pa.added) AS product_sum
  FROM precomputed p, logs l, state_added sa, product_added pa
  WHERE (l.state_id, l.product_id)=(p.state_id,p.product_id) AND p.state_id=sa.state_id AND p.product_id=pa.product_id
)
  SELECT * FROM new_totals UNION SELECT * FROM precomputed p WHERE (p.state_id,p.product_id) NOT IN (
    SELECT nt.state_id, nt.product_id FROM new_totals nt)
  ORDER BY state_sum DESC, product_sum DESC ;

drop table precomputed;
drop table logs;

select * from logs;

select * from logs where state_id = '23' AND product_id='9';
SELECT DISTINCT product_id, product_name, product_sum FROM precomputed WHERE category_id=1
    			ORDER BY product_sum DESC LIMIT 50

/*
----------Old code for refresh----------
----------Create the View----------
CREATE VIEW refresh_view AS SELECT * FROM precomputed;
UPDATE refresh_view pre
	SET cell_sum=(cell_sum+l.added)
	FROM logs l
	WHERE pre.state_id=l.state_id
	AND pre.product_id=l.product_id;
WITH T AS(
		SELECT state_id, sum(added) AS total
		FROM logs GROUP BY state_id )
UPDATE refresh_view pre
	SET state_sum=(state_sum+T.total)
	FROM T
	WHERE pre.state_id=T.state_id;
WITH T AS(
		SELECT product_id, sum(added) AS total
		FROM logs GROUP BY product_id )
UPDATE refresh_view pre
	SET product_sum=(product_sum+T.total)
	FROM T
	WHERE pre.product_id=T.product_id;
----------DO QUERIES HERE----------
--SELECT * FROM refresh_view WHERE state_id=51;
----------DROP THE VIEW----------
DROP VIEW refresh_view;
*/

--Get all state to product purchases
CREATE TABLE state_to_prod AS
SELECT s.id AS state_id, s.state_name, pd.id AS product, pd.product_name, pic.price, sum(pic.quantity), (pic.price*sum(pic.quantity)) AS total FROM
           shopping_cart sc
          INNER JOIN products_in_cart pic ON (pic.cart_id = sc.id)
          RIGHT OUTER JOIN product pd ON (pd.id = pic.product_id)
          RIGHT JOIN person p ON (p.id = sc.person_id)
          INNER JOIN state s ON (s.id = p.id)
        WHERE sc.is_purchased = 't' GROUP BY s.id, pd.id, pic.price ORDER BY s.state_name, pd.id;

SELECT * FROM state_to_prod;

--DROP TABLE state_to_prod;

--Get the state headers ordered by totals
CREATE TABLE state_header AS
SELECT state_id,state_name, SUM(total) FROM state_to_prod GROUP BY state_id, state_name ORDER BY sum DESC;

SELECT * FROM state_header;

--DROP TABLE state_header;

--Get the product headers ordered by totals
CREATE TABLE prod_header AS
SELECT product, product_name, SUM(total) FROM state_to_prod GROUP BY product, product_name ORDER BY sum DESC;

SELECT * FROM prod_header;

--DROP TABLE prod_header;

--TIME TESTING
select * from products_in_cart;
WITH T AS(SELECT s.id AS state_id, s.state_name, pd.id AS product, pd.product_name, pic.price, sum(pic.quantity), (pic.price*sum(pic.quantity)) AS total FROM
           shopping_cart sc
          INNER JOIN products_in_cart pic ON (pic.cart_id = sc.id)
          RIGHT OUTER JOIN product pd ON (pd.id = pic.product_id)
          RIGHT JOIN person p ON (p.id = sc.person_id)
          INNER JOIN state s ON (s.id = p.id)
        WHERE sc.is_purchased = 't' GROUP BY s.id, pd.id, pic.price ORDER BY s.state_name, pd.id)
SELECT state_id,state_name, SUM(total) FROM T GROUP BY state_id, state_name ORDER BY sum DESC;

CREATE TABLE log(
  state_id      INTEGER REFERENCES state(id),
  state_name    TEXT NOT NULL,
  product_id    INTEGER REFERENCES product(id),
  product_name  TEXT NOT NULL,
  added         INTEGER NOT NULL CHECK(added>=0)
);
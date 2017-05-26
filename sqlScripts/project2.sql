CREATE TABLE role (
  id SERIAL PRIMARY KEY,
  role_name TEXT NOT NULL UNIQUE,
  description TEXT
);

CREATE TABLE state (
  id SERIAL PRIMARY KEY,
  state_name TEXT NOT NULL,
  state_code TEXT NOT NULL UNIQUE
);

CREATE TABLE person (
  id SERIAL PRIMARY KEY,
  person_name TEXT NOT NULL UNIQUE,
  role_id INTEGER REFERENCES role (id) NOT NULL,
  state_id INTEGER REFERENCES state (id) NOT NULL,
  age INTEGER NOT NULL CHECK(age > 0),
  created_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT (now() AT TIME ZONE 'UTC')
);

CREATE TABLE category (
  id SERIAL PRIMARY KEY,
  category_name TEXT UNIQUE NOT NULL,
  description TEXT,
  created_by TEXT NOT NULL,
  created_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT (now() AT TIME ZONE 'UTC'),
  modified_by TEXT,
  modified_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT (now() AT TIME ZONE 'UTC')
);

CREATE TABLE product(
  id SERIAL PRIMARY KEY,
  sku_id TEXT NOT NULL UNIQUE,
  product_name TEXT NOT NULL,
  price REAL NOT NULL CHECK(price >= 0.0),
  category_id INTEGER REFERENCES category(id) NOT NULL,
  created_by TEXT NOT NULL,
  created_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT (now() AT TIME ZONE 'UTC'),
  modified_by TEXT,
  modified_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT (now() AT TIME ZONE 'UTC')
);

CREATE TABLE shopping_cart(
  id SERIAL PRIMARY KEY,
  person_id INTEGER REFERENCES person(id) NOT NULL,
  is_purchased BOOLEAN NOT NULL,
  purchase_info TEXT,
  created_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT (now() AT TIME ZONE 'UTC'),
  purchased_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT (now() AT TIME ZONE 'UTC')
);

CREATE TABLE products_in_cart(
  id SERIAL PRIMARY KEY,
  cart_id INTEGER REFERENCES shopping_cart(id) NOT NULL,
  product_id INTEGER REFERENCES product(id) NOT NULL,
  price REAL NOT NULL CHECK (price >= 0.0),
  quantity INTEGER NOT NULL CHECK (quantity > 0)
);

INSERT INTO role (role_name, description) VALUES ('Owner', 'owner. can create categories, product');
INSERT INTO role (role_name, description) VALUES ('Customer', 'customer. can buy stuff');

INSERT INTO state (state_name, state_code) VALUES ('Alabama','AL');
INSERT INTO state (state_name, state_code) VALUES ('Alaska','AK');
INSERT INTO state (state_name, state_code) VALUES ('Arizona','AZ');
INSERT INTO state (state_name, state_code) VALUES ('Arkansas','AR');
INSERT INTO state (state_name, state_code) VALUES ('California','CA');
INSERT INTO state (state_name, state_code) VALUES ('Colorado','CO');
INSERT INTO state (state_name, state_code) VALUES ('Connecticut','CT');
INSERT INTO state (state_name, state_code) VALUES ('Delaware','DE');
INSERT INTO state (state_name, state_code) VALUES ('Florida','FL');
INSERT INTO state (state_name, state_code) VALUES ('Georgia','GA');
INSERT INTO state (state_name, state_code) VALUES ('Hawaii','HI');
INSERT INTO state (state_name, state_code) VALUES ('Idaho','ID');
INSERT INTO state (state_name, state_code) VALUES ('Illinois','IL');
INSERT INTO state (state_name, state_code) VALUES ('Indiana','IN');
INSERT INTO state (state_name, state_code) VALUES ('Iowa','IA');
INSERT INTO state (state_name, state_code) VALUES ('Kansas','KS');
INSERT INTO state (state_name, state_code) VALUES ('Kentucky','KY');
INSERT INTO state (state_name, state_code) VALUES ('Louisiana','LA');
INSERT INTO state (state_name, state_code) VALUES ('Maine','ME');
INSERT INTO state (state_name, state_code) VALUES ('Maryland','MD');
INSERT INTO state (state_name, state_code) VALUES ('Massachusetts','MA');
INSERT INTO state (state_name, state_code) VALUES ('Michigan','MI');
INSERT INTO state (state_name, state_code) VALUES ('Minnesota','MN');
INSERT INTO state (state_name, state_code) VALUES ('Mississippi','MS');
INSERT INTO state (state_name, state_code) VALUES ('Missouri','MO');
INSERT INTO state (state_name, state_code) VALUES ('Montana','MT');
INSERT INTO state (state_name, state_code) VALUES ('Nebraska','NE');
INSERT INTO state (state_name, state_code) VALUES ('Nevada','NV');
INSERT INTO state (state_name, state_code) VALUES ('New Hampshire','NH');
INSERT INTO state (state_name, state_code) VALUES ('New Jersey','NJ');
INSERT INTO state (state_name, state_code) VALUES ('New Mexico','NM');
INSERT INTO state (state_name, state_code) VALUES ('New York','NY');
INSERT INTO state (state_name, state_code) VALUES ('North Carolina','NC');
INSERT INTO state (state_name, state_code) VALUES ('North Dakota','ND');
INSERT INTO state (state_name, state_code) VALUES ('Ohio','OH');
INSERT INTO state (state_name, state_code) VALUES ('Oklahoma','OK');
INSERT INTO state (state_name, state_code) VALUES ('Oregon','OR');
INSERT INTO state (state_name, state_code) VALUES ('Pennsylvania','PA');
INSERT INTO state (state_name, state_code) VALUES ('Rhode Island','RI');
INSERT INTO state (state_name, state_code) VALUES ('South Carolina','SC');
INSERT INTO state (state_name, state_code) VALUES ('South Dakota','SD');
INSERT INTO state (state_name, state_code) VALUES ('Tennessee','TN');
INSERT INTO state (state_name, state_code) VALUES ('Texas','TX');
INSERT INTO state (state_name, state_code) VALUES ('Utah','UT');
INSERT INTO state (state_name, state_code) VALUES ('Vermont','VT');
INSERT INTO state (state_name, state_code) VALUES ('Virginia','VA');
INSERT INTO state (state_name, state_code) VALUES ('Washington','WA');
INSERT INTO state (state_name, state_code) VALUES ('West Virginia','WV');
INSERT INTO state (state_name, state_code) VALUES ('Wisconsin','WI');
INSERT INTO state (state_name, state_code) VALUES ('Wyoming','WY');
INSERT INTO state (state_name, state_code) VALUES ('Washington DC','DC');
INSERT INTO state (state_name, state_code) VALUES ('Puerto Rico','PR');
INSERT INTO state (state_name, state_code) VALUES ('U.S. Virgin Islands','VI');
INSERT INTO state (state_name, state_code) VALUES ('American Samoa','AS');
INSERT INTO state (state_name, state_code) VALUES ('Guam','GU');
INSERT INTO state (state_name, state_code) VALUES ('Northern Mariana Islands','MP');


-- CREATE UNIQUE INDEX ind ON person(id);
-- DROP INDEX ind;

/*queries for choice: customer/state, alphabetical/top-k, no-filtering of category*/
/* CUSTOMER uses this */
WITH T AS (SELECT p.id AS person_id, p.person_name, pd.id AS product, pd.product_name, pic.price, sum(pic.quantity), (pic.price*sum(pic.quantity)) AS total FROM
           shopping_cart sc
          INNER JOIN products_in_cart pic ON (pic.cart_id = sc.id)
          RIGHT OUTER JOIN product pd ON (pd.id = pic.product_id)
          RIGHT JOIN person p ON (p.id = sc.person_id)
        WHERE sc.is_purchased = 't' GROUP BY p.id, pd.id, pic.price ORDER BY p.person_name, pd.id)

/*alphabetical*/
SELECT person_name, SUM(total) AS totalPerPerson FROM T GROUP BY person_name ORDER BY person_name;
/* top-k */
SELECT person_name, SUM(total) AS totalPerPerson FROM T GROUP BY person_name ORDER BY totalPerPerson DESC;

/* STATE uses this */
WITH T AS (SELECT s.id AS state_id, s.state_name, pd.id AS product, pd.product_name, pic.price, sum(pic.quantity), (pic.price*sum(pic.quantity)) AS total FROM
           shopping_cart sc
          INNER JOIN products_in_cart pic ON (pic.cart_id = sc.id)
          RIGHT OUTER JOIN product pd ON (pd.id = pic.product_id)
          RIGHT JOIN person p ON (p.id = sc.person_id)
          INNER JOIN state s ON (s.id = p.id)
        WHERE sc.is_purchased = 't' GROUP BY s.id, pd.id, pic.price ORDER BY s.state_name, pd.id)
/*alphabetical*/
SELECT state_name, SUM(total) AS totalPerState FROM T GROUP BY state_name ORDER BY state_name;
/* top-k */
SELECT state_name, SUM(total) AS totalPerState FROM T GROUP BY state_name ORDER BY totalPerState DESC;

/* other tables */
select * from person ORDER BY person_name;
select * from state ORDER BY state_name;
select * from product ORDER BY product_name;
-- alphabetical PRODUCT
SELECT product_name, SUM(total) AS totalPerProduct FROM T GROUP BY product_name ORDER BY product_name;
-- TOP-K PRODUCT
SELECT product_name, SUM(total) AS totalPerProduct FROM T GROUP BY product_name ORDER BY totalPerProduct DESC;




/*queries for choice: customer/state, alphebatical/top-k, categoryid*/
/* CUSTOMER uses this*/

WITH T AS (SELECT p.id AS person_id, p.person_name, pd.id AS product, pd.product_name, c.category_name, pic.price, sum(pic.quantity), (pic.price*sum(pic.quantity)) AS total FROM
           shopping_cart sc
          INNER JOIN products_in_cart pic ON (pic.cart_id = sc.id)
          RIGHT OUTER JOIN product pd ON (pd.id = pic.product_id)
          RIGHT JOIN person p ON (p.id = sc.person_id)
          INNER JOIN category c ON (pd.category_id = c.id)
        WHERE sc.is_purchased = 't'  GROUP BY p.id, pd.id, c.category_name, pic.price ORDER BY p.person_name, pd.id)
/*alphabetical + categoryid CUSTOMER*/
SELECT person_name, SUM(total) AS totalPerCategoryPerPerson FROM T WHERE category_name = 'CAT_6' GROUP BY person_name ORDER BY person_name;
/*top-k + categoryid CUSTOMER*/
SELECT person_name, SUM(total) AS totalPerCategoryPerPerson FROM T WHERE category_name = 'CAT_6' GROUP BY person_name  ORDER BY totalPerCategoryPerPerson DESC;

/* STATE uses this */
WITH T AS (SELECT s.id AS state_id, s.state_name, pd.id AS product, pd.product_name, c.category_name, pic.price, sum(pic.quantity), (pic.price*sum(pic.quantity)) AS total FROM
           shopping_cart sc
          INNER JOIN products_in_cart pic ON (pic.cart_id = sc.id)
          RIGHT OUTER JOIN product pd ON (pd.id = pic.product_id)
          RIGHT JOIN person p ON (p.id = sc.person_id)
          INNER JOIN state s ON (s.id = p.id)
          INNER JOIN category c ON (pd.category_id = c.id)
        WHERE sc.is_purchased = 't' GROUP BY s.id, s.state_name, c.category_name, pd.id, pic.price ORDER BY s.state_name, pd.id)


/*alphabetical + categoryid STATE*/
SELECT state_name, SUM(total) AS totalPerCategoryPerState FROM T WHERE category_name = 'CAT_6' GROUP BY state_name ORDER BY state_name;

/*top-k + categoryid STATE */
SELECT state_name, SUM(total) AS totalPerCategoryPerState FROM T WHERE category_name = 'CAT_6' GROUP BY state_name ORDER BY totalPerCategoryPerState DESC;


/*other tables */
select * from person ORDER BY person_name;
select * from state ORDER BY state_name;
select * from product ORDER BY product_name;

-- alphabetical PRODUCT
SELECT product_name, SUM(total) AS totalPerProduct FROM T GROUP BY product_name ORDER BY product_name;
-- TOP-K PRODUCT
SELECT product_name, SUM(total) AS totalPerProduct FROM T GROUP BY product_name ORDER BY totalPerProduct DESC;



-- -- alphabetical+categoryid PRODUCT
-- SELECT product_name, SUM(total) AS totalPerProduct FROM T WHERE category_name = 'CAT_6' GROUP BY product_name ORDER BY product_name;
--
-- -- TOP-K + categoryid PRODUCT
-- SELECT product_name, category_name, SUM(total) AS totalPerProduct FROM T WHERE category_id = '4' GROUP BY product_name, category_id ORDER BY category_id, totalPerProduct DESC;

--To get products that are not in the category
-- SELECT pd.product_name FROM product pd WHERE NOT EXISTS (WITH T AS (SELECT
--                                                             s.id                            AS state_id,
--                                                             s.state_name,
--                                                             pd.id                           AS product,
--                                                             pd.product_name,
--                                                             pd.category_id,
--                                                             pic.price,
--                                                             sum(pic.quantity),
--                                                             (pic.price * sum(pic.quantity)) AS total
--                                                           FROM
--                                                             shopping_cart sc
--                                                             INNER JOIN products_in_cart pic ON (pic.cart_id = sc.id)
--                                                             RIGHT OUTER JOIN product pd ON (pd.id = pic.product_id)
--                                                             RIGHT JOIN person p ON (p.id = sc.person_id)
--                                                             INNER JOIN state s ON (s.id = p.id)
--                                                           WHERE sc.is_purchased = 't'
--                                                           GROUP BY s.id, s.state_name, pd.id, pic.price
--                                                           ORDER BY s.state_name, pd.id)
--                                                SELECT
--                                                  product_name,
--                                                  category_id,
--                                                  SUM(total) AS totalPerProduct
--                                                FROM T
--                                                WHERE category_id = '5'
--                                                AND pd.product_name = product_name
--                                                GROUP BY product_name, category_id
-- --                                                 ORDER BY category_id, product_name
-- );


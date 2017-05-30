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



/* CUSTOMER uses this */

/* Query 1 */
create index ind0 on shopping_cart(is_purchased);
create index ind1 on shopping_cart(person_id);
create index ind2 on products_in_cart(cart_id);
/* p(person_name) by default
   product(id) by default */

drop index ind0;
drop index ind1;
drop index ind2;
/*---------------------VIEW WITH NO CATEGORY------------------------------------*/
WITH T AS (SELECT p.id AS person_id, p.person_name, pd.id AS product, pd.product_name, pic.price, sum(pic.quantity), (pic.price*sum(pic.quantity)) AS total FROM
           shopping_cart sc
          INNER JOIN products_in_cart pic ON (pic.cart_id = sc.id)
          RIGHT OUTER JOIN product pd ON (pd.id = pic.product_id)
          RIGHT JOIN person p ON (p.id = sc.person_id)
        WHERE sc.is_purchased = 't' GROUP BY p.id, pd.id, pic.price ORDER BY p.person_name, pd.id)

WITH T AS (SELECT s.id AS state_id, s.state_name, pd.id AS product, pd.product_name, pic.price, sum(pic.quantity), (pic.price*sum(pic.quantity)) AS total FROM
           shopping_cart sc
          INNER JOIN products_in_cart pic ON (pic.cart_id = sc.id)
          RIGHT OUTER JOIN product pd ON (pd.id = pic.product_id)
          RIGHT JOIN person p ON (p.id = sc.person_id)
          INNER JOIN state s ON (s.id = p.id)
        WHERE sc.is_purchased = 't' GROUP BY s.id, pd.id, pic.price ORDER BY s.state_name, pd.id)

/*---------------------VIEW WITH CATEGORY FILTER------------------------------------*/
WITH T AS (SELECT p.id AS person_id, p.person_name, c.category_name, pd.id AS product, pd.product_name,  pic.price, sum(pic.quantity), (pic.price*sum(pic.quantity)) AS total FROM
           shopping_cart sc
          INNER JOIN products_in_cart pic ON (pic.cart_id = sc.id)
          RIGHT OUTER JOIN product pd ON (pd.id = pic.product_id)
          RIGHT JOIN person p ON (p.id = sc.person_id)
          INNER JOIN category c ON (pd.category_id = c.id)
        WHERE sc.is_purchased = 't' AND category_name = ?  GROUP BY p.id, pd.id, c.category_name, pic.price ORDER BY p.person_name, pd.id)

WITH T AS (SELECT s.id AS state_id, s.state_name, c.category_name, pd.id AS product, pd.product_name, pic.price, sum(pic.quantity), (pic.price*sum(pic.quantity)) AS total FROM
           shopping_cart sc
          INNER JOIN products_in_cart pic ON (pic.cart_id = sc.id)
          RIGHT OUTER JOIN product pd ON (pd.id = pic.product_id)
          RIGHT JOIN person p ON (p.id = sc.person_id)
          INNER JOIN state s ON (s.id = p.id)
          INNER JOIN category c ON (pd.category_id = c.id)
        WHERE sc.is_purchased = 't' AND category_name = ? GROUP BY s.id, s.state_name, c.category_name, pd.id, pic.price ORDER BY s.state_name, pd.id)

/* --------------------small table to have the items filtered and ordered for populating------------------------------------------------
/* CUSTOMER: alphabetical + ALL/CATEGORY*/
SELECT p.person_name AS name, SUM(total) AS totalPerItem FROM T RIGHT OUTER JOIN person p ON (T.person_name = p.person_name) GROUP BY p.person_name ORDER BY p.person_name;
/* CUSTOMER: top-k + ALL/CATEGORY */
SELECT p.person_name AS name, SUM(total) AS totalPerItem FROM T RIGHT OUTER JOIN person p ON (T.person_name = p.person_name) GROUP BY p.person_name ORDER BY totalPerItem DESC NULLS LAST, p.person_name;
/* STATE: alphabetical + ALL/CATEGORY*/
SELECT s.state_name AS name, SUM(total) AS totalPerItem FROM T RIGHT OUTER JOIN state s ON (T.state_name = s.state_name) GROUP BY s.state_name ORDER BY s.state_name;
/* STATE: top-k +ALL /CATEGORY*/
SELECT s.state_name AS name, SUM(total) AS totalPerItem FROM T RIGHT OUTER JOIN state s ON (T.state_name = s.state_name ) GROUP BY s.state_name ORDER BY totalPerItem DESC NULLS LAST, s.state_name;
/* PRODUCT: alphabetical + ALL*/
SELECT LEFT(pd.product_name, 10) AS name, SUM(total) AS totalPerItem FROM T RIGHT OUTER JOIN product pd ON (T.product = pd.id) GROUP BY pd.product_name, pd.id ORDER BY pd.product_name, pd.id;
/* PRODUCT: top-k + ALL*/
SELECT LEFT(pd.product_name, 10) AS name, SUM(total) AS totalPerItem FROM T RIGHT OUTER JOIN product pd ON (T.product = pd.id) GROUP BY pd.product_name, pd.id ORDER BY totalPerItem DESC NULLS LAST, pd.id;
/* PRODUCT: alphabetical + CATEGORY*/
SELECT LEFT(pd.product_name, 10) AS name, SUM(total) AS totalPerItem FROM T RIGHT OUTER JOIN product pd ON (T.product = pd.id) INNER JOIN category c1 ON (pd.category_id = c1.id) WHERE c1.category_name= ? GROUP BY pd.product_name, pd.id ORDER BY pd.product_name, pd.id;
/* PRODUCT: top-k+ CATEGORY*/
SELECT LEFT(pd.product_name, 10) AS name, SUM(total) AS totalPerItem FROM T RIGHT OUTER JOIN product pd ON (T.product = pd.id) INNER JOIN category c1 ON (pd.category_id = c1.id) WHERE c1.category_name = ? GROUP BY pd.product_name, pd.id ORDER BY totalPerItem DESC NULLS LAST, pd.id;

/*------------------------Big table for searching products by current user name and current product name-----------------------------------------------------*/
SELECT p.id AS person_id, p.person_name, pd.id AS product, pd.product_name, pic.price, sum(pic.quantity), (pic.price*sum(pic.quantity)) AS total FROM
           shopping_cart sc
          INNER JOIN products_in_cart pic ON (pic.cart_id = sc.id)
          RIGHT OUTER JOIN product pd ON (pd.id = pic.product_id)
          RIGHT JOIN person p ON (p.id = sc.person_id)
        WHERE sc.is_purchased = 't' AND p.person_name = ? AND pd.product_name = ? GROUP BY p.id, pd.id, pic.price ORDER BY p.person_name, pd.id)
SELECT s.id AS state_id, s.state_name, pd.id AS product, pd.product_name, pic.price, sum(pic.quantity), (pic.price*sum(pic.quantity)) AS total FROM
           shopping_cart sc
          INNER JOIN products_in_cart pic ON (pic.cart_id = sc.id)
          RIGHT OUTER JOIN product pd ON (pd.id = pic.product_id)
          RIGHT JOIN person p ON (p.id = sc.person_id)
          INNER JOIN state s ON (s.id = p.id)
        WHERE sc.is_purchased = 't' AND s.state_name = ? AND pd.product_name = ? GROUP BY s.id, pd.id, pic.price ORDER BY s.state_name, pd.id)









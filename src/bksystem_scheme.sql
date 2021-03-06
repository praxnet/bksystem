CREATE TABLE 'bills' (
   'id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL,
   'created_at' DATETIME DEFAULT (datetime('now','localtime')),
   'updated_at' DATETIME DEFAULT (datetime('now','localtime'))
);

CREATE TABLE 'products' (
   'id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL check(typeof(id) = 'integer'),
   'ean' INTEGER,
   'name' VARCHAR NOT NULL ,
   'price' FLOAT DEFAULT 0.00,
   'image' BLOB,
   'status' INTEGER DEFAULT 0,
   'created_at' DATETIME DEFAULT (datetime('now','localtime')),
   'updated_at' DATETIME DEFAULT (datetime('now','localtime'))
);

CREATE TABLE 'fav_products' (
   'placement' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL,
   'product_id' INTEGER NOT NULL
);

CREATE TABLE 'sales' (
   'id' INTEGER PRIMARY KEY  AUTOINCREMENT,
   'user_account_id' INTEGER NOT NULL  check(typeof(user_account_id) = 'integer'),
   'product_id' INTEGER NOT NULL  check(typeof(product_id) = 'integer'),
   'price' FLOAT DEFAULT 0.00,
   'created_at' DATETIME DEFAULT (datetime('now','localtime')),
   'updated_at' DATETIME DEFAULT (datetime('now','localtime')),
   FOREIGN KEY(user_account_id) REFERENCES user_accounts(id),
   FOREIGN KEY(product_id) REFERENCES products(id)
);

CREATE TABLE 'user_accounts' (
   'id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL check(typeof(id) = 'integer'),
   'firstname' VARCHAR,
   'lastname' VARCHAR NOT NULL ,
   'status' INTEGER DEFAULT 0,
   'image' BLOB DEFAULT NULL,
   'created_at' DATETIME DEFAULT (datetime('now','localtime')),
   'updated_at' DATETIME DEFAULT (datetime('now','localtime'))
);

CREATE TABLE 'fav_users' (
   'placement' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL,
   'user_account_id' INTEGER NOT NULL
);

CREATE VIEW 'date_last_bills' AS
SELECT  id, MAX(created_at) AS 'created_at', MAX(created_at) AS 'updated_at' FROM   
   (
      SELECT bills.id AS 'id', bills.created_at, bills.created_at AS 'updated_at'
      FROM bills
   UNION ALL
      SELECT 0 AS 'id', '2000-01-01 00:00:00'  AS 'created_at','2000-01-01 00:00:00' AS 'updated_at'
   );

CREATE VIEW 'date_second_last_bills' AS
SELECT  id, MAX(created_at) AS 'created_at', MAX(created_at) AS 'updated_at' FROM   
   (
      SELECT bills.id AS 'id', bills.created_at, bills.created_at AS 'updated_at'
      FROM bills, date_last_bills
      WHERE bills.created_at < date_last_bills.created_at

   UNION ALL
      SELECT 0 AS 'id', '2000-01-01 00:00:00'  AS 'created_at','2000-01-01 00:00:00' AS 'updated_at'
   );

CREATE VIEW 'all_bills_account_balances' AS
   SELECT sale_id AS 'id', bill_id, user_account_id, firstname, lastname, round(sum(round(price,2)),2) AS 'sum', created_at, updated_at
   FROM
      (
         (SELECT id AS 'user_id',firstname,lastname
         FROM user_accounts)
      INNER JOIN
         (SELECT id AS 'sale_id', bill_id, user_account_id, product_id,price, enddate AS 'created_at', enddate as 'updated_at'  
          FROM sales,(
            SELECT * FROM (
               SELECT bill_id, max(id_pred) AS 'prev_id', startdate, enddate 
               FROM 
                  (SELECT id AS 'bill_id', created_at as 'enddate' FROM bills)
               JOIN
                  (SELECT id AS 'id_pred', created_at AS 'startdate' FROM bills 
                  UNION ALL 
                   SELECT 0 AS 'id_pred', '2000-01-01 00:00:00' AS 'startdate')
               WHERE id_pred < bill_id
               GROUP BY bill_id) 
            )
         WHERE sales.created_at > startdate AND sales.created_at <= enddate)
      ON user_id =user_account_id)
      GROUP BY user_account_id
      ORDER BY bill_id,lastname,firstname;


CREATE VIEW 'all_bills_account_purchases' AS
	SELECT sale_id AS 'id', bill_id, user_account_id, lastname, firstname, product_id, ean, name, price, count(product_id) AS count, round(sum(round(price,2)),2) AS 'sum', created_at, updated_at
	FROM
		(SELECT id AS 'user_id', lastname, firstname
  		FROM user_accounts)
	INNER JOIN
		(
		   (SELECT id AS 'pro_id', ean, name FROM products)
		INNER JOIN
		   (SELECT id AS 'sale_id', bill_id, user_account_id, product_id, price, enddate AS 'created_at', enddate as 'updated_at'  
         FROM sales,(
            SELECT * FROM (
               SELECT bill_id, max(id_pred) AS 'prev_id', startdate, enddate 
               FROM
                  (SELECT id AS 'bill_id', created_at as 'enddate' FROM bills)
               JOIN
                  (SELECT id AS 'id_pred', created_at AS 'startdate' FROM bills 
                  UNION ALL 
                  SELECT 0 AS 'id_pred', '2000-01-01 00:00:00' AS 'startdate')
               WHERE id_pred < bill_id
               GROUP BY bill_id) 
            )  
         WHERE sales.created_at > startdate AND sales.created_at <= enddate)
		ON pro_id = product_id)
	ON user_account_id = user_id
	GROUP BY bill_id, user_account_id, product_id, price
	ORDER BY bill_id, lastname, firstname, product_id, price;

CREATE VIEW 'all_bills_consumptions' AS
   SELECT sale_id AS 'id', bill_id, product_id, ean, name,price, count(product_id) AS 'count', round(sum(round(price,2)),2) AS 'sum', created_at, updated_at
   FROM
      (
         (SELECT id AS 'prod_id', ean,name
         FROM products)
      INNER JOIN
         (SELECT id AS 'sale_id', bill_id,  product_id,price, enddate AS 'created_at', enddate AS 'updated_at'  
         FROM sales,(
            SELECT * FROM (
               SELECT bill_id, max(id_pred) AS 'prev_id', startdate, enddate 
               FROM
                  (SELECT id AS 'bill_id', created_at AS 'enddate' FROM bills)
               JOIN
                  (SELECT id AS 'id_pred', created_at AS 'startdate' FROM bills 
                  UNION ALL 
                  SELECT 0 AS 'id_pred', '2000-01-01 00:00:00' AS 'startdate')
               WHERE id_pred < bill_id
               GROUP BY bill_id) 
              )
         WHERE sales.created_at > startdate AND sales.created_at <= enddate)
      ON prod_id = product_id)
      GROUP BY bill_id, product_id, price
      ORDER BY bill_id, name, price;

CREATE VIEW 'all_sales' AS
	SELECT sale_id AS 'id', bill_id, user_account_id, lastname, firstname, product_id, ean, name, price,created_at, updated_at
	FROM
		(SELECT id AS 'user_id', lastname, firstname
  		FROM user_accounts)
	INNER JOIN
		(
		   (SELECT id AS 'pro_id', ean, name FROM products)
		INNER JOIN
		   (SELECT id AS 'sale_id', bill_id, user_account_id, product_id, price, enddate AS 'created_at', enddate as 'updated_at'  
         FROM sales,(
            SELECT * FROM (
               SELECT bill_id, max(id_pred) AS 'prev_id', startdate, enddate 
               FROM
                  (SELECT id AS 'bill_id', created_at as 'enddate' FROM bills)
               JOIN
                  (SELECT id AS 'id_pred', created_at AS 'startdate' FROM bills 
                  UNION ALL 
                  SELECT 0 AS 'id_pred', '2000-01-01 00:00:00' AS 'startdate')
               WHERE id_pred < bill_id
               GROUP BY bill_id) 
            )  
         WHERE sales.created_at > startdate AND sales.created_at <= enddate)
		ON pro_id = product_id)
	ON user_account_id = user_id
	ORDER BY bill_id, lastname, firstname, product_id, price;


CREATE VIEW 'previous_account_purchases' AS
SELECT sale_id AS 'id', user_account_id, lastname, firstname, product_id, ean, name, price, count(product_id) AS count, round(sum(round(price,2)),2) AS 'sum', created_at,updated_at
   FROM
      (SELECT id AS 'user_id', lastname, firstname
      FROM user_accounts)
   INNER JOIN
      (
         (SELECT id AS 'pro_id', ean, name FROM products)
      INNER JOIN
        (SELECT sales.id AS 'sale_id',user_account_id, product_id, price,date_last_bills.created_at, date_last_bills.updated_at
         FROM sales,date_last_bills, date_second_last_bills
         WHERE sales.created_at > date_second_last_bills.created_at
         AND sales.created_at <= date_last_bills.created_at)
      ON pro_id = product_id
      )
   ON user_account_id = user_id
   GROUP BY user_account_id,product_id, price
   ORDER BY lastname, firstname, product_id;

CREATE VIEW 'previous_account_balances' AS
   SELECT user_account_id AS 'id', user_account_id, firstname, lastname, round(sum(round(price,2)),2) AS 'sum', created_at, updated_at
   FROM
      (
         (SELECT id AS 'user_id',firstname,lastname
         FROM user_accounts)
      INNER JOIN
         (SELECT user_account_id, product_id, price,date_last_bills.created_at,date_last_bills.updated_at
         FROM sales, date_last_bills, date_second_last_bills
         WHERE sales.created_at > date_second_last_bills.created_at
         AND sales.created_at <= date_last_bills.created_at)
      ON user_id =user_account_id)
      GROUP BY user_account_id
      ORDER BY lastname,firstname;

CREATE VIEW 'previous_consumptions' AS
SELECT sale_id AS 'id', product_id, ean, name, price, count(product_id) AS 'count', round(sum(round(price,2)),2) AS 'sum', created_at, updated_at
   FROM
      (
         (SELECT id AS 'prod_id', ean,name
         FROM products)
      INNER JOIN
         (SELECT sales.id AS 'sale_id', user_account_id, product_id, price, date_last_bills.created_at,date_last_bills.updated_at
         FROM sales, date_last_bills,date_second_last_bills
         WHERE sales.created_at > date_second_last_bills.created_at
         AND sales.created_at <= date_last_bills.created_at)
      ON prod_id = product_id)
      GROUP BY product_id, price
      ORDER BY name, price;

CREATE VIEW 'previous_fav_products' AS
   SELECT product_id, ean, name, num
   FROM ( SELECT id AS 'prod_id', ean, name FROM products) 
      INNER JOIN
         (SELECT product_id, count(product_id) AS num
         FROM
            (SELECT product_id
            FROM sales,date_last_bills, date_second_last_bills
            WHERE  sales.created_at > date_second_last_bills.created_at 
            AND sales.created_at <= date_last_bills.created_at
               AND sales.price > 0)
         GROUP BY product_id
         ORDER BY num desc)
      ON prod_id = product_id;

CREATE VIEW 'previous_fav_users' AS
   SELECT user_account_id,firstname,lastname, sum
   FROM (SELECT id AS 'user_id', firstname, lastname FROM user_accounts)
      INNER JOIN
         (SELECT user_account_id, round(sum(round(price,2)),2) AS sum
         FROM
            (SELECT user_account_id, product_id, price
            FROM sales,date_last_bills, date_second_last_bills
            WHERE  sales.created_at > date_second_last_bills.created_at 
            AND sales.created_at <= date_last_bills.created_at
            AND sales.price > 0)
         GROUP BY user_account_id
         ORDER BY sum desc)
      ON user_id=user_account_id;

CREATE VIEW 'current_account_purchases' AS
SELECT sale_id AS 'id', user_account_id, lastname, firstname, product_id, ean, name, price, count(product_id) AS count, round(sum(round(price,2)),2) AS 'sum', created_at, updated_at
   FROM
      (SELECT id AS 'user_id', lastname, firstname
      FROM user_accounts)
   INNER JOIN
      (
         (SELECT id AS 'prod_id', ean,name FROM products)
      INNER JOIN
        (SELECT sales.id AS 'sale_id',user_account_id, product_id, price,date_last_bills.created_at, date_last_bills.updated_at
         FROM sales,date_last_bills
         WHERE sales.created_at >= date_last_bills.created_at)
      ON prod_id = product_id
      )
   ON user_account_id = user_id
   GROUP BY user_account_id, product_id, price
   ORDER BY lastname,firstname,name;

CREATE VIEW 'current_account_balances' AS
   SELECT user_account_id AS 'id', user_account_id, firstname, lastname, round(sum(round(price,2)),2) AS 'sum', created_at, updated_at
   FROM
      (
         (SELECT id AS 'user_id',lastname,firstname
         FROM user_accounts)
      INNER JOIN
         (SELECT user_account_id, product_id, price, date_last_bills.created_at, date_last_bills.updated_at
         FROM sales,date_last_bills
         WHERE sales.created_at > date_last_bills.created_at)
      ON user_id = user_account_id)
      GROUP BY user_account_id
      ORDER BY lastname,firstname;

CREATE VIEW 'current_consumptions' AS
SELECT sale_id AS 'id',product_id, ean, name,price, count(product_id) AS 'count', round(sum(round(price,2)),2) AS 'sum',created_at,updated_at
   FROM
      (
         (SELECT id AS 'prod_id', ean,name
         FROM products )
      INNER JOIN
         (SELECT sales.id AS 'sale_id', user_account_id, product_id, price,date_last_bills.created_at,date_last_bills.updated_at
         FROM sales, date_last_bills
         WHERE  sales.created_at > date_last_bills.created_at)
      ON prod_id = product_id)
      GROUP BY product_id,price
      ORDER BY name, price;

CREATE VIEW 'current_fav_products' AS
   SELECT product_id, ean, name, num
   FROM ( SELECT id AS 'prod_id', ean, name FROM products) 
      INNER JOIN
         (SELECT product_id, count(product_id) AS num
         FROM
            (SELECT product_id
            FROM sales,date_last_bills
            WHERE sales.created_at > date_last_bills.created_at
            AND sales.price > 0)
         GROUP BY product_id
         ORDER BY num desc)
      ON prod_id = product_id;

CREATE VIEW 'current_fav_users' AS
   SELECT user_account_id,firstname,lastname,status,sum
   FROM ( SELECT id AS 'user_id', firstname, lastname,status FROM user_accounts) 
      INNER JOIN
         (SELECT user_account_id, round(sum(round(price,2)),2) AS sum
         FROM
            (SELECT user_account_id, product_id, price
            FROM sales,date_last_bills
            WHERE sales.created_at>date_last_bills.created_at
            AND sales.price > 0)
         GROUP BY user_account_id
         ORDER BY sum desc)
      ON user_id=user_account_id;



CREATE TRIGGER 'check_make_bill'
   BEFORE INSERT ON 'bills'
   BEGIN
      SELECT CASE
         WHEN NEW.created_at < (SELECT MAX(created_at) FROM bills)
         THEN RAISE(ABORT, 'There is a newer bill date in the table.Try a newer date!')
         WHEN NEW.created_at > (SELECT datetime('now','localtime'))
          THEN RAISE(ABORT, 'Date is in the future, Try an older date!')
      END;
   END;

CREATE TRIGGER 'reload_fav'
   AFTER INSERT ON 'bills'
   BEGIN
      DELETE FROM fav_products;
      INSERT INTO fav_products (product_id) SELECT product_id FROM previous_fav_products;
      DELETE FROM fav_users;
      INSERT INTO fav_users (user_account_id) SELECT user_account_id FROM previous_fav_users;
   END;

CREATE TRIGGER 'rewind_reload_fav'
   AFTER DELETE ON 'bills'
   BEGIN
      DELETE FROM fav_products;
      INSERT INTO fav_products (product_id) SELECT product_id FROM previous_fav_products;
      DELETE FROM fav_users;
      INSERT INTO fav_users (user_account_id) SELECT user_account_id FROM previous_fav_users;
   END;

CREATE TRIGGER 'rewind_seq_bills' AFTER DELETE ON 'bills'
   BEGIN
      UPDATE sqlite_sequence SET seq=(SELECT MAX(id) FROM bills) WHERE name = 'bills';
   END;

CREATE TRIGGER 'rewind_seq_products'
   AFTER DELETE ON 'fav_products'
   BEGIN
      UPDATE sqlite_sequence SET seq=(SELECT MAX(placement) FROM 'fav_products') WHERE name = 'fav_products';
   END;

CREATE TRIGGER 'rewind_seq_user' AFTER DELETE ON 'fav_users'
   BEGIN
      UPDATE sqlite_sequence SET seq=(SELECT MAX(placement) FROM 'fav_users') WHERE name = 'fav_users';
   END;

CREATE TRIGGER 'check_delete_product'
   BEFORE DELETE ON 'products'
   FOR EACH ROW
   BEGIN
      SELECT CASE
         WHEN OLD.id IN (SELECT product_id FROM current_consumptions)
         THEN RAISE(ABORT, 'Some unpaid products left in current_consumption. Please make a new bill first.')
         WHEN OLD.id IN (SELECT product_id FROM previous_consumptions)
         THEN RAISE(ABORT, 'Some products left in previous_consumption. Even if you exported the bill already, deletion will be not possile until next bill.')
      END;
      DELETE FROM sales WHERE OLD.id = sales.product_id;
      DELETE FROM fav_products;
      INSERT INTO fav_products (product_id) SELECT product_id FROM previous_fav_products;
   END;

CREATE TRIGGER 'check_delete_user'
   BEFORE DELETE ON 'user_accounts'
   FOR EACH ROW
   BEGIN
      SELECT CASE
         WHEN OLD.id IN (SELECT user_account_id FROM current_account_balances)
         THEN RAISE(ABORT, 'Some unpaid products left in current_account_balance. Please make a new bill first.')
         WHEN OLD.id IN (SELECT user_account_id FROM previous_account_balances)
        THEN RAISE(ABORT, 'Some products left in previous_account_balance. Even if you exported the bill already, deletion will be not possile until next bill.')
      END;
      DELETE FROM sales WHERE OLD.id = sales.user_account_id;
      DELETE FROM fav_users;
      INSERT INTO fav_users (user_account_id) SELECT user_account_id FROM previous_fav_users;
   END;

CREATE TRIGGER 'check_delete_sales'
   BEFORE DELETE ON 'sales'
   FOR EACH ROW
   BEGIN
      SELECT CASE
         WHEN OLD.created_at > (SELECT created_at FROM date_last_bills)
         THEN RAISE(ABORT, 'Cant delete sale, please make a new bill first. If you want to cancel the sale, set the price of sale to 0.00')
         WHEN OLD.created_at > (SELECT created_at FROM date_second_last_bills)
         THEN RAISE(ABORT, 'Cant delete sale. Deletion will be not possile until next bill. If you exported the bill already and want to cancel the sale, set price of sale to 0.00 and export again.')
      END;
   END;

CREATE TRIGGER 'check_perform_sale'
   BEFORE INSERT ON 'sales'
   FOR EACH ROW   
   BEGIN
      SELECT CASE
       WHEN NEW.product_id NOT IN (SELECT id FROM products)
       THEN RAISE(ROLLBACK, 'Product does not exist in products table.')
       WHEN NEW.user_account_id NOT IN (SELECT id FROM user_accounts)
       THEN RAISE(ROLLBACK, 'User does not exist in user_accounts table.')
      END;
   END;

CREATE TRIGGER 'update_products'
   AFTER UPDATE ON 'products'
   FOR EACH ROW
      WHEN OLD.updated_at >= NEW.updated_at OR NEW.id <> OLD.id
   BEGIN
      UPDATE products SET id = OLD.id, created_at = OLD.created_at, updated_at = datetime('now','localtime') WHERE NEW.id=id;
   END;

CREATE TRIGGER 'update_user_accounts'
   AFTER UPDATE ON 'user_accounts'
   FOR EACH ROW
      WHEN OLD.updated_at >= NEW.updated_at OR NEW.id <> OLD.id
   BEGIN
      UPDATE user_accounts SET id = OLD.id, created_at = OLD.created_at, updated_at = datetime('now','localtime') WHERE NEW.id=id;
   END;

CREATE TRIGGER 'update_sales'
   AFTER UPDATE ON 'sales'
   FOR EACH ROW
      WHEN OLD.updated_at >= NEW.updated_at OR NEW.id <> OLD.id
   BEGIN
     UPDATE sales SET id = OLD.id, created_at = OLD.created_at, updated_at = datetime('now','localtime') WHERE NEW.id=id;
   END;  

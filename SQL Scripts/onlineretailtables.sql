USE onlineretail_10_11;

CREATE TABLE invoiceline (
	invoicelineid CHAR(7) PRIMARY KEY, 
    invoiceid VARCHAR(10), 
    stockcode VARCHAR(10), 
    quantity INT, 
    price DECIMAL(10,2),
    FOREIGN KEY (invoiceid) REFERENCES invoice(invoiceid),
    FOREIGN KEY (stockcode) REFERENCES product(stockcode)
    );
    
CREATE TABLE invoice (
	invoiceid VARCHAR(10) PRIMARY KEY, 
    invoicedate DATETIME, 
    customerid INT,
    FOREIGN KEY (customerid) REFERENCES customer(customerid)
);

CREATE TABLE product (
	stockcode VARCHAR(10) PRIMARY KEY,
    productname VARCHAR(100)
);

CREATE TABLE customer (
	customerid INT PRIMARY KEY,
    country VARCHAR(50)
);

UPDATE customer
SET country = NULL
WHERE country = 'Unspecified';








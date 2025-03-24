# RFM  Segmentation - Data Analystics Project



## Step 1: Install Docker and pgAdmin

### 1. Install Docker

Download and install Docker from: [Docker Official Website](https://www.docker.com/get-started/).

Verify the installation:

```bash
docker --version
```

### 2. Install pgAdmin

Download and install from: [pgAdmin Official Website](https://www.pgadmin.org/download/).

After installation, open pgAdmin.

---

## Step 2: Run PostgreSQL with Docker

Run the following command to start a PostgreSQL container:

```bash
docker run --name postgres-container -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=123456 -p 5432:5432 -d postgres
```

- `docker run` → Run a new container.
- `--name postgres-container` → Name the container `postgres-container`.
- `-e POSTGRES_USER=postgres` → Set username to `postgres`.
- `-e POSTGRES_PASSWORD=123456` → Set password to `123456` (you can change it).
- `-p 5432:5432` → Expose port `5432` (default for PostgreSQL).
- `-d postgres` → Run the PostgreSQL container in the background.

Check if PostgreSQL is running:

```bash
docker ps
```

If you see `postgres-container` in the list, PostgreSQL is running successfully.

To restart the container:

```bash
docker start postgres-container
```

---

## Step 3: Connect to PostgreSQL using pgAdmin

1. Open **pgAdmin**.
2. Navigate to **"Servers"** → **"Create"** → **"Server"**.
3. Fill in the details:
   - **Name**: PostgreSQL Docker
   - **Connection** tab:
     - **Host name/address**: `localhost`
     - **Port**: `5432`
     - **Username**: `postgres`
     - **Password**: `123456`
     - **Save password**: ✅
4. Click **Save**. If the connection is successful, you will see PostgreSQL listed in pgAdmin.

---

## Step 4: Copy `.csv` File into Docker Container

### 1. Copy the file into the container:

Run this command in **cmd**:

```bash
docker cp C:\Users\Monkey\Downloads\customer_transaction.csv postgres-container:/customer_transaction.csv
```

- `docker cp` → Copy file from the host to the container.
- `C:\Users\Monkey\Downloads\customer_transaction.csv` → Path of the file on your machine.
- `postgres-container:/customer_transaction.csv` → Destination inside the container.

### 2. Connect to the PostgreSQL container:

```bash
docker exec -it postgres-container psql -U postgres
```

### 3. Create a database and table:

```bash
-- Create database
CREATE DATABASE mydb;

-- Connect to the database
\c mydb
```

```bash
-- Create table
CREATE TABLE customer_transaction (
    transaction_id SERIAL PRIMARY KEY,
    customer_id INT,
    purchase_date DATE,
    gmv NUMERIC
);

-- If you need to delete and recreate the table
DROP TABLE IF EXISTS customer_transaction;
```

---

## Step 5: Import CSV into PostgreSQL

```bash
COPY customer_transaction 
FROM '/customer_transaction.csv' 
DELIMITER ',' CSV HEADER;
```

---

## Step 6: Customer Segmentation

(You can add your segmentation queries and logic here.)

  

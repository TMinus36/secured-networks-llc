-- Database tuning for ATT Compute Plane persistence
CREATE DATABASE att_telemetry;
CREATE USER att_admin WITH ENCRYPTED PASSWORD 'change_me_via_vault';
GRANT ALL PRIVILEGES ON DATABASE att_telemetry TO att_admin;

-- Optimization for high-frequency write operations
ALTER SYSTEM SET max_connections = '100';
ALTER SYSTEM SET shared_buffers = '512MB';
ALTER SYSTEM SET effective_cache_size = '1536MB';
ALTER SYSTEM SET maintenance_work_mem = '128MB';
ALTER SYSTEM SET checkpoint_completion_target = '0.9';
ALTER SYSTEM SET wal_buffers = '16MB';
ALTER SYSTEM SET default_statistics_target = '100';
ALTER SYSTEM SET random_page_cost = '1.1';
ALTER SYSTEM SET effective_io_concurrency = '200';
ALTER SYSTEM SET work_mem = '6MB';
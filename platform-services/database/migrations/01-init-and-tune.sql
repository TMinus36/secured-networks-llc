-- Target: LXC 103 (172.16.30.103)
-- Hardware Profile: 2 vCPU / 2048 MB RAM
-- Enforcing thin-provisioned memory model

ALTER SYSTEM SET shared_buffers = '512MB';
ALTER SYSTEM SET effective_cache_size = '1536MB';
ALTER SYSTEM SET maintenance_work_mem = '128MB';
ALTER SYSTEM SET checkpoint_completion_target = '0.9';
ALTER SYSTEM SET wal_buffers = '16MB';
ALTER SYSTEM SET default_statistics_target = '100';
ALTER SYSTEM SET random_page_cost = '1.1';
ALTER SYSTEM SET effective_io_concurrency = '200';
ALTER SYSTEM SET work_mem = '5242kB';
ALTER SYSTEM SET huge_pages = 'off';
ALTER SYSTEM SET max_connections = '100';

CREATE DATABASE att_telemetry_db;
\c att_telemetry_db;

CREATE SCHEMA IF NOT EXISTS telemetry_data;
CREATE ROLE telemetry_writer WITH LOGIN PASSWORD 'vault_injected_secret';
GRANT USAGE ON SCHEMA telemetry_data TO telemetry_writer;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA telemetry_data TO telemetry_writer;

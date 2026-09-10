--liquibase formatted sql

--changeset conda-forge:1
CREATE TABLE conda_forge_test (id INTEGER PRIMARY KEY, name VARCHAR(100));
INSERT INTO conda_forge_test (id, name) VALUES (1, 'liquibase');
--rollback DROP TABLE conda_forge_test;
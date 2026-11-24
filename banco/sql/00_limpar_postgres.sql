-- Integrantes: Pâmela Cappia Torres; [inserir nome completo dos demais integrantes do grupo]
-- =====================================================================
-- 00_limpar_postgres.sql  (PostgreSQL)
-- Remove os objetos do projeto para permitir reexecução dos scripts.
-- =====================================================================
DROP VIEW  IF EXISTS vw_escolas_sem_saneamento_basico CASCADE;
DROP VIEW  IF EXISTS vw_indicadores_municipio CASCADE;
DROP VIEW  IF EXISTS vw_indicadores_uf CASCADE;
DROP VIEW  IF EXISTS vw_indicadores_regiao CASCADE;
DROP VIEW  IF EXISTS vw_indicadores_localizacao CASCADE;
DROP VIEW  IF EXISTS vw_indicadores_dependencia CASCADE;
DROP VIEW  IF EXISTS vw_indicadores_brasil CASCADE;
DROP VIEW  IF EXISTS vw_escola_completa CASCADE;
DROP TABLE IF EXISTS stg_escola CASCADE;
DROP TABLE IF EXISTS escola_tecnologia CASCADE;
DROP TABLE IF EXISTS escola_acessibilidade CASCADE;
DROP TABLE IF EXISTS escola_dependencias_fisicas CASCADE;
DROP TABLE IF EXISTS escola_saneamento CASCADE;
DROP TABLE IF EXISTS escola CASCADE;
DROP TABLE IF EXISTS municipio CASCADE;
DROP TABLE IF EXISTS uf CASCADE;
DROP TABLE IF EXISTS regiao CASCADE;
DROP TABLE IF EXISTS situacao_funcionamento CASCADE;
DROP TABLE IF EXISTS localizacao_diferenciada CASCADE;
DROP TABLE IF EXISTS localizacao CASCADE;
DROP TABLE IF EXISTS dependencia_administrativa CASCADE;
DROP TABLE IF EXISTS rede_ensino CASCADE;
DROP TABLE IF EXISTS dicionario_dados CASCADE;

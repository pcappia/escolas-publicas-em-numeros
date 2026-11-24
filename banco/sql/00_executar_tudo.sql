-- Integrantes: Pâmela Cappia Torres; [inserir nome completo dos demais integrantes do grupo]
-- =====================================================================
-- 00_executar_tudo.sql  -  roda o projeto inteiro no PostgreSQL (psql)
-- Uso (a partir da PASTA RAIZ do projeto):
--     createdb escolas2025
--     psql -d escolas2025 -v ON_ERROR_STOP=1 -f banco/sql/00_executar_tudo.sql
-- =====================================================================
\i banco/sql/00_limpar_postgres.sql
\i banco/sql/01_criar_estrutura.sql
\i banco/sql/02_carga_dominios.sql
\i banco/sql/03_staging_importacao.sql
\i banco/sql/04_carga_escolas.sql
\i banco/sql/05_indices_e_views.sql
ANALYZE;
\i banco/sql/06_testes_integridade.sql

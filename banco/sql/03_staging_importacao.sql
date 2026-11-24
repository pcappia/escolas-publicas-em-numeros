-- Integrantes: Pâmela Cappia Torres; [inserir nome completo dos demais integrantes do grupo]
-- =====================================================================
-- 03_staging_importacao.sql  (PostgreSQL / psql)
-- Área de transição (staging): recebe o CSV tratado, tudo como texto,
-- exatamente como veio da etapa de ETL. Depois, 04_carga_escolas.sql
-- distribui os dados nas tabelas normalizadas.
-- Execute a partir da pasta raiz do projeto (o caminho do CSV é relativo).
-- =====================================================================
CREATE TABLE stg_escola (
    nu_ano_censo TEXT, no_regiao TEXT, co_regiao TEXT, no_uf TEXT, sg_uf TEXT, co_uf TEXT,
    no_municipio TEXT, co_municipio TEXT, no_entidade TEXT, co_entidade TEXT, co_rede TEXT,
    tp_dependencia TEXT, tp_localizacao TEXT, tp_localizacao_diferenciada TEXT,
    tp_situacao_funcionamento TEXT, in_agua_potavel TEXT, in_agua_rede_publica TEXT,
    in_agua_inexistente TEXT, in_energia_rede_publica TEXT, in_energia_inexistente TEXT,
    in_esgoto_rede_publica TEXT, in_esgoto_fossa_septica TEXT, in_esgoto_inexistente TEXT,
    in_banheiro TEXT, in_banheiro_pne TEXT, in_biblioteca TEXT, in_biblioteca_sala_leitura TEXT,
    in_laboratorio_informatica TEXT, in_quadra_esportes TEXT, in_acessibilidade_elevador TEXT,
    in_acessibilidade_rampas TEXT, in_acessibilidade_inexistente TEXT, in_computador TEXT,
    in_internet TEXT, in_internet_alunos TEXT, in_internet_aprendizagem TEXT, in_banda_larga TEXT
);

-- Comando do cliente psql. O cabeçalho (com BOM) é descartado por HEADER true.
\copy stg_escola FROM 'dados/escolas_publicas_ativas_2025_tratada.csv' WITH (FORMAT csv, DELIMITER ';', HEADER true, ENCODING 'UTF8')

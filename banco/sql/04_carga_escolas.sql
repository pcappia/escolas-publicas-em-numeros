-- Integrantes: Pâmela Cappia Torres; [inserir nome completo dos demais integrantes do grupo]
-- =====================================================================
-- 04_carga_escolas.sql
-- Distribui os dados da área de transição (stg_escola) nas tabelas
-- normalizadas, respeitando a ordem das chaves estrangeiras.
-- =====================================================================
INSERT INTO regiao (co_regiao, no_regiao)
SELECT DISTINCT CAST(co_regiao AS SMALLINT), no_regiao FROM stg_escola;

INSERT INTO uf (co_uf, sg_uf, no_uf, co_regiao)
SELECT DISTINCT CAST(co_uf AS SMALLINT), sg_uf, no_uf, CAST(co_regiao AS SMALLINT) FROM stg_escola;

INSERT INTO municipio (co_municipio, no_municipio, co_uf)
SELECT DISTINCT CAST(co_municipio AS INTEGER), no_municipio, CAST(co_uf AS SMALLINT) FROM stg_escola;

INSERT INTO escola (co_entidade, nu_ano_censo, no_entidade, co_municipio, co_rede, tp_dependencia,
                    tp_localizacao, tp_localizacao_diferenciada, tp_situacao_funcionamento)
SELECT CAST(co_entidade AS INTEGER), CAST(nu_ano_censo AS SMALLINT), no_entidade,
       CAST(co_municipio AS INTEGER), CAST(co_rede AS SMALLINT), CAST(tp_dependencia AS SMALLINT),
       CAST(tp_localizacao AS SMALLINT), CAST(tp_localizacao_diferenciada AS SMALLINT),
       CAST(tp_situacao_funcionamento AS SMALLINT)
FROM stg_escola;

INSERT INTO escola_saneamento
SELECT CAST(co_entidade AS INTEGER),
       CAST(in_agua_potavel AS SMALLINT), CAST(in_agua_rede_publica AS SMALLINT), CAST(in_agua_inexistente AS SMALLINT),
       CAST(in_energia_rede_publica AS SMALLINT), CAST(in_energia_inexistente AS SMALLINT),
       CAST(in_esgoto_rede_publica AS SMALLINT), CAST(in_esgoto_fossa_septica AS SMALLINT), CAST(in_esgoto_inexistente AS SMALLINT)
FROM stg_escola;

INSERT INTO escola_dependencias_fisicas
SELECT CAST(co_entidade AS INTEGER),
       CAST(in_banheiro AS SMALLINT), CAST(in_banheiro_pne AS SMALLINT), CAST(in_biblioteca AS SMALLINT),
       CAST(in_biblioteca_sala_leitura AS SMALLINT), CAST(in_laboratorio_informatica AS SMALLINT), CAST(in_quadra_esportes AS SMALLINT)
FROM stg_escola;

INSERT INTO escola_acessibilidade
SELECT CAST(co_entidade AS INTEGER),
       CAST(in_acessibilidade_elevador AS SMALLINT), CAST(in_acessibilidade_rampas AS SMALLINT), CAST(in_acessibilidade_inexistente AS SMALLINT)
FROM stg_escola;

INSERT INTO escola_tecnologia
SELECT CAST(co_entidade AS INTEGER),
       CAST(in_computador AS SMALLINT), CAST(in_internet AS SMALLINT), CAST(in_internet_alunos AS SMALLINT),
       CAST(in_internet_aprendizagem AS SMALLINT),
       CAST(NULLIF(in_banda_larga, '') AS SMALLINT)   -- vazio = não se aplica (escola sem internet)
FROM stg_escola;

DROP TABLE stg_escola;

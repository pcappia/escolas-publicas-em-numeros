-- Integrantes: Pâmela Cappia Torres; [inserir nome completo dos demais integrantes do grupo]
-- =====================================================================
-- 07_consultas_exemplo.sql
-- Perguntas que a sociedade pode responder com o banco. Copie e execute.
-- =====================================================================

-- 1) Quantas escolas públicas em atividade existem em cada região?
SELECT no_regiao, qtd_escolas FROM vw_indicadores_regiao ORDER BY qtd_escolas DESC;

-- 2) Quais estados têm mais escolas SEM esgotamento sanitário (em %)?
SELECT sg_uf, no_uf, qtd_escolas, pct_sem_esgoto
  FROM vw_indicadores_uf ORDER BY pct_sem_esgoto DESC LIMIT 10;

-- 3) Escolas urbanas x rurais: quem tem mais internet para os alunos?
SELECT ds_localizacao, qtd_escolas, pct_internet, pct_internet_alunos, pct_lab_informatica
  FROM vw_indicadores_localizacao;

-- 4) Escolas sem acessibilidade em cada região
SELECT no_regiao, pct_sem_acessibilidade, pct_rampas, pct_banheiro_acessivel
  FROM vw_indicadores_regiao ORDER BY pct_sem_acessibilidade DESC;

-- 5) Dez municípios com mais escolas sem energia elétrica (quantidade absoluta)
SELECT sg_uf, no_municipio, COUNT(*) AS escolas_sem_energia
  FROM vw_escolas_sem_saneamento_basico
 WHERE sem_energia = 1
 GROUP BY sg_uf, no_municipio ORDER BY escolas_sem_energia DESC LIMIT 10;

-- 6) Escolas do meu município sem água, energia ou esgoto (troque o nome e a UF)
SELECT no_entidade, ds_dependencia, ds_localizacao, sem_agua, sem_energia, sem_esgoto
  FROM vw_escolas_sem_saneamento_basico
 WHERE sg_uf = 'AM' AND no_municipio = 'São Gabriel da Cachoeira'
 ORDER BY no_entidade;

-- 7) Escolas em terras indígenas e quilombolas: acesso à internet
SELECT ds_localizacao_diferenciada, COUNT(*) AS qtd_escolas,
       ROUND(100.0 * SUM(in_internet) / COUNT(*), 1) AS pct_internet,
       ROUND(100.0 * SUM(in_acessibilidade_inexistente) / COUNT(*), 1) AS pct_sem_acessibilidade
  FROM vw_escola_completa
 GROUP BY ds_localizacao_diferenciada ORDER BY qtd_escolas DESC;

-- 8) Ranking de estados por laboratório de informática
SELECT sg_uf, pct_lab_informatica, pct_computador FROM vw_indicadores_uf ORDER BY pct_lab_informatica DESC;

-- 9) Buscar escolas pelo nome (ex.: "SAO JOSE")
SELECT no_entidade, no_municipio, sg_uf, ds_dependencia
  FROM vw_escola_completa WHERE no_entidade LIKE '%SAO JOSE%' ORDER BY sg_uf, no_municipio LIMIT 20;

-- 10) Escolas rurais municipais sem internet e sem computador
SELECT sg_uf, COUNT(*) AS qtd
  FROM vw_escola_completa
 WHERE ds_localizacao = 'Rural' AND ds_dependencia = 'Municipal' AND in_internet = 0 AND in_computador = 0
 GROUP BY sg_uf ORDER BY qtd DESC;

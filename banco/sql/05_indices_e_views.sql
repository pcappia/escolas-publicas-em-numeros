-- Integrantes: Pâmela Cappia Torres; [inserir nome completo dos demais integrantes do grupo]
-- =====================================================================
-- 05_indices_e_views.sql
-- Índices para acelerar junções/filtros e views públicas para consulta
-- simples (sem precisar conhecer as tabelas nem fazer JOIN).
-- =====================================================================
CREATE INDEX idx_uf_regiao            ON uf (co_regiao);
CREATE INDEX idx_municipio_uf         ON municipio (co_uf);
CREATE INDEX idx_escola_municipio     ON escola (co_municipio);
CREATE INDEX idx_escola_dependencia   ON escola (tp_dependencia);
CREATE INDEX idx_escola_localizacao   ON escola (tp_localizacao);
CREATE INDEX idx_escola_loc_dif       ON escola (tp_localizacao_diferenciada);

-- ---------------------------------------------------------------------
-- vw_escola_completa: uma linha por escola, com tudo já "traduzido".
-- É a visão mais simples para quem só quer consultar ou exportar.
-- ---------------------------------------------------------------------
CREATE VIEW vw_escola_completa AS
SELECT e.nu_ano_censo, r.co_regiao, r.no_regiao, u.co_uf, u.sg_uf, u.no_uf,
       m.co_municipio, m.no_municipio, e.co_entidade, e.no_entidade,
       d.ds_dependencia, l.ds_localizacao, ld.ds_localizacao_diferenciada,
       e.co_rede, e.tp_dependencia, e.tp_localizacao, e.tp_localizacao_diferenciada, e.tp_situacao_funcionamento,
       s.in_agua_potavel, s.in_agua_rede_publica, s.in_agua_inexistente,
       s.in_energia_rede_publica, s.in_energia_inexistente,
       s.in_esgoto_rede_publica, s.in_esgoto_fossa_septica, s.in_esgoto_inexistente,
       f.in_banheiro, f.in_banheiro_pne, f.in_biblioteca, f.in_biblioteca_sala_leitura,
       f.in_laboratorio_informatica, f.in_quadra_esportes,
       a.in_acessibilidade_elevador, a.in_acessibilidade_rampas, a.in_acessibilidade_inexistente,
       t.in_computador, t.in_internet, t.in_internet_alunos, t.in_internet_aprendizagem, t.in_banda_larga
  FROM escola e
  JOIN municipio m                  ON m.co_municipio = e.co_municipio
  JOIN uf u                         ON u.co_uf = m.co_uf
  JOIN regiao r                     ON r.co_regiao = u.co_regiao
  JOIN dependencia_administrativa d ON d.tp_dependencia = e.tp_dependencia
  JOIN localizacao l                ON l.tp_localizacao = e.tp_localizacao
  JOIN localizacao_diferenciada ld  ON ld.tp_localizacao_diferenciada = e.tp_localizacao_diferenciada
  JOIN escola_saneamento s          ON s.co_entidade = e.co_entidade
  JOIN escola_dependencias_fisicas f ON f.co_entidade = e.co_entidade
  JOIN escola_acessibilidade a      ON a.co_entidade = e.co_entidade
  JOIN escola_tecnologia t          ON t.co_entidade = e.co_entidade;

-- ---------------------------------------------------------------------
-- Indicadores: percentual de escolas que possuem cada item.
-- (pct_sem_* = percentual de escolas que declararam NÃO ter o serviço)
-- pct_banda_larga_entre_com_internet considera só escolas com internet.
-- ---------------------------------------------------------------------
-- Indicadores do país inteiro (uma linha).
CREATE VIEW vw_indicadores_brasil AS
SELECT 'Brasil' AS abrangencia,
       COUNT(*) AS qtd_escolas,
       ROUND(100.0 * SUM(in_agua_potavel) / COUNT(*), 1) AS pct_agua_potavel,
       ROUND(100.0 * SUM(in_agua_rede_publica) / COUNT(*), 1) AS pct_agua_rede_publica,
       ROUND(100.0 * SUM(in_agua_inexistente) / COUNT(*), 1) AS pct_sem_agua,
       ROUND(100.0 * SUM(in_energia_rede_publica) / COUNT(*), 1) AS pct_energia_rede_publica,
       ROUND(100.0 * SUM(in_energia_inexistente) / COUNT(*), 1) AS pct_sem_energia,
       ROUND(100.0 * SUM(in_esgoto_rede_publica) / COUNT(*), 1) AS pct_esgoto_rede_publica,
       ROUND(100.0 * SUM(in_esgoto_inexistente) / COUNT(*), 1) AS pct_sem_esgoto,
       ROUND(100.0 * SUM(in_banheiro) / COUNT(*), 1) AS pct_banheiro,
       ROUND(100.0 * SUM(in_banheiro_pne) / COUNT(*), 1) AS pct_banheiro_acessivel,
       ROUND(100.0 * SUM(in_biblioteca_sala_leitura) / COUNT(*), 1) AS pct_biblioteca_sala_leitura,
       ROUND(100.0 * SUM(in_laboratorio_informatica) / COUNT(*), 1) AS pct_lab_informatica,
       ROUND(100.0 * SUM(in_quadra_esportes) / COUNT(*), 1) AS pct_quadra_esportes,
       ROUND(100.0 * SUM(in_acessibilidade_rampas) / COUNT(*), 1) AS pct_rampas,
       ROUND(100.0 * SUM(in_acessibilidade_inexistente) / COUNT(*), 1) AS pct_sem_acessibilidade,
       ROUND(100.0 * SUM(in_computador) / COUNT(*), 1) AS pct_computador,
       ROUND(100.0 * SUM(in_internet) / COUNT(*), 1) AS pct_internet,
       ROUND(100.0 * SUM(in_internet_alunos) / COUNT(*), 1) AS pct_internet_alunos,
       ROUND(100.0 * SUM(in_internet_aprendizagem) / COUNT(*), 1) AS pct_internet_aprendizagem,
       ROUND(100.0 * SUM(in_banda_larga) / NULLIF(SUM(in_internet), 0), 1) AS pct_banda_larga_entre_com_internet
  FROM vw_escola_completa;

-- Indicadores por região geográfica.
CREATE VIEW vw_indicadores_regiao AS
SELECT no_regiao,
       COUNT(*) AS qtd_escolas,
       ROUND(100.0 * SUM(in_agua_potavel) / COUNT(*), 1) AS pct_agua_potavel,
       ROUND(100.0 * SUM(in_agua_rede_publica) / COUNT(*), 1) AS pct_agua_rede_publica,
       ROUND(100.0 * SUM(in_agua_inexistente) / COUNT(*), 1) AS pct_sem_agua,
       ROUND(100.0 * SUM(in_energia_rede_publica) / COUNT(*), 1) AS pct_energia_rede_publica,
       ROUND(100.0 * SUM(in_energia_inexistente) / COUNT(*), 1) AS pct_sem_energia,
       ROUND(100.0 * SUM(in_esgoto_rede_publica) / COUNT(*), 1) AS pct_esgoto_rede_publica,
       ROUND(100.0 * SUM(in_esgoto_inexistente) / COUNT(*), 1) AS pct_sem_esgoto,
       ROUND(100.0 * SUM(in_banheiro) / COUNT(*), 1) AS pct_banheiro,
       ROUND(100.0 * SUM(in_banheiro_pne) / COUNT(*), 1) AS pct_banheiro_acessivel,
       ROUND(100.0 * SUM(in_biblioteca_sala_leitura) / COUNT(*), 1) AS pct_biblioteca_sala_leitura,
       ROUND(100.0 * SUM(in_laboratorio_informatica) / COUNT(*), 1) AS pct_lab_informatica,
       ROUND(100.0 * SUM(in_quadra_esportes) / COUNT(*), 1) AS pct_quadra_esportes,
       ROUND(100.0 * SUM(in_acessibilidade_rampas) / COUNT(*), 1) AS pct_rampas,
       ROUND(100.0 * SUM(in_acessibilidade_inexistente) / COUNT(*), 1) AS pct_sem_acessibilidade,
       ROUND(100.0 * SUM(in_computador) / COUNT(*), 1) AS pct_computador,
       ROUND(100.0 * SUM(in_internet) / COUNT(*), 1) AS pct_internet,
       ROUND(100.0 * SUM(in_internet_alunos) / COUNT(*), 1) AS pct_internet_alunos,
       ROUND(100.0 * SUM(in_internet_aprendizagem) / COUNT(*), 1) AS pct_internet_aprendizagem,
       ROUND(100.0 * SUM(in_banda_larga) / NULLIF(SUM(in_internet), 0), 1) AS pct_banda_larga_entre_com_internet
  FROM vw_escola_completa
 GROUP BY no_regiao;

-- Indicadores por unidade da federação.
CREATE VIEW vw_indicadores_uf AS
SELECT no_regiao,
       sg_uf,
       no_uf,
       COUNT(*) AS qtd_escolas,
       ROUND(100.0 * SUM(in_agua_potavel) / COUNT(*), 1) AS pct_agua_potavel,
       ROUND(100.0 * SUM(in_agua_rede_publica) / COUNT(*), 1) AS pct_agua_rede_publica,
       ROUND(100.0 * SUM(in_agua_inexistente) / COUNT(*), 1) AS pct_sem_agua,
       ROUND(100.0 * SUM(in_energia_rede_publica) / COUNT(*), 1) AS pct_energia_rede_publica,
       ROUND(100.0 * SUM(in_energia_inexistente) / COUNT(*), 1) AS pct_sem_energia,
       ROUND(100.0 * SUM(in_esgoto_rede_publica) / COUNT(*), 1) AS pct_esgoto_rede_publica,
       ROUND(100.0 * SUM(in_esgoto_inexistente) / COUNT(*), 1) AS pct_sem_esgoto,
       ROUND(100.0 * SUM(in_banheiro) / COUNT(*), 1) AS pct_banheiro,
       ROUND(100.0 * SUM(in_banheiro_pne) / COUNT(*), 1) AS pct_banheiro_acessivel,
       ROUND(100.0 * SUM(in_biblioteca_sala_leitura) / COUNT(*), 1) AS pct_biblioteca_sala_leitura,
       ROUND(100.0 * SUM(in_laboratorio_informatica) / COUNT(*), 1) AS pct_lab_informatica,
       ROUND(100.0 * SUM(in_quadra_esportes) / COUNT(*), 1) AS pct_quadra_esportes,
       ROUND(100.0 * SUM(in_acessibilidade_rampas) / COUNT(*), 1) AS pct_rampas,
       ROUND(100.0 * SUM(in_acessibilidade_inexistente) / COUNT(*), 1) AS pct_sem_acessibilidade,
       ROUND(100.0 * SUM(in_computador) / COUNT(*), 1) AS pct_computador,
       ROUND(100.0 * SUM(in_internet) / COUNT(*), 1) AS pct_internet,
       ROUND(100.0 * SUM(in_internet_alunos) / COUNT(*), 1) AS pct_internet_alunos,
       ROUND(100.0 * SUM(in_internet_aprendizagem) / COUNT(*), 1) AS pct_internet_aprendizagem,
       ROUND(100.0 * SUM(in_banda_larga) / NULLIF(SUM(in_internet), 0), 1) AS pct_banda_larga_entre_com_internet
  FROM vw_escola_completa
 GROUP BY no_regiao, sg_uf, no_uf;

-- Indicadores por município.
CREATE VIEW vw_indicadores_municipio AS
SELECT sg_uf,
       no_municipio,
       co_municipio,
       COUNT(*) AS qtd_escolas,
       ROUND(100.0 * SUM(in_agua_potavel) / COUNT(*), 1) AS pct_agua_potavel,
       ROUND(100.0 * SUM(in_agua_rede_publica) / COUNT(*), 1) AS pct_agua_rede_publica,
       ROUND(100.0 * SUM(in_agua_inexistente) / COUNT(*), 1) AS pct_sem_agua,
       ROUND(100.0 * SUM(in_energia_rede_publica) / COUNT(*), 1) AS pct_energia_rede_publica,
       ROUND(100.0 * SUM(in_energia_inexistente) / COUNT(*), 1) AS pct_sem_energia,
       ROUND(100.0 * SUM(in_esgoto_rede_publica) / COUNT(*), 1) AS pct_esgoto_rede_publica,
       ROUND(100.0 * SUM(in_esgoto_inexistente) / COUNT(*), 1) AS pct_sem_esgoto,
       ROUND(100.0 * SUM(in_banheiro) / COUNT(*), 1) AS pct_banheiro,
       ROUND(100.0 * SUM(in_banheiro_pne) / COUNT(*), 1) AS pct_banheiro_acessivel,
       ROUND(100.0 * SUM(in_biblioteca_sala_leitura) / COUNT(*), 1) AS pct_biblioteca_sala_leitura,
       ROUND(100.0 * SUM(in_laboratorio_informatica) / COUNT(*), 1) AS pct_lab_informatica,
       ROUND(100.0 * SUM(in_quadra_esportes) / COUNT(*), 1) AS pct_quadra_esportes,
       ROUND(100.0 * SUM(in_acessibilidade_rampas) / COUNT(*), 1) AS pct_rampas,
       ROUND(100.0 * SUM(in_acessibilidade_inexistente) / COUNT(*), 1) AS pct_sem_acessibilidade,
       ROUND(100.0 * SUM(in_computador) / COUNT(*), 1) AS pct_computador,
       ROUND(100.0 * SUM(in_internet) / COUNT(*), 1) AS pct_internet,
       ROUND(100.0 * SUM(in_internet_alunos) / COUNT(*), 1) AS pct_internet_alunos,
       ROUND(100.0 * SUM(in_internet_aprendizagem) / COUNT(*), 1) AS pct_internet_aprendizagem,
       ROUND(100.0 * SUM(in_banda_larga) / NULLIF(SUM(in_internet), 0), 1) AS pct_banda_larga_entre_com_internet
  FROM vw_escola_completa
 GROUP BY sg_uf, no_municipio, co_municipio;

-- Indicadores: escolas urbanas x rurais.
CREATE VIEW vw_indicadores_localizacao AS
SELECT ds_localizacao,
       COUNT(*) AS qtd_escolas,
       ROUND(100.0 * SUM(in_agua_potavel) / COUNT(*), 1) AS pct_agua_potavel,
       ROUND(100.0 * SUM(in_agua_rede_publica) / COUNT(*), 1) AS pct_agua_rede_publica,
       ROUND(100.0 * SUM(in_agua_inexistente) / COUNT(*), 1) AS pct_sem_agua,
       ROUND(100.0 * SUM(in_energia_rede_publica) / COUNT(*), 1) AS pct_energia_rede_publica,
       ROUND(100.0 * SUM(in_energia_inexistente) / COUNT(*), 1) AS pct_sem_energia,
       ROUND(100.0 * SUM(in_esgoto_rede_publica) / COUNT(*), 1) AS pct_esgoto_rede_publica,
       ROUND(100.0 * SUM(in_esgoto_inexistente) / COUNT(*), 1) AS pct_sem_esgoto,
       ROUND(100.0 * SUM(in_banheiro) / COUNT(*), 1) AS pct_banheiro,
       ROUND(100.0 * SUM(in_banheiro_pne) / COUNT(*), 1) AS pct_banheiro_acessivel,
       ROUND(100.0 * SUM(in_biblioteca_sala_leitura) / COUNT(*), 1) AS pct_biblioteca_sala_leitura,
       ROUND(100.0 * SUM(in_laboratorio_informatica) / COUNT(*), 1) AS pct_lab_informatica,
       ROUND(100.0 * SUM(in_quadra_esportes) / COUNT(*), 1) AS pct_quadra_esportes,
       ROUND(100.0 * SUM(in_acessibilidade_rampas) / COUNT(*), 1) AS pct_rampas,
       ROUND(100.0 * SUM(in_acessibilidade_inexistente) / COUNT(*), 1) AS pct_sem_acessibilidade,
       ROUND(100.0 * SUM(in_computador) / COUNT(*), 1) AS pct_computador,
       ROUND(100.0 * SUM(in_internet) / COUNT(*), 1) AS pct_internet,
       ROUND(100.0 * SUM(in_internet_alunos) / COUNT(*), 1) AS pct_internet_alunos,
       ROUND(100.0 * SUM(in_internet_aprendizagem) / COUNT(*), 1) AS pct_internet_aprendizagem,
       ROUND(100.0 * SUM(in_banda_larga) / NULLIF(SUM(in_internet), 0), 1) AS pct_banda_larga_entre_com_internet
  FROM vw_escola_completa
 GROUP BY ds_localizacao;

-- Indicadores: escolas federais, estaduais e municipais.
CREATE VIEW vw_indicadores_dependencia AS
SELECT ds_dependencia,
       COUNT(*) AS qtd_escolas,
       ROUND(100.0 * SUM(in_agua_potavel) / COUNT(*), 1) AS pct_agua_potavel,
       ROUND(100.0 * SUM(in_agua_rede_publica) / COUNT(*), 1) AS pct_agua_rede_publica,
       ROUND(100.0 * SUM(in_agua_inexistente) / COUNT(*), 1) AS pct_sem_agua,
       ROUND(100.0 * SUM(in_energia_rede_publica) / COUNT(*), 1) AS pct_energia_rede_publica,
       ROUND(100.0 * SUM(in_energia_inexistente) / COUNT(*), 1) AS pct_sem_energia,
       ROUND(100.0 * SUM(in_esgoto_rede_publica) / COUNT(*), 1) AS pct_esgoto_rede_publica,
       ROUND(100.0 * SUM(in_esgoto_inexistente) / COUNT(*), 1) AS pct_sem_esgoto,
       ROUND(100.0 * SUM(in_banheiro) / COUNT(*), 1) AS pct_banheiro,
       ROUND(100.0 * SUM(in_banheiro_pne) / COUNT(*), 1) AS pct_banheiro_acessivel,
       ROUND(100.0 * SUM(in_biblioteca_sala_leitura) / COUNT(*), 1) AS pct_biblioteca_sala_leitura,
       ROUND(100.0 * SUM(in_laboratorio_informatica) / COUNT(*), 1) AS pct_lab_informatica,
       ROUND(100.0 * SUM(in_quadra_esportes) / COUNT(*), 1) AS pct_quadra_esportes,
       ROUND(100.0 * SUM(in_acessibilidade_rampas) / COUNT(*), 1) AS pct_rampas,
       ROUND(100.0 * SUM(in_acessibilidade_inexistente) / COUNT(*), 1) AS pct_sem_acessibilidade,
       ROUND(100.0 * SUM(in_computador) / COUNT(*), 1) AS pct_computador,
       ROUND(100.0 * SUM(in_internet) / COUNT(*), 1) AS pct_internet,
       ROUND(100.0 * SUM(in_internet_alunos) / COUNT(*), 1) AS pct_internet_alunos,
       ROUND(100.0 * SUM(in_internet_aprendizagem) / COUNT(*), 1) AS pct_internet_aprendizagem,
       ROUND(100.0 * SUM(in_banda_larga) / NULLIF(SUM(in_internet), 0), 1) AS pct_banda_larga_entre_com_internet
  FROM vw_escola_completa
 GROUP BY ds_dependencia;

-- ---------------------------------------------------------------------
-- vw_escolas_sem_saneamento_basico: escolas que declararam NÃO ter água,
-- energia elétrica ou esgotamento sanitário (lista para cobrança e priorização).
-- ---------------------------------------------------------------------
CREATE VIEW vw_escolas_sem_saneamento_basico AS
SELECT no_regiao, sg_uf, no_municipio, co_entidade, no_entidade, ds_dependencia, ds_localizacao,
       in_agua_inexistente   AS sem_agua,
       in_energia_inexistente AS sem_energia,
       in_esgoto_inexistente AS sem_esgoto
  FROM vw_escola_completa
 WHERE in_agua_inexistente = 1 OR in_energia_inexistente = 1 OR in_esgoto_inexistente = 1;

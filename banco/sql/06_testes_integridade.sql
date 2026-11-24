-- Integrantes: Pâmela Cappia Torres; [inserir nome completo dos demais integrantes do grupo]
-- =====================================================================
-- 06_testes_integridade.sql
-- PARTE A (portável: PostgreSQL e SQLite) - consultas que devem retornar
--          resultado = 'OK' em todas as linhas.
-- PARTE B (somente PostgreSQL) - tentativas de inserir dados inválidos que
--          o banco DEVE rejeitar; cada bloco imprime "OK" quando rejeita.
-- =====================================================================

-- ===================== PARTE A: contagens e vínculos =====================
SELECT 'A01 Escolas carregadas' AS teste, 138086 AS esperado, COUNT(*) AS obtido,
       CASE WHEN COUNT(*) = 138086 THEN 'OK' ELSE 'FALHA' END AS resultado FROM escola
UNION ALL SELECT 'A02 Regiões', 5, COUNT(*), CASE WHEN COUNT(*) = 5 THEN 'OK' ELSE 'FALHA' END FROM regiao
UNION ALL SELECT 'A03 UFs', 27, COUNT(*), CASE WHEN COUNT(*) = 27 THEN 'OK' ELSE 'FALHA' END FROM uf
UNION ALL SELECT 'A04 Municípios com escola', 5571, COUNT(*), CASE WHEN COUNT(*) = 5571 THEN 'OK' ELSE 'FALHA' END FROM municipio
UNION ALL SELECT 'A05 Variáveis no dicionário', 37, COUNT(*), CASE WHEN COUNT(*) = 37 THEN 'OK' ELSE 'FALHA' END FROM dicionario_dados
UNION ALL SELECT 'A06 Escolas federais', 716, COUNT(*), CASE WHEN COUNT(*) = 716 THEN 'OK' ELSE 'FALHA' END FROM escola WHERE tp_dependencia = 1
UNION ALL SELECT 'A07 Escolas estaduais', 29998, COUNT(*), CASE WHEN COUNT(*) = 29998 THEN 'OK' ELSE 'FALHA' END FROM escola WHERE tp_dependencia = 2
UNION ALL SELECT 'A08 Escolas municipais', 107372, COUNT(*), CASE WHEN COUNT(*) = 107372 THEN 'OK' ELSE 'FALHA' END FROM escola WHERE tp_dependencia = 3
UNION ALL SELECT 'A09 Escolas urbanas', 87993, COUNT(*), CASE WHEN COUNT(*) = 87993 THEN 'OK' ELSE 'FALHA' END FROM escola WHERE tp_localizacao = 1
UNION ALL SELECT 'A10 Escolas rurais', 50093, COUNT(*), CASE WHEN COUNT(*) = 50093 THEN 'OK' ELSE 'FALHA' END FROM escola WHERE tp_localizacao = 2
UNION ALL SELECT 'A11 Saneamento 1:1 com escola', 138086, COUNT(*), CASE WHEN COUNT(*) = 138086 THEN 'OK' ELSE 'FALHA' END FROM escola_saneamento
UNION ALL SELECT 'A12 Dependências físicas 1:1', 138086, COUNT(*), CASE WHEN COUNT(*) = 138086 THEN 'OK' ELSE 'FALHA' END FROM escola_dependencias_fisicas
UNION ALL SELECT 'A13 Acessibilidade 1:1', 138086, COUNT(*), CASE WHEN COUNT(*) = 138086 THEN 'OK' ELSE 'FALHA' END FROM escola_acessibilidade
UNION ALL SELECT 'A14 Tecnologia 1:1', 138086, COUNT(*), CASE WHEN COUNT(*) = 138086 THEN 'OK' ELSE 'FALHA' END FROM escola_tecnologia
UNION ALL SELECT 'A15 Banda larga nula = escolas sem internet', 9472, COUNT(*), CASE WHEN COUNT(*) = 9472 THEN 'OK' ELSE 'FALHA' END FROM escola_tecnologia WHERE in_banda_larga IS NULL AND in_internet = 0
UNION ALL SELECT 'A16 Banda larga nula em escola COM internet', 0, COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'FALHA' END FROM escola_tecnologia WHERE in_banda_larga IS NULL AND in_internet = 1
-- ---- órfãos: registros sem o pai correspondente (devem ser 0) ----
UNION ALL SELECT 'A17 Escolas sem município', 0, COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'FALHA' END FROM escola e LEFT JOIN municipio m ON m.co_municipio = e.co_municipio WHERE m.co_municipio IS NULL
UNION ALL SELECT 'A18 Municípios sem UF', 0, COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'FALHA' END FROM municipio m LEFT JOIN uf u ON u.co_uf = m.co_uf WHERE u.co_uf IS NULL
UNION ALL SELECT 'A19 UFs sem região', 0, COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'FALHA' END FROM uf u LEFT JOIN regiao r ON r.co_regiao = u.co_regiao WHERE r.co_regiao IS NULL
UNION ALL SELECT 'A20 Escolas sem saneamento cadastrado', 0, COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'FALHA' END FROM escola e LEFT JOIN escola_saneamento s ON s.co_entidade = e.co_entidade WHERE s.co_entidade IS NULL
UNION ALL SELECT 'A21 Escolas sem tecnologia cadastrada', 0, COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'FALHA' END FROM escola e LEFT JOIN escola_tecnologia t ON t.co_entidade = e.co_entidade WHERE t.co_entidade IS NULL
-- ---- views: somam o mesmo total da tabela escola ----
UNION ALL SELECT 'A22 vw_escola_completa = escola', 138086, COUNT(*), CASE WHEN COUNT(*) = 138086 THEN 'OK' ELSE 'FALHA' END FROM vw_escola_completa
UNION ALL SELECT 'A23 Soma das UFs na view', 138086, SUM(qtd_escolas), CASE WHEN SUM(qtd_escolas) = 138086 THEN 'OK' ELSE 'FALHA' END FROM vw_indicadores_uf
UNION ALL SELECT 'A24 Soma dos municípios na view', 138086, SUM(qtd_escolas), CASE WHEN SUM(qtd_escolas) = 138086 THEN 'OK' ELSE 'FALHA' END FROM vw_indicadores_municipio
UNION ALL SELECT 'A25 Soma das regiões na view', 138086, SUM(qtd_escolas), CASE WHEN SUM(qtd_escolas) = 138086 THEN 'OK' ELSE 'FALHA' END FROM vw_indicadores_regiao
-- ---- indicador conferido contra o relatório de ETL (internet = 93,1%) ----
UNION ALL SELECT 'A26 % de escolas com internet (Brasil)', 93.1, pct_internet, CASE WHEN pct_internet = 93.1 THEN 'OK' ELSE 'FALHA' END FROM vw_indicadores_brasil
ORDER BY 1;

-- ===================== PARTE B (PostgreSQL): o banco deve REJEITAR =====================
DO $$ BEGIN
  BEGIN
    INSERT INTO escola VALUES (99999999, 2025, 'ESCOLA TESTE', 1234567, 1, 3, 1, 0, 1);
    RAISE EXCEPTION 'FALHA B01: aceitou escola com município inexistente';
  EXCEPTION WHEN foreign_key_violation THEN RAISE NOTICE 'B01 OK: município inexistente rejeitado (FK)';
  END;
END $$;

DO $$ BEGIN
  BEGIN
    INSERT INTO escola SELECT co_entidade, nu_ano_censo, 'DUPLICADA', co_municipio, co_rede, tp_dependencia, tp_localizacao, tp_localizacao_diferenciada, tp_situacao_funcionamento FROM escola LIMIT 1;
    RAISE EXCEPTION 'FALHA B02: aceitou código de escola duplicado';
  EXCEPTION WHEN unique_violation THEN RAISE NOTICE 'B02 OK: CO_ENTIDADE duplicado rejeitado (PK)';
  END;
END $$;

DO $$ BEGIN
  BEGIN
    UPDATE escola_saneamento SET in_agua_potavel = 2 WHERE co_entidade = (SELECT MIN(co_entidade) FROM escola);
    RAISE EXCEPTION 'FALHA B03: aceitou indicador fora de 0/1';
  EXCEPTION WHEN check_violation THEN RAISE NOTICE 'B03 OK: valor 2 em indicador 0/1 rejeitado (CHECK)';
  END;
END $$;

DO $$ BEGIN
  BEGIN
    UPDATE escola_saneamento SET in_agua_inexistente = 1, in_agua_rede_publica = 1 WHERE co_entidade = (SELECT MIN(co_entidade) FROM escola);
    RAISE EXCEPTION 'FALHA B04: aceitou "sem água" junto com "água da rede pública"';
  EXCEPTION WHEN check_violation THEN RAISE NOTICE 'B04 OK: contradição água x sem água rejeitada (CHECK)';
  END;
END $$;

DO $$ BEGIN
  BEGIN
    UPDATE escola_tecnologia SET in_internet = 0, in_banda_larga = 1, in_internet_alunos = 0, in_internet_aprendizagem = 0 WHERE co_entidade = (SELECT MIN(co_entidade) FROM escola);
    RAISE EXCEPTION 'FALHA B05: aceitou banda larga em escola sem internet';
  EXCEPTION WHEN check_violation THEN RAISE NOTICE 'B05 OK: banda larga sem internet rejeitada (CHECK)';
  END;
END $$;

DO $$ BEGIN
  BEGIN
    UPDATE escola_dependencias_fisicas SET in_banheiro = 0, in_banheiro_pne = 1 WHERE co_entidade = (SELECT MIN(co_entidade) FROM escola);
    RAISE EXCEPTION 'FALHA B06: aceitou banheiro acessível sem banheiro';
  EXCEPTION WHEN check_violation THEN RAISE NOTICE 'B06 OK: banheiro acessível sem banheiro rejeitado (CHECK)';
  END;
END $$;

DO $$ BEGIN
  BEGIN
    INSERT INTO municipio VALUES (3550308, 'MUNICIPIO TESTE', 53);   -- prefixo 35 não bate com a UF 53
    RAISE EXCEPTION 'FALHA B07: aceitou município com código incompatível com a UF';
  EXCEPTION WHEN check_violation THEN RAISE NOTICE 'B07 OK: código de município incompatível com a UF rejeitado (CHECK)';
  END;
END $$;

DO $$ BEGIN
  BEGIN
    DELETE FROM uf WHERE sg_uf = 'SP';
    RAISE EXCEPTION 'FALHA B08: permitiu apagar UF que possui municípios';
  EXCEPTION WHEN foreign_key_violation THEN RAISE NOTICE 'B08 OK: exclusão de UF com municípios bloqueada (FK)';
  END;
END $$;

-- B09: apagar uma escola remove, em cascata, seus registros de infraestrutura.
-- Tudo dentro de uma transação desfeita (ROLLBACK): o banco não é alterado.
BEGIN;
  DELETE FROM escola WHERE co_entidade = (SELECT MIN(co_entidade) FROM escola);
  SELECT 'B09 Cascata: filhos órfãos após excluir escola' AS teste, 0 AS esperado,
         (SELECT COUNT(*) FROM escola_saneamento s WHERE NOT EXISTS (SELECT 1 FROM escola e WHERE e.co_entidade = s.co_entidade)) AS obtido,
         CASE WHEN (SELECT COUNT(*) FROM escola_saneamento) = 138085 THEN 'OK' ELSE 'FALHA' END AS resultado;
ROLLBACK;

-- Integrantes: Pâmela Cappia Torres; [inserir nome completo dos demais integrantes do grupo]
-- =====================================================================
-- 02_carga_dominios.sql
-- Carga das tabelas de domínio (códigos oficiais do dicionário do INEP)
-- e do dicionário de dados do próprio banco.
-- =====================================================================
INSERT INTO rede_ensino (co_rede, ds_rede) VALUES (1, 'Pública'), (2, 'Privada');

INSERT INTO dependencia_administrativa (tp_dependencia, ds_dependencia) VALUES
 (1, 'Federal'), (2, 'Estadual'), (3, 'Municipal'), (4, 'Privada');

INSERT INTO localizacao (tp_localizacao, ds_localizacao) VALUES (1, 'Urbana'), (2, 'Rural');

INSERT INTO localizacao_diferenciada (tp_localizacao_diferenciada, ds_localizacao_diferenciada) VALUES
 (0, 'A escola não está em área de localização diferenciada'),
 (1, 'Área de assentamento'),
 (2, 'Terra indígena'),
 (3, 'Comunidade quilombola'),
 (8, 'Área onde se localizam povos e comunidades tradicionais');

INSERT INTO situacao_funcionamento (tp_situacao_funcionamento, ds_situacao_funcionamento) VALUES
 (1, 'Em Atividade'), (2, 'Paralisada'), (3, 'Extinta (ano do Censo)'), (4, 'Extinta em Anos Anteriores');

INSERT INTO dicionario_dados (variavel_origem, tabela, coluna, descricao, categorias) VALUES
('NU_ANO_CENSO', 'escola', 'nu_ano_censo', 'Ano do Censo', NULL),
('NO_REGIAO', 'regiao', 'no_regiao', 'Nome da Região Geográfica', NULL),
('CO_REGIAO', 'regiao', 'co_regiao', 'Código da Região Geográfica', NULL),
('NO_UF', 'uf', 'no_uf', 'Nome da Unidade da Federação', NULL),
('SG_UF', 'uf', 'sg_uf', 'Sigla da Unidade da Federação', NULL),
('CO_UF', 'uf', 'co_uf', 'Código da Unidade da Federação', NULL),
('NO_MUNICIPIO', 'municipio', 'no_municipio', 'Nome do Município', NULL),
('CO_MUNICIPIO', 'escola', 'co_municipio', 'Código do Município', NULL),
('NO_ENTIDADE', 'escola', 'no_entidade', 'Nome da Escola', NULL),
('CO_ENTIDADE', 'escola', 'co_entidade', 'Código da Escola', NULL),
('CO_REDE', 'escola', 'co_rede', 'Rede de Ensino', '1 - Pública; 2 - Privada'),
('TP_DEPENDENCIA', 'escola', 'tp_dependencia', 'Dependência Administrativa', '1 - Federal; 2 - Estadual; 3 - Municipal; 4 - Privada'),
('TP_LOCALIZACAO', 'escola', 'tp_localizacao', 'Localização', '1 - Urbana; 2 - Rural'),
('TP_LOCALIZACAO_DIFERENCIADA', 'escola', 'tp_localizacao_diferenciada', 'Localização diferenciada da escola', '0 - A escola não está em área de localização diferenciada; 1 - Área de assentamento; 2 - Terra indígena; 3 - Comunidade quilombola; 8 - Área onde se localizam povos e comunidades tradicionais'),
('TP_SITUACAO_FUNCIONAMENTO', 'escola', 'tp_situacao_funcionamento', 'Situação de funcionamento', '1 - Em Atividade; 2 - Paralisada; 3 - Extinta (ano do Censo); 4 - Extinta em Anos Anteriores'),
('IN_AGUA_POTAVEL', 'escola_saneamento', 'in_agua_potavel', 'Fornece água potável para o consumo humano', '0 - Não; 1 - Sim'),
('IN_AGUA_REDE_PUBLICA', 'escola_saneamento', 'in_agua_rede_publica', 'Abastecimento de água - Rede pública', '0 - Não; 1 - Sim'),
('IN_AGUA_INEXISTENTE', 'escola_saneamento', 'in_agua_inexistente', 'Abastecimento de água - Não há abastecimento de água', '0 - Não; 1 - Sim'),
('IN_ENERGIA_REDE_PUBLICA', 'escola_saneamento', 'in_energia_rede_publica', 'Abastecimento de energia elétrica - Rede pública', '0 - Não; 1 - Sim'),
('IN_ENERGIA_INEXISTENTE', 'escola_saneamento', 'in_energia_inexistente', 'Abastecimento de energia elétrica - Não há energia elétrica', '0 - Não; 1 - Sim'),
('IN_ESGOTO_REDE_PUBLICA', 'escola_saneamento', 'in_esgoto_rede_publica', 'Esgoto sanitário - Rede pública', '0 - Não; 1 - Sim'),
('IN_ESGOTO_FOSSA_SEPTICA', 'escola_saneamento', 'in_esgoto_fossa_septica', 'Esgoto sanitário - Fossa Séptica', '0 - Não; 1 - Sim'),
('IN_ESGOTO_INEXISTENTE', 'escola_saneamento', 'in_esgoto_inexistente', 'Esgoto sanitário - Não há esgotamento sanitário', '0 - Não; 1 - Sim'),
('IN_BANHEIRO', 'escola_dependencias_fisicas', 'in_banheiro', 'Dependências físicas existentes e utilizadas na escola - Banheiro', '0 - Não; 1 - Sim'),
('IN_BANHEIRO_PNE', 'escola_dependencias_fisicas', 'in_banheiro_pne', 'Dependências físicas existentes e utilizadas na escola - Banheiro acessível, adequado ao uso de pessoas com deficiência ou mobilidade reduzida', '0 - Não; 1 - Sim'),
('IN_BIBLIOTECA', 'escola_dependencias_fisicas', 'in_biblioteca', 'Dependências físicas existentes e utilizadas na escola - Biblioteca', '0 - Não; 1 - Sim'),
('IN_BIBLIOTECA_SALA_LEITURA', 'escola_dependencias_fisicas', 'in_biblioteca_sala_leitura', 'Dependências físicas existentes e utilizadas na escola - Biblioteca e/ou Sala de leitura', '0 - Não; 1 - Sim'),
('IN_LABORATORIO_INFORMATICA', 'escola_dependencias_fisicas', 'in_laboratorio_informatica', 'Dependências físicas existentes e utilizadas na escola - Laboratório de informática', '0 - Não; 1 - Sim'),
('IN_QUADRA_ESPORTES', 'escola_dependencias_fisicas', 'in_quadra_esportes', 'Dependências físicas existentes e utilizadas na escola - Quadra de esportes coberta ou descoberta', '0 - Não; 1 - Sim'),
('IN_ACESSIBILIDADE_ELEVADOR', 'escola_acessibilidade', 'in_acessibilidade_elevador', 'Recursos de acessibilidade para pessoas com deficiência ou mobilidade reduzida nas vias de circulação interna na escola - Elevador', '0 - Não; 1 - Sim'),
('IN_ACESSIBILIDADE_RAMPAS', 'escola_acessibilidade', 'in_acessibilidade_rampas', 'Recursos de acessibilidade para pessoas com deficiência ou mobilidade reduzida nas vias de circulação interna na escola - Rampas', '0 - Não; 1 - Sim'),
('IN_ACESSIBILIDADE_INEXISTENTE', 'escola_acessibilidade', 'in_acessibilidade_inexistente', 'Recursos de acessibilidade para pessoas com deficiência ou mobilidade reduzida nas vias de circulação interna na escola - Nenhum dos recursos de acessibilidade listados', '0 - Não; 1 - Sim'),
('IN_COMPUTADOR', 'escola_tecnologia', 'in_computador', 'Equipamentos existentes na escola para uso técnico e administrativo - Computador', '0 - Não; 1 - Sim'),
('IN_INTERNET', 'escola_tecnologia', 'in_internet', 'Acesso à Internet', '0 - Não; 1 - Sim'),
('IN_INTERNET_ALUNOS', 'escola_tecnologia', 'in_internet_alunos', 'Acesso à Internet - Para uso dos alunos', '0 - Não; 1 - Sim'),
('IN_INTERNET_APRENDIZAGEM', 'escola_tecnologia', 'in_internet_aprendizagem', 'Acesso à Internet - Para uso nos processos de ensino e aprendizagem', '0 - Não; 1 - Sim'),
('IN_BANDA_LARGA', 'escola_tecnologia', 'in_banda_larga', 'Internet Banda Larga', '0 - Não; 1 - Sim;    - Não aplicável para escolas sem acesso à internet');

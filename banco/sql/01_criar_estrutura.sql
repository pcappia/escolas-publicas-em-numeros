-- Integrantes: Pâmela Cappia Torres; [inserir nome completo dos demais integrantes do grupo]
-- =====================================================================
-- 01_criar_estrutura.sql
-- Projeto de Extensão: Banco de Dados das Escolas Públicas em Atividade
-- Fonte: Censo Escolar 2025 (INEP) - Tabela de Escola
-- SGBD principal: PostgreSQL 16 (o script também roda em SQLite 3)
--
-- Modelo lógico (3FN):
--   regiao 1-N uf 1-N municipio 1-N escola
--   escola N-1 dependencia_administrativa | localizacao |
--              localizacao_diferenciada | rede_ensino | situacao_funcionamento
--   escola 1-1 escola_saneamento | escola_dependencias_fisicas |
--              escola_acessibilidade | escola_tecnologia
-- =====================================================================

-- ---------------------- Tabelas de domínio (códigos do INEP) ----------------------
CREATE TABLE rede_ensino (
    co_rede           SMALLINT     NOT NULL,
    ds_rede           VARCHAR(30)  NOT NULL,
    CONSTRAINT pk_rede_ensino PRIMARY KEY (co_rede),
    CONSTRAINT uq_rede_ensino_ds UNIQUE (ds_rede)
);

CREATE TABLE dependencia_administrativa (
    tp_dependencia    SMALLINT     NOT NULL,
    ds_dependencia    VARCHAR(30)  NOT NULL,
    CONSTRAINT pk_dependencia_administrativa PRIMARY KEY (tp_dependencia),
    CONSTRAINT uq_dependencia_ds UNIQUE (ds_dependencia)
);

CREATE TABLE localizacao (
    tp_localizacao    SMALLINT     NOT NULL,
    ds_localizacao    VARCHAR(30)  NOT NULL,
    CONSTRAINT pk_localizacao PRIMARY KEY (tp_localizacao),
    CONSTRAINT uq_localizacao_ds UNIQUE (ds_localizacao)
);

CREATE TABLE localizacao_diferenciada (
    tp_localizacao_diferenciada SMALLINT     NOT NULL,
    ds_localizacao_diferenciada VARCHAR(80)  NOT NULL,
    CONSTRAINT pk_localizacao_diferenciada PRIMARY KEY (tp_localizacao_diferenciada),
    CONSTRAINT uq_localizacao_dif_ds UNIQUE (ds_localizacao_diferenciada)
);

CREATE TABLE situacao_funcionamento (
    tp_situacao_funcionamento SMALLINT    NOT NULL,
    ds_situacao_funcionamento VARCHAR(40) NOT NULL,
    CONSTRAINT pk_situacao_funcionamento PRIMARY KEY (tp_situacao_funcionamento),
    CONSTRAINT uq_situacao_ds UNIQUE (ds_situacao_funcionamento)
);

-- ---------------------- Hierarquia geográfica ----------------------
CREATE TABLE regiao (
    co_regiao   SMALLINT    NOT NULL,
    no_regiao   VARCHAR(20) NOT NULL,
    CONSTRAINT pk_regiao PRIMARY KEY (co_regiao),
    CONSTRAINT uq_regiao_nome UNIQUE (no_regiao)
);

CREATE TABLE uf (
    co_uf       SMALLINT    NOT NULL,
    sg_uf       CHAR(2)     NOT NULL,
    no_uf       VARCHAR(30) NOT NULL,
    co_regiao   SMALLINT    NOT NULL,
    CONSTRAINT pk_uf PRIMARY KEY (co_uf),
    CONSTRAINT uq_uf_sigla UNIQUE (sg_uf),
    CONSTRAINT uq_uf_nome UNIQUE (no_uf),
    CONSTRAINT fk_uf_regiao FOREIGN KEY (co_regiao) REFERENCES regiao (co_regiao)
);

CREATE TABLE municipio (
    co_municipio INTEGER      NOT NULL,
    no_municipio VARCHAR(100) NOT NULL,
    co_uf        SMALLINT     NOT NULL,
    CONSTRAINT pk_municipio PRIMARY KEY (co_municipio),
    CONSTRAINT uq_municipio_uf_nome UNIQUE (co_uf, no_municipio),
    CONSTRAINT fk_municipio_uf FOREIGN KEY (co_uf) REFERENCES uf (co_uf),
    -- os 2 primeiros dígitos do código IBGE do município são o código da UF
    CONSTRAINT ck_municipio_prefixo_uf CHECK (co_municipio / 100000 = co_uf)
);

-- ---------------------- Entidade central: escola ----------------------
CREATE TABLE escola (
    co_entidade                  INTEGER       NOT NULL,
    nu_ano_censo                 SMALLINT      NOT NULL,
    no_entidade                  VARCHAR(150)  NOT NULL,
    co_municipio                 INTEGER       NOT NULL,
    co_rede                      SMALLINT      NOT NULL,
    tp_dependencia               SMALLINT      NOT NULL,
    tp_localizacao               SMALLINT      NOT NULL,
    tp_localizacao_diferenciada  SMALLINT      NOT NULL,
    tp_situacao_funcionamento    SMALLINT      NOT NULL,
    CONSTRAINT pk_escola PRIMARY KEY (co_entidade),
    CONSTRAINT fk_escola_municipio   FOREIGN KEY (co_municipio) REFERENCES municipio (co_municipio),
    CONSTRAINT fk_escola_rede        FOREIGN KEY (co_rede) REFERENCES rede_ensino (co_rede),
    CONSTRAINT fk_escola_dependencia FOREIGN KEY (tp_dependencia) REFERENCES dependencia_administrativa (tp_dependencia),
    CONSTRAINT fk_escola_localizacao FOREIGN KEY (tp_localizacao) REFERENCES localizacao (tp_localizacao),
    CONSTRAINT fk_escola_loc_dif     FOREIGN KEY (tp_localizacao_diferenciada) REFERENCES localizacao_diferenciada (tp_localizacao_diferenciada),
    CONSTRAINT fk_escola_situacao    FOREIGN KEY (tp_situacao_funcionamento) REFERENCES situacao_funcionamento (tp_situacao_funcionamento),
    CONSTRAINT ck_escola_ano CHECK (nu_ano_censo >= 2007)
);

-- ---------------------- Infraestrutura (1 para 1 com escola) ----------------------
CREATE TABLE escola_saneamento (
    co_entidade             INTEGER  NOT NULL,
    in_agua_potavel         SMALLINT NOT NULL,
    in_agua_rede_publica    SMALLINT NOT NULL,
    in_agua_inexistente     SMALLINT NOT NULL,
    in_energia_rede_publica SMALLINT NOT NULL,
    in_energia_inexistente  SMALLINT NOT NULL,
    in_esgoto_rede_publica  SMALLINT NOT NULL,
    in_esgoto_fossa_septica SMALLINT NOT NULL,
    in_esgoto_inexistente   SMALLINT NOT NULL,
    CONSTRAINT pk_escola_saneamento PRIMARY KEY (co_entidade),
    CONSTRAINT fk_saneamento_escola FOREIGN KEY (co_entidade) REFERENCES escola (co_entidade) ON DELETE CASCADE,
    CONSTRAINT ck_saneamento_binarios CHECK (
        in_agua_potavel IN (0,1) AND in_agua_rede_publica IN (0,1) AND in_agua_inexistente IN (0,1)
        AND in_energia_rede_publica IN (0,1) AND in_energia_inexistente IN (0,1)
        AND in_esgoto_rede_publica IN (0,1) AND in_esgoto_fossa_septica IN (0,1) AND in_esgoto_inexistente IN (0,1)),
    -- "não há" não pode coexistir com a existência do próprio serviço
    CONSTRAINT ck_agua_coerente    CHECK (in_agua_inexistente = 0 OR in_agua_rede_publica = 0),
    CONSTRAINT ck_energia_coerente CHECK (in_energia_inexistente = 0 OR in_energia_rede_publica = 0),
    CONSTRAINT ck_esgoto_coerente  CHECK (in_esgoto_inexistente = 0 OR (in_esgoto_rede_publica = 0 AND in_esgoto_fossa_septica = 0))
);

CREATE TABLE escola_dependencias_fisicas (
    co_entidade                 INTEGER  NOT NULL,
    in_banheiro                 SMALLINT NOT NULL,
    in_banheiro_pne             SMALLINT NOT NULL,
    in_biblioteca               SMALLINT NOT NULL,
    in_biblioteca_sala_leitura  SMALLINT NOT NULL,
    in_laboratorio_informatica  SMALLINT NOT NULL,
    in_quadra_esportes          SMALLINT NOT NULL,
    CONSTRAINT pk_escola_dependencias PRIMARY KEY (co_entidade),
    CONSTRAINT fk_dependencias_escola FOREIGN KEY (co_entidade) REFERENCES escola (co_entidade) ON DELETE CASCADE,
    CONSTRAINT ck_dependencias_binarios CHECK (
        in_banheiro IN (0,1) AND in_banheiro_pne IN (0,1) AND in_biblioteca IN (0,1)
        AND in_biblioteca_sala_leitura IN (0,1) AND in_laboratorio_informatica IN (0,1) AND in_quadra_esportes IN (0,1)),
    CONSTRAINT ck_banheiro_pne_coerente CHECK (in_banheiro_pne = 0 OR in_banheiro = 1)
);

CREATE TABLE escola_acessibilidade (
    co_entidade                    INTEGER  NOT NULL,
    in_acessibilidade_elevador     SMALLINT NOT NULL,
    in_acessibilidade_rampas       SMALLINT NOT NULL,
    in_acessibilidade_inexistente  SMALLINT NOT NULL,
    CONSTRAINT pk_escola_acessibilidade PRIMARY KEY (co_entidade),
    CONSTRAINT fk_acessibilidade_escola FOREIGN KEY (co_entidade) REFERENCES escola (co_entidade) ON DELETE CASCADE,
    CONSTRAINT ck_acessibilidade_binarios CHECK (
        in_acessibilidade_elevador IN (0,1) AND in_acessibilidade_rampas IN (0,1) AND in_acessibilidade_inexistente IN (0,1)),
    CONSTRAINT ck_acessibilidade_coerente CHECK (
        in_acessibilidade_inexistente = 0 OR (in_acessibilidade_elevador = 0 AND in_acessibilidade_rampas = 0))
);

CREATE TABLE escola_tecnologia (
    co_entidade                INTEGER  NOT NULL,
    in_computador              SMALLINT NOT NULL,
    in_internet                SMALLINT NOT NULL,
    in_internet_alunos         SMALLINT NOT NULL,
    in_internet_aprendizagem   SMALLINT NOT NULL,
    in_banda_larga             SMALLINT NULL,   -- NULL = não aplicável (escola sem internet)
    CONSTRAINT pk_escola_tecnologia PRIMARY KEY (co_entidade),
    CONSTRAINT fk_tecnologia_escola FOREIGN KEY (co_entidade) REFERENCES escola (co_entidade) ON DELETE CASCADE,
    CONSTRAINT ck_tecnologia_binarios CHECK (
        in_computador IN (0,1) AND in_internet IN (0,1) AND in_internet_alunos IN (0,1)
        AND in_internet_aprendizagem IN (0,1) AND (in_banda_larga IS NULL OR in_banda_larga IN (0,1))),
    -- sem internet: não há uso por alunos/ensino e banda larga não se aplica (NULL)
    CONSTRAINT ck_internet_coerente CHECK (
        (in_internet = 1 AND in_banda_larga IS NOT NULL)
        OR (in_internet = 0 AND in_banda_larga IS NULL AND in_internet_alunos = 0 AND in_internet_aprendizagem = 0))
);

-- ---------------------- Dicionário de dados dentro do próprio banco ----------------------
CREATE TABLE dicionario_dados (
    variavel_origem VARCHAR(40)  NOT NULL,   -- nome da coluna no arquivo do INEP
    tabela          VARCHAR(40)  NOT NULL,   -- onde a variável ficou no banco
    coluna          VARCHAR(40)  NOT NULL,
    descricao       VARCHAR(400) NOT NULL,
    categorias      VARCHAR(600) NULL,       -- códigos e significados, quando existem
    CONSTRAINT pk_dicionario_dados PRIMARY KEY (variavel_origem)
);

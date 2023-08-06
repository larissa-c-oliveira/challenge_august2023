/*
Descrição: Criação das tabelas para análise de dados
Data: 05/08/2023
Autora: Larissa Oliveira
*/

--Tabela Customer
CREATE TABLE Customer (
  id int PRIMARY KEY IDENTITY(1, 1),
  email varchar(255),
  nome varchar(255),
  sobrenome varchar(255),
  sexo char(1),
  endereco varchar(255),
  dataNascimento date,
  telefone bigint
)

GO

--Tabela Order
CREATE TABLE [Order] (
  id int PRIMARY KEY IDENTITY(1, 1),
  idCliente int,
  idVendedor int,
  idItem int,
  status bit,
  dataStatus datetime,
  dataPedido datetime,
  quantidade int,
  desconto decimal(10,2),
  valorUnitario decimal(10,2),
  valorTotal decimal(10,2)
)
GO

--Tabela Item
CREATE TABLE Item (
  id int PRIMARY KEY IDENTITY(1, 1),
  idCategoria int,
  descricao varchar(255),
  [status] bit,
  valor decimal(15,2)
)
GO

--Tabela Category
CREATE TABLE Category (
  id int PRIMARY KEY IDENTITY(1, 1),
  descricao varchar(255)
)


--Configuração das chaves estrangeiras
ALTER TABLE [Order] ADD FOREIGN KEY (idCliente) REFERENCES Customer (id)
GO

ALTER TABLE [Order] ADD FOREIGN KEY (idVendedor) REFERENCES Customer (id)
GO

ALTER TABLE [Order] ADD FOREIGN KEY (idItem) REFERENCES Item (id)
GO

ALTER TABLE Item ADD FOREIGN KEY (idCategoria) REFERENCES Category (id)
GO

--Criação dos índices para otimização de consultas
CREATE INDEX IX_Order_idCliente ON [Order] (idCliente)
GO
CREATE INDEX IX_Order_idVendedor ON [Order] (idVendedor)
GO
CREATE INDEX IX_Order_idItem ON [Order] (idItem)
GO


--Inserindo dados fictícios para análise

-- Inserir dados na tabela Category
INSERT INTO  Category (descricao)
SELECT 'Celular'	AS descricao
UNION ALL
SELECT 'Notebook'	AS descricao
UNION ALL
SELECT 'Tablet'	AS descricao


-- Inserir dados na tabela Item
INSERT INTO Item (idCategoria, descricao, [status], valor)
SELECT TOP 50
    (ABS(CHECKSUM(NEWID())) % 3) + 1											AS idCategoria,
    'Item ' + CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS VARCHAR(10))	AS descricao,
    CAST(ABS(CHECKSUM(NEWID())) % 2 AS BIT)										AS [status],
    (ABS(CHECKSUM(NEWID())) % 1000) + 10										AS valor
FROM sys.columns c1
CROSS JOIN sys.columns c2


-- Inserir dados na tabela Customer
INSERT INTO Customer (email, nome, sobrenome, sexo, endereco, dataNascimento, telefone)
SELECT TOP 50
    'cliente' + CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS VARCHAR(10)) + '@teste.com.br'	AS email,
    'Nome' + CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS VARCHAR(10))						AS nome,
    'Sobrenome' + CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS VARCHAR(10))					AS apelido,
    
	CASE	WHEN (ROW_NUMBER() OVER (ORDER BY (SELECT NULL))) % 2 = 0 THEN 'M' 
			ELSE 'F' 
	END																								AS sexo,

    'Endereco' + CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS VARCHAR(10))					AS endereco,
    DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365*30, '1990-01-01')									AS dataNascimento,
    ABS(CHECKSUM(NEWID())) % 10000000000															AS telefone
FROM sys.columns c1
CROSS JOIN sys.columns c2

-- Inserir dados na tabela Order
INSERT INTO  [Order] (idCliente, idVendedor, idItem, [status], dataStatus, dataPedido, quantidade, desconto, valorUnitario)
SELECT TOP 50
    (ABS(CHECKSUM(NEWID())) % 50) + 1							AS idCliente,
    (ABS(CHECKSUM(NEWID())) % 10) + 1							AS idVendedor,
    (ABS(CHECKSUM(NEWID())) % 50) + 1							AS idItem,
    CAST(ABS(CHECKSUM(NEWID())) % 2 AS BIT)						AS [status],
    DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 365, '2020-01-01')	AS dataStatus,
	DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 365, '2020-01-02')	AS dataPedido,
    (ABS(CHECKSUM(NEWID())) % 10) + 1							AS quantidade,
    CAST((ABS(CHECKSUM(NEWID())) % 50)	AS DECIMAL(10, 2))		AS desconto,
    (ABS(CHECKSUM(NEWID())) % 200) + 10							AS valorUnitario
FROM sys.columns c1
CROSS JOIN sys.columns c2

--Atualiza conforme os valores inseridos
UPDATE [Order] 
SET valorTotal = ( quantidade * valorUnitario ) - desconto


--Visualização dos dados inseridos:
SELECT * FROM Customer
GO
SELECT * FROM  [Order]
GO
SELECT * FROM [Item]
GO
SELECT * FROM [Category]
/*
Descrição: Análise de dados
Data: 05/08/2023
Autora: Larissa Oliveira
*/

--1.Listar os usuários que fazem aniversário no dia de hoje e cuja quantidade de vendas realizadas em janeiro/2020 > R$ 1.500
WITH tbl AS 
(
	SELECT 
			idVendedor,
			SUM(valorTotal)	AS valor
	FROM [Order] WITH(NOLOCK)
	WHERE YEAR(dataPedido)	= 2020
	AND   MONTH(dataPedido)	= 1
	GROUP BY idVendedor
)
SELECT
		c.nome
FROM			Customer  c WITH(NOLOCK)
INNER JOIN	    tbl		  t  on c.id = t.idVendedor
WHERE DAY(c.dataNascimento)		= DAY(GETDATE())
AND   MONTH(c.dataNascimento)	= MONTH(GETDATE())
AND   t.valor > 1500

--2.Para cada mês de 2020, listar os top 5 usuários que mais venderam na categoria celulares. 
--Apresentar mês, ano de análise, nome e sobrenome do vendedor, quantidade de vendas realizadas, total de produtos vendidos e o valor.
WITH tbl AS 
(
	SELECT 
			o.idVendedor,
			MONTH(o.dataPedido)		AS mesPedido,
			YEAR(o.dataPedido)		AS anoPedido,
			SUM(o.valorTotal)		AS valorTotal,
			SUM(o.quantidade)		AS quantidadeProduto,
			COUNT(o.id)			AS quantidadeVenda,
			ROW_NUMBER() OVER(PARTITION BY MONTH(o.dataPedido) ORDER BY SUM(o.valorTotal) DESC)
									AS linha
	FROM			[Order]		o WITH(NOLOCK)
	INNER JOIN		Item		i WITH(NOLOCK) on o.idItem		= i.id
	INNER JOIN      Category	c WITH(NOLOCK) on i.idCategoria = c.id
	WHERE YEAR(o.dataPedido)	= 2020
	AND   c.descricao = 'Celular'
	GROUP BY o.idVendedor, MONTH(o.dataPedido), YEAR(o.dataPedido)
)
SELECT 
		t.mesPedido,
		t.anoPedido,
		v.nome,
		v.sobrenome,
		t.quantidadeVenda,
		t.quantidadeProduto,
		t.valorTotal
FROM		tbl t
INNER JOIN	Customer v on t.idVendedor = v.id
WHERE t.linha < 6

--3.Criar e popular uma nova tabela com o preço e status dos itens no fim do dia. Essa ação deve ser reprocessável
CREATE PROCEDURE PRC_ITEM_STATUS_DIA
AS
	BEGIN
			--Verifica se a tabela existe
			IF NOT EXISTS(SELECT 1 FROM sys.tables WHERE name = 'StatusItem')
			BEGIN
				CREATE TABLE StatusItem (
				  id int PRIMARY KEY,
				  [status] bit,
				  valor decimal(15,2),
				  dataStatus date
				)
	
			END;

			--Remove alguma exclusão anterior do mesmo dia
			DELETE FROM StatusItem WHERE dataStatus = CAST( GETDATE() AS DATE ) 

			--Insere registros
			INSERT INTO StatusItem
			SELECT 
					id,
					[status],
					valor,
					CAST( GETDATE() AS DATE ) AS dataStatus
			FROM Item 

			
	END


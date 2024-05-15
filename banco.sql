CREATE SCHEMA IF NOT EXISTS `BancoNFT` DEFAULT CHARACTER SET utf8;
USE `BancoNFT`;
DROP DATABASE banconft;

CREATE TABLE `BancoNFT`.`Usuario` (
    id_Usuario INT NOT NULL PRIMARY KEY,
    nome VARCHAR(45) NOT NULL,
    email VARCHAR(45) NOT NULL,
    senha VARCHAR(45) NOT NULL,
    telefone INT(11) NOT NULL,
    dataNasc DATE,
    genero VARCHAR(20),
    cpf VARCHAR(11)
) ENGINE = InnoDB;

CREATE TABLE `BancoNFT`.`PRODUTO` (
    id_Produto INT NOT NULL PRIMARY KEY,
    valor INT NOT NULL,
    categoria VARCHAR(45) NOT NULL,
    estoque INT NOT NULL,
    marca VARCHAR(45) NOT NULL,
    descricao VARCHAR(45)
) ENGINE = InnoDB;

CREATE TABLE `BancoNFT`.`Pedido` (
    idPEDIDO INT NOT NULL PRIMARY KEY,
    data DATETIME,
    quantidade VARCHAR(45) NOT NULL,
    valor INT NOT NULL,
    id_Produto INT NOT NULL,
    id_Usuario INT NOT NULL,
    CONSTRAINT fk_Produto_id_Produto
	FOREIGN KEY (id_Produto)
	REFERENCES PRODUTO (id_Produto),
    CONSTRAINT fk_Usuario_id_Usuario
	FOREIGN KEY (id_Usuario)
	REFERENCES Usuario (id_Usuario)
) ENGINE = InnoDB;

CREATE TABLE `BancoNFT`.`FormaPGMT` (
    idPedido INT NOT NULL,
    pix VARCHAR(3),
    debito VARCHAR(3),
    credito VARCHAR(3),
    CONSTRAINT fk_idPedido
	FOREIGN KEY (idPedido)
	REFERENCES Pedido (idPEDIDO)
) ENGINE = InnoDB;

-- Inserções na tabela Usuario
INSERT INTO Usuario (id_Usuario, nome, email, senha, telefone, dataNasc, genero, cpf) 
VALUES 
(1, 'Maria Silva', 'maria@mail.com', 'senha123', 982322454, '1990-05-15', 'Feminino', '12345678901'),
(2, 'João Oliveira', 'joao@mail.com', 'abc123', 987654321, '1988-10-25', 'Masculino', '98765432109'),
(3, 'Ana Santos', 'ana@mail.com', 'qwerty', 981222333, '1995-02-20', 'Feminino', '11122233304'),
(4, 'Pedro Costa', 'pedro@mail.com', 'senha456', 985666777, '1980-12-10', 'Masculino', '55566677707'),
(5, 'Carla Souza', 'carla@mail.com', '123456', 988999000, '1998-08-05', 'Feminino', '88899900002');

-- Inserções na tabela PRODUTO
INSERT INTO PRODUTO (id_Produto, valor, categoria, estoque, marca, descricao)
VALUES 
(1, 1000, 'Bored Ape', 10, 'Emanuel', 'Bored Ape'),
(2, 1500, 'Bored Ape 1', 15, 'Lilian', 'Bored Ape 1'),
(3, 1200, 'Bored Ape 2', 8, 'SkullX', 'Bored Ape 2'),
(4, 2000, 'Bored Ape 3', 12, 'Van Gogh', 'Bored Ape 3'),
(5, 1800, 'Bored Ape 4', 20, 'Neymar JR', 'Bored Ape 4');

-- Inserções na tabela Pedido
INSERT INTO Pedido (idPEDIDO, data, quantidade, valor, id_Produto, id_Usuario)
VALUES 
(1, '2024-05-01 10:30:00', '1', 1000, 1, 1),
(2, '2024-05-02 11:45:00', '2', 3000, 2, 2),
(3, '2024-05-03 09:15:00', '1', 1200, 3, 3),
(4, '2024-05-04 14:20:00', '3', 6000, 4, 4),
(5, '2024-05-05 13:00:00', '2', 3600, 5, 5);

-- Inserções na tabela FormaPGMT
INSERT INTO FormaPGMT (idPedido, pix, debito, credito)
VALUES 
(1, 'Sim', 'Não', 'Não'),
(2, 'Não', 'Sim', 'Não'),
(3, 'Não', 'Não', 'Sim'),
(4, 'Não', 'Sim', 'Não'),
(5, 'Sim', 'Não', 'Não');

DELIMITER $$
CREATE TRIGGER before_pedido_insert
BEFORE INSERT ON Pedido
FOR EACH ROW
BEGIN
    -- Exemplo de ação: verificando se o produto está em estoque antes de fazer um pedido
    DECLARE estoque_atual INT;
    SELECT estoque INTO estoque_atual FROM PRODUTO WHERE id_Produto = NEW.id_Produto;
    
    IF NEW.quantidade > estoque_atual THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantidade solicitada excede o estoque disponível.';
    END IF;
END;
$$

DELIMITER $$
-- Trigger que é acionado após excluir um registro da tabela Pedido
CREATE TRIGGER after_pedido_delete
AFTER DELETE ON Pedido
FOR EACH ROW
BEGIN
    -- Exemplo de ação: atualizando o estoque do produto após a exclusão de um pedido
    UPDATE PRODUTO SET estoque = estoque + OLD.quantidade WHERE id_Produto = OLD.id_Produto;
END;
$$
DELIMITER ;

-- Inserir um novo pedido que desencadeará o trigger before_pedido_insert
INSERT INTO Pedido (idPEDIDO, data, quantidade, valor, id_Produto, id_Usuario)
VALUES (6, '2024-05-06 12:00:00', 10, 15000, 1, 1);

-- Excluir um pedido que desencadeará o trigger after_pedido_delete
DELETE FROM Pedido WHERE idPEDIDO = 6;

-- Procedure para inserir um novo usuário
DELIMITER $$
CREATE PROCEDURE inserir_usuario(
    IN p_nome VARCHAR(45),
    IN p_email VARCHAR(45),
    IN p_senha VARCHAR(45),
    IN p_telefone INT,
    IN p_dataNasc DATE,
    IN p_genero VARCHAR(20),
    IN p_cpf VARCHAR(11)
)
BEGIN
    INSERT INTO Usuario (nome, email, senha, telefone, dataNasc, genero, cpf) 
    VALUES (p_nome, p_email, p_senha, p_telefone, p_dataNasc, p_genero, p_cpf);
END;
$$
DELIMITER $$
-- Procedure para atualizar o estoque de um produto
CREATE PROCEDURE atualizar_estoque(
    IN p_id_Produto INT,
    IN p_nova_quantidade INT
)
BEGIN
    UPDATE PRODUTO SET estoque = p_nova_quantidade WHERE id_Produto = p_id_Produto;
END;
$$
DELIMITER ;

CALL inserir_usuario('Felipinho', 'felipe@email.com', '123', 123456789, '1990-01-01', 'Outro', '12345678901');
CALL atualizar_estoque(1, 20);

-- Função para calcular o valor total de um pedido
DELIMITER $$
CREATE FUNCTION calcular_valor_total(
    quantidade INT,
    preco_unitario INT
)
RETURNS INT
BEGIN
    DECLARE total INT;
    SET total = quantidade * preco_unitario;
    RETURN total;
END;
$$
DELIMITER $$
-- Função para verificar se um usuário é maior de idade
CREATE FUNCTION verificar_maioridade(
    data_nasc DATE
)
RETURNS BOOLEAN
BEGIN
    DECLARE idade INT;
    DECLARE maior BOOLEAN;
    
    SET idade = YEAR(CURRENT_DATE()) - YEAR(data_nasc);
    
    IF idade >= 18 THEN
        SET maior = TRUE;
    ELSE
        SET maior = FALSE;
    END IF;
    
    RETURN maior;
END;
$$
DELIMITER ;

SELECT calcular_valor_total(3, 1000); -- Isso retorna o valor total para 3 produtos que custam 1000 cada.

SELECT verificar_maioridade('2010-05-15'); -- Isso retorna TRUE ou FALSE dependendo da data de nascimento fornecida.

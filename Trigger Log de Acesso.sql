--DROP TRIGGER tgTabelaLogUsuario;
CREATE TRIGGER tgTabelaLogUsuario
	ON tblUsuario
	FOR INSERT, UPDATE
AS
DECLARE	@lstrTabela VARCHAR(40) = 'tblUsuario',
		@lintCont INT = 1,
		@lintMaximo INT,
		@lstrColuna VARCHAR(50),
		@lstrValor VARCHAR(MAX) = '',
		@lstrValorOld VARCHAR(MAX) = '',
		@lstrSQL NVARCHAR(MAX),
		@lstrSQLOld NVARCHAR(MAX),
		@lstrId NVARCHAR(MAX);
BEGIN

	SET @lintMaximo = (SELECT COUNT(1) FROM sys.columns WHERE object_id = object_id(@lstrTabela));
	SET @lstrId = (SELECT idUsuario FROM INSERTED);

	SELECT * INTO tempInsert FROM INSERTED;
	SELECT * INTO tempDelete FROM DELETED;

	IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS (SELECT * FROM DELETED)
	BEGIN

		WHILE @lintCont <= @lintMaximo
		BEGIN
			SET @lstrColuna = (SELECT name FROM sys.columns WHERE object_id = object_id(@lstrTabela) AND column_id = @lintCont);
			SET @lstrSQL = 'SELECT ' + @lstrColuna + ' AS Valor INTO teste FROM tempInsert';
			PRINT @lstrSQL;
			EXEC sp_executesql @lstrSQL;

			SET @lstrValor = (SELECT Valor FROM teste);
			PRINT @lstrValor;
			DROP TABLE teste;

			IF(@lstrValor != '')
			BEGIN
				INSERT INTO
					tblLogTable
						(
							tabela
						,	id
						,	acao
						,	dataHora
						,	campo
						,	dado
						,	idUsuario
						)
					VALUES
						(
							@lstrTabela
						,	@lstrId
						,	'INSERT'
						,	SYSDATETIME()
						,	@lstrColuna
						,	@lstrValor
						,	COALESCE((SELECT idUsuario FROM tblUsuario WHERE login = CURRENT_USER), 1)
						);
			END
			
			SET @lintCont += 1;
		END
	END

	IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN

		WHILE @lintCont <= @lintMaximo
		BEGIN
			SET @lstrColuna = (SELECT name FROM sys.columns WHERE object_id = object_id(@lstrTabela) AND column_id = @lintCont);
			SET @lstrSQL = 'SELECT ' + @lstrColuna + ' AS Valor INTO teste FROM tempInsert';
			SET @lstrSQLOld = 'SELECT ' + @lstrColuna + ' AS Valor INTO testeDel FROM tempDelete';

			PRINT @lstrSQL;
			PRINT @lstrSQLOld;

			EXEC sp_executesql @lstrSQL;
			EXEC sp_executesql @lstrSQLOld;

			SET @lstrValor = (SELECT Valor FROM teste);
			DROP TABLE teste;

			SET @lstrValorOld = (SELECT Valor FROM testeDel);
			DROP TABLE testeDel;

			IF(@lstrValor != @lstrValorOld AND @lstrValor != '')
			BEGIN

				INSERT INTO
					tblLogTable
						(
							tabela
						,	id
						,	acao
						,	dataHora
						,	campo
						,	dado
						,	idUsuario
						)
					VALUES
						(
							@lstrTabela
						,	@lstrId
						,	'UPDATE'
						,	SYSDATETIME()
						,	@lstrColuna
						,	@lstrValor
						,	COALESCE((SELECT idUsuario FROM tblUsuario WHERE login = CURRENT_USER), 1)
						);

			END
			
			SET @lintCont += 1;
		END
	END

	DROP TABLE tempInsert;
	DROP TABLE tempDelete;
END;
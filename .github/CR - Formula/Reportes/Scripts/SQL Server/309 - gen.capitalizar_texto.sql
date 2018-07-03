IF OBJECT_ID('gen.capitalizar_texto') IS NOT NULL
BEGIN
	DROP FUNCTION gen.capitalizar_texto
END

GO

--SELECT gen.capitalizar_texto('esta es una prueba.')
CREATE FUNCTION gen.capitalizar_texto
                (@svalor VARCHAR(500))
RETURNS VARCHAR(500) AS
BEGIN
    DECLARE @i			      VARCHAR(500),
            @cletras 		VARCHAR(500)

    --************************************--
    --*  valida que este vacio el valor  *--
    --************************************--
    IF (LTRIM(RTRIM(@svalor)) = '') OR (@svalor IS NULL)
        SET @cletras = 'dato no tiene ningun caracter o esta nulo'
    ELSE
       BEGIN
          SET @svalor = LTRIM(RTRIM(@svalor))
          --************************************--
          --*  valida si es una sola palabra   *--
          --************************************--
          IF CHARINDEX(' ',@svalor) IS NULL OR CHARINDEX(' ',@svalor) = 0
             SET @cletras = UPPER(LEFT(@svalor,1)) + LOWER(right(@svalor,LEN(@svalor)- 1))
          ELSE
             BEGIN                   
                WHILE CHARINDEX(' ',@svalor) <> 0
      		          BEGIN
                          IF LEN(LEFT(@svalor,CHARINDEX(' ',@svalor) - 1)) > 0                       
                             BEGIN
      		       	             SET @i = LEFT(@svalor,CHARINDEX(' ',@svalor) - 1)
                                  IF @i IS NOT NULL
                                     BEGIN
                                        IF LEN(@i) > 1
                                           BEGIN
               	                            SET @cletras = ISNULL(@cletras,'') + UPPER(LEFT(@i,1)) + LOWER(right(@i,LEN(@i)- 1)) + ' ' 
               	                            SET @svalor = SUBSTRING(@svalor,(CHARINDEX(' ',@svalor)+1), LEN(@svalor) - CHARINDEX(' ',@svalor))
                                           END
                                        ELSE
                                           BEGIN
                                              --************************************--
                                              --* si es una letra  no la convierte *--
                                              --************************************--
                                              SET @cletras = ISNULL(@cletras,'') + LOWER(@i) + ' ' 
                                              SET @svalor = SUBSTRING(@svalor,(CHARINDEX(' ',@svalor)+1), LEN(@svalor) - CHARINDEX(' ',@svalor))
                                           END
                                     END
                                  ELSE
                                     SET @svalor = SUBSTRING(@svalor,(CHARINDEX(' ',@svalor)+1), LEN(@svalor) - CHARINDEX(' ',@svalor))
                             END
                          ELSE
                              SET @svalor = SUBSTRING(@svalor,(CHARINDEX(' ',@svalor)+1), LEN(@svalor) - CHARINDEX(' ',@svalor))
      		          END
                IF LEN(@svalor) <> 0 
                   SET @cletras = ISNULL(@cletras,'') + UPPER(LEFT(@svalor,1)) + LOWER(right(@svalor,LEN(@svalor)- 1))                   
             END

       END
   
RETURN @cletras

END
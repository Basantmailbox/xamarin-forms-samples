

/****** Object:  UserDefinedFunction [dbo].[Split]    Script Date: 09-10-2019 12:33:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[Split] (
      @InputString                  VARCHAR(8000),
      @Delimiter                    VARCHAR(50)
)

RETURNS @Items TABLE (
      Item                          VARCHAR(8000)
)

AS
BEGIN
      IF @Delimiter = ' '
      BEGIN
            SET @Delimiter = ','
            SET @InputString = REPLACE(@InputString, ' ', @Delimiter)
      END

      IF (@Delimiter IS NULL OR @Delimiter = '')
            SET @Delimiter = ','

      DECLARE @Item                 VARCHAR(8000)
      DECLARE @ItemList       VARCHAR(8000)
      DECLARE @DelimIndex     INT

      SET @ItemList = @InputString
      SET @DelimIndex = CHARINDEX(@Delimiter, @ItemList, 0)
      WHILE (@DelimIndex != 0)
      BEGIN
            SET @Item = SUBSTRING(@ItemList, 0, @DelimIndex)
            INSERT INTO @Items VALUES (@Item)

            -- Set @ItemList = @ItemList minus one less item
            SET @ItemList = SUBSTRING(@ItemList, @DelimIndex+1, LEN(@ItemList)-@DelimIndex)
            SET @DelimIndex = CHARINDEX(@Delimiter, @ItemList, 0)
      END -- End WHILE

      IF @Item IS NOT NULL -- At least one delimiter was encountered in @InputString
      BEGIN
            SET @Item = @ItemList
            INSERT INTO @Items VALUES (@Item)
      END

      -- No delimiters were encountered in @InputString, so just return @InputString
      ELSE INSERT INTO @Items VALUES (@InputString)

      RETURN

END -- End Function






ALTER PROCEDURE InsertSplitString
@strValue nvarchar(MAX)
AS
DECLARE @FinalSplitTbl TABLE (FsId INT IDENTITY(1,1),C1 VARCHAR(100), C2 VARCHAR(100),C3 VARCHAR(100),C4 VARCHAR(100),C5 VARCHAR(100)) 
DECLARE @FirstSplitTbl TABLE (FsId INT IDENTITY(1,1),C1 VARCHAR(MAX))
DECLARE @SecondSplitTbl TABLE (FsId INT IDENTITY(1,1),C1 VARCHAR(MAX))
INSERT INTO @FirstSplitTbl (C1) 
SELECT Item from Split(@strValue,',')

DECLARE @CNT_TOTAL INT
DECLARE @Total_Inner INT
SELECT @CNT_TOTAL=COUNT(*) FROM @FirstSplitTbl 
DECLARE @i int = 0
DECLARE @inner int = 0

DECLARE @FirstSplitRow VARCHAR(MAX)

DECLARE @Col1 VARCHAR(MAX)
DECLARE @Col2 VARCHAR(MAX)
DECLARE @Col3 VARCHAR(MAX)
DECLARE @Col4 VARCHAR(MAX)
DECLARE @Col5 VARCHAR(MAX)
DECLARE @ContactId INT

SELECT * FROM  @FirstSplitTbl


WHILE @i < @CNT_TOTAL
BEGIN
    SET @i = @i + 1
	SET @Total_Inner=0
	delete from  @SecondSplitTbl
	select @FirstSplitRow= C1 FROM @FirstSplitTbl WHERE FsId=@i
	INSERT INTO @SecondSplitTbl (C1) SELECT * FROM Split(@FirstSplitRow,'|')
	SELECT @Total_Inner=COUNT(*) FROM @SecondSplitTbl
	
	SET @inner=0
	SELECt @Total_Inner
			WHILE @inner < @Total_Inner
			BEGIN
			SELECT @inner
				SET @inner = @inner + 1
				IF (@inner=1)    
				BEGIN
				select @Col1=C1 FROM @SecondSplitTbl WHERE FsId=@inner
				END
				
				IF (@inner=2)    
				BEGIN
				select @Col2=C1 FROM @SecondSplitTbl WHERE FsId=@inner
				END

				IF (@inner=3)    
				BEGIN
				select @Col3=C1 FROM @SecondSplitTbl WHERE FsId=@inner
				END

				IF (@inner=4)    
				BEGIN
				select @Col4=C1 FROM @SecondSplitTbl WHERE FsId=@inner
				END

				IF (@inner=5)    
				BEGIN
				select @Col5=C1 FROM @SecondSplitTbl WHERE FsId=@inner
				END

			END


			select @ContactId=id from contacts where wano= @Col1 and contactno= @Col2;

			IF (@ContactId>0)  
				BEGIN
				INSERT INTO MEDIA_HEX (CONTACTID,MEDIA_URL,MEDIA_MIME_TYPE,THUMB_IMAGE) VALUES (@ContactId,@Col3,@Col4,@Col5)
				END
				ELSE
				BEGIN

				INSERT INTO CONTACTS (WANO,CONTACTNO) VALUES (@col1,@col2)
				SET	@ContactId = SCOPE_IDENTITY()
				INSERT INTO MEDIA_HEX (CONTACTID,MEDIA_URL,MEDIA_MIME_TYPE,THUMB_IMAGE) VALUES (@ContactId,@Col3,@Col4,@Col5)

				END

		INSERT INTO @FinalSplitTbl (C1,C2,C3,C4,C5) VALUES(@Col1,@Col2,@Col3,@Col4,@Col5)

END

SELECT * FROM @FinalSplitTbl
GO



--  EXEC InsertSplitString '918403082585|919555590000|fgj4jkj|fjgkj666|iuituri,918403082585|919555590000|222222|333333|4444444'


--   select * from MEDIA_HEX
	-- delete   from MEDIA_HEX






/*
	Program		: dbo.sp_depends_v2
	Developer 	: Manjuke Fernando
	Date 		: 06.07.2018
*/

CREATE PROCEDURE dbo.sp_depends_v2
--Parameters
	@objname			AS NVARCHAR(100)
	,@objclass			AS NVARCHAR (60) = 'OBJECT'

AS
BEGIN

	SET NOCOUNT ON
  
  
	DECLARE
		@ProcessTag			AS VARCHAR(512) = '__Undefined_Message__'
		,@ProccessName		AS VARCHAR(256) = OBJECT_NAME(@@PROCID)
		,@ErrorMessage		AS VARCHAR(MAX) = ''
		,@Sql				AS NVARCHAR(MAX) = ''


	BEGIN TRY
		SET @ProcessTag = CONCAT('Preparing dynamic query to fetch relevant details for object : ',@objname)
		SET @Sql = '
		SELECT 
			CONCAT(sch.[name],''.'',Obj.[name]) AS [name]
			,(CASE Obj.type
				WHEN ''C''  THEN ''CHECK constraint''
				WHEN ''D''  THEN ''DEFAULT (constraint or stand-alone)''
				WHEN ''F''  THEN ''FOREIGN KEY constraint''
				WHEN ''PK'' THEN ''PRIMARY KEY constraint''
				WHEN ''R''  THEN ''Rule (old-style, stand-alone)''
				WHEN ''TA'' THEN ''Assembly (CLR-integration) trigger''
				WHEN ''TR'' THEN ''SQL trigger''
				WHEN ''UQ'' THEN ''UNIQUE constraint''
				WHEN ''AF'' THEN ''Aggregate function (CLR)''
				WHEN ''C'' THEN ''CHECK constraint''
				WHEN ''D'' THEN ''DEFAULT (constraint or stand-alone)''
				WHEN ''F'' THEN ''FOREIGN KEY constraint''
				WHEN ''FN'' THEN ''SQL scalar function''
				WHEN ''FS'' THEN ''Assembly (CLR) scalar-function''
				WHEN ''FT'' THEN ''Assembly (CLR) table-valued function''
				WHEN ''IF'' THEN ''SQL inline table-valued function''
				WHEN ''IT'' THEN ''Internal table''
				WHEN ''P'' THEN ''SQL Stored Procedure''
				WHEN ''PC'' THEN ''Assembly (CLR) stored-procedure''
				WHEN ''PG'' THEN ''Plan guide''
				WHEN ''PK'' THEN ''PRIMARY KEY constraint''
				WHEN ''R'' THEN ''Rule (old-style, stand-alone)''
				WHEN ''RF'' THEN ''Replication-filter-procedure''
				WHEN ''S'' THEN ''System base TABLE''
				WHEN ''SN'' THEN ''Synonym''
				WHEN ''SO'' THEN ''Sequence OBJECT''
				WHEN ''U'' THEN ''Table (user-defined)''
				WHEN ''V'' THEN ''VIEW''
				WHEN ''SQ'' THEN ''Service queue''
				WHEN ''TA'' THEN ''Assembly (CLR) DML trigger''
				WHEN ''TF'' THEN ''SQL table-valued-function''
				WHEN ''TR'' THEN ''SQL DML trigger''
				WHEN ''TT'' THEN ''Table type''
				WHEN ''UQ'' THEN ''UNIQUE CONSTRAINT''
				WHEN ''X''  THEN ''Extended stored procedure''
				ELSE ''Undefined''
			END) AS [type]
			,Obj.create_date
			,Obj.modify_date
			,src.referenced_minor_name AS [column]
			,IIF(src.is_selected   = 1,''yes'',''no'') AS is_selected
			,IIF(src.is_updated	   = 1,''yes'',''no'') AS is_updated
			,IIF(src.is_select_all = 1,''yes'',''no'') AS is_select_all
			,IIF(src.is_insert_all = 1,''yes'',''no'') AS is_insert_all
		FROM 
			sys.dm_sql_referenced_entities (@RefObjectName,@objclass) AS src
			JOIN sys.objects AS Obj
				ON src.referenced_id = Obj.[object_id]
			JOIN sys.schemas AS Sch
				ON Sch.[schema_id] = Obj.[schema_id]
		WHERE 1=1
			--AND src.referenced_minor_name IS NOT NULL
			;
			
		
		SELECT 
			CONCAT(Src.referencing_schema_name,''.'',Src.referencing_entity_name) AS [name]
			,(CASE Obj.type
				WHEN ''C''  THEN ''CHECK constraint''
				WHEN ''D''  THEN ''DEFAULT (constraint or stand-alone)''
				WHEN ''F''  THEN ''FOREIGN KEY constraint''
				WHEN ''PK'' THEN ''PRIMARY KEY constraint''
				WHEN ''R''  THEN ''Rule (old-style, stand-alone)''
				WHEN ''TA'' THEN ''Assembly (CLR-integration) trigger''
				WHEN ''TR'' THEN ''SQL trigger''
				WHEN ''UQ'' THEN ''UNIQUE constraint''
				WHEN ''AF'' THEN ''Aggregate function (CLR)''
				WHEN ''C'' THEN ''CHECK constraint''
				WHEN ''D'' THEN ''DEFAULT (constraint or stand-alone)''
				WHEN ''F'' THEN ''FOREIGN KEY constraint''
				WHEN ''FN'' THEN ''SQL scalar function''
				WHEN ''FS'' THEN ''Assembly (CLR) scalar-function''
				WHEN ''FT'' THEN ''Assembly (CLR) table-valued function''
				WHEN ''IF'' THEN ''SQL inline table-valued function''
				WHEN ''IT'' THEN ''Internal table''
				WHEN ''P'' THEN ''SQL Stored Procedure''
				WHEN ''PC'' THEN ''Assembly (CLR) stored-procedure''
				WHEN ''PG'' THEN ''Plan guide''
				WHEN ''PK'' THEN ''PRIMARY KEY constraint''
				WHEN ''R'' THEN ''Rule (old-style, stand-alone)''
				WHEN ''RF'' THEN ''Replication-filter-procedure''
				WHEN ''S'' THEN ''System base TABLE''
				WHEN ''SN'' THEN ''Synonym''
				WHEN ''SO'' THEN ''Sequence OBJECT''
				WHEN ''U'' THEN ''Table (user-defined)''
				WHEN ''V'' THEN ''VIEW''
				WHEN ''SQ'' THEN ''Service queue''
				WHEN ''TA'' THEN ''Assembly (CLR) DML trigger''
				WHEN ''TF'' THEN ''SQL table-valued-function''
				WHEN ''TR'' THEN ''SQL DML trigger''
				WHEN ''TT'' THEN ''Table type''
				WHEN ''UQ'' THEN ''UNIQUE CONSTRAINT''
				WHEN ''X''  THEN ''Extended stored procedure''
				ELSE ''Undefined''
			END) AS [type]
			,Obj.create_date
			,Obj.modify_date
		FROM 
			sys.dm_sql_referencing_entities (@RefObjectName,@objclass) AS Src
			JOIN sys.objects AS Obj
				ON Obj.[object_id] = Src.referencing_id	
		'
		EXEC sys.sp_executesql
			@Sql
			,N'@RefObjectName AS NVARCHAR(517), @objclass AS NVARCHAR(60)'
			,@RefObjectName = @objname
			,@objclass = @objclass
        
		RETURN 0
		
	END TRY

	BEGIN CATCH
		/*
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN
		END    
		*/
		--== Error Details ==--
		SELECT 
			@ErrorMessage = @ProccessName
			,@ErrorMessage += ': Error in '
			,@ErrorMessage += @ProcessTag
			,@ErrorMessage += ' at Line '
			,@ErrorMessage += ISNULL(CAST(ERROR_LINE() AS VARCHAR),'Not Available')
			,@ErrorMessage += '. SQL Exception => '
			,@ErrorMessage += ISNULL(ERROR_MESSAGE(),'Not Available');
		
		THROW 50000, @ErrorMessage, 1;
	END CATCH  

END

IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SHREmpInfoSave' AND xtype = 'P')    
    DROP PROC minjun_SHREmpInfoSave
GO
    
/*************************************************************************************************    
 ��  �� - SP-�����λ��������:Save_minjun
 �ۼ��� - '2020-03-23
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SHREmpInfoSave
     @xmlDocument    NVARCHAR(MAX)          -- Xml������
    ,@xmlFlags       INT            = 0     -- XmlFlag
    ,@ServiceSeq     INT            = 0     -- ���� ��ȣ
    ,@WorkingTag     NVARCHAR(10)   = ''    -- WorkingTag
    ,@CompanySeq     INT            = 1     -- ȸ�� ��ȣ
    ,@LanguageSeq    INT            = 1     -- ��� ��ȣ
    ,@UserSeq        INT            = 0     -- ����� ��ȣ
    ,@PgmSeq         INT            = 0     -- ���α׷� ��ȣ
 AS
    DECLARE @TblName        NVARCHAR(MAX)   -- Table��
           ,@ItemTblName    NVARCHAR(MAX)   -- ��Table��
           ,@SeqName        NVARCHAR(MAX)   -- Seq��
           ,@TblColumns     NVARCHAR(MAX)
    
    -- ���̺�, Ű�� ��Ī
    SELECT  @TblName        = N'_TDAEmp'
           ,@ItemTblName    = N'_THRBasFamily'
           ,@SeqName        = N'EmpSeq'

    -- Xml������ �ӽ����̺� ���
    CREATE TABLE #_TDAEmp (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock1', '#_TDAEmp' 
    
    IF @@ERROR <> 0 RETURN
      
    -- �α����̺� �����(������ �Ķ���ʹ� �ݵ�� ���ٷ� ������)  	
	SELECT @TblColumns = dbo._FGetColumnsForLog(@TblName)
    
    EXEC _SCOMLog @CompanySeq   ,      
                  @UserSeq      ,      
                  @TblName      ,		-- ���̺��      
                  '#_TDAEmp'    ,		-- �ӽ� ���̺��      
                  @SeqName      ,   -- CompanySeq�� ������ Ű(Ű�� �������� ���� , �� ���� )      
                  @TblColumns   ,   -- ���̺� ��� �ʵ��
                  ''            ,
                  @PgmSeq
                    
    -- =============================================================================================================================================
    -- DELETE
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #_TDAEmp WHERE WorkingTag = 'D' AND Status = 0 )    
    BEGIN
        -- ���������̺� �α� �����(������ �Ķ���ʹ� �ݵ�� ���ٷ� ������)  	
    	SELECT @TblColumns = dbo._FGetColumnsForLog(@ItemTblName)
        
        -- �����α� �����
        EXEC _SCOMDELETELog @CompanySeq   ,      
                            @UserSeq      ,      
                            @ItemTblName  ,		-- ���̺��      
                            '#_TDAEmp'       ,		-- �ӽ� ���̺��      
                            @SeqName      ,   -- CompanySeq�� ������ Ű(Ű�� �������� ���� , �� ���� )      
                            @TblColumns   ,   -- ���̺� ��� �ʵ��
                            ''            ,
                            @PgmSeq

        IF @@ERROR <> 0 RETURN



        SET @ItemTblName = '_THRBasAcademic'
        -- ���������̺� �α� �����(������ �Ķ���ʹ� �ݵ�� ���ٷ� ������)  	
    	SELECT @TblColumns = dbo._FGetColumnsForLog(@ItemTblName)
        
        -- �����α� �����
        EXEC _SCOMDELETELog @CompanySeq   ,      
                            @UserSeq      ,      
                            @ItemTblName  ,		-- ���̺��      
                            '#_TDAEmp'       ,		-- �ӽ� ���̺��      
                            @SeqName      ,   -- CompanySeq�� ������ Ű(Ű�� �������� ���� , �� ���� )      
                            @TblColumns   ,   -- ���̺� ��� �ʵ��
                            ''            ,
                            @PgmSeq

        IF @@ERROR <> 0 RETURN




        -- Detail���̺� ������ ����
        DELETE  A
          FROM  #_TDAEmp          AS M
                JOIN _THRBasFamily      AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                           AND  A.EmpSeq      = M.EmpSeq
         WHERE  M.WorkingTag    = 'D'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN

         



         
    --     -- Master���̺� ������ ����
    --    DELETE  A
    --      FROM  #_TDAEmp          AS M
    --            JOIN _THRBasFamily          AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
    --                                                                 AND  A.EmpSeq  = M.EmpSeq
    --     WHERE  M.WorkingTag    = 'D'
    --       AND  M.Status        = 0
    --
    --    IF @@ERROR <> 0 RETURN



    END



    -- =============================================================================================================================================
    -- Update
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #_TDAEmp WHERE WorkingTag = 'U' AND Status = 0 )    
    BEGIN
        UPDATE  A 
           SET 
                EmpId             = M.EmpId   
                                   
          FROM  #_TDAEmp          AS M
                JOIN _TDAEmp          AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                           AND  A.EmpSeq      = M.EmpSeq

         WHERE  M.WorkingTag    = 'U'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

 --  -- =============================================================================================================================================
 --  -- INSERT
 --  -- =============================================================================================================================================
 --  IF EXISTS (SELECT 1 FROM #_TDAEmp WHERE WorkingTag = 'A' AND Status = 0 )    
 --  BEGIN
 --      INSERT INTO _TDAEmp (
 --                CompanySeq
 --                ,EmpSeq
 --                ,EmpName
 --                ,EmpId
 --                --,DeptName
 --                ,DeptSeq
 --      )
 --      SELECT  
 --              @CompanySeq
 --              , M.EmpSeq
 --              , M.EmpName
 --              , M.EmpId
 --              --, M.DeptName
 --              , M.DeptSeq
 --
 --        FROM  #_TDAEmp          AS M
 --       WHERE  M.WorkingTag    = 'A'
 --         AND  M.Status        = 0
 --
 --      IF @@ERROR <> 0 RETURN
 --  END
 --  
  SELECT * FROM #_TDAEmp
   
RETURN


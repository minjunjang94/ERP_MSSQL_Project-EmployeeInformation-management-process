IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SHREmpInfoFamilySave' AND xtype = 'P')    
    DROP PROC minjun_SHREmpInfoFamilySave
GO
    
/*************************************************************************************************    
 ��  �� - SP-�����λ��������:��������Save_minjun
 �ۼ��� - 2020-03-23
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SHREmpInfoFamilySave
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
           ,@SeqName        NVARCHAR(MAX)   -- Seq��
           ,@SerlName       NVARCHAR(MAX)   -- Serl��
           ,@TblColumns     NVARCHAR(MAX)
    
    -- ���̺�, Ű�� ��Ī
    SELECT  @TblName        = N'_THRBasFamily'
           ,@SeqName        = N'EmpSeq'
           ,@SerlName       = N'FamilySeq'

    -- Xml������ �ӽ����̺� ���
    CREATE TABLE #_THRBasFamily (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock2', '#_THRBasFamily' 
    
    IF @@ERROR <> 0 RETURN
      
    -- �α����̺� �����(������ �Ķ���ʹ� �ݵ�� ���ٷ� ������)  	
	SELECT @TblColumns = dbo._FGetColumnsForLog(@TblName)
    
    EXEC _SCOMLog @CompanySeq   ,      
                  @UserSeq      ,      
                  @TblName      ,		-- ���̺��      
                  '#_THRBasFamily'       ,		-- �ӽ� ���̺��      
                  'EmpSeq, FamilySeq'     ,   -- CompanySeq�� ������ Ű(Ű�� �������� ���� , �� ���� )      
                  @TblColumns   ,   -- ���̺� ��� �ʵ��
                  ''            ,
                  @PgmSeq
                    
    -- =============================================================================================================================================
    -- DELETE
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #_THRBasFamily WHERE WorkingTag = 'D' AND Status = 0 )    
    BEGIN
        -- Master���̺� ������ ����
        DELETE  A
          FROM  #_THRBasFamily               AS M
                JOIN _THRBasFamily          AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                           AND  A.EmpSeq      = M.EmpSeq
                                                           AND  A.FamilySeq     = M.FamilySeq
         WHERE  M.WorkingTag    = 'D'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- Update
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #_THRBasFamily WHERE WorkingTag = 'U' AND Status = 0 )    
    BEGIN
        UPDATE  _THRBasFamily 
           SET  
                 FamilyName             = M.FamilyName         
                ,UMRelSeq               = M.UMRelSeq        
                ,BirthDate              = M.BirthDate       
                ,SMBirthType            = M.SMBirthType     
                ,Occupation             = M.Occupation      
                ,FamilyPhone            = M.FamilyPhone     


          FROM  #_THRBasFamily          AS M
                JOIN _THRBasFamily          AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                                AND  A.EmpSeq      = M.EmpSeq
                                                                AND  A.FamilySeq     = M.FamilySeq
         WHERE  M.WorkingTag    = 'U'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- INSERT
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #_THRBasFamily WHERE WorkingTag = 'A' AND Status = 0 )    
    BEGIN
        INSERT INTO _THRBasFamily (
                CompanySeq
                ,EmpSeq
                ,FamilySeq
                ,FamilyName
                ,UMRelSeq
                ,BirthDate
                ,SMBirthType
                ,Occupation
                ,FamilyPhone
        )
        SELECT  
            @CompanySeq
            ,M.EmpSeq
            ,M.FamilySeq
            ,M.FamilyName
            ,M.UMRelSeq
            ,M.BirthDate
            ,M.SMBirthType
            ,M.Occupation
            ,M.FamilyPhone

          FROM  #_THRBasFamily          AS M
         WHERE  M.WorkingTag    = 'A'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END
    
    SELECT * FROM #_THRBasFamily
   
RETURN  
 /***************************************************************************************************************/
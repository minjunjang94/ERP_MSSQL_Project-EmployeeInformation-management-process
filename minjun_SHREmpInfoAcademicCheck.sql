IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SHREmpInfoAcademicCheck' AND xtype = 'P')    
    DROP PROC minjun_SHREmpInfoAcademicCheck
GO
    
/*************************************************************************************************    
 ��  �� - SP-�����λ��������:�з�����Check_minjun
 �ۼ��� - 2020-03-23
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SHREmpInfoAcademicCheck
     @xmlDocument    NVARCHAR(MAX)          -- Xml������
    ,@xmlFlags       INT            = 0     -- XmlFlag
    ,@ServiceSeq     INT            = 0     -- ���� ��ȣ
    ,@WorkingTag     NVARCHAR(10)   = ''    -- WorkingTag
    ,@CompanySeq     INT            = 1     -- ȸ�� ��ȣ
    ,@LanguageSeq    INT            = 1     -- ��� ��ȣ
    ,@UserSeq        INT            = 0     -- ����� ��ȣ
    ,@PgmSeq         INT            = 0     -- ���α׷� ��ȣ
 AS    
    DECLARE @MessageType    INT             -- �����޽��� Ÿ��
           ,@Status         INT             -- ���º���
           ,@Results        NVARCHAR(250)   -- �������
           ,@Count          INT             -- ä�������� Row ��
           ,@Seq            INT             -- Seq
           ,@MaxNo          NVARCHAR(20)    -- ä�� ������ �ִ� No
           ,@MaxSerl        INT             -- Serl�� �ִ밪
           ,@TblName        NVARCHAR(MAX)   -- Table��
           ,@SeqName        NVARCHAR(MAX)   -- Seq��
           ,@SerlName       NVARCHAR(MAX)   -- Serl��
    
    -- ���̺�, Ű�� ��Ī
    SELECT  @TblName    = N'_THRBasAcademic'
           ,@SeqName    = N'EmpSeq'
           ,@SerlName   = N'AcademicSeq'
           ,@MaxSerl    = 0
    
    -- Xml������ �ӽ����̺� ���
    CREATE TABLE #_THRBasAcademic (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock3', '#_THRBasAcademic' 
    
    IF @@ERROR <> 0 RETURN
    




    -- üũ����
    EXEC dbo._SCOMMessage   @MessageType    OUTPUT
                           ,@Status         OUTPUT
                           ,@Results        OUTPUT
                           ,0                       -- SELECT * FROM _TCAMessageLanguage WITH(NOLOCK) WHERE LanguageSeq = 1 AND Message LIKE '%%'
                           ,@LanguageSeq
                           ,0, ''                   -- SELECT * FROM _TCADictionary WITH(NOLOCK) WHERE LanguageSeq = 1 AND Word LIKE '%%'
                           ,0, ''                   -- SELECT * FROM _TCADictionary WITH(NOLOCK) WHERE LanguageSeq = 1 AND Word LIKE '%%'
    UPDATE  #_THRBasAcademic
       SET  Result          = @Results
           ,MessageType     = @MessageType
           ,Status          = @Status
      FROM  #_THRBasAcademic     AS M
     WHERE  M.WorkingTag IN('')
       AND  M.Status = 0





    -- ä���ؾ� �ϴ� ������ �� Ȯ��
    SELECT @Count = COUNT(1) FROM #_THRBasAcademic WHERE WorkingTag = 'A' AND Status = 0 
     
    -- ä��
    IF @Count > 0
    BEGIN
        -- Serl Max�� ��������
        SELECT  @MaxSerl    = MAX(ISNULL(A.AcademicSeq, 0))
          FROM  #_THRBasAcademic                 AS M
                LEFT OUTER JOIN _THRBasAcademic  AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                              AND  A.EmpSeq      = M.EmpSeq
         WHERE  M.WorkingTag IN('A')
           AND  M.Status = 0                    
        
        UPDATE  #_THRBasAcademic
           SET  AcademicSeq = @MaxSerl + DataSeq
         WHERE  WorkingTag  = 'A'
           AND  Status      = 0
    END
   
    SELECT * FROM #_THRBasAcademic
    
RETURN
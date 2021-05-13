IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SHREmpInfoCheck' AND xtype = 'P')    
    DROP PROC minjun_SHREmpInfoCheck
GO
    
/*************************************************************************************************    
 ��  �� - SP-�����λ��������:Check_minjun
 �ۼ��� - '2020-03-23
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SHREmpInfoCheck
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
           ,@Date           NCHAR(8)        -- Date
           ,@TblName        NVARCHAR(MAX)   -- Table��
           ,@SeqName        NVARCHAR(MAX)   -- Table Ű�� ��
    
    -- ���̺�, Ű�� ��Ī
    SELECT  @TblName        = N'_TDAEmp'
           ,@SeqName        = N'EmpSeq'
    
    -- Xml������ �ӽ����̺� ���
    CREATE TABLE #_TDAEmp (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock1', '#_TDAEmp' 
    
    IF @@ERROR <> 0 RETURN
    



    -- üũ����
     EXEC dbo._SCOMMessage   @MessageType    OUTPUT
                           ,@Status         OUTPUT
                           ,@Results        OUTPUT
                           ,6                       -- SELECT * FROM _TCAMessageLanguage WITH(NOLOCK) WHERE LanguageSeq = 1 AND Message LIKE '%�ߺ�%'
                           ,@LanguageSeq
                           ,0, '���.'                   -- SELECT * FROM _TCADictionary WITH(NOLOCK) WHERE LanguageSeq = 1 AND Word LIKE '%%'
                           ,0, ''                   -- SELECT * FROM _TCADictionary WITH(NOLOCK) WHERE LanguageSeq = 1 AND Word LIKE '%%'
    UPDATE  #_TDAEmp
       SET  Result          = REPLACE(@Results, '@2', M.EmpId)
           ,MessageType     = @MessageType
           ,Status          = @Status
      FROM  #_TDAEmp     AS M
            JOIN(   SELECT  X.EmpId
                      FROM  _TDAEmp         AS X   WITH(NOLOCK)
                     WHERE  X.CompanySeq    = @CompanySeq
                       AND  NOT EXISTS( SELECT  1
                                          FROM  #_TDAEmp
                                         WHERE  WorkingTag IN('U', 'D')
                                           AND  Status = 0
                                           AND  EmpSeq     = X.EmpSeq)
                    INTERSECT
                    SELECT  Y.EmpId
                      FROM  #_TDAEmp         AS Y   WITH(NOLOCK)
                     WHERE  Y.WorkingTag IN('A', 'U')
                       AND  Y.Status = 0
                                   )AS A    ON  A.EmpId  = M.EmpId
     WHERE  M.WorkingTag IN('A', 'U')
       AND  M.Status = 0





    -- ä���ؾ� �ϴ� ������ �� Ȯ��
    SELECT @Count = COUNT(1) FROM #_TDAEmp WHERE WorkingTag = 'A' AND Status = 0 
     
    -- ä��
    IF @Count > 0
    BEGIN
        -- �����ڵ�ä�� : ���̺��� �ý��ۿ��� Max������ �ڵ� ä���� ���� �����Ͽ� ä��
        EXEC @Seq = dbo._SCOMCreateSeq @CompanySeq, @TblName, @SeqName, @Count
        
        UPDATE  #_TDAEmp
           SET  EmpSeq = @Seq + DataSeq
         WHERE  WorkingTag  = 'A'
           AND  Status      = 0
        
        -- �ܺι�ȣ ä���� ���� ���ڰ�
        SELECT @Date = CONVERT(NVARCHAR(8), GETDATE(), 112)        
        
        -- �ܺι�ȣä�� : ������ �ܺ�Ű�������ǵ�� ȭ�鿡�� ���ǵ� ä����Ģ���� ä��
        EXEC dbo._SCOMCreateNo 'SL', @TblName, @CompanySeq, '', @Date, @MaxNo OUTPUT
        
        UPDATE  #_TDAEmp
           SET  EmpSeq = @MaxNo
         WHERE  WorkingTag  = 'A'
           AND  Status      = 0
    END
   
    SELECT * FROM #_TDAEmp
    
RETURN
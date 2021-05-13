IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SHREmpInfoAcademicSave' AND xtype = 'P')    
    DROP PROC minjun_SHREmpInfoAcademicSave
GO
    
/*************************************************************************************************    
 ��  �� - SP-�����λ��������:�з�����Save_minjun
 �ۼ��� - '2020-03-24
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SHREmpInfoAcademicSave
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
    SELECT  @TblName        = N'_THRBasAcademic'
           ,@SeqName        = N'EmpSeq'
           ,@SerlName       = N'AcademicSeq'

    -- Xml������ �ӽ����̺� ���
    CREATE TABLE #_THRBasAcademic (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock3', '#_THRBasAcademic' 
    
    IF @@ERROR <> 0 RETURN
      
    -- �α����̺� �����(������ �Ķ���ʹ� �ݵ�� ���ٷ� ������)  	
	SELECT @TblColumns = dbo._FGetColumnsForLog(@TblName)
    
    EXEC _SCOMLog @CompanySeq   ,      
                  @UserSeq      ,      
                  @TblName      ,		-- ���̺��      
                  '#_THRBasAcademic'       ,		-- �ӽ� ���̺��      
                  'EmpSeq, AcademicSeq'     ,   -- CompanySeq�� ������ Ű(Ű�� �������� ���� , �� ���� )      
                  @TblColumns   ,   -- ���̺� ��� �ʵ��
                  ''            ,
                  @PgmSeq
                    
    -- =============================================================================================================================================
    -- DELETE
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #_THRBasAcademic WHERE WorkingTag = 'D' AND Status = 0 )    
    BEGIN
        -- Master���̺� ������ ����
        DELETE  A
          FROM  #_THRBasAcademic               AS M
                JOIN _THRBasAcademic          AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                           AND  A.EmpSeq      = M.EmpSeq
                                                           AND  A.AcademicSeq     = M.AcademicSeq
         WHERE  M.WorkingTag    = 'D'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- Update
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #_THRBasAcademic WHERE WorkingTag = 'U' AND Status = 0 )    
    BEGIN
        UPDATE  _THRBasAcademic 
           SET           
            AcademicSeq        = M.AcademicSeq     
            ,UMSchCareerSeq     = M.UMSchCareerSeq  
            ,EtcSchNm           = M.EtcSchNm        
            ,MajorCourse        = M.MajorCourse     
            ,MinorCourse        = M.MinorCourse     
            ,EntYm              = M.EntYm           
            ,GrdYm              = M.GrdYm           
            ,DegreeNo           = M.DegreeNo        
            ,IsLastSchCareer    = M.IsLastSchCareer 

          FROM  #_THRBasAcademic          AS M
                JOIN _THRBasAcademic          AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                                 AND  A.EmpSeq      = M.EmpSeq
                                                                 AND  A.AcademicSeq     = M.AcademicSeq
         WHERE  M.WorkingTag    = 'U'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- INSERT
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #_THRBasAcademic WHERE WorkingTag = 'A' AND Status = 0 )    
    BEGIN
        INSERT INTO _THRBasAcademic (
            CompanySeq
            ,EmpSeq           
            ,AcademicSeq      
            ,UMSchCareerSeq   
            ,EtcSchNm         
            ,MajorCourse      
            ,MinorCourse      
            ,EntYm            
            ,GrdYm            
            ,DegreeNo         
            ,IsLastSchCareer  

        )
        SELECT  
                @CompanySeq
                ,M.EmpSeq           
                ,M.AcademicSeq      
                ,M.UMSchCareerSeq   
                ,M.EtcSchNm         
                ,M.MajorCourse      
                ,M.MinorCourse      
                ,M.EntYm            
                ,M.GrdYm            
                ,M.DegreeNo         
                ,M.IsLastSchCareer  


          FROM  #_THRBasAcademic          AS M
         WHERE  M.WorkingTag    = 'A'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END
    
    SELECT * FROM #_THRBasAcademic
   
RETURN  
 /***************************************************************************************************************/
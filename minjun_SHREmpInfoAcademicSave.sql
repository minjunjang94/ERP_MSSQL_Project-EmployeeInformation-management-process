IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SHREmpInfoAcademicSave' AND xtype = 'P')    
    DROP PROC minjun_SHREmpInfoAcademicSave
GO
    
/*************************************************************************************************    
 설  명 - SP-개인인사정보등록:학력정보Save_minjun
 작성일 - '2020-03-24
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SHREmpInfoAcademicSave
     @xmlDocument    NVARCHAR(MAX)          -- Xml데이터
    ,@xmlFlags       INT            = 0     -- XmlFlag
    ,@ServiceSeq     INT            = 0     -- 서비스 번호
    ,@WorkingTag     NVARCHAR(10)   = ''    -- WorkingTag
    ,@CompanySeq     INT            = 1     -- 회사 번호
    ,@LanguageSeq    INT            = 1     -- 언어 번호
    ,@UserSeq        INT            = 0     -- 사용자 번호
    ,@PgmSeq         INT            = 0     -- 프로그램 번호
 AS
    DECLARE @TblName        NVARCHAR(MAX)   -- Table명
           ,@SeqName        NVARCHAR(MAX)   -- Seq명
           ,@SerlName       NVARCHAR(MAX)   -- Serl명
           ,@TblColumns     NVARCHAR(MAX)
    
    -- 테이블, 키값 명칭
    SELECT  @TblName        = N'_THRBasAcademic'
           ,@SeqName        = N'EmpSeq'
           ,@SerlName       = N'AcademicSeq'

    -- Xml데이터 임시테이블에 담기
    CREATE TABLE #_THRBasAcademic (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock3', '#_THRBasAcademic' 
    
    IF @@ERROR <> 0 RETURN
      
    -- 로그테이블 남기기(마지막 파라메터는 반드시 한줄로 보내기)  	
	SELECT @TblColumns = dbo._FGetColumnsForLog(@TblName)
    
    EXEC _SCOMLog @CompanySeq   ,      
                  @UserSeq      ,      
                  @TblName      ,		-- 테이블명      
                  '#_THRBasAcademic'       ,		-- 임시 테이블명      
                  'EmpSeq, AcademicSeq'     ,   -- CompanySeq를 제외한 키(키가 여러개일 경우는 , 로 연결 )      
                  @TblColumns   ,   -- 테이블 모든 필드명
                  ''            ,
                  @PgmSeq
                    
    -- =============================================================================================================================================
    -- DELETE
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #_THRBasAcademic WHERE WorkingTag = 'D' AND Status = 0 )    
    BEGIN
        -- Master테이블 데이터 삭제
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
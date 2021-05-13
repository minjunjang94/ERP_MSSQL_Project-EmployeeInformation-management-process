IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SHREmpInfoAcademicQuery' AND xtype = 'P')    
    DROP PROC minjun_SHREmpInfoAcademicQuery
GO
    
/*************************************************************************************************    
 설  명 - SP-개인인사정보등록:학력정보Query_minjun
 작성일 - 2020-03-23
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SHREmpInfoAcademicQuery
    @xmlDocument    NVARCHAR(MAX)          -- Xml데이터
   ,@xmlFlags       INT            = 0     -- XmlFlag
   ,@ServiceSeq     INT            = 0     -- 서비스 번호
   ,@WorkingTag     NVARCHAR(10)   = ''    -- WorkingTag
   ,@CompanySeq     INT            = 1     -- 회사 번호
   ,@LanguageSeq    INT            = 1     -- 언어 번호
   ,@UserSeq        INT            = 0     -- 사용자 번호
   ,@PgmSeq         INT            = 0     -- 프로그램 번호
AS
    -- 변수선언
    DECLARE @docHandle      INT
           ,@EmpSeq       INT
  
    -- Xml데이터 변수에 담기
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT  @EmpSeq            = ISNULL(EmpSeq       ,  0)
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock3', @xmlFlags)
      WITH (EmpSeq        INT)
    
    -- 최종Select
    SELECT  
            A.EmpSeq
            ,A.AcademicSeq
            ,C.MinorName        AS UMSchCareerName
            ,A.UMSchCareerSeq
            ,A.EtcSchNm
            ,A.MajorCourse
            ,A.MinorCourse
            ,A.EntYm
            ,A.GrdYm
            ,A.DegreeNo
            ,A.IsLastSchCareer

      FROM  _THRBasAcademic                 AS A  WITH(NOLOCK)
            JOIN _TDAEmp                    AS A1 WITH(NOLOCK)  ON      A1.CompanySeq   = A.CompanySeq
                                                               AND      A1.EmpSeq       = A.EmpSeq
            LEFT OUTER JOIN _TDAUMinor      AS  C   WITH(NOLOCK) ON C.CompanySeq        = A.CompanySeq
                                                                AND C.MinorSeq          = A.UMSchCareerSeq      



     WHERE  A.CompanySeq    = @CompanySeq
       AND  A.EmpSeq      = @EmpSeq
  
RETURN
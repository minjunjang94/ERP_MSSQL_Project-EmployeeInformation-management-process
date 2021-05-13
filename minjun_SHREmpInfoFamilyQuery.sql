IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SHREmpInfoFamilyQuery' AND xtype = 'P')    
    DROP PROC minjun_SHREmpInfoFamilyQuery
GO
    
/*************************************************************************************************    
 설  명 - SP-개인인사정보등록:가족정보Query_minjun
 작성일 - 2020-03-23
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SHREmpInfoFamilyQuery
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
           ,@EmpSeq         INT
  

    -- Xml데이터 변수에 담기
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT  @EmpSeq            = ISNULL(EmpSeq       ,  0)
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock2', @xmlFlags)
      WITH (EmpSeq        INT)
    

    -- 최종Select
    SELECT  
            B.EmpSeq
            ,B.FamilySeq
            ,B.FamilyName
            ,C.MinorName                     AS UMRelName
            ,B.UMRelSeq
            ,B.BirthDate        
            ,D.MinorName                     AS SMBirthTypeName
            ,B.SMBirthType
            ,B.Occupation
            ,B.FamilyPhone


      FROM  _TDAEmp                         AS  A  WITH(NOLOCK)
            JOIN _THRBasFamily              AS  B   WITH(NOLOCK) ON B.CompanySeq        = A.CompanySeq
                                                                AND B.EmpSeq            = A.EmpSeq
            LEFT OUTER JOIN _TDAUMinor      AS  C   WITH(NOLOCK) ON C.CompanySeq        = B.CompanySeq
                                                                AND C.MinorSeq          = B.UMRelSeq      
            LEFT OUTER JOIN _TDASMinor      AS  D   WITH(NOLOCK) ON D.CompanySeq        = B.CompanySeq
                                                                AND D.MinorSeq          = B.SMBirthType                                                      


     WHERE  A.CompanySeq    = @CompanySeq
       AND  A.EmpSeq        = @EmpSeq
  
RETURN


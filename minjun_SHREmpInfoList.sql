IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SHREmpInfoList' AND xtype = 'P')    
    DROP PROC minjun_SHREmpInfoList
GO
    
/*************************************************************************************************    
 설  명 - SP-개인인사정보조회_minjun
 작성일 - '2020-03-24
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SHREmpInfoList
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
    DECLARE @docHandle              INT
            ,@EmpName               nvarchar(100)
            ,@EmpId                 nvarchar(100)
            ,@DeptSeq               INT
  
    -- Xml데이터 변수에 담기
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT  
                 @EmpName              = RTRIM(LTRIM(ISNULL(EmpName            , '')))
                ,@EmpId                = RTRIM(LTRIM(ISNULL(EmpId              , '')))
                ,@DeptSeq              = RTRIM(LTRIM(ISNULL(DeptSeq            ,  0)))
           
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock1', @xmlFlags)
      WITH (    
            docHandle              INT
            ,EmpName               nvarchar(100)
            ,EmpId                 nvarchar(100)
            ,DeptSeq               INT
           )

           
    
    -- 최종Select
    SELECT  
            A.EmpSeq
            ,A.EmpName         
            ,A.EmpId         
            ,B.DeptSeq         
            ,B.DeptName        
            ,C.MinorName As  UMSchCareerName
            ,E.FamilyCount       
            ,D.EtcSchNm        
            ,D.EntYm           
            ,D.GrdYm           
            ,D.DegreeNo        
            ,D.MajorCourse   
            ,D.MinorCourse   

      FROM  _TDAEmp                             AS A  WITH(NOLOCK)
            LEFT OUTER JOIN _TDADept            AS B  WITH(NOLOCK)          ON B.CompanySeq      = A.CompanySeq
                                                                            AND B.Deptseq        = A.Deptseq
                                                                            
            LEFT OUTER JOIN _THRBasAcademic     AS D  WITH(NOLOCK)          ON D.CompanySeq      = A.CompanySeq                                  
                                                                            AND D.EmpSeq         = A.EmpSeq
                                                                            AND D.IsLastSchCareer  = '1'
            LEFT OUTER JOIN _TDAUMinor          AS C  WITH(NOLOCK)          ON C.CompanySeq      = A.CompanySeq                                  
                                                                            AND C.MinorSeq      = D.UMSchCareerSeq
            LEFT OUTER JOIN      (select x.CompanySeq
                                , x.EmpSeq
                                , Count(x.FamilySeq) as FamilyCount
                                from _THRBasFamily  as X with(nolock)
                                group by X.CompanySeq, X.EmpSeq
                                ) AS E       
                                ON  E.CompanySeq        = A.CompanySeq  
                                AND E.EmpSeq            = A.EmpSeq
                                                                            





     WHERE  A.CompanySeq    = @CompanySeq    
       AND (@EmpName    =''         OR  A.EmpName           LIKE @EmpName         + '%' )
       AND (@EmpId      =''         OR  A.EmpId             LIKE @EmpId           + '%' )  
       AND (@DeptSeq    =0          OR  B.DeptSeq           =    @DeptSeq               ) 
  
RETURN
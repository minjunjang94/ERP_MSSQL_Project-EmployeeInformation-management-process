IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SHREmpInfoList' AND xtype = 'P')    
    DROP PROC minjun_SHREmpInfoList
GO
    
/*************************************************************************************************    
 ��  �� - SP-�����λ�������ȸ_minjun
 �ۼ��� - '2020-03-24
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SHREmpInfoList
     @xmlDocument    NVARCHAR(MAX)          -- Xml������
    ,@xmlFlags       INT            = 0     -- XmlFlag
    ,@ServiceSeq     INT            = 0     -- ���� ��ȣ
    ,@WorkingTag     NVARCHAR(10)   = ''    -- WorkingTag
    ,@CompanySeq     INT            = 1     -- ȸ�� ��ȣ
    ,@LanguageSeq    INT            = 1     -- ��� ��ȣ
    ,@UserSeq        INT            = 0     -- ����� ��ȣ
    ,@PgmSeq         INT            = 0     -- ���α׷� ��ȣ
AS
    -- ��������
    DECLARE @docHandle              INT
            ,@EmpName               nvarchar(100)
            ,@EmpId                 nvarchar(100)
            ,@DeptSeq               INT
  
    -- Xml������ ������ ���
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

           
    
    -- ����Select
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
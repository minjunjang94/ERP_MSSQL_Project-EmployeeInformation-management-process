IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SHREmpInfoFamilyQuery' AND xtype = 'P')    
    DROP PROC minjun_SHREmpInfoFamilyQuery
GO
    
/*************************************************************************************************    
 ��  �� - SP-�����λ��������:��������Query_minjun
 �ۼ��� - 2020-03-23
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SHREmpInfoFamilyQuery
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
    DECLARE @docHandle      INT
           ,@EmpSeq         INT
  

    -- Xml������ ������ ���
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT  @EmpSeq            = ISNULL(EmpSeq       ,  0)
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock2', @xmlFlags)
      WITH (EmpSeq        INT)
    

    -- ����Select
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


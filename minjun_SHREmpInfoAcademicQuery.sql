IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SHREmpInfoAcademicQuery' AND xtype = 'P')    
    DROP PROC minjun_SHREmpInfoAcademicQuery
GO
    
/*************************************************************************************************    
 ��  �� - SP-�����λ��������:�з�����Query_minjun
 �ۼ��� - 2020-03-23
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SHREmpInfoAcademicQuery
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
           ,@EmpSeq       INT
  
    -- Xml������ ������ ���
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT  @EmpSeq            = ISNULL(EmpSeq       ,  0)
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock3', @xmlFlags)
      WITH (EmpSeq        INT)
    
    -- ����Select
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
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SHREmpInfoQuery' AND xtype = 'P')    
    DROP PROC minjun_SHREmpInfoQuery
GO
    
/*************************************************************************************************    
 ��  �� - SP-�����λ��������:Query_minjun
 �ۼ��� - '2020-03-23
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SHREmpInfoQuery
    @xmlDocument    NVARCHAR(MAX)           -- Xml������
   ,@xmlFlags       INT             = 0     -- XmlFlag
   ,@ServiceSeq     INT             = 0     -- ���� ��ȣ
   ,@WorkingTag     NVARCHAR(10)    = ''    -- WorkingTag
   ,@CompanySeq     INT             = 1     -- ȸ�� ��ȣ
   ,@LanguageSeq    INT             = 1     -- ��� ��ȣ
   ,@UserSeq        INT             = 0     -- ����� ��ȣ
   ,@PgmSeq         INT             = 0     -- ���α׷� ��ȣ
AS
    -- ��������
    DECLARE @docHandle      INT
           ,@EmpSeq       INT

    -- Xml������ ������ ���
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT  @EmpSeq       = ISNULL(EmpSeq       ,  0)
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock1', @xmlFlags)
      WITH (EmpSeq        INT)
    
    -- ����Select
    SELECT   A.EmpSeq
            ,A.EmpName
            ,A.EmpId
            ,B.DeptName
            ,B.DeptSeq

      FROM  _TDAEmp               AS A  WITH(NOLOCK)
            LEFT OUTER JOIN _TDADept            AS B    WITH(NOLOCK) ON B.CompanySeq      = A.CompanySeq
                                                                    AND B.Deptseq         = A.Deptseq

      WHERE  A.CompanySeq    = @CompanySeq
        AND  A.EmpSeq        = @EmpSeq  
RETURN
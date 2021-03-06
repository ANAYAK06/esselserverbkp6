USE [ESSELDB2]
GO
/****** Object:  StoredProcedure [dbo].[TaxDcas_sp]    Script Date: 2/21/2021 9:03:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Procedure [dbo].[TaxDcas_sp]
@Type VARCHAR(50)=null
,@Taxtype VARCHAR(20)
,@date VARCHAR(30)=null
,@CCCode VARCHAR(30)
,@MRR VARCHAR(20)=null

As
Begin
Begin Try
Begin Transaction
declare @Year varchar(10)
DECLARE @CCtype VARCHAR(50)
DECLARE @mrrdate varchar(20)
declare @Year1 varchar(10)


Select @CCtype=cc_type from Cost_Center where cc_code=@CCCode
set @Year=dbo.FinancialYear(@date)
  IF(@Taxtype='TaxClient')
		Begin
			IF(@Type='Creditable')
				select d.mapdca_code, d.dca_code from dca d where d.Dca_Type='Tax' and d.Tax_Type='Creditable' AND d.mapdca_code IN('DCA-VAT-CR','DCA-EXCISE-CR','DCA-SRTX-CR','DCA-GST-CR')
			ELSE
			   Begin
					IF(@CCtype='Performing')
						SELECT d.mapdca_code, d.dca_code from dca d JOIN yearly_dcabudget yd ON d.dca_code=yd.dca_code AND d.mapdca_code IN ('DCA-VAT-NON-CR','DCA-EXCISE-NON-CR','DCA-SRTX-NON-CR','DCA-GST-NON-CR') AND yd.cc_code=@CCCode
					ELSE IF (@CCtype='Non-Performing' OR @CCtype='Capital') 	
					    SELECT d.mapdca_code, d.dca_code from dca d JOIN yearly_dcabudget yd ON d.dca_code=yd.dca_code AND d.mapdca_code IN ('DCA-VAT-NON-CR','DCA-EXCISE-NON-CR','DCA-SRTX-NON-CR','DCA-GST-NON-CR') AND yd.cc_code=@CCCode AND yd.year=@Year
			   END
		End
	ELSE IF(@Taxtype='Tax')
		Begin
			IF(@Type='Creditable')
				select d.mapdca_code, d.dca_code from dca d where d.Dca_Type='Tax' and d.Tax_Type='Creditable' AND d.mapdca_code IN('DCA-VAT-CR','DCA-EXCISE-CR','DCA-SRTX-CR')
			ELSE
			   Begin
					IF(@CCtype='Performing')
						SELECT d.mapdca_code, d.dca_code from dca d JOIN yearly_dcabudget yd ON d.dca_code=yd.dca_code AND d.mapdca_code IN ('DCA-VAT-NON-CR','DCA-EXCISE-NON-CR','DCA-SRTX-NON-CR') AND yd.cc_code=@CCCode
					ELSE IF (@CCtype='Non-Performing' OR @CCtype='Capital') 	
					    SELECT d.mapdca_code, d.dca_code from dca d JOIN yearly_dcabudget yd ON d.dca_code=yd.dca_code AND d.mapdca_code IN ('DCA-VAT-NON-CR','DCA-EXCISE-NON-CR','DCA-SRTX-NON-CR') AND yd.cc_code=@CCCode AND yd.year=@Year
			   END
		End
	 ELSE IF(@Taxtype='Cess')
		Begin
			IF(@Type='Creditable')
				select d.mapdca_code, d.dca_code from dca d where d.Dca_Type='Tax' and d.Tax_Type='Creditable' AND d.mapdca_code IN('DCA-CESS-CR')				    
			ELSE
				Begin
				  IF(@CCtype='Performing')
						SELECT d.mapdca_code, d.dca_code from dca d JOIN yearly_dcabudget yd ON d.dca_code=yd.dca_code AND d.mapdca_code='DCA-CESS-NON-CR' AND yd.cc_code=@CCCode 
					ELSE IF (@CCtype='Non-Performing' OR @CCtype='Capital') 
						SELECT d.mapdca_code, d.dca_code from dca d JOIN yearly_dcabudget yd ON d.dca_code=yd.dca_code AND d.mapdca_code='DCA-CESS-NON-CR' AND yd.cc_code=@CCCode AND yd.year=@Year						
			    End
		End
	  ELSE IF(@Taxtype='Other' or @Taxtype='Deduction')		
				Begin
				  IF(@CCtype='Performing')
						SELECT d.mapdca_code, d.dca_code,d.dca_name from dca d JOIN yearly_dcabudget yd ON d.dca_code=yd.dca_code AND d.dca_type='Expense' AND yd.cc_code=@CCCode 
					ELSE IF (@CCtype='Non-Performing' OR @CCtype='Capital') 
						SELECT d.mapdca_code, d.dca_code,d.dca_name from dca d JOIN yearly_dcabudget yd ON d.dca_code=yd.dca_code AND d.dca_type='Expense' AND yd.cc_code=@CCCode AND yd.year=@Year						
			    End
	  ELSE	IF(@Taxtype='Refunds')
				Begin
				  IF(@CCtype='Performing')
						SELECT distinct d.mapdca_code, d.dca_code,d.dca_name from dca d JOIN yearly_dcabudget yd ON d.dca_code=yd.dca_code AND d.dca_type='Expense'  AND yd.cc_code=@CCCode and yd.status='3'
					ELSE IF (@CCtype='Non-Performing' OR @CCtype='Capital') 
						SELECT distinct d.mapdca_code, d.dca_code,d.dca_name from dca d JOIN yearly_dcabudget yd ON d.dca_code=yd.dca_code AND d.dca_type='Expense' AND yd.cc_code=@CCCode AND yd.year=@Year and yd.status='3'	 					
			    End
	   ELSE IF(@Taxtype='Refundsnew')
				Begin
				  IF(@CCtype='Performing')
						SELECT distinct d.mapdca_code, d.dca_code,d.dca_name from dca d JOIN yearly_dcabudget yd ON d.dca_code=yd.dca_code  AND yd.cc_code=@CCCode and yd.status='3'
					ELSE IF (@CCtype='Non-Performing' OR @CCtype='Capital') 
						SELECT distinct d.mapdca_code, d.dca_code,d.dca_name from dca d JOIN yearly_dcabudget yd ON d.dca_code=yd.dca_code  AND yd.cc_code=@CCCode AND yd.year=@Year and yd.status='3'	 					
			    End
	  ELSE IF(@Taxtype='Others' or @Taxtype='Deductions')		
				Begin
				  IF(@CCtype='Performing')
						SELECT distinct(d.mapdca_code+' , '+dca_name)as mapdca_code, d.dca_code,d.dca_name from dca d JOIN yearly_dcabudget yd ON d.dca_code=yd.dca_code AND d.dca_type='Expense' AND yd.cc_code=@CCCode 
					ELSE IF (@CCtype='Non-Performing' OR @CCtype='Capital') 
						SELECT distinct(d.mapdca_code+' , '+dca_name)as mapdca_code, d.dca_code,d.dca_name from dca d JOIN yearly_dcabudget yd ON d.dca_code=yd.dca_code AND d.dca_type='Expense' AND yd.cc_code=@CCCode AND yd.year=@Year						
			    End
	   ELSE IF(@Taxtype='SupplierOthers' or @Taxtype='SupplierDeductions')
				BEGIN
					SELECT @mrrdate=recieved_date FROM MR_Report mr WHERE mr.MRR_no=@MRR
					set @Year1=dbo.FinancialYear(@mrrdate)		
					Begin
					  IF(@CCtype='Performing')
							SELECT distinct d.mapdca_code as mapdca_code, d.dca_code,d.dca_name from dca d JOIN yearly_dcabudget yd ON d.dca_code=yd.dca_code AND d.dca_type='Expense' AND yd.cc_code=@CCCode 
						ELSE IF (@CCtype='Non-Performing' OR @CCtype='Capital') 
							SELECT distinct d.mapdca_code as mapdca_code, d.dca_code,d.dca_name from dca d JOIN yearly_dcabudget yd ON d.dca_code=yd.dca_code AND d.dca_type='Expense' AND yd.cc_code=@CCCode AND yd.year=@Year1						
					End
			    End
	   ELSE	IF(@Taxtype='FDIntrest')
				Begin
				  IF(@CCtype='Performing')
						SELECT distinct d.mapdca_code, d.dca_code,d.dca_name,(d.mapdca_code+' , '+d.dca_name)as name from dca d JOIN yearly_dcabudget yd ON d.dca_code=yd.dca_code AND d.dca_type='Expense'  AND yd.cc_code=@CCCode and yd.dca_code='DCA-46' and yd.status='3'
					ELSE IF (@CCtype='Non-Performing' OR @CCtype='Capital') 
						SELECT distinct d.mapdca_code, d.dca_code,d.dca_name,(d.mapdca_code+' , '+d.dca_name)as name from dca d JOIN yearly_dcabudget yd ON d.dca_code=yd.dca_code AND d.dca_type='Expense' AND yd.cc_code=@CCCode and yd.dca_code='DCA-46' AND yd.year=@Year and yd.status='3'	 					
			    End
	   ELSE IF(@Taxtype='ClientDeductions')		
				Begin
				  IF(@CCtype='Performing')
						--SELECT distinct(d.mapdca_code+' , '+dca_name)as mapdca_code, d.dca_code,d.dca_name from dca d JOIN yearly_dcabudget yd ON d.dca_code=yd.dca_code AND d.dca_type in ('Expense','Tax') and d.Tax_Type is null and d.Tax_Type='Non-Creditable' AND yd.cc_code=@CCCode 
						BEGIN
							SELECT distinct(d.mapdca_code+' , '+dca_name)as mapdca_code, d.dca_code,d.dca_name from dca d JOIN yearly_dcabudget yd ON d.dca_code=yd.dca_code AND d.dca_type in ('Expense')  AND yd.cc_code=@CCCode  
							UNION ALL
							SELECT distinct(d.mapdca_code+' , '+dca_name)as mapdca_code, d.dca_code,d.dca_name from dca d JOIN yearly_dcabudget yd ON d.dca_code=yd.dca_code AND d.dca_type in ('Tax')  and d.Tax_Type in('Non-Creditable') AND yd.cc_code=@CCCode  
						End
					ELSE IF (@CCtype='Non-Performing' OR @CCtype='Capital') 
						Begin
							if(@CCCode!='CCC')
								BEGIN
									SELECT distinct(d.mapdca_code+' , '+dca_name)as mapdca_code, d.dca_code,d.dca_name from dca d JOIN yearly_dcabudget yd ON d.dca_code=yd.dca_code AND d.dca_type in ('Expense') AND yd.cc_code=@CCCode AND yd.year=@Year						
									UNION ALL
									SELECT distinct(d.mapdca_code+' , '+dca_name)as mapdca_code, d.dca_code,d.dca_name from dca d JOIN yearly_dcabudget yd ON d.dca_code=yd.dca_code AND d.dca_type in ('Tax') and d.Tax_Type in('Non-Creditable') AND yd.cc_code=@CCCode AND yd.year=@Year						
								END
							ELSE
								BEGIN
									SELECT distinct(d.mapdca_code+' , '+dca_name)as mapdca_code, d.dca_code,d.dca_name from dca d JOIN yearly_dcabudget yd ON d.dca_code=yd.dca_code AND d.dca_type in ('Expense') AND yd.cc_code=@CCCode AND yd.year=@Year						
									UNION ALL
									SELECT distinct(d.mapdca_code+' , '+dca_name)as mapdca_code, d.dca_code,d.dca_name from dca d JOIN yearly_dcabudget yd ON d.dca_code=yd.dca_code AND d.dca_type in ('Tax') and d.Tax_Type in('Non-Creditable') AND yd.cc_code=@CCCode AND yd.year=@Year						
									UNION All
									select distinct(d.mapdca_code+' , '+dca_name)as mapdca_code, d.dca_code,d.dca_name from dca d where d.Dca_Type='Tax' and d.Tax_Type='Creditable' AND d.mapdca_code IN('DCA-VAT-CR','DCA-EXCISE-CR','DCA-SRTX-CR','DCA-GST-CR')
								End
						END
			    End
	 
commit transaction
end try
begin catch
-- Incase of Exception Rollback the transanction
ROLLBACK TRANSACTION
Select convert(varchar,ERROR_LINE())+' '+ERROR_MESSAGE()
end catch
End

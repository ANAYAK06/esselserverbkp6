USE [EsselV2QA]
GO
/****** Object:  StoredProcedure [dbo].[spGetNotification]    Script Date: 2/9/2021 2:21:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Procedure   [dbo].[spGetNotification] 
@RoleID int,
@CCCodes varchar(max)=null,
@UserID varchar(10)=null
AS
BEGIN
 Declare @status varchar(20)
 Declare @Count int
 Declare @Count1 int 
 Declare @Sumcount int
 Declare @Path Varchar(100)
 Declare @NotificationCount int
--DECLARE @Masterid INT
--select @Masterid from WorkFlowLevels where UserRoleID=104
	if(@CCCodes !='' or @CCCodes is not null)
	Begin	
	Declare @CClist TABLE
			(
			CCCode varchar(100)
			)

       INSERT INTO @CClist
     SELECT VALUE As CCCode From fnsplit(@CCCodes,',',1)
	End
  	IF OBJECT_ID(N'tempdb..#Tempnotificationcount') IS NOT NULL
	DROP TABLE  #Tempnotificationcount;
	ELSE
	CREATE TABLE #Tempnotificationcount(Rowid INT IDENTITY(1,1) PRIMARY KEY,MOID int,MOCategory VARCHAR(100),MOCode varchar(100),Status varchar(100),IndCount int,[Path] varchar(max));
	--insert into #Tempnotificationcount select  distinct MasterOperationID as MOID,null as MOCategory,null as MOCode,LevelOfApproval as Status,null as IndCount,null as Path from WorkFlowLevels where UserRoleID=@RoleID
	insert into #Tempnotificationcount select  distinct MasterOperationID as MOID,null as MOCategory,null as MOCode,LevelOfApproval-1 as Status, null as IndCount,null as Path from WorkFlowLevels where UserRoleID=@RoleID and (LevelOfApproval-1)>=0 and MasterOperationID is not null
	DECLARE @countchk INT
	SET @countchk = (Select Count(*) from #Tempnotificationcount)
	DECLARE @ids INT;
	DECLARE @TEMPMOCATEGORY VARCHAR(100)	
	DECLARE @TEMPMOCODE VARCHAR(100)
	DECLARE @Rolestatus INT
	--Declare @Rolename varchar(100)
    --Set @Rolename=(Select UserRoleCode from  UserRole  where UserRoleID=@RoleID)
	SET @ids = 1;
	WHILE (@ids <= @countchk)
	BEGIN
	 SELECT @TEMPMOCATEGORY=Category,@TEMPMOCODE=MasterOperationCode from MasterOperation  WHERE MasterOperationID=(SELECT MOID FROM #Tempnotificationcount WHERE Rowid=@ids )
	  --SELECT @TEMPMOCATEGORY=Category,@TEMPMOCODE=MasterOperationCode from MasterOperation  WHERE MasterOperationID=(282 )
	 UPDATE #Tempnotificationcount SET MOCategory=@TEMPMOCATEGORY,MOCode=@TEMPMOCODE WHERE Rowid=@ids
		if exists(Select * from #Tempnotificationcount where MOCode in ('CostCenterCreation(PCC)') and MOCategory='Cost Center')
		  Begin	
		  Set @Count=0;  									
				if(@RoleID=108)
				Begin
				   select @status = Status from #Tempnotificationcount where MOCode in ('CostCenterCreation(PCC)') and MOCategory='Cost Center'
			       Select @Count= Count(*) from Cost_Center where Status=@status and CC_Code in (Select CCCode from @CClist)
				   if exists(Select * from UserCostCenters  where RoleId=@RoleID and UserId=@UserID and CCCode in(select cc_code from Cost_Center where status=@status and CC_Type='Performing'))
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/ApproveCostCenter' , MOCategory='Cost Center(PCC)' where MOCode in ('CostCenterCreation(PCC)') and Rowid=@ids			
				End
				Else
				Begin
				    select @status = Status from #Tempnotificationcount where MOCode in ('CostCenterCreation(PCC)') and MOCategory='Cost Center'
			        Select @Count= Count(*) from Cost_Center where Status=@status and CC_Type='Performing'				   
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/ApproveCostCenter' , MOCategory='Cost Center(PCC)' where MOCode in ('CostCenterCreation(PCC)') and Rowid=@ids			
				End			
		  
	     End
		if exists(Select * from #Tempnotificationcount where MOCode in ('CostCenterCreation(NPCC)') and MOCategory='Cost Center')
		  Begin 
			Set @Count=0; 
		    if(@RoleID!=108)
				Begin					   
					   select @status = Status from #Tempnotificationcount where MOCode in ('CostCenterCreation(NPCC)') and MOCategory='Cost Center'
					   Select @Count= Count(*) from Cost_Center where Status=@status and CC_Type in ('Non-Performing','Capital')								
					   UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/ApproveCostCenter', MOCategory='Cost Center(NPCC)' where MOCode in ('CostCenterCreation(NPCC)') and Rowid=@ids			
				End	  
	     End
		if exists(Select * from #Tempnotificationcount where MOCode in('CostCenterBudgetAssignment(PCC)') and MOCategory='Cost Center Budget')
		  Begin	
			Set @Count=0;
				if(@RoleID=108)
				Begin 			  
					select @status = Status from #Tempnotificationcount where MOCode in('CostCenterBudgetAssignment(PCC)') and MOCategory='Cost Center Budget'
					Select @Count= Count(*) from CCBudget where Status=@status and CCCode in (Select CCCode from @CClist)								
					if exists(Select * from UserCostCenters  where RoleId=@RoleID and UserId=@UserID and CCCode in (select ccb.CCCode from CCBudget ccb join Cost_Center cc on ccb.CCCode=cc.CC_Code where cc.CC_Type='Performing'))
					 UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/CostCenterBudgetApproval',MOCategory='Cost Center Budget(PCC)' where MOCode ='CostCenterBudgetAssignment(PCC)' and Rowid=@ids	
				End
				Else	
				Begin
				    select @status = Status from #Tempnotificationcount where MOCode in ('CostCenterBudgetAssignment(PCC)') and MOCategory='Cost Center Budget'
			        Select @Count= Count(*) from CCBudget ccb join Cost_Center cc on ccb.CCCode=cc.CC_Code where ccb.Status=@status and cc.CC_Type='Performing'				   
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/CostCenterBudgetApproval' , MOCategory='Cost Center Budget(PCC)' where MOCode in ('CostCenterBudgetAssignment(PCC)') and Rowid=@ids			
				
				End	
		   End
		if exists(Select * from #Tempnotificationcount where MOCode in ('CostCenterBudgetAssignment(NPCC)') and MOCategory='Cost Center Budget')
		  Begin 
			Set @Count=0; 
		    if(@RoleID!=108)
				Begin					   
					   select @status = Status from #Tempnotificationcount where MOCode in ('CostCenterBudgetAssignment(NPCC)') and MOCategory='Cost Center Budget'
					   Select @Count= Count(*) from CCBudget ccb join Cost_Center cc on ccb.CCCode=cc.CC_Code where ccb.Status=@status and cc.CC_Type in ('Non-Performing','Capital')								
					   UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/CostCenterBudgetApproval', MOCategory='Cost Center Budget(NPCC)' where MOCode in ('CostCenterBudgetAssignment(NPCC)') and Rowid=@ids			
				End	  
	      End	
		if exists(Select * from #Tempnotificationcount where MOCode in('CostCenterBudgetAmendment(PCC)') and MOCategory='Cost Center Budget')
		  Begin	
			Set @Count=0; 	
			  if(@RoleID=108)
				Begin
				   select @status = Status from #Tempnotificationcount where MOCode in ('CostCenterBudgetAmendment(PCC)') and MOCategory='Cost Center Budget'
			       Select @Count= Count(*) from CCBudgetAmendment where Status=@status and CCCode in (Select CCCode from @CClist)
				   if exists(Select * from UserCostCenters  where RoleId=@RoleID and UserId=@UserID and CCCode in(select ccb.CCCode from CCBudgetAmendment ccb join Cost_Center cc on ccb.CCCode=cc.CC_Code where cc.CC_Type='Performing'))
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyCCAmendBudget' , MOCategory='Cost Center Budget Amend(PCC)' where MOCode in ('CostCenterBudgetAmendment(PCC)') and Rowid=@ids			
				End
				Else
				Begin
				    select @status = Status from #Tempnotificationcount where MOCode in ('CostCenterBudgetAmendment(PCC)') and MOCategory='Cost Center Budget'
			        Select @Count= Count(*) from CCBudgetAmendment ccb join Cost_Center cc on ccb.CCCode=cc.CC_Code where ccb.Status=@status and cc.CC_Type in ('Non-Performing','Capital')		   
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyCCAmendBudget'  , MOCategory='Cost Center Budget Amend(PCC)' where MOCode in ('CostCenterBudgetAmendment(PCC)') and Rowid=@ids			
				End					  
		   End
		if exists(Select * from #Tempnotificationcount where MOCode in('CostCenterBudgetAmendment(NPCC)') and MOCategory='Cost Center Budget')
		  Begin	
			Set @Count=0; 	
			 if(@RoleID!=108)
				Begin					   
					   select @status = Status from #Tempnotificationcount where MOCode in ('CostCenterBudgetAmendment(NPCC)') and MOCategory='Cost Center Budget'
					   Select @Count= Count(*) from CCBudgetAmendment ccb join Cost_Center cc on ccb.CCCode=cc.CC_Code where ccb.Status=@status and cc.CC_Type in ('Non-Performing','Capital')								
					   UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyCCAmendBudget', MOCategory='Cost Center Budget Amend(NPCC)' where MOCode in ('CostCenterBudgetAssignment(NPCC)') and Rowid=@ids			
				End			  
		   End	
		if exists(Select * from #Tempnotificationcount where MOCode in ('CloseCostCenter(PCC)') and MOCategory='Close Cost Center')
		  Begin	
			Set @Count=0; 		
			if(@RoleID=108)
				Begin
				   select @status = Status from #Tempnotificationcount where MOCode in ('CloseCostCenter(PCC)') and MOCategory='Close Cost Center'
			       Select @Count= Count(*) from ClosingDetails where Status=@status and ClosingFor in (Select CCCode from @CClist)
				   if exists(Select * from UserCostCenters  where RoleId=@RoleID and UserId=@UserID and CCCode in(select ccb.ClosingFor from ClosingDetails ccb join Cost_Center cc on ccb.ClosingFor=cc.CC_Code where cc.CC_Type='Performing'))
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Home/VerifyCloseCostCenter' , MOCategory='Close Cost Center(PCC)' where MOCode in ('CloseCostCenter(PCC)') and Rowid=@ids			
				End
				Else
				Begin
				    select @status = Status from #Tempnotificationcount where MOCode in ('CloseCostCenter(PCC)') and MOCategory='Close Cost Center'
			        --Select @Count= Count(*) from Cost_Center where Status=@status and CC_Type='Performing'
					Select @Count= Count(*) from ClosingDetails ccb join Cost_Center cc on ccb.ClosingFor=cc.CC_Code where ccb.Status=@status and cc.CC_Type='Performing'					   
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Home/VerifyCloseCostCenter' , MOCategory='Close Cost Center(PCC)' where MOCode in ('CloseCostCenter(PCC)') and Rowid=@ids			
				End			  
		   End
		 if exists(Select * from #Tempnotificationcount where MOCode in ('CloseCostCenter(NPCC)') and MOCategory='Close Cost Center')
		  Begin	
			Set @Count=0; 		
			if(@RoleID!=108)
				Begin					   
					   select @status = Status from #Tempnotificationcount where MOCode in ('CloseCostCenter(NPCC)') and MOCategory='Close Cost Center'
					   Select @Count= Count(*) from ClosingDetails ccb join Cost_Center cc on ccb.ClosingFor=cc.CC_Code where ccb.Status=@status and cc.CC_Type='Non-Performing'								
					   UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Home/VerifyCloseCostCenter', MOCategory='Close Cost Center(NPCC)' where MOCode in ('CloseCostCenter(NPCC)') and Rowid=@ids			
				End		  
		   End
		if exists(Select * from #Tempnotificationcount where MOCode='AccountHeadCreation' and MOCategory='Account Head')
		  Begin	
			Set @Count=0; 				   
			select @status = Status from #Tempnotificationcount where MOCode='AccountHeadCreation' and MOCategory='Account Head'
			Select @Count= Count(*) from DCA where Status=@status			
			   UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyDCA' where MOCode='AccountHeadCreation' and Rowid=@ids	
			End
		if exists(Select * from #Tempnotificationcount where MOCode='SubAccountHeadCreation' and MOCategory='SubAccount Head')
		  Begin	
			Set @Count=0; 
			select @status = Status from #Tempnotificationcount where MOCode='SubAccountHeadCreation' and MOCategory='SubAccount Head'
			Select @Count= Count(*) from subdca where Status=@status			
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifySubDCA' where MOCode='SubAccountHeadCreation' and Rowid=@ids	
		   End
		if exists(Select * from #Tempnotificationcount where MOCode='ITCodeCreation' and MOCategory='IT Code')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='ITCodeCreation' and MOCategory='IT Code'
			Select @Count= Count(*) from IT where Status=@status
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/ApproveIT' where MOCode='ITCodeCreation' and Rowid=@ids	
		   End
		if exists(Select * from #Tempnotificationcount where MOCode='SubClientCreation' and MOCategory='Sub-Client')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='SubClientCreation' and MOCategory='Sub-Client'
			Select @Count= Count(*) from SubClient where Status=@status
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifySubClient' where MOCode='SubClientCreation' and Rowid=@ids	
		   End
		if exists(Select * from #Tempnotificationcount where MOCode='BankAccountCreation' and MOCategory='Bank Account')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='BankAccountCreation' and MOCategory='Bank Account'
			Select @Count= Count(*) from BankDetails where Status=@status
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyBankAccounts' where MOCode='BankAccountCreation' and Rowid=@ids	
		   End
		if exists(Select * from #Tempnotificationcount where MOCode in ('TaxesCreation','GSTCreation') and MOCategory in ('Taxes','GST'))
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode in ('TaxesCreation','GSTCreation') and MOCategory in ('Taxes','GST')
			Select @Count= Count(*) from Taxes where Status=@status and TaxType in ('General','GST')
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyTaxGeneral' where MOCode in ('TaxesCreation','GSTCreation') and Rowid=@ids	
		   End
		if exists(Select * from #Tempnotificationcount where MOCode='ClientPOCreation' and MOCategory='Client PO')
		  Begin	
			Set @Count=0; 			
				if(@RoleID=108)
				Begin
				   select @status = Status from #Tempnotificationcount where MOCode in ('ClientPOCreation') and MOCategory='Client PO'
			       Select @Count= Count(*) from ClientPO where Status=@status and CCCode in (Select CCCode from @CClist)
				   if exists(Select * from UserCostCenters  where RoleId=@RoleID and UserId=@UserID and CCCode in(select CCCode from ClientPO where status=@status))
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyClientPO'  where MOCode in ('ClientPOCreation') and Rowid=@ids			
				End
				Else
				Begin
				    select @status = Status from #Tempnotificationcount where MOCode in ('ClientPOCreation') and MOCategory='Client PO'
			        Select @Count= Count(*) from ClientPO where Status=@status			   
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyClientPO' where MOCode in ('ClientPOCreation') and Rowid=@ids			
				End						  
			--select @status = Status from #Tempnotificationcount where MOCode='ClientPOCreation' and MOCategory='Client PO'
			--Select @Count= Count(*) from ClientPO where Status=@status
			--UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyClientPO' where MOCode='ClientPOCreation' and Rowid=@ids	
		   End
		if exists(Select * from #Tempnotificationcount where MOCode='ClientPOAmendment' and MOCategory='Client PO')
		  Begin	
			Set @Count=0; 	
				if(@RoleID=108)
				Begin
				   select @status = Status from #Tempnotificationcount where MOCode in ('ClientPOAmendment') and MOCategory='Client PO'
			       Select @Count= Count(*) from ClientPOAmendment cpa join clientpo cp on cpa.PONumber=cp.PONumber where cpa.status=@status and cp.CCCode in (Select CCCode from @CClist)
				   if exists(Select * from UserCostCenters  where RoleId=@RoleID and UserId=@UserID and CCCode in(Select cp.CCCode from ClientPOAmendment cpa join clientpo cp on cpa.PONumber=cp.PONumber where cpa.status=@status))
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyClientPOAmend'  where MOCode in ('ClientPOAmendment') and Rowid=@ids			
				End
				Else
				Begin
				    select @status = Status from #Tempnotificationcount where MOCode in ('ClientPOAmendment') and MOCategory='Client PO'
			        Select @Count= Count(*) from ClientPOAmendment where Status=@status			   
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyClientPOAmend' where MOCode in ('ClientPOAmendment') and Rowid=@ids			
				End					  
			--select @status = Status from #Tempnotificationcount where MOCode='ClientPOAmendment' and MOCategory='Client PO'
			--Select @Count= Count(*) from ClientPOAmendment where Status=@status
			--UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyClientPOAmend' where MOCode='ClientPOAmendment' and Rowid=@ids	
		   End
		if exists(Select * from #Tempnotificationcount where MOCode='GroupCreation' and MOCategory='Groups')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='GroupCreation' and MOCategory='Groups'
			Select @Count= Count(*) from MasterGroups where Status=@status
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyMasterGroups' where MOCode='GroupCreation' and Rowid=@ids	
		   End
		if exists(Select * from #Tempnotificationcount where MOCode='SubGroupCreation' and MOCategory='Sub-Group')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='SubGroupCreation' and MOCategory='Sub-Group'
			Select @Count= Count(*) from SubGroup where Status=@status and ParentId is NULL
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifySubGroups' where MOCode='SubGroupCreation' and Rowid=@ids	
		   End
		if exists(Select * from #Tempnotificationcount where MOCode='ChildGroupCreation' and MOCategory='Child-Group')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='ChildGroupCreation' and MOCategory='Child-Group'
			Select @Count= Count(*) from SubGroup where Status=@status and ParentId is not NULL
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyChildGroups' where MOCode='SubGroupCreation' and Rowid=@ids	
		   End
		if exists(Select * from #Tempnotificationcount where MOCode='LedgerCreation' and MOCategory='Ledger')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='LedgerCreation' and MOCategory='Ledger'
			Select @Count= Count(*) from Ledger where Status=@status
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyLedger' where MOCode='LedgerCreation' and Rowid=@ids	
		   End
		if exists(Select * from #Tempnotificationcount where MOCode in ('AccountHeadBudgetAssignment(PCC)') and MOCategory='Account Head Budget')
		  Begin	
		  Set @Count=0;  									
				if(@RoleID=108)
				Begin
				   select @status = Status from #Tempnotificationcount where MOCode in ('AccountHeadBudgetAssignment(PCC)') and MOCategory='Account Head Budget'
			       Select @Count= Count(*) from DCABudget db join Cost_Center cc on db.CCCode=cc.CC_Code where db.Status=@status and cc.CC_Code in (Select CCCode from @CClist)
				   if exists(Select * from UserCostCenters  where RoleId=@RoleID and UserId=@UserID and CCCode in(select cccode from dcabudget db join Cost_Center cc on cc.cc_code=db.cccode where db.status=@status and CC_Type='Performing'))
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyDCABudget' , MOCategory='Account Head Budget(PCC)' where MOCode in ('AccountHeadBudgetAssignment(PCC)') and Rowid=@ids			
				End
				Else
				Begin
				    select @status = Status from #Tempnotificationcount where MOCode in ('AccountHeadBudgetAssignment(PCC)') and MOCategory='Account Head Budget'
			        Select @Count= Count(*) from DCABudget db join Cost_Center cc on db.CCCode=cc.CC_Code where db.Status=@status and cc.CC_Type='Performing'				   
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyDCABudget' , MOCategory='Account Head Budget(PCC)' where MOCode in ('AccountHeadBudgetAssignment(PCC)') and Rowid=@ids			
				End			
		  
	     End
		if exists(Select * from #Tempnotificationcount where MOCode in ('AccountHeadBudgetAssignment(NPCC)') and MOCategory='Account Head Budget')
		  Begin 
			Set @Count=0; 
		    if(@RoleID!=108)
				Begin					   
					   select @status = Status from #Tempnotificationcount where MOCode in ('AccountHeadBudgetAssignment(NPCC)') and MOCategory='Account Head Budget'
					   Select @Count= Count(*) from DCABudget db join Cost_Center cc on db.CCCode=cc.CC_Code where db.Status=@status and CC_Type in ('Non-Performing','Capital')								
					   UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyDCABudget', MOCategory='Account Head Budget(NPCC)' where MOCode in ('AccountHeadBudgetAssignment(NPCC)') and Rowid=@ids			
				End	  
	     End
		--if exists(Select * from #Tempnotificationcount where MOCode='AccountHeadBudgetAssignment' and MOCategory='Account Head Budget')
		--  Begin	
		--	Set @Count=0; 			  
		--	select @status = Status from #Tempnotificationcount where MOCode='AccountHeadBudgetAssignment' and MOCategory='Account Head Budget'
		--	Select @Count= Count(*) from DCABudget where Status=@status
		--	UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyDCABudget' where MOCode='AccountHeadBudgetAssignment' and Rowid=@ids	
		--   End
		if exists(Select * from #Tempnotificationcount where MOCode in ('AccountHeadBudgetAmendment(PCC)') and MOCategory='Account Head Budget')
		  Begin	
		  Set @Count=0;  									
				if(@RoleID=108)
				Begin
				   select @status = Status from #Tempnotificationcount where MOCode in ('AccountHeadBudgetAmendment(PCC)') and MOCategory='Account Head Budget'
			       Select @Count= Count(*) from DCABudgetAmendment db join Cost_Center cc on db.CCCode=cc.CC_Code where db.Status=@status and cc.CC_Code in (Select CCCode from @CClist)
				   if exists(Select * from UserCostCenters  where RoleId=@RoleID and UserId=@UserID and CCCode in(select cc_code from Cost_Center where status=@status and CC_Type='Performing'))
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyDCABudgetAmend' , MOCategory='Account Head Amend Budget(PCC)' where MOCode in ('AccountHeadBudgetAmendment(PCC)') and Rowid=@ids			
				End
				Else
				Begin
				    select @status = Status from #Tempnotificationcount where MOCode in ('AccountHeadBudgetAmendment(PCC)') and MOCategory='Account Head Budget'
			        Select @Count= Count(*) from DCABudgetAmendment db join Cost_Center cc on db.CCCode=cc.CC_Code where db.Status=@status and cc.CC_Type='Performing'				   
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyDCABudgetAmend' , MOCategory='Account Head Amend Budget(PCC)' where MOCode in ('AccountHeadBudgetAmendment(PCC)') and Rowid=@ids			
				End			
		  
	     End
		if exists(Select * from #Tempnotificationcount where MOCode in ('AccountHeadBudgetAmendment(NPCC)') and MOCategory='Account Head Budget')
		  Begin 
			Set @Count=0; 
		    if(@RoleID!=108)
				Begin					   
					   select @status = Status from #Tempnotificationcount where MOCode in ('AccountHeadBudgetAmendment(NPCC)') and MOCategory='Account Head Budget'
					   Select @Count= Count(*) from DCABudgetAmendment db join Cost_Center cc on db.CCCode=cc.CC_Code where db.Status=@status and CC_Type in ('Non-Performing','Capital')								
					   UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyDCABudgetAmend', MOCategory='Account Head Amend Budget(NPCC)' where MOCode in ('AccountHeadBudgetAmendment(NPCC)') and Rowid=@ids			
				End	  
	     End
		--if exists(Select * from #Tempnotificationcount where MOCode='AccountHeadBudgetAmendment' and MOCategory='Account Head Budget Amend')
		--  Begin	
		--	Set @Count=0; 			  
		--	select @status = Status from #Tempnotificationcount where MOCode='AccountHeadBudgetAmendment' and MOCategory='Account Head Budget Amend'
		--	Select @Count= Count(*) from DCABudgetAmendment where Status=@status
		--	UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyDCABudgetAmend' where MOCode='AccountHeadBudgetAmendment' and Rowid=@ids	
		--   End
		if exists(Select * from #Tempnotificationcount where MOCode='GeneralInvoiceDebitFromOtherCostCenter' and MOCategory='General Invoice Payment')
		  Begin	
			Set @Count=0; 
				if(@RoleID=110)
				Begin
				   select @status = Status from #Tempnotificationcount where MOCode in ('GeneralInvoiceDebitFromOtherCostCenter') and MOCategory='General Invoice Payment'
			       Select @Count= Count(*) from CashBook  where VoucherType='General' and Status=@status and CCCode in (Select CCCode from @CClist)
				   if exists(Select * from UserCostCenters  where RoleId=@RoleID and UserId=@UserID and CCCode in(select CCCode from CashBook where status=@status and VoucherType='General'))
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyGeneralPayablebyCash', MOCategory='Cash Voucher'  where MOCode in ('GeneralInvoiceDebitFromOtherCostCenter') and Rowid=@ids			
				End
				Else
				Begin
					select @status = Status from #Tempnotificationcount where MOCode='GeneralInvoiceDebitFromOtherCostCenter' and MOCategory='General Invoice Payment'
					Select @Count= Count(*) from CashBook where VoucherType='General' and Status=@status
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyGeneralPayablebyCash', MOCategory='Cash Voucher' where MOCode='GeneralInvoiceDebitFromOtherCostCenter' and Rowid=@ids	
				End
		   End
		if exists(Select * from #Tempnotificationcount where MOCode='CostCentertoCostCenterCashTransfer' and MOCategory='General Invoice Payment')
		  Begin	
			Set @Count=0;
				if(@RoleID=110)
				Begin
				   select @status = Status from #Tempnotificationcount where MOCode in ('CostCentertoCostCenterCashTransfer') and MOCategory='General Invoice Payment'
			       Select @Count= Count(*) from CashBook  where VoucherType='CCTransfer' and Status=@status and CCCode in (Select CCCode from @CClist)
				   if exists(Select * from UserCostCenters  where RoleId=@RoleID and UserId=@UserID and CCCode in(select CCCode from CashBook where status=@status and VoucherType='CCTransfer'))
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyCCCashTransfer'  where MOCode in ('CostCentertoCostCenterCashTransfer') and Rowid=@ids			
				End
				Else
				Begin 			  
					select @status = Status from #Tempnotificationcount where MOCode='CostCentertoCostCenterCashTransfer' and MOCategory='General Invoice Payment'
					Select @Count= Count(*) from CashBook where VoucherType='CCTransfer' and Status=@status
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyCCCashTransfer' where MOCode='CostCentertoCostCenterCashTransfer' and Rowid=@ids	
				End
		   End
		if exists(Select * from #Tempnotificationcount where MOCode='ClientInvoiceCreation' and MOCategory='Client  Invoice')
		  Begin	
			Set @Count=0;
			if(@RoleID=108)
				Begin
				   select @status = Status from #Tempnotificationcount where MOCode in ('ClientInvoiceCreation') and MOCategory='Client  Invoice'
			       Select @Count= Count(*) from ClientInvoice where status=@status and CCCode in (Select CCCode from @CClist)
				   if exists(Select * from UserCostCenters  where RoleId=@RoleID and UserId=@UserID and CCCode in(Select CCCode from ClientInvoice where status=@status))
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyClientInvoice'  where MOCode in ('ClientInvoiceCreation') and Rowid=@ids			
				End
				Else
				Begin
				    select @status = Status from #Tempnotificationcount where MOCode in ('ClientInvoiceCreation') and MOCategory='Client  Invoice'
			        Select @Count= Count(*) from ClientInvoice where Status=@status			   
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyClientInvoice' where MOCode in ('ClientInvoiceCreation') and Rowid=@ids			
				End		 			  
			--select @status = Status from #Tempnotificationcount where MOCode='ClientInvoiceCreation' and MOCategory='Client Invoice'
			--Select @Count= Count(*) from ClientInvoice where Status=@status
			--UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyClientInvoice' where MOCode='ClientInvoiceCreation' and Rowid=@ids	
		   End
		if exists(Select * from #Tempnotificationcount where MOCode='ClientRecievableInvoiceServicePayment' and MOCategory='Client Payment')
		  Begin	
			Set @Count=0;
			if(@RoleID=108)
				Begin
				   select @status = Status from #Tempnotificationcount where MOCode in ('ClientRecievableInvoiceServicePayment') and MOCategory='Client Payment'
			       Select @Count= count(*) from BankTransactions bt
                                             inner join PaymentType pt on bt.TypeOfTransactionId=pt.PaymentTypeID
                                             inner join BankTransactionsLog bl on bt.TransactionRefNo= bl.TransactionRefNo
                                             inner join ClientInvoice ci on bl.No= ci.ClientInvoiceNo
                                             inner join BankDetails bd on bt.BankID= bd.BankId
                                             where pt.PaymentTypeName= 'Invoice Service' and TransactionStatus=@status and  ci.CCCode in (Select CCCode from @CClist)
				   if exists(Select * from UserCostCenters  where RoleId=@RoleID and UserId=@UserID and CCCode in(Select ci.CCCode from BankTransactions bt
                                             inner join PaymentType pt on bt.TypeOfTransactionId=pt.PaymentTypeID
                                             inner join BankTransactionsLog bl on bt.TransactionRefNo= bl.TransactionRefNo
                                             inner join ClientInvoice ci on bl.No= ci.ClientInvoiceNo
                                             inner join BankDetails bd on bt.BankID= bd.BankId
                                             where bt.TransactionStatus not in ('Approved','Rejected') and pt.PaymentTypeName= 'Invoice Service' and TransactionStatus=@status))
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyClientRecievable'  where MOCode in ('ClientRecievableInvoiceServicePayment') and Rowid=@ids			
				End
				Else
				Begin
				    select @status = Status from #Tempnotificationcount where MOCode in ('ClientRecievableInvoiceServicePayment') and MOCategory='Client Payment'
			        Select @Count= count(bt.TransactionRefNo) from BankTransactions bt where bt.TransactionStatus=@status and TypeOfTransactionId=(Select PaymentTypeID from PaymentType where PaymentTypeName='Invoice Service')				   
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyClientRecievable' where MOCode in ('ClientRecievableInvoiceServicePayment') and Rowid=@ids			
				End	
		   End
		if exists(Select * from #Tempnotificationcount where MOCode='ClientRecievableAdvancePayment' and MOCategory='Client Payment')
		  Begin	
			Set @Count=0; 
			if(@RoleID=108)
				Begin
				   select @status = Status from #Tempnotificationcount where MOCode in ('ClientRecievableAdvancePayment') and MOCategory='Client Payment'
			       Select @Count= count(*) from BankTransactions bt
                                             inner join PaymentType pt on bt.TypeOfTransactionId=pt.PaymentTypeID
                                             inner join BankTransactionsLog bl on bt.TransactionRefNo= bl.TransactionRefNo
                                             inner join ClientInvoice ci on bl.No= ci.ClientInvoiceNo
                                             inner join BankDetails bd on bt.BankID= bd.BankId
                                             where bt.TransactionStatus not in ('Approved','Rejected') and pt.PaymentTypeName= 'Advance' and TransactionStatus=@status and  ci.CCCode in (Select CCCode from @CClist)
				   if exists(Select * from UserCostCenters  where RoleId=@RoleID and UserId=@UserID and CCCode in(Select ci.CCCode from BankTransactions bt
                                             inner join PaymentType pt on bt.TypeOfTransactionId=pt.PaymentTypeID
                                             inner join BankTransactionsLog bl on bt.TransactionRefNo= bl.TransactionRefNo
                                             inner join ClientInvoice ci on bl.No= ci.ClientInvoiceNo
                                             inner join BankDetails bd on bt.BankID= bd.BankId
                                             where bt.TransactionStatus not in ('Approved','Rejected') and pt.PaymentTypeName= 'Advance' and TransactionStatus=@status))
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyAdvancePayment'  where MOCode in ('ClientRecievableAdvancePayment') and Rowid=@ids			
				End
				Else
				Begin
				    select @status = Status from #Tempnotificationcount where MOCode in ('ClientRecievableAdvancePayment') and MOCategory='Client Payment'
					Select @Count= count(bt.TransactionRefNo) from BankTransactions bt where bt.TransactionStatus=@status and TypeOfTransactionId=(Select PaymentTypeID from PaymentType where PaymentTypeName='Advance')									
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyAdvancePayment' where MOCode in ('ClientRecievableAdvancePayment') and Rowid=@ids			
				End				  
		   End
		if exists(Select * from #Tempnotificationcount where MOCode='ClientRecievableRetentionPayment' and MOCategory='Client Payment')
		  Begin	
			Set @Count=0; 
			if(@RoleID=108)
				Begin
				   select @status = Status from #Tempnotificationcount where MOCode in ('ClientRecievableRetentionPayment') and MOCategory='Client Payment'
			       Select @Count= count(*) from BankTransactions bt
                                             inner join PaymentType pt on bt.TypeOfTransactionId=pt.PaymentTypeID
                                             inner join BankTransactionsLog bl on bt.TransactionRefNo= bl.TransactionRefNo
                                             inner join ClientInvoice ci on bl.No= ci.ClientInvoiceNo
                                             inner join BankDetails bd on bt.BankID= bd.BankId
                                             where bt.TransactionStatus not in ('Approved','Rejected') and pt.PaymentTypeName= 'Retention' and TransactionStatus=@status and  ci.CCCode in (Select CCCode from @CClist)
				   if exists(Select * from UserCostCenters  where RoleId=@RoleID and UserId=@UserID and CCCode in(Select ci.CCCode from BankTransactions bt
                                             inner join PaymentType pt on bt.TypeOfTransactionId=pt.PaymentTypeID
                                             inner join BankTransactionsLog bl on bt.TransactionRefNo= bl.TransactionRefNo
                                             inner join ClientInvoice ci on bl.No= ci.ClientInvoiceNo
                                             inner join BankDetails bd on bt.BankID= bd.BankId
                                             where bt.TransactionStatus not in ('Approved','Rejected') and pt.PaymentTypeName= 'Retention' and TransactionStatus=@status))
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyRetentionPayment'  where MOCode in ('ClientRecievableRetentionPayment') and Rowid=@ids			
				End
				Else
				Begin
				    select @status = Status from #Tempnotificationcount where MOCode in ('ClientRecievableAdvancePayment') and MOCategory='Client Payment'
					Select @Count= count(bt.TransactionRefNo) from BankTransactions bt where bt.TransactionStatus=@status and TypeOfTransactionId=(Select PaymentTypeID from PaymentType where PaymentTypeName='Retention')									
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyRetentionPayment' where MOCode in ('ClientRecievableRetentionPayment') and Rowid=@ids			
				End		
						  
			------select @status = Status from #Tempnotificationcount where MOCode='ClientRecievableRetentionPayment' and MOCategory='Client Payment'
			------Select @Count= count(bt.TransactionRefNo) from BankTransactions bt where bt.TransactionStatus=@status and TypeOfTransactionId=(Select PaymentTypeID from PaymentType where PaymentTypeName='Retention')									
			--Select @Count= count(bt.TransactionRefNo)from BankTransactions bt join BankTransactionsLog btl on bt.TransactionRefNo=btl.TransactionRefNo
			--			   Inner join BankDetails bd on bt.BankID=bd.BankId Inner join ClientInvoice ci on btl.no=ci.ClientInvoiceNo where bt.TransactionStatus=@status									    
			--			  and TypeOfTransactionId=(Select PaymentTypeID from PaymentType where PaymentTypeName='Retention')										
			------UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyRetentionPayment' where MOCode='ClientRecievableRetentionPayment' and Rowid=@ids	
		   End
		if exists(Select * from #Tempnotificationcount where MOCode='ClientRecievableHoldPayment' and MOCategory='Client Payment')
		  Begin	
			Set @Count=0; 	
			if(@RoleID=108)
				Begin
				   select @status = Status from #Tempnotificationcount where MOCode in ('ClientRecievableHoldPayment') and MOCategory='Client Payment'
			       Select @Count= count(*) from BankTransactions bt
                                             inner join PaymentType pt on bt.TypeOfTransactionId=pt.PaymentTypeID
                                             inner join BankTransactionsLog bl on bt.TransactionRefNo= bl.TransactionRefNo
                                             inner join ClientInvoice ci on bl.No= ci.ClientInvoiceNo
                                             inner join BankDetails bd on bt.BankID= bd.BankId
                                             where bt.TransactionStatus not in ('Approved','Rejected') and pt.PaymentTypeName= 'Hold' and TransactionStatus=@status and  ci.CCCode in (Select CCCode from @CClist)
				   if exists(Select * from UserCostCenters  where RoleId=@RoleID and UserId=@UserID and CCCode in(Select ci.CCCode from BankTransactions bt
                                             inner join PaymentType pt on bt.TypeOfTransactionId=pt.PaymentTypeID
                                             inner join BankTransactionsLog bl on bt.TransactionRefNo= bl.TransactionRefNo
                                             inner join ClientInvoice ci on bl.No= ci.ClientInvoiceNo
                                             inner join BankDetails bd on bt.BankID= bd.BankId
                                             where bt.TransactionStatus not in ('Approved','Rejected') and pt.PaymentTypeName= 'Hold' and TransactionStatus=@status))
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyHoldPayment'  where MOCode in ('ClientRecievableRetentionPayment') and Rowid=@ids			
				End
				Else
				Begin
				    select @status = Status from #Tempnotificationcount where MOCode in ('ClientRecievableHoldPayment') and MOCategory='Client Payment'
					Select @Count= count(bt.TransactionRefNo) from BankTransactions bt where bt.TransactionStatus=@status and TypeOfTransactionId=(Select PaymentTypeID from PaymentType where PaymentTypeName='Hold')									
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyHoldPayment' where MOCode in ('ClientRecievableRetentionPayment') and Rowid=@ids			
				End				  
			------select @status = Status from #Tempnotificationcount where MOCode='ClientRecievableHoldPayment' and MOCategory='Client Payment'
			------Select @Count= count(bt.TransactionRefNo) from BankTransactions bt where bt.TransactionStatus=@status and TypeOfTransactionId=(Select PaymentTypeID from PaymentType where PaymentTypeName='Hold')									
			--------Select @Count= count(bt.TransactionRefNo) from BankTransactions bt where bt.TransactionStatus=@status and TypeOfTransactionId=(Select PaymentTypeID from PaymentType where PaymentTypeName='Hold')									
			------UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyHoldPayment' where MOCode='ClientRecievableHoldPayment' and Rowid=@ids	
		   End
		if exists(Select * from #Tempnotificationcount where MOCode='GeneralPayable' and MOCategory='General Payment')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='GeneralPayable' and MOCategory='General Payment'
			Select @Count= count(BankTransactionId) from GeneralPayment gp join BankTransactions bt on gp.TransactionRefNo=bt.TransactionRefNo
                                          where TypeOfTransactionId=6 and TransactionStatus=@status								
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyGeneralPayment' where MOCode='GeneralPayable' and Rowid=@ids	
		   End
		if exists(Select * from #Tempnotificationcount where MOCode='BankWithdrawal' and MOCategory='Withdraw')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='BankWithdrawal' and MOCategory='Withdraw'
			Select @Count=count(distinct bt.BankTransactionId) from BankTransactions bt join BankTransactionsLog btl on bt.TransactionRefNo=btl.TransactionRefNo 
					    join BankDetails bd on bd.BankId=bt.BankID join PaymentType pt on pt.PaymentTypeID=bt.TypeOfTransactionId 
						where bt.TransactionStatus not in ('Approved','Rejected') and bt.TransactionStatus=@status	 and  pt.PaymentTypeName='Withdraw'							
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyBankWithdrawn' where MOCode='BankWithdrawal' and Rowid=@ids	
		   End
		if exists(Select * from #Tempnotificationcount where MOCode='Deposit' and MOCategory='Deposit')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='Deposit' and MOCategory='Deposit'
			Select @Count=count(distinct BankTransactionId) FROM BankTransactions BT JOIN BankDetails BD ON BT.BankID=BD.BankId JOIN BankTransactionsLog BTL ON BTL.TransactionRefNo=BT.TransactionRefNo 
						 WHERE TransactionStatus=@status and TypeOfTransactionId='9'							
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyBankDeposit' where MOCode='Deposit' and Rowid=@ids	
		   End
		if exists(Select * from #Tempnotificationcount where MOCode='BankToBankTransfer' and MOCategory='Transfer')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='BankToBankTransfer' and MOCategory='Transfer'
			Select @Count=count(distinct bt.TransactionRefNo)  from BankDetails bd join BankTransactions bt on bd.BankId= bt.BankID  where 
						  TransactionStatus not in ('Approved','Rejected') and TransactionStatus=@status and TypeOfTransactionId=10						
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyBankTransfer' where MOCode='BankToBankTransfer' and Rowid=@ids	
		   End
	    if exists(Select * from #Tempnotificationcount where MOCode='RefundWork' and MOCategory='Refund')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='RefundWork' and MOCategory='Refund'
			Select @Count=Count(DISTINCT m.TransactionRefNo) from Refund m join Cost_Center cc on m.CCCode=cc.CC_Code 
							join DCA d on d.DCACode=m.DCA join SubDCA sd on sd.SubDCACode=m.SDCA where m.PaymentType='Principle' and m.Status=@status					
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyRefund' where MOCode='RefundWork' and Rowid=@ids	
		   End		
		if exists(Select * from #Tempnotificationcount where MOCode='UnsecuredLoanNew' and MOCategory='UnsecuredLoanNew')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='UnsecuredLoanNew' and MOCategory='UnsecuredLoanNew'
			Select @Count=count(bt.TransactionRefNo)  from BankTransactions bt join UnsecuredLoan ul on bt.TransactionRefNo=ul.TransactionRefNo where 	 
  	                      TypeOfTransactionId=(Select PaymentTypeID from PaymentType where PaymentTypeName='UnsecuredLoanNew') and TransactionStatus=@status					
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyUnsecuredLoan', MOCategory='UnsecuredLoan(New)' where MOCode='UnsecuredLoanNew' and Rowid=@ids	
		   End
		if exists(Select * from #Tempnotificationcount where MOCode='UnsecuredLoanExisting' and MOCategory='UnsecuredLoanExisting')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='UnsecuredLoanExisting' and MOCategory='UnsecuredLoanExisting'
			Select @Count=count(bt.TransactionRefNo)  from BankTransactions bt join UnsecuredLoan ul on bt.TransactionRefNo=ul.TransactionRefNo where 	 
  	                      TypeOfTransactionId=(Select PaymentTypeID from PaymentType where PaymentTypeName='UnsecuredLoanExisting') and TransactionStatus=@status					
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyUnsecuredLoanExisting', MOCategory='UnsecuredLoan(Existing)' where MOCode='UnsecuredLoanExisting' and Rowid=@ids	
		   End
		if exists(Select * from #Tempnotificationcount where MOCode='UnsecuredLoanReturn' and MOCategory='UnsecuredLoanReturn')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='UnsecuredLoanReturn' and MOCategory='UnsecuredLoanReturn'
			Select @Count=count(bt.TransactionRefNo)  from BankTransactions bt join UnsecuredLoan ul on bt.TransactionRefNo=ul.TransactionRefNo where 	 
  	                      TypeOfTransactionId=(Select PaymentTypeID from PaymentType where PaymentTypeName='UnsecuredLoanReturn') and TransactionStatus=@status					
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyUnsecuredLoanReturn', MOCategory='UnsecuredLoan(Return)' where MOCode='UnsecuredLoanReturn' and Rowid=@ids	
		   End
		if exists(Select * from #Tempnotificationcount where MOCode='MiscellaneousClient' and MOCategory='Misc' and MOID=174)
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode in ('MiscellaneousClient') and MOCategory='Misc'and MOID=174
			Select @Count=COUNT(DISTINCT m.TransactionRefNo) from Miscellaneous m join Cost_Center cc on m.CCCode=cc.CC_Code 
				join DCA d on d.DCACode=m.DCA join SubDCA sd on sd.SubDCACode=m.SDCA where m.Type='Interest' and m.Status=@status	and m.WorkFlowLevelId=174				
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyMisc',MOCategory='MiscClient' where MOCode in ('MiscellaneousClient') and Rowid=@ids	 and MOID=174
		   End
		 if exists(Select * from #Tempnotificationcount where MOCode='MiscellaneousOthers' and MOCategory='Misc' and MOID=230)
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode in ('MiscellaneousOthers') and MOCategory='Misc'and MOID=230
			Select @Count=COUNT(DISTINCT m.TransactionRefNo) from Miscellaneous m join Cost_Center cc on m.CCCode=cc.CC_Code 
				join DCA d on d.DCACode=m.DCA join SubDCA sd on sd.SubDCACode=m.SDCA where m.Type='Interest' and m.Status=@status and m.WorkFlowLevelId=230				
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyMisc',MOCategory='MiscOthers' where MOCode in ('MiscellaneousOthers') and Rowid=@ids	  and MOID=230
		   End
		if exists(Select * from #Tempnotificationcount where MOCode='ClientCreation ' and MOCategory='Client')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='ClientCreation ' and MOCategory='Client'
			Select @Count=COUNT(ClientID) from Client c  inner join NatureOfGroup ng on c.NatureGroupId=ng.NatureGroupId where c.Status=@status					
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyClient' where MOCode='ClientCreation ' and Rowid=@ids	
		   End
		if exists(Select * from #Tempnotificationcount where MOCode='FDOpen' and MOCategory='FD')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='FDOpen' and MOCategory='FD'
			Select @Count=COUNT(fd.TransactionRefNo) from FixedDeposit fd join BankTransactions bt on bt.TransactionRefNo=fd.TransactionRefNo where Status=@status and FDType='NewFD'					
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyOpenFD' where MOCode='FDOpen' and Rowid=@ids	
		   End
		if exists(Select * from #Tempnotificationcount where MOCode='FDClose' and MOCategory='FD')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='FDClose' and MOCategory='FD'
			--Select @Count= COUNT(fd.TransactionRefNo) from FixedDeposit fd join BankTransactions bt on bt.TransactionRefNo=fd.TransactionRefNo where FDType='Close' and status=@status
			Select @Count=count( bt.TransactionRefNo) from BankTransactions bt  join BankTransactionsLog bl on bt.TransactionRefNo=bl.TransactionRefNo 
											inner join FixedDeposit fd on fd.FDRNumber=bl.No where  FDRNumber  in (Select distinct FDRNumber from FDPayments where bt.TypeOfTransactionId=(Select PaymentTypeID from PaymentType where PaymentTypeName='FDClose') and 
                                            TransactionStatus not in ('Approved','Rejected') and TransactionStatus =@status)
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyCloseFD' where MOCode='FDClose' and Rowid=@ids	
		   End
		if exists(Select * from #Tempnotificationcount where MOCode='FDPartial' and MOCategory='FD')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='FDPartial' and MOCategory='FD'
			--Select @Count=COUNT(fd.TransactionRefNo) from FixedDeposit fd join BankTransactions bt on bt.TransactionRefNo=fd.TransactionRefNo where FDType='Partial' and status=@status
			Select   @Count= count(bt.TransactionRefNo) from BankTransactions bt  join BankTransactionsLog bl on bt.TransactionRefNo=bl.TransactionRefNo 
           inner join FixedDeposit fd on fd.FDRNumber=bl.No where bt.TypeOfTransactionId=(Select PaymentTypeID from PaymentType where PaymentTypeName='FDPartial') and 
                                            TransactionStatus not in ('Approved','Rejected') and TransactionStatus =@Status
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyPartialFD' where MOCode='FDPartial' and Rowid=@ids	
		   End
		if exists(Select * from #Tempnotificationcount where MOCode='FDInterest' and MOCategory='FD')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='FDInterest' and MOCategory='FD'
			Select @Count= COUNT(bt.TransactionRefNo) from FDMonthlyInterest fmi join BankTransactions bt on bt.TransactionRefNo=fmi.TransactionRefNo
						 where TransactionStatus=@status and TypeOfTransactionId=(select PaymentTypeID from  PaymentType where PaymentTypeName='FDInterest')
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyFDInterest' where MOCode='FDInterest' and Rowid=@ids	
		   End
		if exists(Select * from #Tempnotificationcount where MOCode='BankChequeCreation' and MOCategory='Cheque')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='BankChequeCreation' and MOCategory='Cheque'
			Select @Count= COUNT(*) from cheque_Master cm where cm.Status=@status
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyCheque' where MOCode='BankChequeCreation' and Rowid=@ids	
		   End
		if exists(Select * from #Tempnotificationcount where MOCode='CentralDayBook' and MOCategory='CentralDayBook')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='CentralDayBook' and MOCategory='CentralDayBook'
			Select @Count= COUNT(*) from CashTransfer  where TransactionStatus=@status
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyCentralDayBook' where MOCode='CentralDayBook' and Rowid=@ids	
		   End
		if exists(Select * from #Tempnotificationcount where MOCode='CloseIT' and MOCategory='Close IT')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='CloseIT' and MOCategory='Close IT'
			Select @Count= COUNT(*) from ClosingDetails  where Status=@status and ClosingTypeId=(Select ClosingTypeId from ClosingType where ClosingTypeName='IT')
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Home/VerifyCloseIT' where MOCode='CloseIT' and Rowid=@ids	
		   End
		if exists(Select * from #Tempnotificationcount where MOCode='CloseBankAccount' and MOCategory='Close Bank A/C')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='CloseBankAccount' and MOCategory='Close Bank A/C'
			Select @Count= COUNT(*) from ClosingDetails  where Status=@status and ClosingTypeId=(Select ClosingTypeId from ClosingType where ClosingTypeName='BankAccount')
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Home/VerifyCloseBank' where MOCode='CloseBankAccount' and Rowid=@ids	
		   End		
		if exists(Select * from #Tempnotificationcount where MOCode='CloseAccountHead' and MOCategory='Close Account Head')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='CloseAccountHead' and MOCategory='Close Account Head'
			Select @Count= COUNT(*) from ClosingDetails  where Status=@status and ClosingTypeId=(Select ClosingTypeId from ClosingType where ClosingTypeName='DCA')
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Home/VerifyCloseDCA' where MOCode='CloseAccountHead' and Rowid=@ids	
		   End
		if exists(Select * from #Tempnotificationcount where MOCode='CloseSubAccountHead' and MOCategory='Close Sub Account Head')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='CloseSubAccountHead' and MOCategory='Close Sub Account Head'
			Select @Count= COUNT(*) from ClosingDetails  where Status=@status and ClosingTypeId=(Select ClosingTypeId from ClosingType where ClosingTypeName='SubDCA')
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Home/VerifyCloseSubDCA' where MOCode='CloseSubAccountHead' and Rowid=@ids	
		   End
		if exists(Select * from #Tempnotificationcount where MOCode='CloseClient' and MOCategory='Close Client')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='CloseClient' and MOCategory='Close Client'
			Select @Count= COUNT(*) from ClosingDetails  where Status=@status and ClosingTypeId=(Select ClosingTypeId from ClosingType where ClosingTypeName='Client')
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Home/VerifyCloseClient' where MOCode='CloseClient' and Rowid=@ids	
		   End
		if exists(Select * from #Tempnotificationcount where MOCode='CloseSubClient' and MOCategory='Close SubClient')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='CloseSubClient' and MOCategory='Close SubClient'
			Select @Count= COUNT(*) from ClosingDetails  where Status=@status and ClosingTypeId=(Select ClosingTypeId from ClosingType where ClosingTypeName='SubClient')
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Home/VerifyCloseSubClient' where MOCode='CloseSubClient' and Rowid=@ids	
		   End
		    	if exists(Select * from #Tempnotificationcount where MOCode='CloseTLAgency' and MOCategory='CloseTLAgency')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='CloseTLAgency' and MOCategory='CloseTLAgency'
			Select @Count= COUNT(*) from ClosingDetails  where Status=@status and ClosingTypeId=(Select ClosingTypeId from ClosingType where ClosingTypeName='TermLoanAgency')
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Home/VerifyCloseTLAgency' where MOCode='CloseTLAgency' and Rowid=@ids	
		   End
		if exists(Select * from #Tempnotificationcount where MOCode='UserCreation' and MOCategory='User')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='UserCreation' and MOCategory='User'
			Select @Count= COUNT(*) from Users  where Status=@status 
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyUsers' where MOCode='UserCreation' and Rowid=@ids	
		   End	
	   if exists(Select * from #Tempnotificationcount where MOCode='JournalVoucher' and MOCategory='JV')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='JournalVoucher' and MOCategory='JV'
			Select @Count= COUNT(*) from JVDetails  where Status=@status 
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyJournalVoucher',MOCategory='JV Verification' where MOCode='JournalVoucher' and Rowid=@ids	
		   End	
	   if exists(Select * from #Tempnotificationcount where MOCode='TermLoanAgencyCreation' and MOCategory='TLAgencyCreation')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='TermLoanAgencyCreation' and MOCategory='TLAgencyCreation'
			Select @Count= Count(*) from TermLoanAgency where Status=@status
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyTermLoanAgency' ,MOCategory='TL Agency Verification' where MOCode='TermLoanAgencyCreation' and Rowid=@ids	
		   End	
	   if exists(Select * from #Tempnotificationcount where MOCode='TermLoanCreation' and MOCategory='TermLoanCreation')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='TermLoanCreation' and MOCategory='TermLoanCreation'
			Select @Count= Count(*) from TermLoanCreation where Status=@status
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyTermLoan' ,MOCategory='Term Loan Verification' where MOCode='TermLoanCreation' and Rowid=@ids	
		   End  
		if exists(Select * from #Tempnotificationcount where MOCode='TermLoanSelfDebit' and MOCategory='TermLoanDebit')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='TermLoanSelfDebit' and MOCategory='TermLoanDebit'
			Select @Count= Count(*) from BankTransactions where TransactionStatus=@status and WorkFlowLevelId=246 and TypeOfTransactionId=25
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyTermLoanPayment' ,MOCategory='TLPayment Verification' where MOCode='TermLoanSelfDebit' and Rowid=@ids	
		   End 
		if exists(Select * from #Tempnotificationcount where MOCode='ItemCodeCreation' and MOCategory='ItemCodeCreation')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='ItemCodeCreation' and MOCategory='ItemCodeCreation'
			Select @Count= Count(*) from ItemCodes where Status=@status
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Purchase/VerifyItemCodeCreation' ,MOCategory='Item Code Verification' where MOCode='ItemCodeCreation' and Rowid=@ids	
		   End   
		if exists(Select * from #Tempnotificationcount where MOCode='HSNCodeCreation' and MOCategory='HSNCodeCreation')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='HSNCodeCreation' and MOCategory='HSNCodeCreation'
			Select @Count= Count(*) from HSNSACCodes where Status=@status
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Purchase/VerifyHSNCreation' ,MOCategory='HSN/SAC Code Verification' where MOCode='HSNCodeCreation' and Rowid=@ids	
		   End
		   
		if exists(Select * from #Tempnotificationcount where MOCode='VendorCreation' and MOCategory='VendorCreation')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='VendorCreation' and MOCategory='VendorCreation'
			Select @Count= Count(*) from VendorDetails where Status=@status
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Purchase/VerifyVendor' ,MOCategory='Vendor Verification' where MOCode='VendorCreation' and Rowid=@ids	
		   End  
		   if exists(Select * from #Tempnotificationcount where MOCode in ('SPPOCreation(PCC)') and MOCategory='SPPOCreation(PCC)')
		  Begin	
		  Set @Count=0;  									
				if(@RoleID=108)
				Begin
				   select @status = Status from #Tempnotificationcount where MOCode in ('SPPOCreation(PCC)') and MOCategory='SPPOCreation(PCC)'
			       Select @Count= Count(*) from SPPODetails where Status=@status and CCCode in (Select CCCode from @CClist)
				   if exists(Select * from UserCostCenters  where RoleId=@RoleID and UserId=@UserID and CCCode in(select cc_code from Cost_Center where status='Approved' and CC_Type='Performing'))
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Purchase/VerifySPPO' , MOCategory='SPPO Verification' where MOCode in ('SPPOCreation(PCC)') and Rowid=@ids			
				End
				Else
				Begin
				    select @status = Status from #Tempnotificationcount where MOCode in ('SPPOCreation(PCC)') and MOCategory='SPPOCreation(PCC)'
			        Select @Count= Count(S.SPPOId) from  SPPODetails  S join  Cost_Center c on c.CC_Code=s.CCCode where S.Status=@status and CC_Type='Performing'				   
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Purchase/VerifySPPO' , MOCategory='SPPO Verification' where MOCode in ('SPPOCreation(PCC)') and Rowid=@ids			
				End			
		  
	     End
		 if exists(Select * from #Tempnotificationcount where MOCode in ('SPPOAmendment(PCC)') and MOCategory='SPPOAmendment(PCC)')
		  Begin	
		  Set @Count=0;  									
				if(@RoleID=108) --108 for projectmanager 
				Begin
				   select @status = Status from #Tempnotificationcount where MOCode in ('SPPOAmendment(PCC)') and MOCategory='SPPOAmendment(PCC)'
			       Select @Count= Count(SA.SPPOAmendId) from SPPOAmend SA join SPPODetails S on S.SPPONo=SA.SPPONo where SA.Status=@status and CCCode in (Select CCCode from @CClist)
				   if exists(Select * from UserCostCenters  where RoleId=@RoleID and UserId=@UserID and CCCode in(select cc_code from Cost_Center where status='Approved' and CC_Type='Performing'))
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Purchase/VerifySPPOAmend' , MOCategory='Amend SPPO Verification' where MOCode in ('SPPOAmendment(PCC)') and Rowid=@ids			
				End
				Else
				Begin
				    select @status = Status from #Tempnotificationcount where MOCode in ('SPPOAmendment(PCC)') and MOCategory='SPPOAmendment(PCC)'
			        Select @Count= Count(SA.SPPOAmendId) from  SPPOAmend SA join SPPODetails S on S.SPPONo=SA.SPPONo join  Cost_Center c on c.CC_Code=s.CCCode where SA.Status=@status and CC_Type='Performing'				   
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Purchase/VerifySPPOAmend' , MOCategory='Amend SPPO Verification' where MOCode in ('SPPOAmendment(PCC)') and Rowid=@ids			
				End			
		  
	     End
		 if exists(Select * from #Tempnotificationcount where MOCode in ('Procurement(PCC)') and MOCategory='Procurement(PCC)')
		  Begin	
		  Set @Count=0;  									
				if(@RoleID=108 or @RoleID=122)--108 for projectmanger and 122 for StoreKepper || local storekeeper is 114
				Begin
				   select @status = Status from #Tempnotificationcount where MOCode in ('Procurement(PCC)') and MOCategory='Procurement(PCC)'
			       Select @Count= Count(*) from Indents where Status=@status and CCCode in (Select CCCode from @CClist)
				   if exists(Select * from UserCostCenters  where RoleId=@RoleID and UserId=@UserID and CCCode in(select cc_code from Cost_Center where status='Approved' and CC_Type='Performing'))
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Purchase/VerifyIndentCreation' , MOCategory='Procurement (PCC)' where MOCode in ('Procurement(PCC)') and Rowid=@ids			
				End
				Else
				Begin
				    select @status = Status from #Tempnotificationcount where MOCode in ('Procurement(PCC)') and MOCategory='Procurement(PCC)'
			        Select @Count= Count(*) from Indents i join Cost_Center c on c.CC_Code=i.CCCode where i.Status=@status and CC_Type='Performing'				   
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Purchase/VerifyIndentCreation' , MOCategory='Procurement (PCC)' where MOCode in ('Procurement(PCC)') and Rowid=@ids			
				End			
		  
	     End
		 if exists(Select * from #Tempnotificationcount where MOCode in ('Procurement(NPCC)') and MOCategory='Procurement(NPCC)')
		  Begin	
		  Set @Count=0;  									
				if(@RoleID=108 or @RoleID=122) --108 for projectmanger and 122 for StoreKepper || local storekeeper is 114
				Begin
				   select @status = Status from #Tempnotificationcount where MOCode in ('Procurement(NPCC)') and MOCategory='Procurement(NPCC)'
			       Select @Count= Count(*) from Indents where Status=@status and CCCode in (Select CCCode from @CClist)
				   if exists(Select * from UserCostCenters  where RoleId=@RoleID and UserId=@UserID and CCCode in(select cc_code from Cost_Center where status='Approved' and CC_Type!='Performing'))
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Purchase/VerifyIndentCreation' , MOCategory='Procurement (NPCC)' where MOCode in ('Procurement(NPCC)') and Rowid=@ids			
				End
				Else
				Begin
				    select @status = Status from #Tempnotificationcount where MOCode in ('Procurement(NPCC)') and MOCategory='Procurement(NPCC)'
			        Select @Count= Count(*) from Indents i join Cost_Center c on c.CC_Code=i.CCCode where i.Status=@status and CC_Type!='Performing'				   
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Purchase/VerifyIndentCreation' , MOCategory='Procurement (NPCC)' where MOCode in ('Procurement(NPCC)') and Rowid=@ids			
				End	
	      End
		  if exists(Select * from #Tempnotificationcount where MOCode in ('StockTransfer(PCC)') and MOCategory='StockTransfer(PCC)')
		  Begin	
		  Set @Count=0;  									
				if(@RoleID=108 or @RoleID=122) --108 for projectmanger and 122 for StoreKepper || local storekeeper is 114
				Begin
				   select @status = Status from #Tempnotificationcount where MOCode in ('StockTransfer(PCC)') and MOCategory='StockTransfer(PCC)'
			       Select @Count= Count(*) from TransferInfo where Status=@status and CCCode in (Select CCCode from @CClist)
				   if exists(Select * from UserCostCenters  where RoleId=@RoleID and UserId=@UserID and CCCode in(select cc_code from Cost_Center where status='Approved' and CC_Type ='Performing'))
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Purchase/VerifyItemsTransfer' , MOCategory='StockTransfer (PCC)' where MOCode in ('StockTransfer(PCC)') and Rowid=@ids			
				End
				Else
				Begin
				    select @status = Status from #Tempnotificationcount where MOCode in ('StockTransfer(PCC)') and MOCategory='StockTransfer(PCC)'
			        Select @Count= Count(*) from TransferInfo i join Cost_Center c on c.CC_Code=i.CCCode where i.Status=@status and CC_Type='Performing'				   
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Purchase/VerifyItemsTransfer' , MOCategory='StockTransfer (PCC)' where MOCode in ('StockTransfer(PCC)') and Rowid=@ids			
				End	
	      End
		   if exists(Select * from #Tempnotificationcount where MOCode in ('StockTransfer(NPCC)') and MOCategory='StockTransfer(NPCC)')
		  Begin	
		  Set @Count=0;  									
				if(@RoleID=108 or @RoleID=122) --108 for projectmanger and 122 for StoreKepper || local storekeeper is 114
				Begin
				   select @status = Status from #Tempnotificationcount where MOCode in ('StockTransfer(NPCC)') and MOCategory='StockTransfer(NPCC)'
			       Select @Count= Count(*) from TransferInfo where Status=@status and CCCode in (Select CCCode from @CClist)
				   if exists(Select * from UserCostCenters  where RoleId=@RoleID and UserId=@UserID and CCCode in(select cc_code from Cost_Center where status='Approved' and CC_Type!='Performing'))
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Purchase/VerifyItemsTransfer' , MOCategory='StockTransfer (NPCC)' where MOCode in ('StockTransfer(NPCC)') and Rowid=@ids			
				End
				--Else if(@RoleID=112)
				--Begin
				--    select @status = Status from #Tempnotificationcount where MOCode in ('StockTransfer(NPCC)') and MOCategory='StockTransfer(NPCC)'
			 --       Select @Count= Count(*) from TransferInfo i join Cost_Center c on c.CC_Code=i.CCCode where i.Status=@status and i.Status is null and CC_Type!='Performing'				   
				--	UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Purchase/VerifyItemsTransfer' , MOCategory='StockTransfer (NPCC)' where MOCode in ('StockTransfer(NPCC)') and Rowid=@ids			
				--End	
				Else
				Begin
				    select @status = Status from #Tempnotificationcount where MOCode in ('StockTransfer(NPCC)') and MOCategory='StockTransfer(NPCC)'
			        Select @Count= Count(*) from TransferInfo i join Cost_Center c on c.CC_Code=i.CCCode where i.Status=@status and CC_Type!='Performing'				   
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Purchase/VerifyItemsTransfer' , MOCategory='StockTransfer (NPCC)' where MOCode in ('StockTransfer(NPCC)') and Rowid=@ids			
				End	
	      End
		    if exists(Select * from #Tempnotificationcount where MOCode in ('MRR(PCC)') and MOCategory='MRR(PCC)')
		  Begin	
		  Set @Count=0;  									
				if(@RoleID=108 or @RoleID=122) --108 for projectmanger and 122 for StoreKepper || local storekeeper is 114
				Begin
				   select @status = Status from #Tempnotificationcount where MOCode in ('MRR(PCC)') and MOCategory='MRR(PCC)'
			       Select @Count= Count(*) from MRReciept mr  where mr.Status=@status and mr.CCCode in (Select CCCode from @CClist)
				   if exists(Select * from UserCostCenters  where RoleId=@RoleID and UserId=@UserID and CCCode in(select cc_code from Cost_Center where status='Approved' and CC_Type ='Performing'))
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Purchase/TransferRecieptOthers' , MOCategory='MRR (PCC)' where MOCode in ('MRR(PCC)') and Rowid=@ids			
				End
				Else
				Begin
				    select @status = Status from #Tempnotificationcount where MOCode in ('MRR(PCC)') and MOCategory='MRR(PCC)'
					 Select @Count= Count(*) from MRReciept mr join Cost_Center cc on cc.CC_Code=mr.CCCode  where mr.Status=@status and mr.CCCode=cc.CC_Code and CC_Type='Performing'	
			        --Select @Count= Count(*) from TransferInfo i join Cost_Center c on c.CC_Code=i.CCCode where i.Status=@status and CC_Type='Performing'				   
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Purchase/TransferRecieptOthers' , MOCategory='MRR (PCC)' where MOCode in ('MRR(PCC)') and Rowid=@ids			
				End	
	      End
		  if exists(Select * from #Tempnotificationcount where MOCode in ('MRR(NPCC)') and MOCategory='MRR(NPCC)')
		  Begin	
		  Set @Count=0;  									
				if(@RoleID=108 or @RoleID=122) --108 for projectmanger and 122 for StoreKepper || local storekeeper is 114
				Begin
				   select @status = Status from #Tempnotificationcount where MOCode in ('MRR(NPCC)') and MOCategory='MRR(NPCC)'
			       Select @Count= Count(*) from MRReciept mr  where mr.Status=@status and mr.CCCode in (Select CCCode from @CClist)
				   if exists(Select * from UserCostCenters  where RoleId=@RoleID and UserId=@UserID and CCCode in(select cc_code from Cost_Center where status='Approved' and CC_Type!='Performing'))
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Purchase/TransferRecieptOthers' , MOCategory='MRR (NPCC)' where MOCode in ('MRR(NPCC)') and Rowid=@ids			
				End
				Else
				Begin
				    select @status = Status from #Tempnotificationcount where MOCode in ('MRR(NPCC)') and MOCategory='MRR(NPCC)'
					Select @Count= Count(*) from MRReciept mr join Cost_Center cc on cc.CC_Code=mr.CCCode  where mr.Status=@status and mr.CCCode=cc.CC_Code and CC_Type!='Performing'	
			        --Select @Count= Count(*) from TransferInfo i join Cost_Center c on c.CC_Code=i.CCCode where i.Status=@status and CC_Type!='Performing'				   
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Purchase/TransferRecieptOthers' , MOCategory='MRR (NPCC)' where MOCode in ('MRR(NPCC)') and Rowid=@ids			
				End	
	      End
		  Begin	
		  Set @Count=0;  									
				if(@RoleID=108 or @RoleID=122) --108 for projectmanger and 122 for StoreKepper || local storekeeper is 114
				Begin
				   select @status = Status from #Tempnotificationcount where MOCode in ('MRR(NPCC)') and MOCategory='MRR(NPCC)'
			       Select @Count= Count(*) from MRReciept mr  where mr.Status=@status and mr.CCCode in (Select CCCode from @CClist)
				   if exists(Select * from UserCostCenters  where RoleId=@RoleID and UserId=@UserID and CCCode in(select cc_code from Cost_Center where status='Approved' and CC_Type!='Performing'))
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Purchase/TransferRecieptOthers' , MOCategory='MRR (NPCC)' where MOCode in ('MRR(NPCC)') and Rowid=@ids			
				End
				Else
				Begin
				    select @status = Status from #Tempnotificationcount where MOCode in ('MRR(NPCC)') and MOCategory='MRR(NPCC)'
					Select @Count= Count(*) from MRReciept mr join Cost_Center cc on cc.CC_Code=mr.CCCode  where mr.Status=@status and mr.CCCode=cc.CC_Code and CC_Type!='Performing'	
			        --Select @Count= Count(*) from TransferInfo i join Cost_Center c on c.CC_Code=i.CCCode where i.Status=@status and CC_Type!='Performing'				   
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Purchase/TransferRecieptOthers' , MOCategory='MRR (NPCC)' where MOCode in ('MRR(NPCC)') and Rowid=@ids			
				End	
	      End
		  if exists(Select * from #Tempnotificationcount where MOCode in ('SPPOInvoice(PCC)') and MOCategory='SPPOInvoice(PCC)')
		  Begin	
		  Set @Count=0;  									
				if(@RoleID=108 or @RoleID=122) --108 for projectmanger and 122 for StoreKepper || local storekeeper is 114
				Begin
				   select @status = Status from #Tempnotificationcount where MOCode in ('SPPOInvoice(PCC)') and MOCategory='SPPOInvoice(PCC)'
			       --Select @Count= Count(*) from VendorInvoice where Status=@status and CCCode in (Select CCCode from @CClist)
				   Select @Count= Count(InvoiceNo) from VendorInvoice V   join Cost_Center C on c.CC_Code=V.CCCode join VendorDetails vd on vd.VendorCode=V.VendorId where  V.Status=@status and Type='Service Provider' and V.CCCode  in (Select CCCode from @CClist)
				   if exists(Select * from UserCostCenters  where RoleId=@RoleID and UserId=@UserID and CCCode in(select cc_code from Cost_Center where status='Approved' and CC_Type ='Performing'))
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Purchase/VerifySPPOInvoice' , MOCategory='SPPO Invoice(PCC)' where MOCode in ('SPPOInvoice(PCC)') and Rowid=@ids			
				End
				Else
				Begin
				    select @status = Status from #Tempnotificationcount where MOCode in ('SPPOInvoice(PCC)') and MOCategory='SPPOInvoice(PCC)'
			        --Select @Count= Count(*) from VendorInvoice i join Cost_Center c on c.CC_Code=i.CCCode where i.Status=@status and CC_Type='Performing'	
					 Select @Count= Count(InvoiceNo) from VendorInvoice V   join Cost_Center C on c.CC_Code=V.CCCode join VendorDetails vd on vd.VendorCode=V.VendorId where  V.Status=@status and Type='Service Provider' 			   
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Purchase/VerifySPPOInvoice' , MOCategory='SPPO Invoice(PCC)' where MOCode in ('SPPOInvoice(PCC)') and Rowid=@ids			
				End	
	      End
		  if exists(Select * from #Tempnotificationcount where MOCode in ('SPPOInvoice(NPCC)') and MOCategory='SPPOInvoice(NPCC)')
		  Begin	
		  Set @Count=0;  									
				if(@RoleID=108 or @RoleID=122) --108 for projectmanger and 122 for StoreKepper || local storekeeper is 114
				Begin
				   select @status = Status from #Tempnotificationcount where MOCode in ('SPPOInvoice(NPCC)') and MOCategory='SPPOInvoice(NPCC)'
			       --Select @Count= Count(*) from VendorInvoice  where Status=@status and CCCode in (Select CCCode from @CClist)
				   	Select @Count= Count(InvoiceNo) from VendorInvoice V   join Cost_Center C on c.CC_Code=V.CCCode join VendorDetails vd on vd.VendorCode=V.VendorId where  V.Status=@status and Type='Service Provider' and V.CCCode  in (Select CCCode from @CClist)
				   if exists(Select * from UserCostCenters  where RoleId=@RoleID and UserId=@UserID and CCCode in(select cc_code from Cost_Center where status='Approved' and CC_Type!='Performing'))
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Purchase/VerifySPPOInvoice' , MOCategory='SPPO Invoice(NPCC)' where MOCode in ('SPPOInvoice(NPCC)') and Rowid=@ids			
				End
				Else
				Begin
				    select @status = Status from #Tempnotificationcount where MOCode in ('SPPOInvoice(NPCC)') and MOCategory='SPPOInvoice(NPCC)'
			        --Select @Count= Count(*) from VendorInvoice i join Cost_Center c on c.CC_Code=i.CCCode where i.Status=@status and CC_Type!='Performing'				   
					Select @Count= Count(InvoiceNo) from VendorInvoice V   join Cost_Center C on c.CC_Code=V.CCCode join VendorDetails vd on vd.VendorCode=V.VendorId where  V.Status=@status and Type='Service Provider' 			   
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Purchase/VerifySPPOInvoice' , MOCategory='SPPO Invoice(NPCC)' where MOCode in ('SPPOInvoice(NPCC)') and Rowid=@ids			
				End	
	      End
		   if exists(Select * from #Tempnotificationcount where MOCode in ('SupplierPOInvoice(PCC)') and MOCategory='SupplierPOInvoice(PCC)')
		  Begin	
		  Set @Count=0;  									
				if(@RoleID=108 or @RoleID=122) --108 for projectmanger and 122 for StoreKepper || local storekeeper is 114
				Begin
				   select @status = Status from #Tempnotificationcount where MOCode in ('SupplierPOInvoice(PCC)') and MOCategory='SupplierPOInvoice(PCC)'
			       --Select @Count= Count(*) from VendorInvoice where Status=@status and CCCode in (Select CCCode from @CClist)
				   Select @Count= Count(InvoiceNo) from VendorInvoice V   join Cost_Center C on c.CC_Code=V.CCCode join VendorDetails vd on vd.VendorCode=V.VendorId where  V.Status=@status and Type in ('Supplier','Trading Supply') and V.CCCode  in (Select CCCode from @CClist)
				   if exists(Select * from UserCostCenters  where RoleId=@RoleID and UserId=@UserID and CCCode in(select cc_code from Cost_Center where status='Approved' and CC_Type ='Performing'))
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Purchase/VerifySupplierInvoice' , MOCategory='Supplier PO Invoice(PCC)' where MOCode in ('SupplierPOInvoice(PCC)') and Rowid=@ids			
				End
				Else
				Begin
				    select @status = Status from #Tempnotificationcount where MOCode in ('SupplierPOInvoice(PCC)') and MOCategory='SupplierPOInvoice(PCC)'
			        --Select @Count= Count(*) from VendorInvoice i join Cost_Center c on c.CC_Code=i.CCCode where i.Status=@status and CC_Type='Performing'	
					 Select @Count= Count(InvoiceNo) from VendorInvoice V   join Cost_Center C on c.CC_Code=V.CCCode join VendorDetails vd on vd.VendorCode=V.VendorId where  V.Status=@status and Type in ('Supplier','Trading Supply') 			   
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Purchase/VerifySupplierInvoice' , MOCategory='Supplier PO Invoice(PCC)' where MOCode in ('SupplierPOInvoice(PCC)') and Rowid=@ids			
				End	
	      End
		  if exists(Select * from #Tempnotificationcount where MOCode in ('SupplierPOInvoice(NPCC)') and MOCategory='SupplierPOInvoice(NPCC)')
		  Begin	
		  Set @Count=0;  									
				if(@RoleID=108 or @RoleID=122) --108 for projectmanger and 122 for StoreKepper || local storekeeper is 114
				Begin
				   select @status = Status from #Tempnotificationcount where MOCode in ('SupplierPOInvoice(NPCC)') and MOCategory='SupplierPOInvoice(NPCC)'
			       --Select @Count= Count(*) from VendorInvoice  where Status=@status and CCCode in (Select CCCode from @CClist)
				   	Select @Count= Count(InvoiceNo) from VendorInvoice V   join Cost_Center C on c.CC_Code=V.CCCode join VendorDetails vd on vd.VendorCode=V.VendorId where  V.Status=@status and Type in ('Supplier','Trading Supply') and V.CCCode  in (Select CCCode from @CClist)
				   if exists(Select * from UserCostCenters  where RoleId=@RoleID and UserId=@UserID and CCCode in(select cc_code from Cost_Center where status='Approved' and CC_Type!='Performing'))
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Purchase/VerifySupplierInvoice' , MOCategory='Supplier PO Invoice(NPCC)' where MOCode in ('SupplierPOInvoice(NPCC)') and Rowid=@ids			
				End
				Else
				Begin
				    select @status = Status from #Tempnotificationcount where MOCode in ('SupplierPOInvoice(NPCC)') and MOCategory='SupplierPOInvoice(NPCC)'
			        --Select @Count= Count(*) from VendorInvoice i join Cost_Center c on c.CC_Code=i.CCCode where i.Status=@status and CC_Type!='Performing'				   
					Select @Count= Count(InvoiceNo) from VendorInvoice V   join Cost_Center C on c.CC_Code=V.CCCode join VendorDetails vd on vd.VendorCode=V.VendorId where  V.Status=@status and Type in ('Supplier','Trading Supply')  and CC_Type!='Performing'				   
					UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Purchase/VerifySupplierInvoice' , MOCategory='Supplier PO Invoice(NPCC)' where MOCode in ('SupplierPOInvoice(NPCC)') and Rowid=@ids			
				End	
	      End
		  if exists(Select * from #Tempnotificationcount where MOCode='VendorPaymentbyBank' and MOCategory='VendorPaymentbyBank')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='VendorPaymentbyBank' and MOCategory='VendorPaymentbyBank'
			Select @Count= count(Bt.TransactionRefNo)from BankTransactions bt join PaymentType pt on pt.PaymentTypeID=bt.TypeOfTransactionId where PaymentTypeName in ('Vendor Invoice','Vendor Advance','Vendor Retention','Vendor Hold') and TransactionStatus=@status
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Purchase/VerifyVendorPayment?Paytype=Bank' ,MOCategory='Vendor Payment by Bank' where MOCode='VendorPaymentbyBank' and Rowid=@ids	
		   End 
		   if exists(Select * from #Tempnotificationcount where MOCode='VendorPaymentbyCash' and MOCategory='VendorPaymentbyCash')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='VendorPaymentbyCash' and MOCategory='VendorPaymentbyCash'
			Select @Count= Count(TransactionRefNo) from CashBook C join PaymentType pt on pt.PaymentTypeName=C.VoucherType where PaymentTypeName in ('Vendor Invoice','Vendor Advance','Vendor Retention','Vendor Hold') and c.Status=@status
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Purchase/VerifyVendorPayment?Paytype=Cash' ,MOCategory='Vendor Payment by Cash' where MOCode='VendorPaymentbyCash' and Rowid=@ids	
		   End   
		  if exists(Select * from #Tempnotificationcount where MOCode='SupplierPOCreation' and MOCategory='SupplierPOCreation')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='SupplierPOCreation' and MOCategory='SupplierPOCreation'
			Select @Count= count(Id) from SupplierPO where  [Status]=@status
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/Purchase/VerifySupplierPO' ,MOCategory='Supplier PO Creation' where MOCode='SupplierPOCreation' and Rowid=@ids	
		   End    
		   if exists(Select * from #Tempnotificationcount where MOCode='GeneralPaymentInvoiceCreation' and MOCategory='GeneralPaymentInvoiceCreation')
		  Begin	
			Set @Count=0; 			  
			select @status = Status from #Tempnotificationcount where MOCode='GeneralPaymentInvoiceCreation' and MOCategory='GeneralPaymentInvoiceCreation'
			Select @Count= count(*) from GeneralInvoices    where status not in ('Approved','Rejected') and Status=@status
			UPDATE #Tempnotificationcount SET IndCount=@Count,[Path]='/AccountsApproval/VerifyGeneralPayInvoice' ,MOCategory='General Invoice Creation' where MOCode='GeneralPaymentInvoiceCreation' and Rowid=@ids	
		   End      
     SET @ids = @ids+1;	
	End
		Begin	
			Set @Count=0; 			  
			Select @Count= COUNT(*) from ClosingDetails  where ClosingAsOnDate<=GetDATE()and Status not in ('Closed','Rejected')
			if(@Count>0)
			Begin
			   insert into  #Tempnotificationcount (MOID,MOCategory,MOCode,Status,IndCount,Path) values(0,'Closing Details','0','0',@Count,'/Home/CloseDetailsForAll')
			End
		 End
		 Begin	
		    IF(@RoleID=122)--storekepper
			Begin
			Declare @CountM int;
			Set @CountM=0; 			  
			Select @CountM= Count (*) from(select TI.RefNo,'From Other Store' as [Type],Ti.IndentNo as IndentNo,Ti.CCCode as CCCode,Ti.[Status] from TransferInfo TI  where IndentNo is not null and TI.CCCode  in(select CCCode from UserCostCenters where RoleId=@RoleID)and TI.Status='Approved' and (RefNo not in(Select RefNo from MRReciept) or RefNo in (Select RefNo from MRReciept where Status='Rejected'))
						union all
						Select PoNo,'From Vendor' as [Type],IndentNo as IndentNo,CCCode,Status from SupplierPO sp  where CCCode in (select CCCode from UserCostCenters where RoleId=@RoleID) and sp.Status='Approved' and (PoNo not in(Select RefNo from MRReciept) or PoNo in (Select RefNo from MRReciept where Status='Rejected'))
						)i where i.Status!='Rejected'
				if(@CountM>0)
				Begin
				   insert into  #Tempnotificationcount (MOID,MOCategory,MOCode,Status,IndCount,Path) values(0,'MRR','0','0',@CountM,'/Purchase/TransferReciept')
				End
			End
			Else IF(@RoleID=112)--centralstorekepper
			Begin
			Declare @CountK int;
			Set @CountK=0; 			  
			         Select @CountK=  Count (*) from(
			            select TI.RefNo,'From Other Store' as [Type],Ti.IndentNo as IndentNo,Ti.CCCode as CCCode,Ti.[Status] from TransferInfo TI join Cost_Center cc on cc.CC_Code=TI.CCCode  where IndentNo is not null and cc.CC_Type!='Performing' and TI.Status='Approved' and (RefNo not in(Select RefNo from MRReciept) or RefNo in (Select RefNo from MRReciept where Status='Rejected'))
						union all
						Select PoNo,'From Vendor' as [Type],IndentNo as IndentNo,CCCode,sp.Status from SupplierPO sp join Cost_Center cc on cc.CC_Code=sp.CCCode  where cc.CC_Type!='Performing' and sp.Status='Approved' and (PoNo not in(Select RefNo from MRReciept) or PoNo in (Select RefNo from MRReciept where Status='Rejected'))
						)i where i.Status!='Rejected'
			if(@CountK>0)
			Begin
			   insert into  #Tempnotificationcount (MOID,MOCategory,MOCode,Status,IndCount,Path) values(0,'MRR','0','0',@CountK,'/Purchase/TransferReciept')
			End
			End
			---MultiMRR
		  IF(@RoleID=122)--storekepper
			Begin
			Declare @CountMM int;
			Set @CountMM=0; 			  
			Select @CountMM= Count(MRRNo) from MRReciept where Status='Approved' and MrrStatus='Open' and MrrType='Multi' and CCCode  in(select CCCode from UserCostCenters where RoleId=@RoleID)
				if(@CountMM>0)
				Begin
				   insert into  #Tempnotificationcount (MOID,MOCategory,MOCode,Status,IndCount,Path) values(0,'Multi MRR Items','0','0',@CountMM,'/Purchase/TransferRecieptMulti')
				End
			End
			Else IF(@RoleID=112)--centralstorekepper
			Begin
			Declare @CountKK int;
			Set @CountKK=0; 			  
			         Select @CountKK=  Count(MRRNo) from MRReciept mr join Cost_Center cc on cc.CC_Code=mr.CCCode where mr.Status='Approved' and MrrStatus='Open' and MrrType='Multi' and cc.CC_Type!='Performing'
			if(@CountKK>0)
			Begin
			   insert into  #Tempnotificationcount (MOID,MOCategory,MOCode,Status,IndCount,Path) values(0,'Multi MRR Items','0','0',@CountKK,'/Purchase/TransferRecieptMulti')
			End
			End
		 End
    update notificationcount set PresentDate=GETDATE() where RoleID=@RoleID;
	if(@RoleID!=108 or @RoleID!=110 or @RoleID!=122)
		select sum([Count])as [Count] from notificationcount where RoleID=@RoleID group by RoleID
	else
		select sum([Count])as [Count] from notificationcount where RoleID=@RoleID and  CCCode in (Select CCCode from @CClist) group by RoleID
  
	Select * from #Tempnotificationcount where IndCount>0
	
END

--exec [spGetNotification] 108

--alter database Essedb181219 set enable_broker

--USE [master]
--GO
--SELECT   [name]
-- ,[is_broker_enabled] 
-- ,[service_broker_guid]
--FROM [sys].[databases] 
--GO

--USE [master]
--GO
--ALTER DATABASE Essedb181219 SET NEW_BROKER
--GO

--exec [spGetNotification] 116





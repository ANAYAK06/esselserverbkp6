USE [EsselV2]
GO
/****** Object:  StoredProcedure [dbo].[spGetMenu]    Script Date: 2/17/2021 5:01:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Procedure   [dbo].[spGetMenu] 
@RoleID int
AS
BEGIN   
if(@RoleID=100)
 Begin
    SELECT DISTINCT  FFA.FirmFunctionalAreaID,
	CASE WHEN FFA.FirmFunctionalAreaID IN (10,11,5) THEN 'Configurations'
    ELSE
    FFA.FirmFunctionalAreaName END AreaNAme,GroupName as gname,
	path,'Admin' as Type,'<ul>Admin</ul>'as [UL],FFA.FirmFunctionalAreaName as[LI],
	CASE WHEN M.MasterOperationID IN (190,192,194,196,198) THEN 'Masters'
	ELSE	
	DisplayName
	END
	subLI  FROM menugrouping MG 	
	join FirmFunctionalAreas FFA on MG.FirmFunctionalAreaId=FFA.FirmFunctionalAreaID 
	join Masteroperation M on M.MasterOperationID=MG.MasterOperationID  WHERE m.MasterOperationID in (190,192,194,196,198,254,102,342,340,352,354,356,358) and FFA.FirmFunctionalAreaID not in(9) and DisplayName is not null
	UNION ALL
    SELECT DISTINCT  FFA.FirmFunctionalAreaID,CASE WHEN FFA.FirmFunctionalAreaID IN (9) THEN 'Reports' ELSE FFA.FirmFunctionalAreaName END AreaNAme,GroupName as gname,
	path,'Reports' as Type,'<ul>Reports</ul>'as [UL],FFA.FirmFunctionalAreaName as[LI],
	CASE WHEN M.MasterOperationID IN (248) THEN 'Budget'
	WHEN M.MasterOperationID IN (250) THEN 'Ledger'
	WHEN M.MasterOperationID IN (252) THEN 'Company Report'
	WHEN M.MasterOperationID IN (256) THEN 'Profit and Loss'
	WHEN M.MasterOperationID IN (276) THEN 'View Item Codes'
	WHEN M.MasterOperationID IN (290) THEN 'View Indents'
	WHEN M.MasterOperationID IN (290) THEN 'View Items Transfer'
	WHEN M.MasterOperationID IN (316) THEN 'View SPPO'
    WHEN M.MasterOperationID IN (318) THEN 'View SPPO Invoice Details'
	WHEN M.MasterOperationID IN (320) THEN 'View Supplier PO Details'
	WHEN M.MasterOperationID IN (292) THEN 'View Transfer Items'
	WHEN M.MasterOperationID IN (294) THEN 'View Item Stock'
	--WHEN M.MasterOperationID IN (296) THEN 'View Daily Issue'
	WHEN M.MasterOperationID IN (320) THEN 'View Supplier PO Report'
	WHEN M.MasterOperationID IN (298) THEN 'View Bank Statement'
	WHEN M.MasterOperationID IN (336) THEN 'Accrued Interest'
	WHEN M.MasterOperationID IN (300) THEN 'View Vendor TDS'
	WHEN M.MasterOperationID IN (302) THEN 'View GST Report'
	WHEN M.MasterOperationID IN (338) THEN 'Stock Reconciliation Report'
	WHEN M.MasterOperationID IN (304) THEN 'View Company Depreciation'
	WHEN M.MasterOperationID IN (344) THEN 'View Asset Depreciation'
	ELSE	
	DisplayName
	END	
	subLI  FROM menugrouping MG 
	join WorkFlowLevels MO ON MG.masteroperationid=MO.MasterOperationID
	join FirmFunctionalAreas FFA on MG.FirmFunctionalAreaId=FFA.FirmFunctionalAreaID 
	join Masteroperation M on M.MasterOperationID=MO.MasterOperationID join UserOperation uo on uo.MasterOperationID=m.MasterOperationID WHERE  UserRoleId=@RoleID and  RIGHT(uo.UserOperationCode, 1)='R'and  m.MasterOperationID not in (200,202,204,206,208,210,212,214,222) and FFA.FirmFunctionalAreaID in(9) and uo.Status='1'
    UNION ALL
    SELECT DISTINCT  FFA.FirmFunctionalAreaID,CASE WHEN FFA.FirmFunctionalAreaID IN (10) THEN 'Configuration' ELSE FFA.FirmFunctionalAreaName END AreaNAme,GroupName as gname,
	path,'Configuration' as Type,'<ul>Configuration</ul>'as [UL],FFA.FirmFunctionalAreaName as[LI],
	CASE WHEN M.MasterOperationID IN (254) THEN 'Page Level Configuration'
	WHEN M.MasterOperationID IN (334) THEN 'CC Overhead Depreciation Setting'
	WHEN M.MasterOperationID IN (340) THEN 'Company Depreciation Configure'
	WHEN M.MasterOperationID IN (342) THEN 'Asset Depreciation Configure'
	WHEN M.MasterOperationID IN (350) THEN 'HR Rules'
	WHEN M.MasterOperationID IN (352) THEN 'CC DayLimit Configuration'
	ELSE	
	DisplayName
	END	
	subLI  FROM menugrouping MG 
	join WorkFlowLevels MO ON MG.masteroperationid=MO.MasterOperationID
	join FirmFunctionalAreas FFA on MG.FirmFunctionalAreaId=FFA.FirmFunctionalAreaID 
	join Masteroperation M on M.MasterOperationID=MO.MasterOperationID join UserOperation uo on uo.MasterOperationID=m.MasterOperationID WHERE  UserRoleId=@RoleID and  RIGHT(uo.UserOperationCode, 1)='C' and FFA.FirmFunctionalAreaID in(10) and uo.Status='1'

 End  
 Else if(@RoleID=102)
 Begin
    SELECT DISTINCT  FFA.FirmFunctionalAreaID,
	CASE WHEN FFA.FirmFunctionalAreaID IN (10,11,5) THEN 'Configurations'
    ELSE
    FFA.FirmFunctionalAreaName END AreaNAme,GroupName as gname,
	path,'Admin' as Type,'<ul>Admin</ul>'as [UL],FFA.FirmFunctionalAreaName as[LI],
	CASE WHEN M.MasterOperationID IN (190,192,194,196,198) THEN 'Masters'
	ELSE	
	DisplayName
	END
	subLI  FROM menugrouping MG 
	join WorkFlowLevels MO ON MG.masteroperationid=MO.MasterOperationID
	join FirmFunctionalAreas FFA on MG.FirmFunctionalAreaId=FFA.FirmFunctionalAreaID 
	join Masteroperation M on M.MasterOperationID=MO.MasterOperationID  WHERE  Mo.LevelOfApproval=1 and UserRoleId=@RoleID  and m.MasterOperationID not in (200,202,204,206,208,210,212,214,222,254,342,340,352,354,356,358,334) and FFA.FirmFunctionalAreaID not in(9) and DisplayName is not null
	UNION ALL
    SELECT DISTINCT  FFA.FirmFunctionalAreaID,CASE WHEN FFA.FirmFunctionalAreaID IN (9) THEN 'Reports' ELSE FFA.FirmFunctionalAreaName END AreaNAme,GroupName as gname,
	path,'Reports' as Type,'<ul>Reports</ul>'as [UL],FFA.FirmFunctionalAreaName as[LI],
	CASE WHEN M.MasterOperationID IN (248) THEN 'Budget'
	WHEN M.MasterOperationID IN (250) THEN 'Ledger'
	WHEN M.MasterOperationID IN (252) THEN 'Company Report'
	WHEN M.MasterOperationID IN (256) THEN 'Profit and Loss'
	WHEN M.MasterOperationID IN (276) THEN 'View Item Codes'
	WHEN M.MasterOperationID IN (290) THEN 'View Indents'
	WHEN M.MasterOperationID IN (290) THEN 'View Items Transfer'
	WHEN M.MasterOperationID IN (316) THEN 'View SPPO'
    WHEN M.MasterOperationID IN (318) THEN 'View SPPO Invoice Details'
	WHEN M.MasterOperationID IN (320) THEN 'View Supplier PO Details'
	WHEN M.MasterOperationID IN (292) THEN 'View Transfer Items'
	WHEN M.MasterOperationID IN (294) THEN 'View Item Stock'
	--WHEN M.MasterOperationID IN (296) THEN 'View Daily Issue'
	WHEN M.MasterOperationID IN (320) THEN 'View Supplier PO Report'
	WHEN M.MasterOperationID IN (298) THEN 'View Bank Statement'
	WHEN M.MasterOperationID IN (336) THEN 'Accrued Interest'
	WHEN M.MasterOperationID IN (300) THEN 'View Vendor TDS'
	WHEN M.MasterOperationID IN (302) THEN 'View GST Report'
	WHEN M.MasterOperationID IN (338) THEN 'Stock Reconciliation Report'
	WHEN M.MasterOperationID IN (304) THEN 'View Company Depreciation'
	WHEN M.MasterOperationID IN (344) THEN 'View Asset Depreciation'
	ELSE	
	DisplayName
	END	
	subLI  FROM menugrouping MG 
	join WorkFlowLevels MO ON MG.masteroperationid=MO.MasterOperationID
	join FirmFunctionalAreas FFA on MG.FirmFunctionalAreaId=FFA.FirmFunctionalAreaID 
	join Masteroperation M on M.MasterOperationID=MO.MasterOperationID join UserOperation uo on uo.MasterOperationID=m.MasterOperationID WHERE  UserRoleId=@RoleID and  RIGHT(uo.UserOperationCode, 1)='R'and  m.MasterOperationID not in (200,202,204,206,208,210,212,214,222) and FFA.FirmFunctionalAreaID in(9) and uo.Status='1'
    UNION ALL

    SELECT DISTINCT  FFA.FirmFunctionalAreaID,CASE WHEN FFA.FirmFunctionalAreaID IN (10) THEN 'Configuration' ELSE FFA.FirmFunctionalAreaName END AreaNAme,GroupName as gname,
	path,'Configuration' as Type,'<ul>Configuration</ul>'as [UL],FFA.FirmFunctionalAreaName as[LI],
	CASE WHEN M.MasterOperationID IN (254) THEN 'Page Level Configuration'
	WHEN M.MasterOperationID IN (334) THEN 'CC Overhead Depreciation Setting'
	WHEN M.MasterOperationID IN (340) THEN 'Company Depreciation Configure'
	WHEN M.MasterOperationID IN (342) THEN 'Asset Depreciation Configure'
	WHEN M.MasterOperationID IN (350) THEN 'HR Rules'
	WHEN M.MasterOperationID IN (352) THEN 'CC DayLimit Configuration'
	ELSE	
	DisplayName
	END	
	subLI  FROM menugrouping MG 
	join WorkFlowLevels MO ON MG.masteroperationid=MO.MasterOperationID
	join FirmFunctionalAreas FFA on MG.FirmFunctionalAreaId=FFA.FirmFunctionalAreaID 
	join Masteroperation M on M.MasterOperationID=MO.MasterOperationID join UserOperation uo on uo.MasterOperationID=m.MasterOperationID WHERE  UserRoleId=@RoleID and  RIGHT(uo.UserOperationCode, 1)='C' and FFA.FirmFunctionalAreaID in(10) and uo.Status='1' and m.Status=1

 End
  
 Else
 Begin
 SELECT DISTINCT  FFA.FirmFunctionalAreaID,
CASE WHEN FFA.FirmFunctionalAreaID IN (10,11,5) THEN 'Configurations'
ELSE
FFA.FirmFunctionalAreaName END AreaNAme,GroupName as gname,
	path,'Admin' as Type,'<ul>Admin</ul>'as [UL],FFA.FirmFunctionalAreaName as[LI],	
	case when M.MasterOperationID IN (106,216) THEN 'Cost Center Creation'
	WHEN M.MasterOperationID IN (108) THEN 'Account/SubAccount Head Creation'
	WHEN M.MasterOperationID IN (110) THEN 'IT Creation'
	WHEN M.MasterOperationID IN (116) THEN 'Add Bank'
	WHEN M.MasterOperationID IN (176,114) THEN 'Client And Sub-Client Creation'
	WHEN M.MasterOperationID IN (120) THEN 'Create Taxes'
	WHEN M.MasterOperationID IN (236) THEN 'View/Edit Sub-Account Head'
	WHEN M.MasterOperationID IN (240) THEN 'Term Loan Creation'
	WHEN M.MasterOperationID IN (260) THEN 'Vendor Creation'
	WHEN M.MasterOperationID IN (246,244) THEN 'Term Loan Payment'
	WHEN M.MasterOperationID IN (224,226,228) THEN 'Unsecured Loan'
	WHEN M.MasterOperationID IN (122) THEN 'Client PO'
	WHEN M.MasterOperationID IN (124) THEN 'Client PO Amendment'
	WHEN M.MasterOperationID IN (262,272) THEN 'SPPO Creation'
	WHEN M.MasterOperationID IN (264,274) THEN 'SPPO Amendment'
	WHEN M.MasterOperationID IN (314) THEN 'Supplier PO Creation'
	WHEN M.MasterOperationID IN (126) THEN 'Master Groups'
	WHEN M.MasterOperationID IN (128) THEN 'Sub Groups'
	WHEN M.MasterOperationID IN (130) THEN 'Child Groups'
	WHEN M.MasterOperationID IN (132) THEN 'Ledger Creation'
	WHEN M.MasterOperationID IN (238) THEN 'Journal Voucher'
	WHEN M.MasterOperationID IN (134,136,140,142,218,220,232,234) THEN 'CC/Account Head Budget Assignment&Amendment'
	WHEN M.MasterOperationID IN (150) THEN 'Client Invoice Creation'
	WHEN M.MasterOperationID IN (306,308) THEN 'SPPO Invoice Creation'
	WHEN M.MasterOperationID IN (326,328) THEN 'SupplierPO Invoice Creation'
	WHEN M.MasterOperationID IN (348) THEN 'General Invoice Creation'
	WHEN M.MasterOperationID IN (146) THEN 'Cash Voucher'
	WHEN M.MasterOperationID IN (148) THEN 'Cash Transfer'
	WHEN M.MasterOperationID IN (310,312) THEN 'Supplier/Service Provider Payment'
	WHEN M.MasterOperationID IN (160) THEN 'General Payable'
	WHEN M.MasterOperationID IN (162) THEN 'Cash Withdrawls'
	WHEN M.MasterOperationID IN (166) THEN 'Bank Transfer'
	WHEN M.MasterOperationID IN (152,154,156,158) THEN 'Client Reciept'
	WHEN M.MasterOperationID IN (164) THEN 'Bank Deposit'
	WHEN M.MasterOperationID IN (178,180,182,184) THEN 'Fixed Deposit'
	WHEN M.MasterOperationID IN (174,230) THEN 'Misc Taxable Receipts'
	WHEN M.MasterOperationID IN (170,168) THEN 'Any Other Refund'
	WHEN M.MasterOperationID IN (186) THEN 'Cheque book updation'
	WHEN M.MasterOperationID IN (188) THEN 'Central DayBook'
	WHEN  M.MasterOperationID IN (192,196) THEN 'SystemConfiguration'
	WHEN M.MasterOperationID IN (278,280) THEN 'Indent Creation'	
	WHEN M.MasterOperationID IN (282,284) THEN 'Items Transfer'
	WHEN M.MasterOperationID IN (286,288) THEN 'MRR'	
	WHEN M.MasterOperationID IN (296) THEN 'Daily Issue'
	WHEN M.MasterOperationID IN (322,324) THEN 'Lost Or Damaged Items'
	ELSE	
	DisplayName
	END	
	subLI  FROM menugrouping MG 
	join WorkFlowLevels MO ON MG.masteroperationid=MO.MasterOperationID
	join FirmFunctionalAreas FFA on MG.FirmFunctionalAreaId=FFA.FirmFunctionalAreaID 
	join Masteroperation M on M.MasterOperationID=MO.MasterOperationID WHERE Mo.LevelOfApproval=1  and UserRoleId=@RoleID and m.MasterOperationID not in (200,202,204,206,208,210,212,214,222,254,342,340,352,334) and FFA.FirmFunctionalAreaID not in (9)
	

-- SELECT DISTINCT  FFA.FirmFunctionalAreaID,
--CASE WHEN FFA.FirmFunctionalAreaID IN (10,11,5) THEN 'Configurations'
--ELSE
--FFA.FirmFunctionalAreaName END AreaNAme,GroupName as gname,
--	path,'Admin' as Type,'<ul>Admin</ul>'as [UL],FFA.FirmFunctionalAreaName as[LI],	
--	case when M.MasterOperationID IN (152,154,156,158,160,162,164,166,168,170,172,174,180,182,184,178) THEN 'Bank Payments'
--	WHEN M.MasterOperationID IN (186) THEN 'Cheque book updation'
--	WHEN M.MasterOperationID IN (122,124) THEN 'Client PO and Amend PO'
--	WHEN M.MasterOperationID IN (146,148) THEN 'Cash Transactions'
--	WHEN M.MasterOperationID IN (110,116,208) THEN 'Master Configuration'
--	WHEN  M.MasterOperationID IN (192,196) THEN 'SystemConfiguration'
--	WHEN  M.MasterOperationID IN (218,220,134,136,138,140,142,144) THEN 'Create/Amend Budget'
--	WHEN M.MasterOperationID IN (238) THEN 'Journal Voucher Creation'
--	WHEN M.MasterOperationID IN (188) THEN 'Central DayBook'
--	WHEN M.MasterOperationID IN (244) THEN 'Term Loan Creation'	
--	WHEN M.MasterOperationID IN (278,280) THEN 'Indent Creation'
--	WHEN M.MasterOperationID IN (262,272) THEN 'SPPO Creation'
--	WHEN M.MasterOperationID IN (264,274) THEN 'SPPO Amendment'
--	WHEN M.MasterOperationID IN (282,284) THEN 'Items Transfer'
--	WHEN M.MasterOperationID IN (286,288) THEN 'MRR'
--	WHEN M.MasterOperationID IN (306,308) THEN 'SPPO Invoice'
--	WHEN M.MasterOperationID IN (310,312) THEN 'Vendor Payment'
--	WHEN M.MasterOperationID IN (314) THEN 'Supplier PO Creation'
--	WHEN M.MasterOperationID IN (296) THEN 'Daily Issue'
--	WHEN M.MasterOperationID IN (322,324) THEN 'Lost Or Damaged Items'
--	WHEN M.MasterOperationID IN (326,328) THEN 'Supplier Invoice'
--	WHEN M.MasterOperationID IN (340) THEN 'General Invoice'
--	ELSE	
--	DisplayName
--	END	
--	subLI  FROM menugrouping MG 
--	join WorkFlowLevels MO ON MG.masteroperationid=MO.MasterOperationID
--	join FirmFunctionalAreas FFA on MG.FirmFunctionalAreaId=FFA.FirmFunctionalAreaID 
--	join Masteroperation M on M.MasterOperationID=MO.MasterOperationID WHERE Mo.LevelOfApproval=1  and UserRoleId=@RoleID and m.MasterOperationID not in (200,202,204,206,208,210,212,214,222,254) and FFA.FirmFunctionalAreaID not in (9)

 UNION ALL
 SELECT DISTINCT  FFA.FirmFunctionalAreaID,CASE WHEN FFA.FirmFunctionalAreaID IN (9) THEN 'Reports' ELSE FFA.FirmFunctionalAreaName END AreaNAme,GroupName as gname,
	path,'Reports' as Type,'<ul>Reports</ul>'as [UL],FFA.FirmFunctionalAreaName as[LI],
	CASE WHEN M.MasterOperationID IN (248) THEN 'Budget'
	WHEN M.MasterOperationID IN (250) THEN 'Ledger'
	WHEN M.MasterOperationID IN (252) THEN 'Company Report'
	WHEN M.MasterOperationID IN (256) THEN 'Profit and Loss'
	WHEN M.MasterOperationID IN (276) THEN 'View Item Codes'
	WHEN M.MasterOperationID IN (290) THEN 'View Indents'
	WHEN M.MasterOperationID IN (290) THEN 'View Items Transfer'
	WHEN M.MasterOperationID IN (316) THEN 'View SPPO'
    WHEN M.MasterOperationID IN (318) THEN 'View SPPO Invoice Details'
	WHEN M.MasterOperationID IN (320) THEN 'View Supplier PO Details'
	WHEN M.MasterOperationID IN (292) THEN 'View Transfer Items'
	WHEN M.MasterOperationID IN (294) THEN 'View Item Stock'
	--WHEN M.MasterOperationID IN (296) THEN 'View Daily Issue'
	WHEN M.MasterOperationID IN (320) THEN 'View Supplier PO Report'
	WHEN M.MasterOperationID IN (298) THEN 'View Bank Statement'
	WHEN M.MasterOperationID IN (336) THEN 'Accrued Interest'
	WHEN M.MasterOperationID IN (300) THEN 'View Vendor TDS'
	WHEN M.MasterOperationID IN (302) THEN 'View GST Report'
	WHEN M.MasterOperationID IN (338) THEN 'Stock Reconciliation Report'
	WHEN M.MasterOperationID IN (304) THEN 'View Company Depreciation'
	WHEN M.MasterOperationID IN (344) THEN 'View Asset Depreciation'
	ELSE	
	DisplayName
	END	
	subLI  FROM menugrouping MG 
	join WorkFlowLevels MO ON MG.masteroperationid=MO.MasterOperationID
	join FirmFunctionalAreas FFA on MG.FirmFunctionalAreaId=FFA.FirmFunctionalAreaID 
	join Masteroperation M on M.MasterOperationID=MO.MasterOperationID join UserOperation uo on uo.MasterOperationID=m.MasterOperationID WHERE  UserRoleId=@RoleID and  RIGHT(uo.UserOperationCode, 1)='R'and  m.MasterOperationID not in (200,202,204,206,208,210,212,214,222) and FFA.FirmFunctionalAreaID in(9) and uo.Status='1'
UNION ALL

SELECT DISTINCT  FFA.FirmFunctionalAreaID,CASE WHEN FFA.FirmFunctionalAreaID IN (10) THEN 'Configuration' ELSE FFA.FirmFunctionalAreaName END AreaNAme,GroupName as gname,
	path,'Configuration' as Type,'<ul>Configuration</ul>'as [UL],FFA.FirmFunctionalAreaName as[LI],
	CASE WHEN M.MasterOperationID IN (254) THEN 'Page Level Configuration'
	WHEN M.MasterOperationID IN (334) THEN 'CC Overhead Depreciation Setting'
	WHEN M.MasterOperationID IN (340) THEN 'Company Depreciation Configure'
	WHEN M.MasterOperationID IN (342) THEN 'Asset Depreciation Configure'
	WHEN M.MasterOperationID IN (350) THEN 'HR Rules'
	WHEN M.MasterOperationID IN (352) THEN 'CC DayLimit Configuration'
	ELSE	
	DisplayName
	END	
	subLI  FROM menugrouping MG 
	join WorkFlowLevels MO ON MG.masteroperationid=MO.MasterOperationID
	join FirmFunctionalAreas FFA on MG.FirmFunctionalAreaId=FFA.FirmFunctionalAreaID 
	join Masteroperation M on M.MasterOperationID=MO.MasterOperationID join UserOperation uo on uo.MasterOperationID=m.MasterOperationID WHERE  UserRoleId=@RoleID and  RIGHT(uo.UserOperationCode, 1)='C' and FFA.FirmFunctionalAreaID in(10) and uo.Status='1' 
 
 End
 End
--exec [spGetMenu] 102

--select * from MasterOperation





USE [EsselV2QA]
GO
SET IDENTITY_INSERT [dbo].[CCAccruedValues] ON 

GO
INSERT [dbo].[CCAccruedValues] ([id], [CCCode], [Value], [InterestRate], [ReportType], [WefDate], [Createdby], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1, N'CC-148', 10000.0000, 10, N'Accrued', NULL, N'52M80005088', CAST(N'2020-09-15 21:24:01.380' AS DateTime), N'52M80005088', CAST(N'2020-12-29 21:11:06.017' AS DateTime))
GO
INSERT [dbo].[CCAccruedValues] ([id], [CCCode], [Value], [InterestRate], [ReportType], [WefDate], [Createdby], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, N'CC-148', 10000.0000, 0.01, N'Depreciation', NULL, N'52M80005088', CAST(N'2020-09-15 21:24:50.607' AS DateTime), N'52M80005088', CAST(N'2020-09-17 21:13:04.667' AS DateTime))
GO
INSERT [dbo].[CCAccruedValues] ([id], [CCCode], [Value], [InterestRate], [ReportType], [WefDate], [Createdby], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (3, N'CC-13', 0.0000, 0, N'Depreciation', NULL, N'52M80005088', CAST(N'2020-09-15 21:26:19.623' AS DateTime), N'52M80005088', CAST(N'2020-09-17 21:12:01.953' AS DateTime))
GO
INSERT [dbo].[CCAccruedValues] ([id], [CCCode], [Value], [InterestRate], [ReportType], [WefDate], [Createdby], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4, N'CC-148', 0.0000, 15, N'Overhead', NULL, N'52M80005088', CAST(N'2020-12-27 22:32:05.637' AS DateTime), N'52M80005088', CAST(N'2020-12-29 21:11:00.327' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[CCAccruedValues] OFF
GO

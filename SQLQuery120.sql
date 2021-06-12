Select * From [dbo].[FnLedgerOpeningBalance](
				39,
				'2019',
						'2020',
						'04/01/2019',
						'03/31/2020',
				'1',
				'Ledger')

select * from ledger where LedgerId=39

				exec  [dbo].[spGetLedger]
						39,
						'2019',
						'2020',
						'04/01/2019',
						'03/31/2020'
USE [master]
GO


SET ANSI_NULLS ON
GO


SET QUOTED_IDENTIFIER ON
GO


CREATE TABLE [dbo].[ILikeToKeepThingInMaster](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[niceThings] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO



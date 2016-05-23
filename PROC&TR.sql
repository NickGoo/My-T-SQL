--存过

create proc P_INITDATA
(
@InsertID varchar(50),
@cfg nvarchar(100),
@TotalSum varchar(20),
@fieldSum varchar(20),
@fieldCount varchar(20)
)
as
begin
declare @date datetime
declare @TotalID varchar(50)
declare @DetailID varchar(50)
declare @TotalCount int


set @TotalSum = CONVERT(int,@TotalSum)

if (select count(ConfigID) from StatConfig where ConfigItem = @cfg) <= 0
	begin
	
	insert StatConfig(
	ConfigID,
	ConfigItem,
	FieldSum,
	FieldCount,
	ExtendField1,
	ExtendField2,
	ExtendField3)
	values(
	newid(),
	@cfg,
	@fieldSum,
	@fieldCount,
	N'',
	N'',
	N'')
	
	insert StatTotal(
	TotalID,
	TotalSum,
	TotalCount,
	FieldSum,
	FieldCount,
	ConfigItem,
	ExtendField1,
	ExtendField2,
	ExtendField3)
	values(
	newid(),
	@TotalSum,
	1,
	@fieldSum,
	@fieldCount,
	@cfg,
	N'',
	N'',
	N'')
	
	end
	else 
	begin
		set @TotalCount =((select TotalCount from StatTotal where ConfigItem = @cfg) + 1)
		set @TotalSum = ((select TotalSum from StatTotal where ConfigItem = @cfg) + 1)
		update [StatTotal] set
		[TotalCount] = @TotalCount,
		[TotalSum] = @TotalSum
		where ConfigItem = @cfg
	end
--年

--初始化详情表绑定
	if(object_id(N'TotalBindDetail',N'U') is not null)
		begin 
		set @TotalID = (select TotalID from StatTotal where ConfigItem = @cfg)	
		set @DetailID = @InsertID
		insert TotalBindDetail(
			BindID,
			TotalID,
			DetailID,
			ConfigItem
		)
		values(
			newid(),
			@TotalID,
			@DetailID,
			@cfg
		)
		end
--初始化详情表绑定

end

--存过


--触发器

alter trigger TR_GasTank on [GasTank]
for insert 
as 

declare @cfg nvarchar(100)
declare @date datetime
declare @InsertID varchar(50)

begin 
	--初始化详情表
	if object_id(N'StatDetailGasTank',N'U') is null
	begin
		--复制表结构及数据
		select * into StatDetailGasTank from inserted
		end
		else 
		begin
		insert StatDetailGasTank select * from inserted	
	end
	--初始化详情表
	
	set @InsertID = (select GasTankID from inserted)
	set @date = (select ScanDate from inserted)
	
	--初始化配置条件
	set @cfg = '{"GasTank":{"ScanDate":{"Y":"'+ convert(nvarchar,datepart(yyyy,@date)) +'"}}}'
	exec P_INITDATA @InsertID,@cfg,'','','GasTankID'
	
	set @cfg = '{"Employees":{"OrderDate":{"Y":"'+  convert(nvarchar,datepart(yyyy,@date)) +'","M":"'+ convert(nvarchar,datepart(yyyy,@date)) +'"}}}'
	--初始化配置条件
	exec P_INITDATA @InsertID,@cfg,'','','GasTankID'
	
end

--触发器
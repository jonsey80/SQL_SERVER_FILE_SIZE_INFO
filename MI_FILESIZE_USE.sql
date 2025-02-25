

drop table if exists #dbSize

create table #dbSize (
[databaseName]	varchar(200)  null,
[fileName]		varchar(200)	null,
[file_id]	int			null,
[type_desc]	varchar(200)	null,
[space_used_mb]   numeric(18,2) null,
[space_unused_mb]	numeric(18,2) null,
[space_allocated_mb] numeric(18,2) null,
[max_size_mb]	numeric(18,2) null
)


declare @sql varchar(4000) 
set @sql = 'use [?]
insert into #dbSize
select ''?'' ''DatabaseName'',
name, 
 	   file_id, type_desc,
       CAST(FILEPROPERTY(name, ''SpaceUsed'') AS decimal(19,4)) * 8 / 1024. AS space_used_mb,
       CAST(size/128.0 - CAST(FILEPROPERTY(name, ''SpaceUsed'') AS int)/128.0 AS decimal(19,4)) AS space_unused_mb,
       CAST(size AS decimal(19,4)) * 8 / 1024. AS space_allocated_mb,
       CAST(max_size AS decimal(19,4)) * 8 / 1024. AS max_size_mb
FROM sys.database_files;'


EXECUTE master.sys.sp_MSforeachdb  @sql



select databaseName, fileName,space_allocated_mb,space_unused_mb,space_allocated_mb -((space_unused_mb/100)*80) 'shrink_to', ((space_unused_mb/100)*80) 'shrink_by' from #dbSize
where type_desc = 'Rows'
order by space_unused_mb desc

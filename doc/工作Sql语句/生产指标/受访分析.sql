受访分析	
归总
1.	  常规的group by  order by  having的使用场景
--各页面访问统计
各页面PV

select request as request,count(request) as request_counts from
ods_weblog_detail group by request having request is not null order by request_counts desc limit 20;
-----------------------------------------------
--热门页面统计

统计20130918这个分区里面的受访页面的top10

drop table dw_hotpages_everyday;
create table dw_hotpages_everyday(day string,url string,pvs string);

insert into table dw_hotpages_everyday
select '20130918',a.request,a.request_counts from
(
select request as request,count(request) as request_counts 
from ods_weblog_detail 
where datestr='20130918' 
group by request 
having request is not null
) a
order by a.request_counts desc limit 10;



统计每日最热门页面的top10
select a.month,a.day,a.request ,concat(a.month,a.day),a.total_request
from (
select month,day, request,count(1) as total_request
from ods_weblog_detail
where datestr = '20130918'
group by  request ,month ,day
having request is not null
order by total_request desc limit 10
) a









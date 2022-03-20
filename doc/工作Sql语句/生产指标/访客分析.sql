访客分析
归总
	1. 就是业务名称需要解释成sql伪代码比较难
			1.独立访客:其实就是访客, 也就是对应的不重复的ip的个数
			2.新访客: 就是老的访客表里没有的,要新建新老访客表,然后把今日的访客表和老的访客表对比,只有老的访客表里没有的就是新的访客,然后把他加入新的访客表,最后还有加入到老的访客表中,表示他现在也算是老的访客了

1.-- 独立访客
--需求：按照时间维度来统计独立访客及其产生的pv量

 按照时间维度比如小时来统计独立访客及其产生的 pv 。


时间维度：时
drop table dw_user_dstc_ip_h;
create table dw_user_dstc_ip_h(
remote_addr string,
pvs      bigint,
hour     string);

insert into table dw_user_dstc_ip_h 
select remote_addr,count(1) as pvs,concat(month,day,hour) as hour 
from ods_weblog_detail
Where datestr='20130918'
group by concat(month,day,hour),remote_addr;



--在上述基础之上，可以继续分析，比如每小时独立访客总数
select count(1) as dstc_ip_cnts,hour from dw_user_dstc_ip_h group by hour;


时间维度：日
select remote_addr,count(1) as counts,concat(month,day) as day
from ods_weblog_detail
Where datestr='20130918'
group by concat(month,day),remote_addr;


时间维度： 月
select remote_addr,count(1) as counts,month 
from ods_weblog_detail
group by month,remote_addr;


----------------------------------------------------------------------------------------
-- 每日新访客
-- 需求：将每天的新访客统计出来。

--历日去重访客累积表
drop table dw_user_dsct_history;
create table dw_user_dsct_history(
day string,
ip string)
partitioned by(datestr string);

--每日新访客表
drop table dw_user_new_d;
create table dw_user_new_d (
day string,
ip string) 
partitioned by(datestr string);
2.新老访客建立
-- 历史访客表里没有的就是新访客
-- 这里可以关联访客表和历史访客表, 左关联不上历史访问表的就是新房客
-- 就说明第一次来访, 
-- 细节: 同样的ip需要把它过滤掉, 还有每日, 也需要对日期去重,精准到天
select a.remote_addr ,a.day
from (
select   remote_addr,'20130918' as day 
from ods_weblog_detail newIp
where datestr ='20130918'
group by remote_addr
) a 
left join dw_user_dsct_history hist
on a.remote_addr = hist.ip
where hist.ip is null;






--每日新用户插入新访客表
insert into table dw_user_new_d partition(datestr='20130918')
select tmp.day as day,tmp.today_addr as new_ip 
from
(
select today.day as day,today.remote_addr as today_addr,old.ip as old_addr 
from 
(
select distinct remote_addr as remote_addr,"20130918" as day 
from ods_weblog_detail where datestr="20130918"
) today
left outer join 
dw_user_dsct_history old
on today.remote_addr=old.ip
) tmp
where tmp.old_addr is null;

--每日新用户追加到历史累计表
insert into table dw_user_dsct_history partition(datestr='20130918')
select day,ip from dw_user_new_d where datestr='20130918';


验证：
select count(distinct remote_addr) from ods_weblog_detail;

select count(1) from dw_user_dsct_history where datestr='20130918';

select count(1) from dw_user_new_d where datestr='20130918';





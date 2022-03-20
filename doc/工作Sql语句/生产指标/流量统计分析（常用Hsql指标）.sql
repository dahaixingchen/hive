常用Hsql指标
1.这里主要讲的是group by的用法
	 1.使用场景
	    1.一般出现要求中出现"每"这样的字样的时候需要考虑使用group by 分组
	2.使用语法
        1.group在hive中select后面的字段和group by对应的要一样
		2.他们对应分组的时候如果有多个字段,多个字段之间的顺序也是有讲究的
2.关于topN的求取
	1.使用场景
		1.分组后再对应的求前几名,前几项,等的需求的时候就是了
	2.实现套路
		1.select ref_host,ref_host_cnts,concat(month,day,hou),
		-- row_number() over()主要它是用来给排序好的列,再加一列,row_number()表示的从1开始从小到大一直往下排,对应需要排序的字段等值的时候取前面一个,rank() over()函数如果等值,会给他们同一个数字
		row_number() over (partition by concat(month,day,hour
		-- order by 对应的是需要根据这个字段排序的
		) order by ref_host_cnts desc) as od 
		from dw_pvs_refererhost_everyhour;
3.   流量分析
--------------------------------------------------------------------------------------------
3.1.--计算每小时pvs，注意gruop by语句的语法
select count(*) as pvs,month,day,hour from ods_weblog_detail group by month,day,hour;

select count(*) as pvs,hour from ods_weblog_detail group by hour;

--------------------------------------------------------------------------------------------
4. 多维度统计PV总量
--第一种方式：直接在ods_weblog_detail单表上进行查询
4.1.计算该处理批次（一天）中的各小时pvs
drop table if exists dw_pvs_everyhour_oneday;
create table if not exists dw_pvs_everyhour_oneday(month string,day string,hour string,pvs bigint) partitioned by(datestr string);

insert  into table dw_pvs_everyhour_oneday partition(datestr='20130918')
select a.month as month,a.day as day,a.hour as hour,count(*) as pvs from t_ods_tmp_detail a
where  a.datestr='20130918' group by a.month,a.day,a.hour;

4.2.--计算每天的pvs
drop table if exists dw_pvs_everyday;
create table if not  exists dw_pvs_everyday(pvs bigint,month string,day string);

insert into table dw_pvs_everyday
select count(*) as pvs,a.month as month,a.day as day from ods_weblog_detail a
group by a.month,a.day;

1.1.2 第二种方式：与时间维表关联查询


--维度：日
drop table dw_pvs_everyday;
create table dw_pvs_everyday(pvs bigint,month string,day string);

insert into table dw_pvs_everyday
select count(*) as pvs,a.month as month,a.day as day from (select distinct month, day from t_dim_time) a
join ods_weblog_detail b 
on a.month=b.month and a.day=b.day
group by a.month,a.day;

--维度：月
drop table dw_pvs_everymonth;
create table dw_pvs_everymonth (pvs bigint,month string);

insert into table dw_pvs_everymonth
select count(*) as pvs,a.month from (select distinct month from t_dim_time) a
join ods_weblog_detail b on a.month=b.month group by a.month;


--另外，也可以直接利用之前的计算结果。比如从之前算好的小时结果中统计每一天的
Insert into table dw_pvs_everyday
Select sum(pvs) as pvs,month,day from dw_pvs_everyhour_oneday group by month,day having day='18';


--------------------------------------------------------------------------------------------
4.3.	按照来访维度统计pv

-- 统计每小时各来访url产生的pv量，查询结果存入：( "dw_pvs_referer_everyhour" )

drop table if exists dw_pvs_referer_everyhour;
create table if not exists dw_pvs_referer_everyhour
(referer_url string,referer_host string,month string,day string,
hour string,pv_referer_cnt bigint) partitioned by(datestr string);

insert into table dw_pvs_referer_everyhour partition(datestr='20130918')
select http_referer,ref_host,month,day,hour,count(1) as pv_referer_cnt
from ods_weblog_detail 
group by http_referer,ref_host,month,day,hour 
having ref_host is not null
order by hour asc,day asc,month asc,pv_referer_cnt desc;



--统计每小时各来访host的产生的pv数并排序
-- 以小时和host为分组对象在求count()
drop table dw_pvs_refererhost_everyhour;
create table dw_pvs_refererhost_everyhour(ref_host string,month string,day string,hour string,ref_host_cnts bigint) partitioned by(datestr string);

insert into table dw_pvs_refererhost_everyhour partition(datestr='20130918')
select ref_host,month,day,hour,count(1) as ref_host_cnts
from ods_weblog_detail 
group by ref_host,month,day,hour 
having ref_host is not null
order by hour asc,day asc,month asc,ref_host_cnts desc;

---------------------------------------------------------------------------
4.4.	统计pv总量最大的来源TOPN
--需求：按照时间维度，统计一天内各小时产生最多pvs的来源topN


--row_number函数
select ref_host,ref_host_cnts,concat(month,day,hour),
row_number() over (partition by concat(month,day,hour) order by ref_host_cnts desc) as od 
from dw_pvs_refererhost_everyhour;

--综上可以得出
drop table dw_pvs_refhost_topn_everyhour;
create table dw_pvs_refhost_topn_everyhour(
hour string,
toporder string,
ref_host string,
ref_host_cnts string
)partitioned by(datestr string);

insert into table dw_pvs_refhost_topn_everyhour partition(datestr='20130918')
select t.hour,t.od,t.ref_host,t.ref_host_cnts from
 (select ref_host,ref_host_cnts,concat(month,day,hour) as hour,
row_number() over (partition by concat(month,day,hour) order by ref_host_cnts desc) as od 
from dw_pvs_refererhost_everyhour) t where od<=3;


---------------------------------------------------------------------------------------------
4.5.	人均浏览页数
--需求描述：统计今日所有来访者平均请求的页面数。
--总页面请求数/去重总人数

drop table dw_avgpv_user_everyday;
create table dw_avgpv_user_everyday(
day string,
avgpv string);

insert into table dw_avgpv_user_everyday
select '20130918',sum(b.pvs)/count(b.remote_addr) 
from
(select remote_addr,count(1) as pvs from ods_weblog_detail where datestr='20130918' 
group by remote_addr) b;
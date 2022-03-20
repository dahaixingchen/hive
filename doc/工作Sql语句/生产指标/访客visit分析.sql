访客visit分析
1.归总
	1.案例代码总结
		distinct的去重是在reduce端通过整成一个reducet分区再去重的,应该用group by在map端去重,对大量的数据来说代码更好
		-- 代码优化后
		代码感悟
		1.想要两个或是多个字段做比较(加减乘除,大小等运算),那就需要关联其他的表(包括自己),
		也就是说要先把需要做比较的两列用临时表的方式给弄到一起, 
		然后再select 表1.字段和表2.字段做比较就可以看
	2.业务分析
		1.人均访问频次,
			使用所有的独立访问的人，即独立的session个数除以所有的去重IP即可
		2.回头访客
			查询同一个ip出现的次数大于1就是回头访客


2.--  回头/单次访客统计

-- 在访客表中按照ip分组,如果组成员数据大于1的说明就是来过来回, 也就是回头访问
select remote_addr ,count(remote_addr) ipcount
from  ods_click_stream_visit
group by remote_addr
having ipcount > 1 




-- 查询今日所有回头访客及其访问次数。


drop table dw_user_returning;
create table dw_user_returning(
day string,
remote_addr string,
acc_cnt string)
partitioned by (datestr string);

insert overwrite table dw_user_returning partition(datestr='20130918')
select  '20130918',remote_addr ,count(remote_addr) ipcount 
from  ods_click_stream_visit
group by remote_addr
having ipcount > 1 

-- 太复杂了
select tmp.day,tmp.remote_addr,tmp.acc_cnt
from
(select '20130918' as day,remote_addr,count(session) as acc_cnt from ods_click_stream_visit 
group by remote_addr) tmp
where tmp.acc_cnt>1;



------------------------------------------------------------------------------------
-- 人均访问频次,使用所有的独立访问的人，即独立的session个数除以所有的去重IP即可

-- 计算出一共访问了多少次，除以一共有多少人
-- 频次表示一共访问了多少次，所有页面访问的次数累加即可


select sum(pagevisits)
from ods_click_stream_visit
76


53
select count(distinct remote_addr) from ods_click_stream_visit




select count(tmp.total_count)
from (
select  remote_addr,count(1) as total_count
from ods_click_stream_visit
group by remote_addr
) tmp 
53

-- 人均访问的频次，频次表示我们来了多少个session
--  次数都是使用session来进行区分，一个session就是表示一次
select count(session)/count(distinct remote_addr) from ods_click_stream_visit where datestr='20130918';

-- distinct的去重是在reduce端通过整成一个reducet分区再去重的,应该应group by现在map端去重,对大量的数据来说代码更好
-- 代码优化后

-- 代码感悟
-- 1.想要两个或是多个字段做比较(加减乘除,大小等运算),那就需要关联其他的表(包括自己),
-- 也就是说要先把需要做表的两列用临时表的方式给弄到一起, 
-- 然后再select 表1.字段和表2.字段做比较就可以看

SELECT t.se/te.ip
FROM 
(SELECT COUNT(1) ip
FROM(
SELECT COUNT(1) ip,remote_addr
FROM ods_click_stream_visit
WHERE datestr='20130918'
GROUP BY remote_addr
)p  
) te
LEFT JOIN 
(SELECT COUNT(SESSION) se
FROM ods_click_stream_visit
WHERE datestr='20130918'
) t



select count(1) 
from ods_click_stream_visit
where datestr ='20130918'


3.-- 人均页面浏览量，所有的页面点击次数累加除以所有的独立去重IP总和即可
select sum(pagevisits)/count(distinct remote_addr) from ods_click_stream_visit where datestr='20130918';
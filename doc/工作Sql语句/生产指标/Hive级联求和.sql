Hive级联求和
1.归总
	1.业务
2.		1.统计每个用户累计小费
			0.一般求累计的时候就需要用关联表的方法了
			1.求累计也就是相对自己的,所有这里的表不够,需要关联自己得到更多的字段,然后一步一步求出,具体可以参考下面程序实现
			2.还可以先预想出目标表的样子, 然后在去一步一步靠近
		2.代码感悟
			1.发现通过分组就可以了,不用求order by,
				最后在还需要展示本月的小费, 这时要注意,不能直接a.asumSalary这样写,
				因为asumSalary不仅仅表示a这个临时表中的一个字段, 它是由聚合函数求出来临时字段,
				所有你也需要用聚合函数来得到里面的值,又因为通过对month和username的分组求和,所有它里面就一个值,所以你用min()或是max()这两个聚合函数都可以


	
	
	-- 自我总结
-- 发现通过分组就可以了,不用求order by,
-- 最后在还需要展示本月的小费, 这时要注意,不能直接a.asumSalary这样写,
-- 因为asumSalary不仅仅表示a这个临时表中的一个字段, 它是由聚合函数求出来临时字段,
-- 所有你也需要用聚合函数来得到里面的值,又因为通过对month和username的分组求和,所有它里面就一个值,所以你用min()或是max()这两个聚合函数都可以
	
	
	
	
create table t_salary_detail(username string,month string,salary int)
row format delimited fields terminated by ',';

load data local inpath '/export/servers/hivedatas/accumulate/t_salary_detail.dat' into table t_salary_detail;

用户	时间	收到小费金额
A,2015-01,5
A,2015-01,15
B,2015-01,5
A,2015-01,8
B,2015-01,25
A,2015-01,5
A,2015-02,4
A,2015-02,6
B,2015-02,10
B,2015-02,5
A,2015-03,7
A,2015-03,9
B,2015-03,11
B,2015-03,6


-- 需求：统计每个用户每个月总共获得多少小费

select t.month,t.username,sum(salary) as salSum
from t_salary_detail t 
group by t.username,t.month;

+----------+-------------+---------+--+
| t.month  | t.username  | salsum  |
+----------+-------------+---------+--+
| 2015-01  | A           | 33      |
| 2015-02  | A           | 10      |
| 2015-03  | A           | 16      |
| 2015-01  | B           | 30      |
| 2015-02  | B           | 15      |
| 2015-03  | B           | 17      |
+----------+-------------+---------+--+


-- 需求：统计每个用户累计小费

+----------+-------------+---------+--+
| t.month  | t.username  | salsum  | 累计小费
+----------+-------------+---------+--+
| 2015-01  | A           | 33      |  33
| 2015-02  | A           | 10      |  43
| 2015-03  | A           | 16      |  59
| 2015-01  | B           | 30      |  30
| 2015-02  | B           | 15      |  45
| 2015-03  | B           | 17      |  62
+----------+-------------+---------+--+



-- 第一步：求每个用户的每个月的累计小费
-- 就是每个客户对上几个月的小费的累加
-- 要对自己的上几个月做累加,所有要关联自己

select t.month,t.username,sum(salary) as salSum
from t_salary_detail t 
group by t.username,t.month;

+----------+-------------+---------+--+
| t.month  | t.username  | salsum  |
+----------+-------------+---------+--+
| 2015-01  | A           | 33      |
| 2015-02  | A           | 10      |
| 2015-03  | A           | 16      |
| 2015-01  | B           | 30      |
| 2015-02  | B           | 15      |
| 2015-03  | B           | 17      |
+----------+-------------+---------+--+



-- 第二步：使用inner join 实现自己连接自己

select
A.* ,B.*
from
(select t.month,t.username,sum(salary) as salSum
from t_salary_detail t 
group by t.username,t.month) A
inner join 
(select t.month,t.username,sum(salary) as salSum
from t_salary_detail t 
group by t.username,t.month) B
on A.username = B.username;

+----------+-------------+-----------+----------+-------------+-----------+--+
| a.month  | a.username  | a.salsum  | b.month  | b.username  | b.salsum  |
+----------+-------------+-----------+----------+-------------+-----------+--+
取这一个作为一组
| 2015-01  | A           | 33        | 2015-01  | A           | 33        |

| 2015-01  | A           | 33        | 2015-02  | A           | 10        |
| 2015-01  | A           | 33        | 2015-03  | A           | 16        |
取这两个作为一组
| 2015-02  | A           | 10        | 2015-01  | A           | 33        |
| 2015-02  | A           | 10        | 2015-02  | A           | 10        |

| 2015-02  | A           | 10        | 2015-03  | A           | 16        |
取这三个作为一组
| 2015-03  | A           | 16        | 2015-01  | A           | 33        |
| 2015-03  | A           | 16        | 2015-02  | A           | 10        |
| 2015-03  | A           | 16        | 2015-03  | A           | 16        |


| 2015-01  | B           | 30        | 2015-01  | B           | 30        |
| 2015-01  | B           | 30        | 2015-02  | B           | 15        |
| 2015-01  | B           | 30        | 2015-03  | B           | 17        |
| 2015-02  | B           | 15        | 2015-01  | B           | 30        |
| 2015-02  | B           | 15        | 2015-02  | B           | 15        |
| 2015-02  | B           | 15        | 2015-03  | B           | 17        |
| 2015-03  | B           | 17        | 2015-01  | B           | 30        |
| 2015-03  | B           | 17        | 2015-02  | B           | 15        |
| 2015-03  | B           | 17        | 2015-03  | B           | 17        |
+----------+-------------+-----------+----------+-------------+-----------+--+





-- 加参数继续变形
select
A.* ,B.*
from
(select t.month,t.username,sum(salary) as salSum
from t_salary_detail t 
group by t.username,t.month) A
inner join 
(select t.month,t.username,sum(salary) as salSum
from t_salary_detail t 
group by t.username,t.month) B
on A.username = B.username
where B.month <= A.month;

-- 自我总结
SELECT 
a.* ,b.*
FROM 
(SELECT MONTH,username, SUM(salary)
FROM t_salary_detail
GROUP BY username ,MONTH) a 
INNER JOIN 
(SELECT MONTH,username, SUM(salary)
FROM t_salary_detail
GROUP BY username ,MONTH) b
ON a.username=b.username 
-- 把一个月对应的上几个月的数据都分成了一组
WHERE b.month<=a.month


+----------+-------------+-----------+----------+-------------+-----------+--+
| a.month  | a.username  | a.salsum  | b.month  | b.username  | b.salsum  |
+----------+-------------+-----------+----------+-------------+-----------+--+
| 2015-01  | A           | 33        | 2015-01  | A           | 33        |
| 2015-02  | A           | 10        | 2015-01  | A           | 33        |
| 2015-02  | A           | 10        | 2015-02  | A           | 10        |
| 2015-03  | A           | 16        | 2015-01  | A           | 33        |
| 2015-03  | A           | 16        | 2015-02  | A           | 10        |
| 2015-03  | A           | 16        | 2015-03  | A           | 16        |
| 2015-01  | B           | 30        | 2015-01  | B           | 30        |
| 2015-02  | B           | 15        | 2015-01  | B           | 30        |
| 2015-02  | B           | 15        | 2015-02  | B           | 15        |
| 2015-03  | B           | 17        | 2015-01  | B           | 30        |
| 2015-03  | B           | 17        | 2015-02  | B           | 15        |
| 2015-03  | B           | 17        | 2015-03  | B           | 17        |
+----------+-------------+-----------+----------+-------------+-----------+--+



-- 第三步：从第二步的结果中继续通过a.month与a.username进行分组,并对分组后的b.salsum进行累加求和即可

select
A.username,A.month,max(A.salSum),sum(B.salSum) as accumulate
from
(select t.month,t.username,sum(salary) as salSum from t_salary_detail t group by t.username,t.month) A
inner join 
(select t.month,t.username,sum(salary) as salSum from t_salary_detail t group by t.username,t.month) B
on A.username = B.username
where B.month <= A.month
group by A.username,A.month
order by A.username,A.month;

-- 自我总结
-- 发现通过分组就可以了,不用求order by,
-- 最后在还需要展示本月的小费, 这时要注意,不能直接a.asumSalary这样写,
-- 因为asumSalary不仅仅表示a这个临时表中的一个字段, 它是由聚合函数求出来临时字段,
-- 所有你也需要用聚合函数来得到里面的值,又因为通过对month和username的分组求和,所有它里面就一个值,所以你用min()或是max()这两个聚合函数都可以
SELECT 
a.username,a.month,MIN(a.asumSalary) ,SUM(b.sumSalary)
FROM 
(SELECT MONTH,username, SUM(salary) asumSalary
FROM t_salary_detail
GROUP BY username ,MONTH) a 
INNER JOIN 
(SELECT MONTH,username, SUM(salary) sumSalary
FROM t_salary_detail
GROUP BY username ,MONTH) b
ON a.username=b.username 
-- 把月份大于本月的数据过滤掉
WHERE b.month<=a.month
GROUP BY a.username,a.month


+-------------+----------+------+-------------+--+
| a.username  | a.month  | _c2  | accumulate  |
+-------------+----------+------+-------------+--+
| A           | 2015-01  | 33   | 33          |
| A           | 2015-02  | 10   | 43          |
| A           | 2015-03  | 16   | 59          |
| B           | 2015-01  | 30   | 30          |
| B           | 2015-02  | 15   | 45          |
| B           | 2015-03  | 17   | 62          |
+-------------+----------+------+-------------+--+






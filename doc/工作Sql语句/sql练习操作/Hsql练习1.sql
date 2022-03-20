-- 创建数据库
create table students(
sno String , 
sname String ,
ssex String , 
sbirthday DATE,
class String)

CREATE TABLE courses
(cno String , 
cname String , 
tno string )

CREATE TABLE scores 
(sno string , 
cno string , 
degree float)

CREATE TABLE teachers 
(tno string, 
tname string, 
tsex string, 
tbirthday date ,
 prof string, 
depart string)

-- 插入数据(在HDFS上用insert直接插入很麻烦的,
-- 可以在HDFS上找到数据库对应的表直接把文件放在对应的目录下即可)


-- 45、查询所有选修“计算机导论”课程的“男”同学的成绩表
-- 需要展示: sname   degree 
-- 条    件: 选修了计算机的课程   性别是男
-- 涉及的表: scores  courses  students
select stu.sno,stu.sname,s.degree
from scores s left join courses c on s.cno=c.cno
left join students stu on stu.sno=s.sno
where c.cname='计算机导论'and stu.ssex='男'
+----------+------------+-----------+--+
| stu.sno  | stu.sname  | s.degree  |
+----------+------------+-----------+--+
| 103      | 陆君         | 92.0      |
| 105      | 匡明         | 88.0      |
| 101      | 李军         | 64.0      |
| 108      | 曾华         | 78.0      |
+----------+------------+-----------+--+

-- impala支持in的语法
-- 这种思路: 直接查询scores表,然后选修了计算机的课程   性别是男这两个条件就是对应的本次查询中的cno和sno字段的约束条件
SELECT *
FROM Scores
WHERE Sno IN (
    SELECT Sno
    FROM Students
    WHERE Ssex='男') AND
    Cno IN (
    SELECT Cno
    FROM Courses
    WHERE Cname='计算机导论');

-- 44、查询和“李军”同性别并同班的同学Sname.
-- 需要展示: sno sname 
-- 条    件: 和李军同性别  和李军同班
-- 涉及的表: students 
select *
from students s inner join students s1 
where s1.sname='李军'
+--------+----------+---------+--------------+----------+---------+-----------+----------+---------------+-----------+--+
| s.sno  | s.sname  | s.ssex  | s.sbirthday  | s.class  | s1.sno  | s1.sname  | s1.ssex  | s1.sbirthday  | s1.class  |
+--------+----------+---------+--------------+----------+---------+-----------+----------+---------------+-----------+--+
| 108    | 曾华       | 男       | 1977-09-01   | 95033    | 101     | 李军        | 男        | 1976-02-20    | 95033     |
| 105    | 匡明       | 男       | 1975-10-02   | 95031    | 101     | 李军        | 男        | 1976-02-20    | 95033     |
| 107    | 王丽       | 女       | 1976-01-23   | 95033    | 101     | 李军        | 男        | 1976-02-20    | 95033     |
| 101    | 李军       | 男       | 1976-02-20   | 95033    | 101     | 李军        | 男        | 1976-02-20    | 95033     |
| 109    | 王芳       | 女       | 1975-02-10   | 95031    | 101     | 李军        | 男        | 1976-02-20    | 95033     |
| 103    | 陆君       | 男       | 1974-06-03   | 95031    | 101     | 李军        | 男        | 1976-02-20    | 95033     |
| 106    | 刘亦菲      | 女       | 1988-03-25   | 95032    | 101     | 李军        | 男        | 1976-02-20    | 95033     |
+--------+----------+---------+--------------+----------+---------+-----------+----------+---------------+-----------+--+

select s.sno,s.sname
from students s inner join students s1 
-- 要和李军的性别一样,要和李军同班级
where s1.sname='李军'and s.ssex=s1.ssex and s1.class=s.class
+--------+----------+---------+--------------+----------+---------+-----------+----------+---------------+-----------+--+
| s.sno  | s.sname  | s.ssex  | s.sbirthday  | s.class  | s1.sno  | s1.sname  | s1.ssex  | s1.sbirthday  | s1.class  |
+--------+----------+---------+--------------+----------+---------+-----------+----------+---------------+-----------+--+
| 108    | 曾华       | 男       | 1977-09-01   | 95033    | 101     | 李军        | 男        | 1976-02-20    | 95033     |
| 101    | 李军       | 男       | 1976-02-20   | 95033    | 101     | 李军        | 男        | 1976-02-20    | 95033     |
+--------+----------+---------+--------------+----------+---------+-----------+----------+---------------+-----------+--+
+--------+----------+--+
| s.sno  | s.sname  |
+--------+----------+--+
| 108    | 曾华       |
| 101    | 李军       |
+--------+----------+--+
-- 优化,尽量吧条件写在on的后面, 以避免笛卡尔积的出现
select s.sno,s.sname
from students s inner join students s1 
on s.ssex=s1.ssex and s.class=s1.class
-- 要和李军的性别一样,要和李军同班级
where s1.sname='李军'

-- 43.查询和“李军”同性别的所有同学的Sname.
-- 需要展示:  sname
-- 条    件: 和李军同性别
-- 涉及的表: students
select s.sno, s.sname
from students s inner join students s1 on(s.ssex=s1.ssex)
where s1.sname='李军'
+-----+-------+
| sno | sname |
+-----+-------+
| 103 | 陆君  |
| 108 | 曾华  |
| 101 | 李军  |
| 105 | 匡明  |
+-----+-------+

-- 42、查询最高分同学的Sno、Cno和Degree列。
-- 需要展示:sno,cno,degree
-- 条    件:分数要最高,这里理解成没课的最高分, 最高分这个条件在student表里没有,所有要再弄一张表和students表做比较,所有要用join语法
-- 涉及的表: scores 
-- 心    得: 1.这个题目中隐含着对比的这个概念,首先你根据求出每课的最高分后,发现需要展示的内容没有,所有你就要在弄一张有需要展示内容的表了,也就是scores表和它做关联,最后在scores表找出分数和最高分一样的符合条件的人
--           2.group by是很纯粹的,select里写了什么,group by一定要是什么,所有的聚合函数都要和group by一起出现
select s.sno,s.cno,s.degree
from scores s left join(
select cno, max(degree)  degreeMax
from scores
group by cno) s1 on(s1.cno=s.cno)
where s.degree=s1.degreeMax
+-----+-------+--------+
| sno | cno   | degree |
+-----+-------+--------+
| 103 | 3-245 | 86     |
| 103 | 3-105 | 92     |
| 101 | 6-166 | 85     |
| 107 | 6-106 | 79     |
+-----+-------+--------+

-- 41、查询“男”教师及其所上的课程。
-- 需要展示: 课程,课程编号,
-- 条    件: 男老师
-- 涉及的表: courses,teachers
-- 心    得: 1.两个表中join操作的时候条件一般是关联的"主键",但是inner自己和自己关联相当于每个字段都是主键,就要根据业务需求去写了
select c.cno,c.cname,t.tname
from courses c left join teachers t on c.tno=t.tno 
where t.tsex='男'
+-------+----------+-------+
| cno   | cname    | tname |
+-------+----------+-------+
| 3-245 | 操作系统 | 李诚  |
| 6-166 | 数据电路 | 张旭  |
+-------+----------+-------+

-- 40、以班号和年龄从大到小的顺序查询Student表中的全部记录
-- 需要展示: students的全部字段
-- 条    件: 班号,年轮都要从大到小, 这里的班号, 年轮在students表里都有,所有不用做比较,所有就是简单的单表操作
-- 涉及的表: students
-- 心    得: 1.不要想的太复杂,这就是一个单表的排序问题
--           2.cast(str as int)这个函数把str类型的变成int类型
--           3.to_date(str)这个函数把str类型的变成日期类型的
select s.*
from students s
order by cast(s.classes as int) desc,to_date(s.sbirthday);
+-----+--------+------+------------+---------+
| sno | sname  | ssex | sbirthday  | classes |
+-----+--------+------+------------+---------+
| 107 | 王丽   | 女   | 1976-01-23 | 95033   |
| 101 | 李军   | 男   | 1976-02-20 | 95033   |
| 108 | 曾华   | 男   | 1977-09-01 | 95033   |
| 106 | 刘亦菲 | 女   | 1988-03-25 | 95032   |
| 103 | 陆君   | 男   | 1974-06-03 | 95031   |
| 109 | 王芳   | 女   | 1975-02-10 | 95031   |
| 105 | 匡明   | 男   | 1975-10-02 | 95031   |
+-----+--------+------+------------+---------+

-- 39、查询Student表中最大和最小的Sbirthday日期值。
-- 需要展示: sbirthday的日期
-- 条    件: 最大,最小
-- 涉及的表: students
-- 心    得: 
select max(to_date(sbirthday)) birthdayMax,min(to_date(sbirthday)) birthdayMin
from students
+-------------+-------------+
| birthdaymax | birthdaymin |
+-------------+-------------+
| 1988-03-25  | 1974-06-03  |
+-------------+-------------+

-- 38、查询Student表中每个学生的姓名和年龄
-- 需要展示:
-- 条    件:
-- 涉及的表:
-- 心    得: year()把字符串转换成年,now()得到当前的年月日时分秒等
select sname ,year(now())-year(sbirthday) year
from students
+--------+------+
| sname  | year |
+--------+------+
| 陆君   | 44   |
| 刘亦菲 | 30   |
| 曾华   | 41   |
| 王芳   | 43   |
| 李军   | 42   |
| 匡明   | 43   |
| 王丽   | 42   |
+--------+------+

-- 37、查询Student表中不姓“王”的同学记录。
-- 需要展示: sno,sname,
-- 条    件: 不姓王 ,姓氏不为王这个条件在student表中有
-- 涉及的表: students 
-- 心    得:
select *
from students
where sname not like '王%'

-- 36、查询至少有2名男生的班号
-- 需要展示: 班号classes,
-- 条    件: 至少有两个男生,这里需要计算个数,要以班级分组,再求数量
-- 涉及的表: students
-- 心    得:
select classes,count(1) c 
from students
where ssex='男'
group by classes
having c>2

-- 35  查询所有未讲课的教师的Tname和Depart.
-- 需要展示: tname,depart
-- 条    件: 未讲过课的
-- 涉及的表: courses,teachers
-- 心    得:
select t.tname,t.depart
from teachers t left join courses c on t.tno=c.tno 
where c.cno is null;
+-------+------------+
| tname | depart     |
+-------+------------+
| 刘冰  | 电子工程系 |
+-------+------------+

-- 34、查询所有任课教师的Tname和Depart.
-- 需要展示: tname,depart
-- 条    件: 要有任课的
-- 涉及的表: courses,teachers
-- 心    得: 
select t.tname,t.depart,c.cno
from teachers t left join courses c on t.tno=c.tno
where c.cno is not null;
+-------+------------+-------+
| tname | depart     | cno   |
+-------+------------+-------+
| 李诚  | 计算机系   | 3-245 |
| 张旭  | 电子工程系 | 6-166 |
| 王萍  | 计算机系   | 3-105 |
+-------+------------+-------+

-- 33、查询成绩比该课程平均成绩低的同学的成绩表。
-- 需要展示: 成绩表(sno,cno,degree)
-- 条    件: 平均成绩,要比平均成绩低,平均成绩的表里没有
-- 涉及的表: scores,courses,
-- 心    得: 1.hive不支持把聚合函数的结果写到on表达式后面做过滤条件
--           2.impala支持聚合函数的结果写到on表达式中,而且对应的各种join方式得到的答案不一样
-- 1.先算每科的平均成绩
select cno,avg(degree) dAvg
from scores
group by cno
+-------+-------------------+
| cno   | davg              |
+-------+-------------------+
| 6-166 | 83                |
| 6-106 | 79                |
| 3-105 | 81.5              |
| 3-245 | 76.33333333333333 |
+-------+-------------------+
-- 2.在和成绩表关联,找出比平均分低的人
select s.*
from scores s left join (
select cno,avg(degree) dAvg
from scores
group by cno) sAvg on sAvg.cno=s.cno 
where s.degree<sAvg.dAvg

-- hive中不能跑, impala中能跑
SELECT s1.*
FROM Scores AS s1 INNER JOIN (
SELECT Cno,AVG(Degree) AS aDegree
FROM Scores
GROUP BY Cno) s2
-- ON s1.Degree<s2.aDegree ; 
ON s1.Cno=s2.Cno AND s1.Degree<s2.aDegree ; 
+-----+-------+--------+
| sno | cno   | degree |
+-----+-------+--------+
| 105 | 3-245 | 75     |
| 109 | 3-245 | 68     |
| 109 | 3-105 | 76     |
| 101 | 3-105 | 64     |
| 108 | 3-105 | 78     |
| 108 | 6-166 | 81     |
+-----+-------+--------+

-- 32、查询所有“女”教师和“女”同学的name、sex和birthday.
-- 需要展示: 教师的name,sex,birthday,学生的name,sex,birthday
-- 条    件: 要女的
-- 涉及的表: teachers,students
-- 心    得: 教师表和学生表没有关联的字段,要一起出现只能用union
select tname,tsex,tbirthday
from teachers 
where tsex='女'
union all
select sname,ssex,sbirthday
from students
where ssex='女'

-- 30、查询选修编号为“3-105”且成绩高于选修编号为“3-245”课程的同学的Cno、Sno和Degree.
-- 需要展示: 学生的成绩表(sno,cno,degree)
-- 条    件: 选修编号要为“3-105”, 而且它的成绩要所有比“3-245”高
-- 涉及的表: scores
-- 心    得: 1.所有两个字说明要比3-245中最高的成绩还要高
--           2.inner join和right join的效果一样,都是以join的右边的表为主,和左边的做比较如果符合on的条件就留下,如果不符合就直接丢掉
--             left join是以左边的表为主,每一条数据都和右边的表的每一条,做比较,符合条件的就留下,不符合条件的就丢弃,
--             如果把右边的全部匹配一边仍然没有符合条件的那就把在右边对应的位置填上null
select s1.*,s2.*
from(
select sno,cno,degree 
from scores 
where cno='3-105'
) s1 right outer join (
select cno,max(degree) deMax
from scores
where cno='3-245'
group by cno
)s2 on s1.degree>s2.deMax
-- where s1.degree>s2.deMax
order by s1.degree
+-----+-------+--------+
| sno | cno   | degree |
+-----+-------+--------+
| 105 | 3-105 | 88     |
| 107 | 3-105 | 91     |
| 103 | 3-105 | 92     |
+-----+-------+--------+



-- 30、查询选修编号为“3-105”且成绩高于选修编号为“3-245”课程的同学的Cno、Sno和Degree.
-- 需要展示: 学生的成绩表(sno,cno,degree)
-- 条    件: 选修编号要为“3-105”, 而且它的成绩要比“3-245”高
-- 涉及的表: scores
-- 心    得: 这里隐藏了一个条件那就是这个学生要同时选修了两门课程
-- 1.选修编号为3-105
select s1.*,s2.*
from(
select sno,cno,degree 
from scores 
where cno='3-105'
) s1 left outer join (
select sno,degree
from scores
where cno='3-245'
)s2 on s1.sno=s2.sno
where s1.degree>s2.degree
order by s1.degree
+-----+-------+--------+
| sno | cno   | degree |
+-----+-------+--------+
| 109 | 3-105 | 76     |
| 105 | 3-105 | 88     |
| 103 | 3-105 | 92     |
+-----+-------+--------+
-- 29、查询选修编号为“3-105“课程且成绩至少高于选修编号为“3-245”的
-- 同学的Cno、Sno和Degree,并按Degree从高到低次序排序
-- 需要展示: 
-- 条    件: 
-- 涉及的表: 
-- 心    得: 至少要高于--->比3-245的最低分高就可以了
select s1.*
from(
select sno,cno,degree 
from scores 
where cno='3-105'
) s1 inner join (
select cno,min(degree) deMin
from scores
where cno='3-245'
group by cno
)s2 on s1.degree>s2.deMin
order by s1.degree desc
+-----+-------+--------+
| sno | cno   | degree |
+-----+-------+--------+
| 103 | 3-105 | 92     |
| 107 | 3-105 | 91     |
| 105 | 3-105 | 88     |
| 108 | 3-105 | 78     |
| 109 | 3-105 | 76     |
+-----+-------+--------+

-- 28、查询“计算机系”与“电子工程系“不同职称的教师的Tname和Prof。
-- 需要展示: 教师的tname,prof 
-- 条    件: 是计算机系,和电子工程系,职称要不同
-- 涉及的表: teachers
-- 心    得: 1.可以理解成,假设你是计算机系的, 那么同时你的职称就不能和这些计算机系的老师职称一样就行
--           2.在impala中支持in这种语法
select tname,prof
from teachers
where depart='计算机系' and 
prof not in(
select prof
from teachers
where depart='电子工程系'
)
+-------+--------+
| tname | prof   |
+-------+--------+
| 李诚  | 副教授 |
+-------+--------+

-- 27、查询出“计算机系“教师所教课程的成绩表。
-- 需要展示: 成绩表
-- 条    件: 要求是计算机系的老师
-- 涉及的表: teachers, courses,scores
-- 心    得: 
select *
from scores s
where cno in(
select s.cno
from courses s inner join(
select tno
from teachers 
where depart='计算机系'
)t on s.tno=t.tno
) order by degree desc;
+-----+-------+--------+
| sno | cno   | degree |
+-----+-------+--------+
| 103 | 3-105 | 92     |
| 107 | 3-105 | 91     |
| 105 | 3-105 | 88     |
| 103 | 3-245 | 86     |
| 108 | 3-105 | 78     |
| 109 | 3-105 | 76     |
| 105 | 3-245 | 75     |
| 109 | 3-245 | 68     |
| 101 | 3-105 | 64     |
+-----+-------+--------+

-- 教案里的答案
SELECT Tname,Cname,SName,Degree
FROM Teachers INNER JOIN Courses
ON(Teachers.Tno=Courses.Tno) INNER JOIN Scores
ON(Courses.Cno=Scores.Cno) INNER JOIN Students
ON(Scores.Sno=Students.Sno)
WHERE Teachers.Depart='计算机系'
ORDER BY Tname,Cname,Degree DESC;
+-------+------------+-------+--------+
| tname | cname      | sname | degree |
+-------+------------+-------+--------+
| 李诚  | 操作系统   | 陆君  | 86     |
| 李诚  | 操作系统   | 匡明  | 75     |
| 李诚  | 操作系统   | 王芳  | 68     |
| 王萍  | 计算机导论 | 陆君  | 92     |
| 王萍  | 计算机导论 | 王丽  | 91     |
| 王萍  | 计算机导论 | 匡明  | 88     |
| 王萍  | 计算机导论 | 曾华  | 78     |
| 王萍  | 计算机导论 | 王芳  | 76     |
| 王萍  | 计算机导论 | 李军  | 64     |
+-------+------------+-------+--------+

-- 26、查询存在有85分以上成绩的课程Cno.
-- 需要展示: 
-- 条    件: 
-- 涉及的表: 
-- 心    得: 
select cno
from scores
where degree>85
+-------+
| cno   |
+-------+
| 3-245 |
| 3-105 |
| 3-105 |
| 3-105 |
+-------+

-- 25、查询95033班和95031班全体学生的记录。
select *
from students
where classes in('95033','95031')
+-----+-------+------+------------+---------+
| sno | sname | ssex | sbirthday  | classes |
+-----+-------+------+------------+---------+
| 103 | 陆君  | 男   | 1974-06-03 | 95031   |
| 108 | 曾华  | 男   | 1977-09-01 | 95033   |
| 101 | 李军  | 男   | 1976-02-20 | 95033   |
| 107 | 王丽  | 女   | 1976-01-23 | 95033   |
| 109 | 王芳  | 女   | 1975-02-10 | 95031   |
| 105 | 匡明  | 男   | 1975-10-02 | 95031   |
+-----+-------+------+------------+---------+

-- 24、查询选修某课程的同学人数多于5人的教师姓名。
-- 需要展示: 教师名称,
-- 条    件: 选修某课程-->给课程分组,同学的人数-->给每组计数,选出计数大于5教师姓名
-- 涉及的表: 
-- 心    得: 
select te.tname
from courses cou right join(
select cno,count(1) c
from scores
group by cno
having c>5)tem on tem.cno=cou.cno
inner join 
teachers te on te.tno=cou.tno
+-------+
| tname |
+-------+
| 王萍  |
+-------+
-- 教案的作法
SELECT DISTINCT Tname
FROM Scores INNER JOIN Courses
ON(Scores.Cno=Courses.Cno) INNER JOIN Teachers
ON(Courses.Tno=Teachers.Tno)
WHERE Courses.Cno IN(SELECT Cno FROM Scores GROUP BY(Cno) HAVING COUNT(Sno)>5);

-- 23、查询“张旭“教师任课的学生成绩。
-- 需要展示: 学生的成绩
-- 条    件: 张旭老师任的课
-- 涉及的表: scores,teachers,courses
-- 心    得: 从目的开始也可以,就是跟教案一样

select s.sno,s.degree
from courses c right join(
select tno
from teachers
where tname='张旭')t on t.tno=c.tno
left join scores s on c.cno=s.cno
+-----+--------+
| sno | degree |
+-----+--------+
| 108 | 81     |
| 101 | 85     |
+-----+--------+
-- 教案的作法
SELECT Sno,Degree
FROM Scores INNER JOIN Courses
ON(Scores.Cno=Courses.Cno) INNER JOIN Teachers
ON(Courses.Tno=Teachers.Tno)
WHERE Teachers.Tname='张旭';

-- 22、查询和学号为108的同学同年出生的所有学生的Sno、Sname和Sbirthday列
-- 需要展示: 学生的sno,sname,sbirthday
-- 条    件: 和学号是108的同学同年出生
-- 涉及的表: students
-- 心    得: 1.先求出容易求出的步骤,然后在慢慢的靠近结果
select s.sno,s.sname,s.sbirthday
from students s right join(
select year(sbirthday) b
from students 
where sno='108') tem on tem.b=year(s.sbirthday)
+-----+-------+------------+
| sno | sname | sbirthday  |
+-----+-------+------------+
| 108 | 曾华  | 1977-09-01 |
+-----+-------+------------+

-- 21、查询成绩高于学号为“109”、课程号为“3-105”的成绩的所有记录。
-- 需要展示: 
-- 条    件: 成绩高于学号为109的,成绩高于课程号为3-105的学生的所有信息
-- 涉及的表: scores,students
-- 心    得: 
select s.*
from scores s right join(
select degree,sno
from scores
where sno='109' and cno='3-105'
) tem on tem.degree<s.degree 
+-----+-------+--------+
| sno | cno   | degree |
+-----+-------+--------+
| 103 | 3-245 | 86     |
| 103 | 3-105 | 92     |
| 105 | 3-105 | 88     |
| 107 | 3-105 | 91     |
| 108 | 3-105 | 78     |
| 101 | 6-166 | 85     |
| 107 | 6-106 | 79     |
| 108 | 6-166 | 81     |
+-----+-------+--------+ 

-- 20、查询score中选学一门以上课程的同学中分数为非最高分成绩的记录
-- 需要展示: scores表的所有记录
-- 条    件: 选学一门以上-->以学生分组>1,符合上面条件后求非最大值的那些记录
-- 涉及的表: scores
-- 心    得: 选学一门以上-->要注意这里是以学生分组,不是以课程,以课程分组是选修了这门课程的人
-- 题目都没有讲清楚
select max(sc.degree)
from scores sc left join(
select sno, count(1) c
from scores
group by sno
having c>1 
) tem on tem.



select s.sno, count(1) c
from scores s right join (
select sno,max(degree) m
from scores
group by sno
)tem on s.degree<>tem.m
group by s.sno
having c>1 
+-----+----+
| sno | c  |
+-----+----+
| 105 | 11 |
| 107 | 11 |
| 108 | 11 |
| 101 | 11 |
| 103 | 11 |
| 109 | 11 |
+-----+----+

-- 19、查询选修“3-105”课程的成绩高于“109”号同学成绩的所有同学的记录。
-- 需要展示: 
-- 条    件: 选修3-105课程的成绩,高于109号同学的成绩-->因为109号好几个成绩高于他的最高的成绩就可以
-- 涉及的表: 教案的作法中为什么用cno相等作为过滤的条件
-- 心    得: 
select t1.*
from (
select sno,cno,degree
from scores
where cno='3-105') t1 right join(
select max(degree)m
from scores
where sno='109'
) t2 on(t1.degree>t2.m)
+-----+-------+--------+
| sno | cno   | degree |
+-----+-------+--------+
| 103 | 3-105 | 92     |
| 105 | 3-105 | 88     |
| 107 | 3-105 | 91     |
| 108 | 3-105 | 78     |
+-----+-------+--------+
-- 教案的作法
SELECT s1.Sno,s1.Degree
FROM Scores AS s1 INNER JOIN Scores AS s2
ON(s1.Cno=s2.Cno AND s1.Degree>s2.Degree)
-- ON(s1.sno=s2.sno AND s1.Degree>s2.Degree)
WHERE s1.Cno='3-105' AND s2.Sno='109'
ORDER BY s1.Sno;
-- 17、查询“95033”班所选课程的平均分。
select degree
from students
where classes='95033'

select sc.cno,avg(sc.degree)
from students s inner join scores sc 
on s.sno=sc.sno and s.classes='95033'
group by sc.cno
+-------+-------------------+
| cno   | avg(sc.degree)    |
+-------+-------------------+
| 6-166 | 83                |
| 3-105 | 77.66666666666667 |
| 6-106 | 79                |
+-------+-------------------+

-- 16、查询所有学生的Sname、Cname和Degree列。
SELECT Sname,Cname,Degree
FROM Students LEFT JOIN Scores
ON(Students.Sno=Scores.Sno) INNER JOIN Courses
ON(Scores.Cno=Courses.Cno)
ORDER BY Sname;
-- 15、查询所有学生的Sno、Cname和Degree列。
SELECT Sno,Cname,Degree
FROM Scores INNER JOIN Courses
ON(Scores.Cno=Courses.Cno)
ORDER BY Sno;
-- 14.查询所有学生的Sname、Cno和Degree列。
SELECT Sname,Cno,Degree
FROM Students INNER JOIN Scores 
ON(Students.Sno=Scores.Sno)
ORDER BY Sname;
-- 13.查询最低分大于70，最高分小于90的Sno列。
SELECT Sno
FROM Scores
GROUP BY Sno
HAVING MAX(Degree)<90 AND MIN(Degree)>70;
-- 12.查询Score表中至少有5名学生选修的并以3开头的课程的平均分数。
-- 需要展示: 
-- 条    件: 至少有5名选修,以3开头的课程
-- 涉及的表: scores
-- 心    得: 
select cno,avg(degree)
from  scores 
where cno like '3%'
group by cno
having count(1)>5
+-------+-------------+
| cno   | avg(degree) |
+-------+-------------+
| 3-105 | 81.5        |
+-------+-------------+

-- 11.查询‘3-105’号课程的平均分。
SELECT AVG(Degree)
FROM Scores
WHERE Cno='3-105';
-- 10.查询Score表中的最高分的学生学号和课程号。
SELECT Sno,Cno
FROM Scores
ORDER BY Degree DESC
LIMIT 1;
-- 9.查询“95031”班的学生人数。
SELECT COUNT(1) AS StuNum
FROM Students
WHERE Class='95031';
-- 8.以Cno升序、Degree降序查询Score表的所有记录。
SELECT *
FROM Scores
ORDER BY Cno,Degree DESC;
-- 7.以Class降序查询Student表的所有记录。
SELECT *
FROM Students
ORDER BY Class DESC;
-- 6.查询Student表中“95031”班或性别为“女”的同学记录。
SELECT *
FROM Students
WHERE Class='95031' OR Ssex='女';

-- 5.查询Score表中成绩为85，86或88的记录。
SELECT *
FROM Scores
WHERE Degree IN (85,86,88);
-- 4.查询Score表中成绩在60到80之间的所有记录。
SELECT *
FROM Scores
WHERE Degree BETWEEN 60 AND 80;

-- 3.查询Student表的所有记录。
SELECT *
FROM Students;
-- 2.查询教师所有的单位即不重复的Depart列。
SELECT DISTINCT Depart
FROM Teachers;

-- 1.查询Student表中的所有记录的Sname、Ssex和Class列。
SELECT Sname,Ssex,Class
FROM Student;

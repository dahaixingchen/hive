-- 45. 查询下月过生日的学生(这里有个bug-->如果生日为1月份的就不好弄了)
select birth.name,birth.bir ,nowtimes.nowmonth
from 
(select s.sname name ,month(s.sage) bir
from student s)birth
right join(
SELECT MONTH(FROM_UNIXTIME(UNIX_TIMESTAMP(),'yyyy-MM-dd'))
nowmonth) nowtimes
on(nowtimes.nowmonth+1 = birth.bir)
-- 45. 查询下月过生日的学生(这个答案还可以)
select birth.name,birth.bir ,nowtimes.nowmonth
from 
(select s.sname name ,month(s.sage) bir
from student s)birth
right join(
SELECT MONTH(FROM_UNIXTIME(UNIX_TIMESTAMP(),'yyyy-MM-dd'))
nowmonth) nowtimes
on(if(nowtimes.nowmonth=12,0,nowtimes.nowmonth)+1 = birth.bir)


-- 44. 查询本月过生日的学生
select birth.name,birth.bir ,nowtimes.nowmonth
from 
(select s.sname name ,cast(month(s.sage) as int) bir
from student s)birth
right join(
SELECT cast(MONTH(FROM_UNIXTIME(UNIX_TIMESTAMP(),'yyyy-MM-dd')) as int)
nowmonth) nowtimes
on(nowtimes.nowmonth = birth.bir)


-- 43. 查询下周过生日的学生(weekofyear()得到的是一年中的第几个星期,到了来年又会从新归0的)
select birth.name,birth.bir ,nowtimes.nowweek
from 
(select s.sname name ,weekofyear(s.sage) bir
from student s)birth
right join(
SELECT weekofyear(FROM_UNIXTIME(UNIX_TIMESTAMP(),'yyyy-MM-dd'))
nowweek) nowtimes
on(nowtimes.nowweek+1 = birth.bir)

-- 42. 查询本周过生日的学生
select birth.name,birth.bir ,nowtimes.nowweek
from 
(select s.sname name ,weekofyear(s.sage) bir
from student s)birth
right join(
SELECT weekofyear(FROM_UNIXTIME(UNIX_TIMESTAMP(),'yyyy-MM-dd'))
nowweek) nowtimes
on(nowtimes.nowweek = birth.bir)
-- 41.(算周岁)按照出生日期来算，当前月日 < 出生年的月日则，年龄减一
-- '1990-01-20'
-- 思路:把当前的年月日和学生的出生年月日都分别拎出来,做比较,做运算就可以了
-- 知识:1.from_unixtime()拎出来的是字符串要转成int另行比较
--      2.条件判断句中case和end是开始和结束的标志,when可以看做是if,then是if条件判断成功后的具体实现, 可以嵌套使用
select  (case when cast(from_unixtime(unix_timestamp(),'MM')as int)<month(sage)
then cast(from_unixtime(unix_timestamp(),'yyyy')as int)-year(sage) when  
cast(from_unixtime(unix_timestamp(),'MM')as int)=month(sage) then 
(case when cast(from_unixtime(unix_timestamp(),'dd')as int)<day(sage) then cast(from_unixtime(unix_timestamp(),'yyyy')as int)-year(sage) else cast(from_unixtime(unix_timestamp(),'yyyy')as int)-year(sage)+1 end) 
else cast(from_unixtime(unix_timestamp(),'yyyy')as int)-year(sage)+1 end) age
from student

-- 40. 查询各学生的年龄，只按年份来算
select cast(from_unixtime(unix_timestamp(),'yyyy')as int)-year(sage) age
from student

-- 39. 查询选修了全部课程的学生信息
-- 展示: 学生信息
-- 条件: 选修了全部课程--->所有选修课的数量之和表示即可
-- 涉及的表: student,sc,course
-- 思路: 以sc表按照学生的标号分组,可以求出对应标号的学生选修的课程的总数,然后求出course表中的总的课程数量, 两个做比较, 如果相等的说明是选修了全部的
select st.*
from(
select s.sno ss
from (select sno,count(1)con from sc group by sno)s
right join (select count(1)co from course) c
on (s.con=c.co))tem left join student st
on(tem.ss=st.sno)
order by st.sno;


-- 38. 检索至少选修两门课程的学生学号
select sno from sc group by sno
having count(1)>=2
order by sno;

-- 37. 统计每门课程的学生选修人数（超过 5 人的课程才统计)



























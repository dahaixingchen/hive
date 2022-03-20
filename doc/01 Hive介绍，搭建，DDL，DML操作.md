# 一、 Hive的基本介绍

### 1、hive产生的原因

·	a) 方便对文件及数据的元数据进行管理，提供统一的元数据管理方式

​	 b) 提供更加简单的方式来访问大规模的数据集，使用SQL语言进行数据分析

### 2、hive是什么？

```
The Apache Hive ™ data warehouse software facilitates reading, writing, and managing large datasets residing in distributed storage using SQL. Structure can be projected onto data already in storage. A command line tool and JDBC driver are provided to connect users to Hive.
```

​		Hive经常被大数据企业用作企业级数据仓库。

​		Hive在使用过程中是使用SQL语句来进行数据分析，由SQL语句到具体的任务执行还需要经过解释器，编译器，优化器，执行器四部分才能完成。

​		（1）解释器：调用语法解释器和语义分析器将SQL语句转换成对应的可执行的java代码或者业务代码

​		（2）编译器：将对应的java代码转换成字节码文件或者jar包

​		（3）优化器：从SQL语句到java代码的解析转化过程中需要调用优化器，进行相关策略的优化，实现最优的								 查询性能

​		（4）执行器：当业务代码转换完成之后，需要上传到MapReduce的集群中执行

### 3、数据仓库--Hive	

#### 		1、数据仓库基本概念

​	    数据仓库，英文名称为Data Warehouse，可简写为DW或DWH。数据仓库，是为企业所有级别的决策制定过程，提供所有类型数据支持的战略集合。它是单个数据存储，出于分析性报告和决策支持目的而创建。 为需要业务智能的企业，提供指导业务流程改进、监视时间、成本、质量以及控制。

#### 		2、数据处理分类：OLAP与OLTP

​		数据处理大致可以分成两大类：联机事务处理OLTP（on-line transaction processing）、联机分析处理OLAP（On-Line Analytical Processing）。OLTP是传统的关系型数据库的主要应用，主要是基本的、日常的事务处理，例如银行交易。OLAP是数据仓库系统的主要应用，支持复杂的分析操作，侧重决策支持，并且提供直观易懂的查询结果。

#### 		3、OLTP

​		OLTP，也叫联机事务处理（Online Transaction Processing），表示事务性非常高的系统，一般都是高可用的在线系统，以小的事务以及小的查询为主，评估其系统的时候，一般看其每秒执行的Transaction以及Execute SQL的数量。在这样的系统中，单个数据库每秒处理的Transaction往往超过几百个，或者是几千个，Select 语句的执行量每秒几千甚至几万个。典型的OLTP系统有电子商务系统、银行、证券等，如美国eBay的业务数据库，就是很典型的OLTP数据库。

#### 		4、OLAP

​		OLAP（On-Line Analysis Processing）在线分析处理是一种共享多维信息的快速分析技术；OLAP利用多维数据库技术使用户从不同角度观察数据；OLAP用于支持复杂的分析操作，侧重于对管理人员的决策支持，可以满足分析人员快速、灵活地进行大数据复量的复杂查询的要求，并且以一种直观、易懂的形式呈现查询结果，辅助决策。

##### 		基本概念：

​			度量：数据度量的指标，数据的实际含义
​			维度：描述与业务主题相关的一组属性
​			事实：不同维度在某一取值下的度量

##### 		特点：

​			(1)快速性：用户对OLAP的快速反应能力有很高的要求。系统应能在5秒内对用户的大部分分析要求做出反								应。
​			(2)可分析性：OLAP系统应能处理与应用有关的任何逻辑分析和统计分析。

​			(3)多维性：多维性是OLAP的关键属性。系统必须提供对数据的多维视图和分析,包括对层次维和多重层次								维的完全支持。
​			(4)信息性：不论数据量有多大，也不管数据存储在何处，OLAP系统应能及时获得信息，并且管理大容量信								息。

##### 		分类：

​			按照存储方式分类：

​					ROLAP：关系型在线分析处理

​					MOLAP：多维在线分析处理

​					HOLAP：混合型在线分析处理

​			按照处理方式分类：

​					Server OLAP和Client OLAP

##### 		操作：

![相关名词的解释](../hive-udf/image/OLAP.png)

​			钻取：在维的不同层次间的变化，从上层降到下一层，或者说将汇总数据拆分到更细节的数据，比如通过						对2019年第二季度的总销售数据进行钻取来查看2019年4,5,6,每个月的消费数据，再例如可以钻取						浙江省来查看杭州市、温州市、宁波市......这些城市的销售数据
​			上卷：钻取的逆操作，即从细粒度数据向更高汇总层的聚合，如将江苏省、上海市、浙江省的销售数据进						行汇总来查看江浙沪地区的销售数据
​			切片：选择维中特定的值进行分析，比如只选择电子产品的销售数据或者2019年第二季度的数据
​			切块：选择维中特定区间的数据或者某批特定值进行分析，比如选择2019年第一季度到第二季度的销售数						据或者是电子产品和日用品的销售数据
​			旋转：维的位置互换，就像是二维表的行列转换，比如通过旋转来实现产品维和地域维的互换		

### 4、数据库与数据仓库的区别

​		**注意：前三条重点掌握理解，后面的了解即可**				

​		**1、数据库是对业务系统的支撑，性能要求高，相应的时间短，而数据仓库则对响应时间没有太多的要求，当然也是越快越好**

​		**2、数据库存储的是某一个产品线或者某个业务线的数据，数据仓库可以将多个数据源的数据经过统一的规则清洗之后进行集中统一管理**

​		**3、数据库中存储的数据可以修改，无法保存各个历史时刻的数据，数据仓库可以保存各个时间点的数据，形成时间拉链表，可以对各个历史时刻的数据做分析**

​		4、数据库一次操作的数据量小，数据仓库操作的数据量大

​		5、数据库使用的是实体-关系（E-R）模型，数据仓库使用的是星型模型或者雪花模型

​		6、数据库是面向事务级别的操作，数据仓库是面向分析的操作

# 二、hvie的架构

## 1、Hive的架构图

![](../hive-udf/image/hive架构图.png)





## 2、Hive的服务（角色）



### 1、用户访问接口
 CLI（Command Line Interface）：用户可以使用Hive自带的命令行接口执行Hive QL、设置参数等功能
 JDBC/ODBC：用户可以使用JDBC或者ODBC的方式在代码中操作Hive

### 2、Thrift Server:
 Thrift服务运行客户端使用Java、C++、Ruby等多种语言，通过编程的方式远程访问Hive

### 3、Driver
 Hive Driver是Hive的核心，其中包含解释器、编译器、优化器等各个组件，完成从SQL语句到MapReduce任务的解析优化执行过程

### 4、metastore
 Hive的元数据存储服务，一般将数据存储在关系型数据库中，为了实现Hive元数据的持久化操作，Hive的安装包中自带了Derby内存数据库，但是在实际的生产环境中一般使用mysql来存储元数据

## 3、hive的访问流程

![](../hive-udf/image/访问流程图.png)

# 三、Hive-2.3.4的安装和搭建

## 1、官网中解释解释的安装

[官方文档，请点击](https://cwiki.apache.org/confluence/display/Hive/AdminManual+Metastore+Administration)

## 2、使用远程数据库mysql作为元数据存储

架构图![dfasd](../hive-udf/image/远程数据库模式安装.png)

只需修改hive的hive-site.xml文件（所有需要启动hive的机器都需要）

```xml
<configuration>
<property>
	<name>hive.metastore.warehouse.dir</name>
	<value>/user/hive/warehouse</value>
</property>
<property>
	<name>javax.jdo.option.ConnectionURL</name>
	<value>jdbc:mysql://node03:3306/hive?createDatabaseIfNotExist=true</value>
</property>
<property>
	<name>javax.jdo.option.ConnectionDriverName</name>
	<value>com.mysql.jdbc.Driver</value>
</property>
<property>
	<name>javax.jdo.option.ConnectionUserName</name>
	<value>root</value>
</property>
<property>
	<name>javax.jdo.option.ConnectionPassword</name>
	<value>123456</value>
</property>
</configuration>
```

## 3、使用本地/远程元数据服务模式安装hive

架构图![](../hive-udf/image/远程元数据服务安装.png)

hive-site.xml文件跟**使用远程数据库mysql作为元数据存储**配置一样（**启动metastore的服务端机器**）

对应的服务这台想要启动客户端，不需要另外配置东西

```xml
<configuration>
<property>
	<name>hive.metastore.warehouse.dir</name>
	<value>/user/hive/warehouse</value>
</property>
<property>
	<name>javax.jdo.option.ConnectionURL</name>
	<value>jdbc:mysql://node03:3306/hive?createDatabaseIfNotExist=true</value>
</property>
<property>
	<name>javax.jdo.option.ConnectionDriverName</name>
	<value>com.mysql.jdbc.Driver</value>
</property>
<property>
	<name>javax.jdo.option.ConnectionUserName</name>
	<value>root</value>
</property>
<property>
	<name>javax.jdo.option.ConnectionPassword</name>
	<value>123456</value>
</property>
</configuration>
```

hive-site.xml（**启动服务端的机器**）

```xml
<configuration>
# node03是Thrift机器的服务IP
<property>
	<name>hive.metastore.uris</name>
	<value>thrift://node03:9083</value>
</property>
</configuration>
```

然后初始化hive的元数据库（mysql）和启动metastore服务

```shell
schematool -dbType mysql -initSchema
hive --service metastore
```

## 4、hiveserver2的配置（在使用metastore模式下）

​	hiveserver2服务是一个可选的服务，它能实现用jdbc的方式来链接hive，对外提供DQL的查询功能

​	在搭建hiveserver2服务的时候需要修改hdfs的超级用户的管理权限，修改配置如下：

```xml
--在hdfs集群的core-site.xml文件中添加如下配置文件
	<!--  -->
	<property>
		<name>hadoop.proxyuser.root.groups</name>	
		<value>*</value>
    </property>
    <property>
		<name>hadoop.proxyuser.root.hosts</name>	
		<value>*</value>
    </property>

--配置完成之后重新启动集群，或者在namenode的节点上执行如下命令
	hdfs dfsadmin -fs hdfs://node01:8020 -refreshSuperUserGroupsConfiguration
	hdfs dfsadmin -fs hdfs://node02:8020 -refreshSuperUserGroupsConfiguration
```



# 四、Hive基本Sql操作

## 1、官网创建表的语法

```sql
-- external 表示外部表
CREATE [TEMPORARY] [EXTERNAL] TABLE [IF NOT EXISTS] [db_name.]table_name    -- 			(Note: TEMPORARY available in Hive 0.14.0 and later)
  		[(col_name data_type [COMMENT col_comment], ... [constraint_specification])]
  		[COMMENT table_comment]
  		[PARTITIONED BY (col_name data_type [COMMENT col_comment], ...)]
  		[CLUSTERED BY (col_name, col_name, ...) [SORTED BY (col_name [ASC|DESC], ...)] 				INTO num_buckets BUCKETS]
  		[SKEWED BY (col_name, col_name, ...)                  -- (Note: Available in Hive 			0.10.0 and later)]
     	ON ((col_value, col_value, ...), (col_value, col_value, ...), ...)
     	[STORED AS DIRECTORIES]
  		[
   			[ROW FORMAT row_format] 
   			[STORED AS file_format]
     		| STORED BY 'storage.handler.class.name' [WITH SERDEPROPERTIES (...)]  -- 				(Note: Available in Hive 0.6.0 and later)
  		]
  		[LOCATION hdfs_path]
  		[TBLPROPERTIES (property_name=property_value, ...)]   -- (Note: Available in Hive 			0.6.0 and later)
  		[AS select_statement];   -- (Note: Available in Hive 0.5.0 and later; not 					supported for external tables)
 
		CREATE [TEMPORARY] [EXTERNAL] TABLE [IF NOT EXISTS] [db_name.]table_name
  			LIKE existing_table_or_view_name
  		[LOCATION hdfs_path];
 		-- 复杂数据类型
		data_type
  		 : primitive_type
  		 | array_type
  		 | map_type
  		 | struct_type
  		 | union_type  -- (Note: Available in Hive 0.7.0 and later)
 		-- 基本数据类型
		primitive_type
 		 : TINYINT
 		 | SMALLINT
 		 | INT
 		 | BIGINT
 		 | BOOLEAN
 		 | FLOAT
 		 | DOUBLE
  		 | DOUBLE PRECISION -- (Note: Available in Hive 2.2.0 and later)
 		 | STRING
 		 | BINARY      -- (Note: Available in Hive 0.8.0 and later)
 		 | TIMESTAMP   -- (Note: Available in Hive 0.8.0 and later)
 		 | DECIMAL     -- (Note: Available in Hive 0.11.0 and later)
 		 | DECIMAL(precision, scale)  -- (Note: Available in Hive 0.13.0 and later)
 		 | DATE        -- (Note: Available in Hive 0.12.0 and later)
 		 | VARCHAR     -- (Note: Available in Hive 0.12.0 and later)
 		 | CHAR        -- (Note: Available in Hive 0.13.0 and later)
 
		array_type
 		 : ARRAY < data_type >
 
		map_type
 		 : MAP < primitive_type, data_type >
 
		struct_type
 		 : STRUCT < col_name : data_type [COMMENT col_comment], ...>
 
		union_type
  		 : UNIONTYPE < data_type, data_type, ... >  -- (Note: Available in Hive 0.7.0 and 			later)
 		-- 行格式规范
		row_format
 		 : DELIMITED [FIELDS TERMINATED BY char [ESCAPED BY char]] [COLLECTION ITEMS 				TERMINATED BY char]
 	       [MAP KEYS TERMINATED BY char] [LINES TERMINATED BY char]
	       [NULL DEFINED AS char]   -- (Note: Available in Hive 0.13 and later)
  			| SERDE serde_name [WITH SERDEPROPERTIES (property_name=property_value, 				property_name=property_value, ...)]
 		-- 文件基本类型
		file_format:
 		 : SEQUENCEFILE
 		 | TEXTFILE    -- (Default, depending on hive.default.fileformat configuration)
 		 | RCFILE      -- (Note: Available in Hive 0.6.0 and later)
 		 | ORC         -- (Note: Available in Hive 0.11.0 and later)
 		 | PARQUET     -- (Note: Available in Hive 0.13.0 and later)
 		 | AVRO        -- (Note: Available in Hive 0.14.0 and later)
 		 | JSONFILE    -- (Note: Available in Hive 4.0.0 and later)
 		 | INPUTFORMAT input_format_classname OUTPUTFORMAT output_format_classname
 		-- 表约束
		constraint_specification:
 		 : [, PRIMARY KEY (col_name, ...) DISABLE NOVALIDATE ]
 		   [, CONSTRAINT constraint_name FOREIGN KEY (col_name, ...) REFERENCES 					table_name(col_name, ...) DISABLE NOVALIDATE 
```

## 2、内部表和外部表

```sql
-- 创建hive的外部表(需要添加external和location的关键字)
	create external table psn4
	(
	id int,
	name string,
	likes array ,
	address map 
	)
	row format delimited
	fields terminated by ','
	collection items terminated by '-'
	map keys terminated by ':'
	location '/data';
```

内部表跟外部表的区别：
		1、hive内部表创建的时候数据存储在hive的默认存储目录中，外部表在创建的时候需要制定额外的目录
		2、hive内部表删除的时候，会将元数据和数据都删除，而外部表只会删除元数据，不会删除数据
应用场景:
		内部表:需要先创建表，然后向表中添加数据，适合做中间表的存储
		外部表：可以先创建表，再添加数据，也可以先有数据，再创建表，本质上是将hdfs的某一个目录的数据跟
		       hive的表关联映射起来，因此适合原始数据的存储，不会因为误操作将数据给删除掉

```sql
-- 创建自定义行格式的hive表
    create table psn
    (
    id int,
    name string,
    likes array<string> ,
    address map<string,string> 
    )
    row format delimited
    fields terminated by ','
    collection items terminated by '-'
    map keys terminated by ':';
-- 创建默认分隔符的hive表（^A、^B、^C）
	create table psn3
	(
	id int,
	name string,
	likes array ,
	address map 
	)
	row format delimited
	fields terminated by '\001'
	collection items terminated by '\002'
	map keys terminated by '\003';
```

## 3、分区表

```sql
--创建单分区表
	create table psn5
	(
	id int,
	name string,
	likes array ,
	address map 
	)
	partitioned by(gender string)
	row format delimited
	fields terminated by ','
	collection items terminated by '-'
	map keys terminated by ':';
--创建多分区表
	create table psn6
	(
	id int,
	name string,
	likes array ,
	address map 
	)
	partitioned by(gender string,age int)
	row format delimited
	fields terminated by ','
	collection items terminated by '-'
	map keys terminated by ':';	
```

注意：
		1、当创建完分区表之后，在保存数据的时候，会在hdfs目录中看到分区列会成为一个目录，以多级目录的形式 存在
		2、当创建多分区表之后，插入数据的时候不可以只添加一个分区列，需要将所有的分区列都添加值
		3、多分区表在添加分区列的值得时候，与顺序无关，与分区表的分区列的名称相关，按照名称就行匹配

```sql
--给分区表添加分区列的值
	alter table table_name add partition(col_name=col_value)
--删除分区列的值
	alter table table_name drop partition(col_name=col_value)
```

注意:
		1、添加分区列的值的时候，如果定义的是多分区表，那么必须给所有的分区列都赋值
		2、删除分区列的值的时候，无论是单分区表还是多分区表，都可以将指定的分区进行删除

修复分区:
		在使用hive外部表的时候，可以先将数据上传到hdfs的某一个目录中，然后再创建外部表建立映射关系，如果在上传数据的时候，参考分区表的形式也创建了多级目录，那么此时创建完表之后，是查询不到数据的，原因是分区的元数据没有保存在mysql中，因此需要修复分区，将元数据同步更新到mysql中，此时才可以查询到元数据。具体操作如下：

外部表分区的创建和数据导入过程

```sql
--在hdfs创建目录并上传文件
	hdfs dfs -mkdir /msb
	hdfs dfs -mkdir /msb/age=10
	hdfs dfs -mkdir /msb/age=20
	hdfs dfs -put /root/data/data /msb/age=10
	hdfs dfs -put /root/data/data /msb/age=20
--创建外部表
	create external table psn7
	(
	id int,
	name string,
	likes array ,
	address map 
	)
	partitioned by(age int)
	row format delimited
	fields terminated by ','
	collection items terminated by '-'
	map keys terminated by ':'
	location '/msb';
--查询结果（没有数据）
	select * from psn7;
--修复分区
	msck repair table psn7;
--查询结果（有数据）
	select * from psn7;
```



问题：
		以上面的方式创建hive的分区表会存在问题，每次插入的数据都是人为指定分区列的值，我们更加希望能够根据记录中的某一个字段来判断将数据插入到哪一个分区目录下，此时利用我们上面的分区方式是无法完成操作的，需要使用动态分区来完成相关操作，现在学的知识点无法满足，后续讲解（动态分区）。

## 4、数据插入

```sql
--加载本地数据到hive表
	load data local inpath '/root/data/data' into table psn;--(/root/data/data指的是本地		linux目录)
--加载hdfs数据文件到hive表
	load data inpath '/data/data' into table psn;--(/data/data指的是hdfs的目录)
```

注意：
		1、load操作不会对数据做任何的转换修改操作
		2、从本地linux load数据文件是复制文件的过程
		3、从hdfs load数据文件是移动文件的过程
		4、load操作也支持向分区表中load数据，只不过需要添加分区列的值

## 4、查询

### 1. hive的数组查询

```sql
select likes[1] from psn2;
```



### 2. hvie的map集合查询

```sql
select address['beijing'] from psn2;
```

### 3、hvie中的结构体类型struct

```sql
-- 创建表
create table psn5
    (
    id int,
    name string,
    likes array<string> ,
    address map<string,string> ,
    subject struct<name:string,score:double,rank:int>
    )
    row format delimited
    fields terminated by ','
    collection items terminated by '-'
    map keys terminated by ':'
-- 数据集
1,小明1,lol-book-movie,beijing:mashibing-shanghai:pudong,chinese-85-9
2,小明2,lol-book-movie,beijing:mashibing-shanghai:pudong,chinese-85-9
3,小明3,lol-book-movie,beijing:mashibing-shanghai:pudong,chinese-85-9
4,小明4,lol-book-movie,beijing:mashibing-shanghai:pudong,chinese-85-9
5,小明5,lol-movie,beijing:mashibing-shanghai:pudong,chinese-85-9
6,小明6,lol-book-movie,beijing:mashibing-shanghai:pudong,chinese-85-9
7,小明7,lol-book,beijing:mashibing-shanghai:pudong,math-95-1
8,小明8,lol-book,beijing:mashibing-shanghai:pudong,english-85-9
9,小明9,lol-book-movie,beijing:mashibing-shanghai:pudong,english-85-9
-- 导数据
load data local inpath '/root/structTest' into table psn5;
-- 查询全部
select * from psn5;
-- 查询其中的字段
select subject.name from psn5;
```



## 5、数据的更新和删除

在官网中我们明确看到hive中是支持Update和Delete操作的，但是实际上，是需要事务的支持的，Hive对于事务的支持有很多的限制，因此，在使用hive的过程中，我们一般不会产生删除和更新的操作，如果你需要测试的话，参考下面如下配置：

```xml
# 在hive的hive-site.xml中添加如下配置：
	<property>
		<name>hive.support.concurrency</name>
		<value>true</value>
	</property>
	<property>
		<name>hive.enforce.bucketing</name>
		<value>true</value>
	</property>
	<property>
		<name>hive.exec.dynamic.partition.mode</name>
		<value>nonstrict</value>
	</property>
	<property>
		<name>hive.txn.manager</name>
		<value>org.apache.hadoop.hive.ql.lockmgr.DbTxnManager</value>
	</property>
	<property>
		<name>hive.compactor.initiator.on</name>
		<value>true</value>
	</property>
	<property>
		<name>hive.compactor.worker.threads</name>
		<value>1</value>
	</property>

```

操作语句：

```sql
	create table test_trancaction (user_id Int,name String) clustered by (user_id) into 3 			buckets stored as orc TBLPROPERTIES ('transactional'='true');
	create table test_insert_test(id int,name string) row format delimited fields 				  TERMINATED BY ',';
	insert into test_trancaction select * from test_insert_test;
	update test_trancaction set name='jerrick_up' where id=1;
//数据文件
	1,jerrick
	2,tom
	3,jerry
	4,lily
	5,hanmei
	6,limlei
	7,lucky
```

## 5、在hive窗口直接执行hdfs语句，或是执行Linux命

```shell
# 在hive窗口执行Linux行命令（beeline窗口不可以）
hive> ! ls /;
# 在hive窗口执行 hdfs 命令（beeline窗口可以）
hive> dfs -rm -f user/hive_remote/warehouse/psn4/structTest
```





# 五、Hive Serde

### 1.目的：
 Hive Serde用来做序列化和反序列化，构建在数据存储和执行引擎之间，对两者实现解耦。

### 2、应用场景：
 1、hive主要用来存储结构化数据，如果结构化数据存储的格式嵌套比较复杂的时候，可以使用serde的方式，利用正则表达式匹配的方法来读取数据，例如，表字段如下：id,name,map<string,array<map<string,string>>>
 2、当读取数据的时候，数据的某些特殊格式不希望显示在数据中，如：
192.168.57.4 - - [29/Feb/2019:18:14:35 +0800] "GET /bg-upper.png HTTP/1.1" 304 -
不希望数据显示的时候包含[]或者"",此时可以考虑使用serde的方式

### 3、语法规则

```sql
row_format
		: DELIMITED 
          [FIELDS TERMINATED BY char [ESCAPED BY char]] 
          [COLLECTION ITEMS TERMINATED BY char] 
          [MAP KEYS TERMINATED BY char] 
          [LINES TERMINATED BY char] 
		: SERDE serde_name [WITH SERDEPROPERTIES (property_name=property_value, 	
```

### 4、应用案例

数据文件

```log
192.168.57.4 - - [29/Feb/2019:18:14:35 +0800] "GET /bg-upper.png HTTP/1.1" 304 -
192.168.57.4 - - [29/Feb/2019:18:14:35 +0800] "GET /bg-nav.png HTTP/1.1" 304 -
192.168.57.4 - - [29/Feb/2019:18:14:35 +0800] "GET /asf-logo.png HTTP/1.1" 304 -
192.168.57.4 - - [29/Feb/2019:18:14:35 +0800] "GET /bg-button.png HTTP/1.1" 304 -
192.168.57.4 - - [29/Feb/2019:18:14:35 +0800] "GET /bg-middle.png HTTP/1.1" 304 -
192.168.57.4 - - [29/Feb/2019:18:14:36 +0800] "GET / HTTP/1.1" 200 11217
192.168.57.4 - - [29/Feb/2019:18:14:36 +0800] "GET / HTTP/1.1" 200 11217
192.168.57.4 - - [29/Feb/2019:18:14:36 +0800] "GET /tomcat.css HTTP/1.1" 304 -
192.168.57.4 - - [29/Feb/2019:18:14:36 +0800] "GET /tomcat.png HTTP/1.1" 304 -
192.168.57.4 - - [29/Feb/2019:18:14:36 +0800] "GET /asf-logo.png HTTP/1.1" 304 -
192.168.57.4 - - [29/Feb/2019:18:14:36 +0800] "GET /bg-middle.png HTTP/1.1" 304 -
192.168.57.4 - - [29/Feb/2019:18:14:36 +0800] "GET /bg-button.png HTTP/1.1" 304 -
192.168.57.4 - - [29/Feb/2019:18:14:36 +0800] "GET /bg-nav.png HTTP/1.1" 304 -
192.168.57.4 - - [29/Feb/2019:18:14:36 +0800] "GET /bg-upper.png HTTP/1.1" 304 -
192.168.57.4 - - [29/Feb/2019:18:14:36 +0800] "GET / HTTP/1.1" 200 11217
192.168.57.4 - - [29/Feb/2019:18:14:36 +0800] "GET /tomcat.css HTTP/1.1" 304 -
192.168.57.4 - - [29/Feb/2019:18:14:36 +0800] "GET /tomcat.png HTTP/1.1" 304 -
192.168.57.4 - - [29/Feb/2019:18:14:36 +0800] "GET / HTTP/1.1" 200 11217
192.168.57.4 - - [29/Feb/2019:18:14:36 +0800] "GET /tomcat.css HTTP/1.1" 304 -
192.168.57.4 - - [29/Feb/2019:18:14:36 +0800] "GET /tomcat.png HTTP/1.1" 304 -
192.168.57.4 - - [29/Feb/2019:18:14:36 +0800] "GET /bg-button.png HTTP/1.1" 304 -
192.168.57.4 - - [29/Feb/2019:18:14:36 +0800] "GET /bg-upper.png HTTP/1.1" 304 -
```

操作

```sql
--创建表
	CREATE TABLE logtbl (
	    host STRING,
	    identity STRING,
	    t_user STRING,
	    time STRING,
	    request STRING,
	    referer STRING,
	    agent STRING)
	  ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.RegexSerDe'
	  WITH SERDEPROPERTIES (
	    "input.regex" = "([^ ]*) ([^ ]*) ([^ ]*) \\[(.*)\\] \"(.*)\" (-|[0-9]*) (-|[0-		9]*)"
	  )
  STORED AS TEXTFILE;
--加载数据
	load data local inpath '/root/data/log' into table logtbl;
--查询操作
	select * from logtbl;
--数据显示如下（不包含[]和"）
192.168.57.4	-	-	29/Feb/2019:18:14:35 +0800	GET /bg-upper.png HTTP/1.1	304	-
192.168.57.4	-	-	29/Feb/2019:18:14:35 +0800	GET /bg-nav.png HTTP/1.1	304	-
192.168.57.4	-	-	29/Feb/2019:18:14:35 +0800	GET /asf-logo.png HTTP/1.1	304	-
192.168.57.4	-	-	29/Feb/2019:18:14:35 +0800	GET /bg-button.png HTTP/1.1	304	-
192.168.57.4	-	-	29/Feb/2019:18:14:35 +0800	GET /bg-middle.png HTTP/1.1	304	-
```


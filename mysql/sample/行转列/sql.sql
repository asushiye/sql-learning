/* ��ת��*/
select code, name, item, value, comment  from fit_student_item_score 
where title = 'test3';

select fsis.code, fsis.name,
	MAX(IF(fsis.item = '����ָ��(BMI)', fsis.value, 0)) AS '����ָ��(BMI)',
	MAX(IF(fsis.item = '��֬��(PBF)', fsis.value, 0)) AS '��֬��(PBF)'
from fit_student_item_score fsis 
where fsis.title = 'test3' 
group by fsis.code, fsis.name;

select fsis.code, fsis.name,
	MAX(IF(fsis.item = '����ָ��(BMI)', fsis.value, 0)) AS '����ָ��(BMI)',
	MAX(IF(fsis.item = '����ָ��(BMI)', fsis.comment, 0)) AS '����',
	MAX(IF(fsis.item = '��֬��(PBF)', fsis.value, 0)) AS '��֬��(PBF)',
	MAX(IF(fsis.item = '��֬��(PBF)', fsis.comment, 0)) AS '����'
from fit_student_item_score fsis 
where fsis.title = 'test3' 
group by fsis.code, fsis.name;


/* ��̬��ת��*/
-- 1�����ɻ������
SELECT
	GROUP_CONCAT(
		DISTINCT CONCAT(
			'MAX(IF(fsis.item = ''',
			fsis.item,
			''', fsis.value, 0)) AS ''',
			fsis.item,
			''''
		)
	)
FROM
	fit_student_item_score fsis
WHERE
	fsis.title = 'test3';

SELECT
	GROUP_CONCAT(
		DISTINCT CONCAT(
			'MAX(IF(fsis.item = ''',
			fsis.item,
			''', fsis.value, 0)) AS ''',
			fsis.item,
			''',',
			'MAX(IF(fsis.item = ''',
			fsis.item,
			''', fsis.comment, 0)) AS ''',
			'����',
			''''
		)
	)
FROM
	fit_student_item_score fsis
WHERE
	fsis.title = 'test3';


-- 2.���ƴ��

SELECT fsis. CODE, fsis. NAME, (
		SELECT
			GROUP_CONCAT(
				DISTINCT CONCAT(
					'MAX(IF(fsis.item = ''',
					fsis.item,
					''', fsis.great, 0)) AS ''',
					fsis.item,
					''''
				)
			)
		FROM
			fit_student_item_score fsis
		WHERE
			fsis.title = 'test1'
	)
FROM
	fit_student_item_score fsis
WHERE
	fsis.title = 'test1'
GROUP BY fsis. CODE, fsis. NAME;

-- �����������󣬶�̬ƴ��sql

-- 3. ��̬ƴ��sql

set @subsql = '';

SELECT
	GROUP_CONCAT(
		DISTINCT CONCAT(
			'MAX(IF(fsis.item = ''',
			fsis.item,
			''', fsis.great, 0)) AS ''',
			fsis.item,
			''''
		)
	) into @subsql
FROM
	fit_student_item_score fsis
WHERE
	fsis.title = 'test3';

set @sql = CONCAT(' SELECT fsis.CODE, fsis.NAME, ', @subsql,
								  ' FROM fit_student_item_score fsis
									  WHERE fsis.title = ''test3''',
									' GROUP BY fsis.CODE, fsis.NAME');

-- select @sql;
PREPARE stmt FROM @sql;
EXECUTE stmt ;
DEALLOCATE PREPARE stmt;

-- ���������

-- 4. �޸Ķ�̬��ѯ����

set @subsql = '';
set @title= 'test3';

SELECT
	GROUP_CONCAT(
		DISTINCT CONCAT(
			'MAX(IF(fsis.item = ''',
			fsis.item,
			''', fsis.great, 0)) AS ''',
			fsis.item,
			''''
		)
	) into @subsql
FROM
	fit_student_item_score fsis
WHERE
	fsis.title = @title;

set @sql = CONCAT(' SELECT fsis.NAME, fsis.gender, fsis.CODE, fsis.specialty', @subsql,
								  ' FROM fit_student_item_score fsis
									  WHERE fsis.title = ''', @title, '''
									  GROUP BY fsis.NAME, fsis.gender, fsis.CODE, fsis.specialty');

-- select @sql;
PREPARE stmt FROM @sql;
EXECUTE stmt ;
DEALLOCATE PREPARE stmt;


-- 5. �洢����

DROP PROCEDURE IF EXISTS SP_QueryTest ; 
CREATE PROCEDURE SP_QueryTest (IN title VARCHAR(30)) 
READS SQL DATA
BEGIN
	SET @subsql = '' ;
	SET @title = title ; 
  SELECT
		GROUP_CONCAT(
			DISTINCT CONCAT(
				'MAX(IF(fsis.item = ''',
				fsis.item,
				''', fsis.great, 0)) AS ''',
				fsis.item,
				''''
			)
		) INTO @subsql
	FROM
		fit_student_item_score fsis
	WHERE
		fsis.title = @title ;
	SET @SQL = CONCAT(
		' SELECT fsis.CODE, fsis.NAME, ',
		@subsql,
		' FROM fit_student_item_score fsis WHERE fsis.title = ''',
		@title,
		'''GROUP BY fsis.CODE, fsis.NAME') ; 
	PREPARE stmt FROM @SQL ; 
  EXECUTE stmt ; 
  DEALLOCATE PREPARE stmt ;
END

call SP_QueryTest('test3');


-- ��дƴ����ת�нű�

drop function if exists get_concat_strs;
create function get_concat_strs(i_title varchar(30)) returns varchar(3000)
begin
  declare b int default 0;
  declare l_subsql, l_sql varchar(3000) default '';
  declare cur_1 cursor for 
	SELECT
		GROUP_CONCAT(
			DISTINCT CONCAT(
				'MAX(IF(fsis.item = ''',
				fsis.item,
				''', fsis.value, ''-'')) AS ''',
				fsis.item,
				''',',
				'MAX(IF(fsis.item = ''',
				fsis.item,
				''', fsis.comment, ''-'')) AS ''',
				'����',
				''''
			)
		) as sstr
	FROM
		fit_student_item_score fsis
	WHERE
		fsis.title = i_title
  group by fsis.item,fsis.fic_id order by fsis.fic_id;

  declare continue handler for not found set b=1;

  open cur_1;
    repeat
      fetch cur_1 into l_subsql;
      if (l_sql = '') then 
        set l_sql= l_subsql;
      else
        set l_sql= CONCAT(l_sql,',',l_subsql);
      end if;
    until b=1 end repeat;
  close cur_1;
  
  return l_sql;
end;


 set @sql = get_concat_strs('test3');
select @sql;


-- 5. ��д�洢����

drop procedure if exists SP_QueryData;
Create Procedure SP_QueryData(i_title varchar(30))
READS SQL DATA 
BEGIN
 
  set @subsql= get_concat_strs(i_title);
  set @mainsql= CONCAT('SELECT fsis.NAME as ����, fsis.CODE as ѧ��, fsis.gender as �Ա�, fsis.specialty as רҵ, ', @subsql, 
											' FROM fit_student_item_score fsis ',
											'	WHERE fsis.title = ''', i_title, '''',
											'	GROUP BY fsis.NAME, fsis.CODE, fsis.gender, fsis.specialty ');

	PREPARE stmt FROM @mainsql;
	EXECUTE stmt ;
	DEALLOCATE PREPARE stmt;
END;



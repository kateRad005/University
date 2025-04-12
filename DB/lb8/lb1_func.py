import csv

import  mysql.connector as sql
from pandas import  DataFrame
from csv import reader
import json
from django.core.exceptions import ValidationError
import io,sys,os

class BD:


    def __init__(self,db:str):
        self.cur_con = sql.connect(user = 'root',password = 'root1',database = db)
        self.db_name = db

    def close_con(self):
        if self.cur_con.is_connected():
            self.cur_con.close()
    def show_tables(self):
        try:
            self.cur_con.reset_session()
            cursor = self.cur_con.cursor()
            comm = 'show tables'
            cursor.execute(comm)
            res = cursor.fetchall()
            cursor.close()
            return res
        except Exception as e:
            print(e)
    def get_all_table_as_list(self,table_name:str): #1.1.1
        try:
            if 'drop' in table_name or 'delete' in table_name or 'or' in table_name:
                print('kys')
                return None
            new_table_name = table_name.partition(';')[0]
            self.cur_con.reset_session()
            cursor = self.cur_con.cursor()
            command_str = "select * from " + new_table_name
            cursor.execute(command_str)
            res = cursor.fetchall()
            cursor.close()
            return res
        except Exception as e:
            print(e)

    def get_all_table_as_dataframe(self,t_name: str,reset = True): #1.1.2
        try:
            if reset:
                self.cur_con.reset_session()
            cursor = self.cur_con.cursor(prepared=True)
            command_str = "select * from "+ t_name
            cursor.execute(command_str)
            res = DataFrame(cursor.fetchall())
            res.columns = [i[0] for i in cursor.description]
            command_str = f"show keys from {t_name} where Key_name = 'primary'"
            cursor.execute(command_str)
            keys = cursor.fetchall()
            res.set_index(keys[0][4],inplace=True)
            cursor.close()
            return res
        except Exception as e:
            print(e)

    # 1.1.6----------------------------------------------------------
    def get_tables_as_csv(self,t_name):
        try:
            self.cur_con.reset_session()
            data = self.get_all_table_as_list(t_name)
            with open('my_bd.csv','w',encoding='utf-8') as f:
                writer = csv.writer(f,lineterminator = '\n')
                for tup in data:
                    writer.writerow(tup)
        except Exception as e:
            print(e)

    def get_tables_as_json(self,t_name):
        try:
            self.cur_con.reset_session()
            data = self.get_all_table_as_dataframe(t_name)
            with open('json_'+str(t_name)+'.json','w',encoding='utf-8') as f:
                data.to_json(f,date_format='iso',orient='records')
        except Exception as e:
            print(e)

    def get_table_as_dat(self,t_name):
        try:
            self.cur_con.reset_session()
            data = self.get_all_table_as_dataframe(t_name)
            data.to_csv(str(t_name)+'.dat')
        except Exception as e:
            print(e)

    def transfer_fee(self,fromst:int,tost:int):
        try:
            with self.cur_con.cursor(buffered=True) as cursor:
                command_st = f"select * from studs where st_id = {fromst} or st_id  = {tost}"
                cursor.execute(command_st)
                row_number = cursor.rowcount
                cursor.fetchall()
            if row_number == 2:
                with self.cur_con.cursor() as cursor:
                    command_text = 'update studs set st_value = st_value - 20 where st_id = %s'
                    cursor.execute(command_text,(fromst,))
                    if cursor.rowcount == 1:
                        input()
                        command_text = "update studs set st_value=st_value+20 where st_id= %s"
                        cursor.execute(command_text,(tost,))
                        if cursor.rowcount == 1:
                            self.cur_con.commit()
                        else:
                            self.cur_con.rollback()
            else:
                self.cur_con.rollback()
        except Exception as e:
            print(e)
            self.cur_con.rollback()

    def join_pat(self): #1.1.3
        try:
            with self.cur_con.cursor(buffered=True) as cursor:
                command_st = f"select  distinct patient_daily_diary.p_id , " \
                             f"patient_daily_diary.p_date, patient_daily_diary.p_dairy " \
                             f"from patient_daily_diary" \
                             f" inner join vac_patient on vac_patient.p_id = patient_daily_diary.p_id;"
                cursor.execute(command_st)
                data = DataFrame(cursor.fetchall())
                data.columns = [i[0] for i in cursor.description]
                print(data)
        except Exception as e:
            print(e)

    def group_pat(self): #1.1.3
        try:
            with self.cur_con.cursor(buffered=True) as cursor:
                command_st = f"select analises.p_analis,count(analises.p_analis) from  analises group by analises.p_analis"
                cursor.execute(command_st)
                data = DataFrame(cursor.fetchall())
                data.columns = [i[0] for i in cursor.description]
                print(data)
        except Exception as e:
            print(e)


    def max_glucose(self): #1.1.3
        try:
            with self.cur_con.cursor(buffered=True) as cursor:
                command_st = f"select max(an_value) from analises where p_analis = 'Blood Glucose'"
                cursor.execute(command_st)
                data = cursor.fetchall()
                print(data)
        except Exception as e:
            print(e)

    def file_limit(self,t_name,limit):
        if limit < 0:
            limit = -limit
        limit = int(limit)
        self.cur_con.reset_session()
        data = self.get_all_table_as_list(t_name)
        filename = 'lim_table.csv'
        with open(filename, 'w+', encoding='utf-8') as f:
            writer = csv.writer(f, lineterminator='\n')
            for tup in data:
                writer.writerow(tup)
                size = f.tell()
                if size >= limit:
                    break
            size = f.tell()
        input()
        if size> limit:
            with open(filename, 'r') as f:
                lines = f.readlines()
            with open(filename, 'w') as f:
                f.seek(0)
                f.truncate()
                f.writelines(lines[:-1])
        return filename


    # 1.2.1. Приведите код вставки данных всех возможных в MySQL типов.
    def insert_all(self):
        try:
            self.cur_con.reset_session()
            cursor = self.cur_con.cursor()
            cursor.execute('drop table if exists all_types')
            cursor.close()
            cursor = self.cur_con.cursor()
            mess = ''' create table if not exists all_types \
                   (tiny TINYINT, \
                   small SMALLINT, \
                   int_1 int,\
                   int_uns int unsigned,\
                   bigg bigint, \
                   decc decimal(5,2), \
                   en enum('m','n'),
                   sett set('day1','day2'), \
                   fl float, \
                   doub double, \
                   b bit(10), \
                   bl blob, \
                   year_1 year, \
                   time_1 time, \
                   times TIMESTAMP DEFAULT CURRENT_TIMESTAMP, \
                   dt datetime, \
                   date_1 date, \
                   text_1 text, \
                   varch varchar(20), \
                   ch char(10), \
                   bol bool)'''
            cursor.execute(mess)
            cursor.close()
            cursor = self.cur_con.cursor()
            mess = '''insert into all_types \
                   (tiny,small,int_1,int_uns,bigg,decc,en,sett,fl,doub,b,bl,year_1, \
                   time_1,times,dt,date_1,text_1,varch,ch,bol) values(25,32766,2147483646,\
                   4294967294,223372036854775806,-999.99,'m','day1',3.4515,454,b'111', \
                   "bloblobl",2024,"9:21:00","2038-01-19 03:14:07", \
                   "9999-12-31 23:59:59","9999-12-31","kshdjkdh djkhdjksnd sjkdhsk","jshxksx","qwertyuiop",0)'''
            cursor.execute(mess)
            if cursor.rowcount == 1:
                self.cur_con.commit()
            cursor.close()
            cursor = self.cur_con.cursor()
            cursor.execute('select* from  all_types')
            res = cursor.fetchall()
            print(res)
            cursor.close()
        except Exception as e:
            print(e)

#1.2.2. Приведите пример Code Injections и методов борьбы с ними.

    def get_table_analises(self,type = ''):
        if not type:
            return self.get_all_table_as_list('analises')
        elif type == 'DataFrame':
            return self.get_all_table_as_dataframe('analises')
        elif type == 'csv':
            return self.get_tables_as_csv('analises')
#1.2.3. Методы обновления / удаления. Подумайте об аргументах функций.
    def update_analises(self,n_list  = '',n_value = None,condition = '',delete = False):
        try:
            if delete:
                self.cur_con.reset_session()
                cursor = self.cur_con.cursor()
                mess = 'delete from analises ' + str(condition)
                cursor.execute(mess)
                self.cur_con.commit()
                cursor.close()
                return
            if n_list and n_value:
                self.cur_con.reset_session()
                cursor = self.cur_con.cursor()
                mess = 'update analises set '+ str(n_list) + ' = ' + str(n_value) +' ' + str(condition)
                cursor.execute(mess)
                input()
                print(cursor.rowcount)
                self.cur_con.commit()
                cursor.close()
        except Exception as e:
            print(e)

    def insert_into_analises_from_csv(self,filename):
        try:
            with open(filename,'r',encoding='utf-8') as f:
                csv_r = reader(f)
                tuples = list(map(tuple,csv_r))
            with self.cur_con.cursor() as cursor:
                comm_text = "insert into analises(p_id,p_analis,an_value) values (%s,%s,%s)"
                cursor.executemany(comm_text,tuples)
            self.cur_con.commit()
        except Exception as e:
            print(e)

    def insert_into_table_from_csv(self, t_name,fields_names,filename):
        try:
            with open(filename, 'r', encoding='utf-8') as f:
                csv_r = reader(f)
                tuples = list(map(tuple, csv_r))
            if tuples:
                with self.cur_con.cursor() as cursor:
                    comm_text = "insert into " + t_name + "(" + fields_names + ") values (" + ','.join('%s' for _ in range(fields_names.count(',')+1))+")"
                    cursor.executemany(comm_text, tuples)
                self.cur_con.commit()
            else:
                print('Nothing to insert')
                return
        except Exception as e:
            print(e)
    def insert_into_analises_from_json(self, filename):
        try:
            with open(filename, 'r', encoding='utf-8') as f:
                json_r = json.load(f)
                columns = "(" + ", ".join(json_r[0].keys()) + ")"
                values = [list(elem.values()) for elem in json_r]
            with self.cur_con.cursor() as cursor:
                mess = f"insert into analises{columns} values (%s,%s,%s)"
                cursor.executemany(mess, values)
                if cursor.rowcount == len(values):
                    self.cur_con.commit()
                else:
                    print('hmmmmmmmmmm')
                    return None
        except Exception as e:
            print(e)
    def insert_into_table_from_json(self,t_name:str,fname):
        try:
            if fname:
                filename = fname
            else:
                return None
            t_name = t_name.partition(';')[0]
            with open(filename, 'r', encoding='utf-8') as f:
                json_r = json.load(f)
                columns = "(" + ", ".join(json_r[0].keys()) + ")"
                values = [list(elem.values()) for elem in json_r]
            with self.cur_con.cursor() as cursor:
                mess = f"insert into {t_name} " +columns +" values ('%s'" + ',%s'*( len(values[0])-1)  + ')'
                print(mess)
                cursor.executemany(mess, values)
                if cursor.rowcount == len(values):
                    self.cur_con.commit()
                else:
                    print('hmmmmmmmmmm')
                    return None
        except Exception as e:
            print(e)

    def back_data_from_csv(self,files:list,t_name):
        try:
            self.cur_con.reset_session()
            with self.cur_con.cursor() as cursor:
                mess = 'USE information_schema; '
                cursor.execute(mess)
                self.cur_con.commit()
                mess2 = "select table_name from referential_constraints WHERE constraint_schema = '" + self.db_name + "' AND referenced_table_name = '" + t_name + "' AND delete_rule='CASCADE';"
                cursor.execute(mess2)
                tables = cursor.fetchall()
                mess = "select column_name from INFORMATION_SCHEMA.COLUMNS WHERE table_name = '" + t_name + "' order by ordinal_position"
                cursor.execute(mess)
                f_name = cursor.fetchall()
                field_names = []
                for i in range(len(tables)):
                    mess = "select column_name from INFORMATION_SCHEMA.COLUMNS WHERE table_name = '" + tables[i][
                        0] + "' order by ordinal_position"
                    cursor.execute(mess)
                    field_names.append(cursor.fetchall())
                t2 = []
                for i in range(len(f_name)):
                    t2.append(f_name[i][0])
                f_name = str(','.join(elem for elem in t2))
                cursor.execute(f"Use {self.db_name}")
                self.cur_con.commit()
                self.insert_into_table_from_csv(t_name=t_name, fields_names=f_name, filename=files[0])
                print(self.get_all_table_as_dataframe(t_name))

                for i in range(len(field_names)):
                        t = []
                        for j in range(len(field_names[i])):
                            t.append(field_names[i][j][0])
                        f_names = str(','.join(str(elem) for elem in t))

                        self.insert_into_table_from_csv(t_name = str(tables[i][0]),fields_names=f_names,filename=files[1][i])
                        print(self.get_all_table_as_dataframe(tables[i][0]))
                os.remove(files[0])
                for i in range(len(files[1])):
                    os.remove(files[1][i])
        except Exception as e:
            print(e)



    def del_with_csv_copy(self,t_name,condition = '',back = False):
        try:
            self.cur_con.reset_session()
            with self.cur_con.cursor() as cursor:
                mess = 'USE information_schema; '
                cursor.execute(mess)
                self.cur_con.commit()
                mess2 = "select table_name from referential_constraints WHERE constraint_schema = '" + self.db_name + "' AND referenced_table_name = '" + t_name + "' AND delete_rule='CASCADE';"
                cursor.execute(mess2)
                tables = cursor.fetchall()

                mess = 'use ' + self.db_name
                cursor.execute(mess)
                self.cur_con.commit()

                mess = ' select* from ' + t_name + ' ' + condition
                cursor.execute(mess)
                data = cursor.fetchall()
                if back:
                    filename1 = 'copy_' + t_name + '.csv'
                    fnames = ['copy_ref_' + str(tables[i][0]) + '.csv' for i in range(len(tables))]
                    with open(filename1, 'a',newline='') as f:
                        writer = csv.writer(f, lineterminator='\n')
                        for tup in data:
                            writer.writerow(tup)
                    for i in range(len(tables)):
                        mess = 'select* from ' + tables[i][0] + ' ' + condition
                        cursor.execute(mess)
                        data = cursor.fetchall()
                        with open(fnames[i], 'a',newline='') as f:
                            writer = csv.writer(f, lineterminator='\n')
                            for tup in data:
                                writer.writerow(tup)
                    res = [filename1,fnames]
                mess = 'delete from ' + t_name + ' ' + condition
                cursor.execute(mess)
                self.cur_con.commit()
                return res
        except Exception as e:
            print(e)

#----------------+++++++++++++++++++++++++++++++++54561215456435135464132154
    def age_death(self,age_period:tuple):
        try:
            self.cur_con.reset_session()
            cursor = self.cur_con.cursor()
            if age_period[0] < age_period[1]:
                mess = 'select patients.p_age,patients.p_name,death.p_death_reason from patients ' \
                       'left join death ' \
                       'on death.p_id = patients.p_id where patients.p_age between ' + str(age_period[0])  +  ' and ' + str(age_period[1])
                cursor.execute(mess)
                return cursor.fetchall()
            else:
                return 'wrong age period'
        except Exception as e:
            print(e)


    def age_survived(self,age_period:tuple):
        try:
            self.cur_con.reset_session()
            cursor = self.cur_con.cursor()
            if age_period[0] < age_period[1]:
                mess = 'select patients.p_age,patients.p_name from patients ' \
                       'left join survived' \
                       ' on survived.p_id  = patients.p_id where patients.p_age between ' + str(age_period[0])  +  ' and ' + str(age_period[1])
                cursor.execute(mess)
                return cursor.fetchall()
            else:
                return 'wrong age period'
        except Exception as e:
            print(e)

    def vacine_survived(self,vacine_name):
        try:
            self.cur_con.reset_session()
            cursor = self.cur_con.cursor()
            mess = 'select tb1.v_name, count(tb1.v_name) from (select vacines.v_id,vacines.v_name ,vacines.v_formula,vac_patient.p_id from vacines left join vac_patient' \
                   " on vacines.v_id = vac_patient.v_id) as tb1 inner join survived on survived.p_id = tb1.p_id where tb1.v_name = '" + str(vacine_name)  + "'"
            cursor.execute(mess)
            return cursor.fetchall()
        except Exception as e:
            print(e)

    def vacine_death(self,vacine_name):
        try:
            self.cur_con.reset_session()
            cursor = self.cur_con.cursor()
            mess = 'select tb1.v_name, count(tb1.v_name) from (select vacines.v_id,vacines.v_name ,vacines.v_formula,vac_patient.p_id from vacines left join vac_patient' \
                   " on vacines.v_id = vac_patient.v_id) as tb1 inner join death on death.p_id = tb1.p_id where tb1.v_name = '" + str(vacine_name) + "'"
            cursor.execute(mess)
            return cursor.fetchall()
        except Exception as e:
            print(e)

    def check_patient_history(self,id):
        try:
            self.cur_con.reset_session()
            cursor = self.cur_con.cursor()
            mess = 'select p_history from patient_past_card where p_id = '+ str(id)
            cursor.execute(mess)
            return cursor.fetchall()
        except Exception as e:
            print(e)

#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    def create(self,name,col_types):
        try:
            self.cur_con.reset_session()
            cursor = self.cur_con.cursor()
            cols = ""
            for col, typ in col_types.items():
                cols += col + " " + typ + ","
            cols = cols.strip(",")
            mess = f"create table if not exists {name} (" + cols + ");"
            cursor.execute(mess)
            self.cur_con.commit()
            rows = cursor.rowcount
            cursor.close()
            return rows
        except Exception as e:
            print(e)

    def update(self,t_name,col_name,n_val,condition):
        try:
            self.cur_con.reset_session()
            cursor = self.cur_con.cursor()
            mess = f"update {t_name} set {col_name} = {n_val} " + condition
            cursor.execute(mess)
            self.cur_con.commit()
            rows = cursor.rowcount
            cursor.close()
            return rows
        except Exception as e:
            print(e)

    def delete(self,t_name,condition):
        try:
            self.cur_con.reset_session()
            with self.cur_con.cursor() as cursor:
                mess = f'delete from {t_name} {condition}'
                cursor.execute(mess)
                self.cur_con.commit()
                rows = cursor.rowcount
                return rows
        except Exception as e:
            print(e)
    def get_all_tables(self):
        with self.cur_con.cursor() as cursor:
            cursor.execute("select table_name from information_schema.tables where table_type='BASE TABLE' AND table_schema = %s",(self.db_name,))
            tables =cursor.fetchall()
        return [elem[0] for elem in tables]
    def get_columns(self,t_name):
        try:
            with self.cur_con.cursor() as cur:
                cur.execute(
                    "select column_name from INFORMATION_SCHEMA.COLUMNS WHERE table_name = '" + t_name + "' order by ordinal_position")
                columns = cur.fetchall()
            return columns
        except Exception as e:
            print(e)
    def insert(self,t_name,c_name,vals):
        try:
            with self.cur_con.cursor() as cur:
                mess =  f"insert into {t_name} " + c_name + f" values (%s" + ",%s" * (len(vals[0]) - 1) + ")"
                cur.executemany(mess, vals)
                if cur.rowcount == len(vals):
                    self.cur_con.commit()
                else:
                    self.cur_con.rollback()
                    print("something went wrong while inserting")
                return cur.rowcount
        except Exception as e:
            print(e)
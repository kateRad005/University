import  lb1_func
import pandas as pd
from pandas import DataFrame
if __name__ == '__main__':
    layer = lb1_func.BD('covid')
# Task 1.1.4
    print(layer.join_pat())
    df1 = layer.get_all_table_as_dataframe('patient_daily_diary')
    df2 = layer.get_all_table_as_dataframe('vac_patient')
    res = df1.merge( df2,how = 'inner',on = 'p_id' )[['p_id','p_date','p_dairy']]
    res = res.drop_duplicates()
    idx = pd.Index(list(range(len(res))))
    res = res.set_index(idx)
    print(res)
    print('--------------------------------------------')
    df3 = layer.get_all_table_as_dataframe('analises')
    print('---------------------------------------------')
    res = DataFrame(df3.loc[df3['p_analis']=='Blood Glucose']['an_value']).to_numpy().max()
    layer.max_glucose()
    print(res)

#1.1.5--------------------------------------------------
    world = lb1_func.BD('world')
    # world.show_tables()
    city = world.get_all_table_as_dataframe('city')
    country = world.get_all_table_as_dataframe('country')
    countrylanguage = world.get_all_table_as_dataframe('countrylanguage')

# --1.1.6. В виде csv и json - файлов.
    world.get_tables_as_csv('country')
    world.get_tables_as_json('country')
#--1.1.7. В виде dat – файла.
    # world.get_table_as_dat('country')
    world.file_limit('city',21*1024)
#
    world.close_con()
    # #1.2.1. Приведите код вставки данных всех возможных в MySQL типов.
    layer.insert_all()


#1.2.3. Методы обновления / удаления. Подумайте об аргументах функций.
    layer.update_analises('an_value', 100000, 'where p_id = 8')
    res = layer.get_all_table_as_dataframe('analises')
    print(res)
    layer.update_analises(n_list='an_value',n_value=1000,condition= 'where p_id = 18',delete=True)
    res = layer.get_all_table_as_dataframe('analises')
    print(res)


#1.2.4. Функция для вставки данных в БД из csv и json – файла.
    layer.insert_into_analises_from_csv('insert.csv')
    res = layer.get_all_table_as_dataframe('analises')
    print(res)
    layer.update_analises(delete=True,condition='where p_id = 1')
    print(layer.get_all_table_as_dataframe('analises'))

    layer.get_tables_as_json('analises')
    layer.insert_into_analises_from_json('json_analises.json')
    res = layer.get_all_table_as_dataframe('analises')
    print(res)
    layer.insert_into_table_from_json(t_name = 'analises',fname='json_analises.json')
    print(layer.get_all_table_as_dataframe('analises'))
    layer.insert_into_table_from_csv(t_name='analises', fields_names='p_id,p_analis,an_value', filename='insert.csv')
    res = layer.get_all_table_as_dataframe('analises')
    print(res)
# 1.2.5. Функция для удаления данных с созданием резервной сsv копии с возможностью
# восстановления всех удалённых записей.
    files = layer.del_with_csv_copy(t_name='patients',condition='where p_id = 2',back=True)
    print(files)
    layer.back_data_from_csv(files,t_name='patients')
#     # 1.3. Реализуйте некоторые последовательности команд бизнес – логики в python функциях.
# # 1.3.1. Не менее 5 функций для манипуляции данными.
    print(layer.check_patient_history(1))
    print(layer.vacine_death('COVID-19 Vaccine1'))

    print(layer.vacine_survived('COVID-19 Vaccine1'))

    print(layer.age_death((10,30)))

    print(layer.age_survived((15,45)))

# 1.3.3. Вызов хранимых процедур и функций сервера в клиентском приложении.
    cursor = layer.cur_con.cursor()
    res =cursor.callproc('count_death',(0,))
    print(res)
    cursor.close()
    with layer.cur_con.cursor() as cursor:
        cursor.execute('select count_death2(10,50)')
        res = cursor.fetchall()
        print(res)

# 3. Реализуйте полноценный консольный интерфейс в виде скрипта для пользователя с CRUD
# функционалом используя задания 1 и 2. Пользователь должен иметь возможность циклической
# работы с БД после запуска скрипта

    layer.close_con()






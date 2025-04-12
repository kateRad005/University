import lb1_func
import numpy as np
import pandas as pd
world = lb1_func.BD('world')
city = world.get_all_table_as_dataframe('city')
city = city.reset_index()
country = world.get_all_table_as_dataframe('country')
country = country.reset_index()
countrylanguage = world.get_all_table_as_dataframe('countrylanguage')
countrylanguage = countrylanguage.reset_index()

res = city.merge(countrylanguage,how = 'inner',on = 'CountryCode')[['Name','Language']]
res = res.loc[res['Language']=='French']
print(res)

# # -- 2. Какой процент населения планеты проживает в странах с ВНП ниже 10000?
#

big = country['Population'].sum()
sumPopGNP = country.loc[country['GNP']<10000]['Population'].sum()
res = 100*sumPopGNP/big
print(res)

# -- 3. Выведите языки мира, занимающие по числу стран использования в мире позиции с 20 по 27.
c_language = countrylanguage.groupby(['Language']).size().reset_index(name='counts')
c_language = c_language.sort_values(by=['counts'],ascending=False)
c_language['rank_lang'] = np.arange(1,len(c_language)+1,1)
res = c_language.loc[(c_language['rank_lang'] >= 20) & (c_language['rank_lang'] <=27 )][['Language','rank_lang']]
print(res)

# -- 4. Сколько городов Украины имеют население превосходящее число людей,говорящих в Украине на русском.

res = country.merge(countrylanguage,right_on='CountryCode',left_on='Code')[['Code','Name','Language','Percentage','Population']]
res = res.loc[res['Code'] == 'UKR']
pop = res['Population'].values[0]
pers = float(res.loc[res['Language'] == 'Russian']['Percentage'].values[0])
print(pers)
print(res)
print(pop)
print(pers)
cities = city.loc[(city['CountryCode'] == 'UKR') & (city['Population'] > pop*0.01*pers)]
print(cities)


#-- 5. Выведите города России, в которых проживает не более 100000 человек.
cities = city.loc[(city['CountryCode'] == 'RUS') & (city['Population'] <= 100000)]
print(cities)


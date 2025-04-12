import lb1_func

class Interface_BD:
    def __init__(self):
        self.commands = {"1":self.create,"2":self.select,"3":self.insert,"4":self.update,"5":self.delete}
        self.sql =lb1_func.BD('covid')
        self.tables = self.sql.get_all_tables()


    def start(self):
        print("--You are connected to database covid. Be carefull here. To finish type 'exit'. To cancel program type 'cancel'."
              "\n--What would you like to do? Enter a number\n"
              "1. Create a table\n2. View a table\n3. Insert into table \n4. Update a table\n5. Delete from table")
        inp = input()

        if inp == 'cansel'or inp == 'exit':
            print('know you are loved')
            return
        while inp!="exit" or inp not in list(str(i) for i in range(1,6)):
            self.commands[inp]()
            print(
                "--You are connected to database covid. Be carefull here. To finish type 'exit'. To cancel program type 'cancel'."
                "\n--What would you like to do? Enter a number\n"
                "1. Create a table\n2. View a table\n3. Insert into table \n4. Update a table\n5. Delete from table")
            inp = input()
            if inp == 'cansel'or 'exit':
                print('know you are loved')
                return

    def create(self):
        print("--Input table name")
        name = input()
        if name.strip() == 'cancel':
            return None
        while (not name.strip()) or (name in self.tables) or not name[:1].isalpha() :
            print("--This is invalid table name (blank name or table already exists). Choose another name")
            name = input()
            if name.strip() == 'cancel':
                return None
        print("--Now enter column_name column_type one by one. To finish enter blank")
        columns = dict()
        coltype = input()
        if coltype.strip() == 'cancel':
            return None
        while coltype.strip() != "":
            try:
                col_name,col_type = coltype.split(" ")
                if col_name and col_type:
                    if not col_name[:1].isalpha() or not col_type[:1].isalpha():
                        print("--Invalid column name or type. Enter again")
                        coltype = input()
                        if coltype.strip() == 'cancel':
                            return None
                    else:
                        columns[col_name] = col_type
                        coltype = input()
                        if coltype.strip() == 'cancel':
                            return None
                else:
                    print("--One of your inputs is blank. Enter again")
                    coltype = input()
                    if coltype.strip() == 'cancel':
                        return None
            except ValueError:
                print("--Column_name and column_type should be divided by one blank space. Enter again")
                coltype = input()
                if coltype.strip() == 'cancel':
                    return None

        self.sql.create(name,columns)
        print("finish", name, columns)
        self.tables = self.sql.get_all_tables()

    def select(self):
        print("--Where do you want your table?\n1.Dataframe\n2.List\n3.CSV file\n4.JSON file\n5.DAT file")
        where = input().strip()
        if where.strip() == 'cancel':
            return None
        while where not in list(str(i) for i in range(1,6)):
            print("--Enter a number between 1 and 5, please.\n"
                  "--Where do you want your table?\n1.Dataframe\n2.List\n3.CSV file\n4.JSON file\n5.DAT file")
            where = input().strip()
            if where.strip() == 'cancel':
                return None
        print("--Input table name you want to select. Here are all the tables in this database:\n" + ", ".join(self.tables))
        name = input()
        if name.strip() == 'cancel':
            return None
        while name not in self.tables:
            print("--Table doesn't exist. Enter again")
            name = input()
            if name.strip() == 'cancel':
                return None

        table = self.sql.get_all_table_as_dataframe(name)
        if where == '1':
            print(table,'\n')
        if where == '2':
            print(self.sql.get_all_table_as_list(name),'\n')
        if where == '3':
            print(table)
            print(self.sql.get_tables_as_csv(name),'\n')
        if where == '4':
            print(table)
            print(self.sql.get_tables_as_json(name),'\n')
        if where == '5':
            print(table)
            print(self.sql.get_table_as_dat(name), '\n')

    def insert(self):
        print("--Input table name you want to insert into. Here are all the tables in this database:\n" + ", "
              .join(self.tables))
        table = input()
        if table.strip() == 'cancel':
            return None
        while table not in self.tables:
            print("--Table doesn't exist. Enter again")
            table = input()
            if table.strip() == 'cancel':
                return None
        cols = self.sql.get_columns(table)
        col_names = [elem[0] for elem in cols]
        print("--Here are all the columns in this table:\n",cols)

        print("--Enter values you want to insert. Values are to be divided by ','. Enter blank to finish")
        values = []
        v = input()
        if v.strip() =='cancel':
            return None

        while v.strip() != "":
            v = v.split(",")
            v = [None if elem == "" else elem for elem in v]
            if len(v)!=len(cols):
                print("--Incorrect number of values. Enter again")
                v = input()
                if v.strip() == 'cancel':
                    return None
            else:
                values.append(v)
                v = input()
                if v.strip() == 'cancel':
                    return None
        try:
            self.sql.insert(table,"("+",".join(col_names)+")", values)
        except Exception as e:
            print(e)
            return None

    def update(self):
        self.sql.get_all_tables()
        print("--Input table name you want to update. Here are all the tables in this database:\n" + ", "
              .join(self.tables))
        table = input()
        if table.strip() == 'cancel':
            return None
        while table not in self.tables:
            print("--Table doesn't exist. Enter again")
            table = input()
            if table.strip() == 'cancel':
                return None

        cols = self.sql.get_columns(table)
        col_names = [elem[0] for elem in cols]
        print("--Here are all the columns in this table:\n", cols)
        column = input()
        if column.strip() == 'cancel':
            return None
        while column not in col_names:
            print("--Column doesn't exist. Enter again")
            column = input()
            if column.strip() == 'cancel':
                return None

        print("--Now enter new value for column ", column)
        value = input()
        if value.strip() == 'cancel':
            return None
        print("--Enter where-condition. If not needed leave blank")
        condition = input()
        if condition.strip() == 'cancel':
            return None

        try:
            self.sql.update(table,column,value,condition)
        except Exception as e:
            print(e)

    def delete(self):
        self.sql.get_all_tables()
        print("--Input table name you want to delete from. Here are all the tables in this database:\n" + ", "
              .join(self.tables))
        table = input()
        if table.strip() == 'cancel':
            return None
        while table not in self.tables:
            print("--Table doesn't exist. Enter again")
            table = input()
            if table.strip() == 'cancel':
                return None

        print("--Enter where-condition. If not needed leave blank")
        condition = input()
        if condition.strip() == 'cancel':
            return None

        try:
            self.sql.delete(table, condition)
        except Exception as e:
            print(e)


if __name__ == '__main__':
    unu = Interface_BD()
    unu.start()



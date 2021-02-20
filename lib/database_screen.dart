import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseScreen extends StatefulWidget {

  @override
  _DatabaseScreenState createState() => _DatabaseScreenState();
}

class _DatabaseScreenState extends State<DatabaseScreen> {
  Database currentDatabase;
  List<Map> taskat = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    createDatabase();



  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DataBase'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('CLICKED');
          taskDialog(context,null);
        },
        child: Icon(
          Icons.add,
        ),
      ),
      body: ListView.separated(
        itemBuilder: (ctx , index) => buildItem(ctx, taskat[index]),
        separatorBuilder:  (ctx , index) => Container(
          width: double.infinity,
          height: 1,
          color: Colors.grey[400],
        ),
        itemCount: taskat.length,
      ),
    );
  }

  Widget buildItem(context, taskat) => Padding(
    padding: EdgeInsets.all(15.0),
    child: Row(
      children: <Widget>[
        CircleAvatar(
          backgroundColor: Colors.blue,
          radius: 20.0,
          child: Text(
            '${taskat['id']}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(
          width: 20.0,
        ),
        Text(
          '${taskat['name']}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        SizedBox(
          width: 20.0,
        ),
        Spacer(
          flex: 1,
        ),
        IconButton(
          onPressed: (){
            taskDialog(context, taskat);
          },
          icon: Icon(
            Icons.edit,
            color: Colors.green,
          ),
        ),
        IconButton(
          onPressed: (){
            deleteDialog(context, taskat['id']);
          },
          icon: Icon(
            Icons.remove_circle,
            color: Colors.red,
          ),
        ),
      ],
    ),
  );


  void taskDialog(BuildContext context,taskat) {
    var titleController = TextEditingController();
    String dropdownValue = '1';
    if(taskat != null)
    {
      titleController.text = taskat['name'];
      dropdownValue = taskat['priority'];
    }

    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                keyboardType: TextInputType.text,
                maxLines: 1,
                controller: titleController,
                decoration: InputDecoration(hintText: 'Enter Task Title..'),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Priority : '),
                  SizedBox(
                    width: 20,
                  ),
                  DropdownButton<String>(
                    value: dropdownValue,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 20,
                    elevation: 16,
                    style: TextStyle(color: Colors.black),
                    underline: Container(
                      height: 2,
                      color: Colors.black,
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValue = newValue;
                      });
                    },
                    items: <String>['1', '2', '3'].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                width: double.infinity,
                color: Colors.blue,
                height: 40.0,
                child: FlatButton(
                  padding: EdgeInsets.zero,
                  onPressed: ()
                  {
                    if(taskat != null)
                      updateTask(taskat['id'],titleController.text, dropdownValue);
                    else
                      insertTask(titleController.text,dropdownValue);

                    Navigator.pop(context);
                  },
                  child: Text(
                    taskat == null ? 'add task'.toUpperCase() : 'update task'.toUpperCase(),
                    style: TextStyle(
                        color: Colors.white
                    ),
                  ),

                ),
              ),
            ],
          ),
        )
    );
  }

  void createDatabase() async {

    // open the database
    await openDatabase('tasks.dp', version: 1, onOpen: (Database dp) {
      currentDatabase = dp;
      getTasks();
    }, onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute('CREATE TABLE Tasks (id INTEGER PRIMARY KEY, name TEXT, priority TEXT)');
    });

    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'tasks.dp');
    print(path);


  }

  void insertTask(name,priority) async {
    if (currentDatabase != null) {
      await currentDatabase.transaction((txn) async {
        int id1 = await txn.rawInsert('INSERT INTO Tasks(name, priority) VALUES("$name", "$priority")').then((value)
        {
          getTasks();
          return null;
        });
        print('inserted + $id1');
      });
    }
  }


  void updateTask(id,name,priority) async {
    int count =
    await currentDatabase.rawUpdate('UPDATE Tasks SET name = ?, priority = ?  WHERE id = $id',  ['$name,$priority']).then((value)
    {
      getTasks();
      return null;
    });
  }

  void deleteTask(id) async {
    await currentDatabase.rawDelete('DELETE FROM Tasks WHERE id = ?', ['$id']).then((value) {
      getTasks();
      return ;
    });
  }

  void getTasks() async {
    taskat = await currentDatabase.rawQuery('SELECT * FROM Tasks');
    setState(() {
    });
  }

  void deleteDialog(context, id)
  {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Are You Sure To Delete This Item?',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Container(
                width: double.infinity,
                height: 40.0,
                color: Colors.blue,
                child: FlatButton(
                  onPressed: ()
                  {
                    deleteTask(id);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Yes'.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

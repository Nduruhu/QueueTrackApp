import 'package:flutter/material.dart';

import 'login_page.dart';
class RoleSelection extends StatefulWidget {
  const RoleSelection({super.key});

  @override
  State<RoleSelection> createState() => _RoleSelectionState();
}

class _RoleSelectionState extends State<RoleSelection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: ListTile(
          titleAlignment: ListTileTitleAlignment.center,

          title: Text(
            'Karibu Queue Track',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25
          ),
          ),
          subtitle: Text('Digital Queueing',style: TextStyle(color: Colors.black),),
        ),
      ),
      backgroundColor: Colors.blue,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              Card(
                elevation: 5,
                child: ListTile(
                    leading: Icon(Icons.badge,size: 40,),
                    title: Text('Sacco Official'),
                    onTap: (){
                      //aende login page as sacco official
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => LoginPage(selectedRole: 'sacco_official',)));
                    }
                ),
              ),
              Divider(),
              Card(elevation: 5,child: ListTile(
                leading: Icon(Icons.person,size: 40,),
                title: Text('Stage Marshal'),
                onTap: (){
                  //aende login page as stage marshal
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(selectedRole: 'stage_marshal',)));
                },
              )
              ),
              Divider(),
              Card(elevation: 5,
              child: ListTile(
                leading: Icon(Icons.handshake,size: 40,),
                title: Text('Matatu Owner'),
                onTap: (){
                  //aende login page as matatu owner
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(selectedRole: 'matatu_owner',)));
                },
              ),),
              Divider(),
              Card(
                elevation: 5,
                child: ListTile(
                  leading: Icon(Icons.directions_car,size: 40,),
                  title: Text('Driver'),
                  onTap: (){
                    //aende login page as driver
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(selectedRole: 'driver',)));

                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

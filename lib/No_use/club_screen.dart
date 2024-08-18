import 'package:flutter/material.dart';

class ClubScreen extends StatefulWidget {
  @override
  _ClubScreenState createState() => _ClubScreenState();
}

class _ClubScreenState extends State<ClubScreen> {
  final _formKey = GlobalKey<FormState>(); // 폼의 상태를 관리하기 위한 키
  String _clubName = '';
  String _clubDescription = '';

  void _saveClub() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // 여기서 데이터를 서버에 저장하거나 로컬 상태로 관리할 수 있습니다.
      // 예제에서는 간단히 출력만 합니다.
      print('Club Name: $_clubName');
      print('Club Description: $_clubDescription');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Club saved successfully!'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Club"),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Club Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter club name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _clubName = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Club Description',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onSaved: (value) {
                  _clubDescription = value!;
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: _saveClub,
                  child: Text('Save Club'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

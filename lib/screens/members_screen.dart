import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MembersScreen extends StatelessWidget {
  final String clubId;

  MembersScreen({required this.clubId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Members'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('clubs').doc(clubId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return Center(child: Text('No members found'));
          }

          // 클럽 멤버 목록 가져오기 (members 필드가 Map으로 저장됨)
          Map<String, dynamic> members = snapshot.data!['members'];

          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              String userId = members.keys.elementAt(index);
              String role = members[userId]['role']; // 멤버 역할 정보

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text('Loading...'),
                    );
                  }
                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return ListTile(
                      title: Text('Unknown User'),
                    );
                  }

                  // users 컬렉션에서 닉네임 가져오기
                  String nickname = userSnapshot.data!['nickname'] ?? 'Unnamed';

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text(nickname), // 사용자 ID 대신 닉네임 표시
                      subtitle: Text('Role: $role'),
                      trailing: _buildRoleDropdown(context, clubId, userId, role), // 역할 변경 기능
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // 역할 변경을 위한 드롭다운 메뉴
  Widget _buildRoleDropdown(BuildContext context, String clubId, String userId, String currentRole) {
    List<String> roles = ['admin', 'member', 'viewer'];

    return DropdownButton<String>(
      value: currentRole,
      onChanged: (newRole) {
        if (newRole != null) {
          _updateUserRole(clubId, userId, newRole);
        }
      },
      items: roles.map<DropdownMenuItem<String>>((String role) {
        return DropdownMenuItem<String>(
          value: role,
          child: Text(role),
        );
      }).toList(),
    );
  }

  // Firestore에서 멤버의 역할 업데이트
  void _updateUserRole(String clubId, String userId, String newRole) {
    FirebaseFirestore.instance.collection('clubs').doc(clubId).update({
      'members.$userId.role': newRole,
    });
  }
}



/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MembersScreen extends StatelessWidget {
  final String clubId;

  MembersScreen({required this.clubId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Members'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('clubs').doc(clubId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return Center(child: Text('No members found'));
          }

          // 클럽 멤버 목록 가져오기
          Map<String, dynamic> members = snapshot.data!['members'];

          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              String userId = members.keys.elementAt(index);
              String role = members[userId]['role']; // 멤버 역할 정보

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(userId), // 실제 사용자 정보로 대체
                  subtitle: Text('Role: $role'),
                  trailing: _buildRoleDropdown(context, clubId, userId, role), // 역할 변경 기능 추가
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 역할 변경을 위한 드롭다운 메뉴
  Widget _buildRoleDropdown(BuildContext context, String clubId, String userId, String currentRole) {
    List<String> roles = ['admin', 'member', 'viewer'];

    return DropdownButton<String>(
      value: currentRole,
      onChanged: (newRole) {
        if (newRole != null) {
          _updateUserRole(clubId, userId, newRole);
        }
      },
      items: roles.map<DropdownMenuItem<String>>((String role) {
        return DropdownMenuItem<String>(
          value: role,
          child: Text(role),
        );
      }).toList(),
    );
  }

  // Firestore에서 멤버의 역할 업데이트
  void _updateUserRole(String clubId, String userId, String newRole) {
    FirebaseFirestore.instance.collection('clubs').doc(clubId).update({
      'members.$userId.role': newRole,
    });
  }
}

 */

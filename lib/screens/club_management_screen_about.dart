import 'package:flutter/material.dart';
import 'members_screen.dart';

class AboutTab extends StatelessWidget {
  final String clubId;
  final String clubName;
  final String clubDescription;
  final int memberCount;
  final Function() pickImage;
  final String? uploadedImageUrl;

  AboutTab({
    required this.clubId,
    required this.clubName,
    required this.clubDescription,
    required this.memberCount,
    required this.pickImage,
    required this.uploadedImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 클럽 대표 이미지 및 업로드 버튼
            Stack(
              children: [
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    image: uploadedImageUrl != null
                        ? DecorationImage(
                      image: NetworkImage(uploadedImageUrl!),
                      fit: BoxFit.cover,
                    )
                        : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.black,
                    child: Icon(Icons.groups, size: 40, color: Colors.green),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: GestureDetector(
                    onTap: pickImage,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.black,
                          child: Icon(Icons.camera_alt, color: Colors.green),
                        ),
                        SizedBox(width: 8),
                        Text('Upload', style: TextStyle(color: Colors.green)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // 클럽 이름 및 멤버 수
            Text(
              clubName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '$memberCount member${memberCount > 1 ? 's' : ''}',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 16),
            // 프리미엄 업그레이드 및 편집 버튼
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // 클럽 정보 수정 기능
                  },
                  icon: Icon(Icons.edit, color: Colors.green),
                  label: Text('Edit club', style: TextStyle(color: Colors.green)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.green),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    // 설정 화면으로 이동
                  },
                  icon: Icon(Icons.settings, color: Colors.green),
                ),
              ],
            ),
            Divider(color: Colors.white70),
            // 멤버, 사진, 문서 관리 섹션
            ListTile(
              leading: Icon(Icons.group, color: Colors.green),
              title: Text('Members', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MembersScreen(clubId: clubId),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.photo, color: Colors.green),
              title: Text('Photos', style: TextStyle(color: Colors.white)),
              trailing: Text('Premium feature', style: TextStyle(color: Colors.white70)),
              onTap: () {
                // 프리미엄 기능 안내
              },
            ),
            ListTile(
              leading: Icon(Icons.insert_drive_file, color: Colors.green),
              title: Text('Documents', style: TextStyle(color: Colors.white)),
              trailing: Text('Premium feature', style: TextStyle(color: Colors.white70)),
              onTap: () {
                // 프리미엄 기능 안내
              },
            ),
          ],
        ),
      ),
    );
  }
}

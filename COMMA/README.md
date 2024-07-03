
# flutter_plugin


A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# 데이터베이스 생성 및 데이터 추가

```sql
CREATE TABLE folders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  type ENUM('lecture', 'colon') NOT NULL
);

INSERT INTO folders (name, type) VALUES
('기본 폴더', 'lecture'),
('정보통신공학', 'lecture'),
('컴퓨터알고리즘', 'lecture'),
('이산수학', 'lecture'),
('기본 폴더 (:)', 'colon'),
('정보통신공학 (:)', 'colon'),
('컴퓨터알고리즘 (:)', 'colon'),
('이산수학 (:)', 'colon');
```

const express = require('express');
const mysql = require('mysql');
const bodyParser = require('body-parser');
const cors = require('cors');
const crypto = require('crypto');

const app = express();
const port = 3000;

app.use(bodyParser.json());
app.use(cors());

const db = mysql.createConnection({
    host: 'localhost',
    user: 'comma',
    password: 'comma0812@',
    database: 'comma'
});

db.connect((err) => {
    if (err) {
        throw err;
    }
    console.log('MySQL Connected...');
});

// 강의 폴더 목록 가져오기
app.get('/api/lecture-folders', (req, res) => {
    const sql = 'SELECT id, folder_name FROM LectureFolders';
    db.query(sql, (err, result) => {
        if (err) throw err;
        res.send(result);
    });
});

// 콜론 폴더 목록 가져오기
app.get('/api/colon-folders', (req, res) => {
    const sql = 'SELECT id, folder_name FROM ColonFolders';
    db.query(sql, (err, result) => {
        if (err) throw err;
        res.send(result);
    });
});

// 강의 폴더의 파일 목록 가져오기
app.get('/api/lecture-files/:folderId', (req, res) => {
    const folderId = req.params.folderId;
    const sql = 'SELECT id, folder_id, file_name, file_url, created_at FROM LectureFiles WHERE folder_id = ?';
    db.query(sql, [folderId], (err, result) => {
        if (err) throw err;
        res.send(result);
    });
});

// 콜론 폴더의 파일 목록 가져오기
app.get('/api/colon-files/:folderId', (req, res) => {
    const folderId = req.params.folderId;
    const sql = 'SELECT id, folder_id, file_name, file_url, created_at FROM ColonFiles WHERE folder_id = ?';
    db.query(sql, [folderId], (err, result) => {
        if (err) throw err;
        res.send(result);
    });
});

// 강의 폴더 추가
app.post('/api/lecture-folders', (req, res) => {
    const folderName = req.body.folder_name;
    const sql = 'INSERT INTO LectureFolders (folder_name) VALUES (?)';
    db.query(sql, [folderName], (err, result) => {
        if (err) throw err;
        res.send({ id: result.insertId, folder_name: folderName });
    });
});

// 콜론 폴더 추가
app.post('/api/colon-folders', (req, res) => {
    const folderName = req.body.folder_name;
    const sql = 'INSERT INTO ColonFolders (folder_name) VALUES (?)';
    db.query(sql, [folderName], (err, result) => {
        if (err) throw err;
        res.send({ id: result.insertId, folder_name: folderName });
    });
});

// 폴더 이름 변경하기
app.put('/api/:folderType-folders/:id', (req, res) => {
    const folderType = req.params.folderType;
    const folderId = req.params.id;
    const newName = req.body.folder_name;
    const tableName = folderType === 'lecture' ? 'LectureFolders' : 'ColonFolders';
    const sql = `UPDATE ${tableName} SET folder_name = ? WHERE id = ?`;

    db.query(sql, [newName, folderId], (err, result) => {
        if (err) throw err;
        res.status(200).send({
            id: folderId,
            folder_name: newName,
        });
    });
});

// 폴더 삭제하기
app.delete('/api/:folderType-folders/:id', (req, res) => {
    const folderType = req.params.folderType;
    const id = req.params.id;
    const table = folderType === 'lecture' ? 'LectureFolders' : 'ColonFolders';
    const sql = `DELETE FROM ${table} WHERE id = ?`;
    db.query(sql, [id], (err, result) => {
        if (err) throw err;
        res.status(200).send('Folder deleted');
    });
});

// 파일 이름 변경하기
app.put('/api/:fileType-files/:id', (req, res) => {
    const fileType = req.params.fileType;
    const fileId = req.params.id;
    const newName = req.body.file_name;
    const tableName = fileType === 'lecture' ? 'LectureFiles' : 'ColonFiles';
    const sql = `UPDATE ${tableName} SET file_name = ? WHERE id = ?`;

    db.query(sql, [newName, fileId], (err, result) => {
        if (err) throw err;
        res.status(200).send({
            id: fileId,
            file_name: newName,
        });
    });
});

// 파일 삭제하기
app.delete('/api/:fileType-files/:id', (req, res) => {
    const fileType = req.params.fileType;
    const id = req.params.id;
    const table = fileType === 'lecture' ? 'LectureFiles' : 'ColonFiles';
    const sql = `DELETE FROM ${table} WHERE id = ?`;
    db.query(sql, [id], (err, result) => {
        if (err) throw err;
        res.status(200).send('File deleted');
    });
});

// 파일 이동하기
app.put('/api/:fileType-files/move/:id', (req, res) => {
    const fileType = req.params.fileType;
    const fileId = req.params.id;
    const newFolderId = req.body.folder_id;
    const tableName = fileType === 'lecture' ? 'LectureFiles' : 'ColonFiles';
    const sql = `UPDATE ${tableName} SET folder_id = ? WHERE id = ?`;

    db.query(sql, [newFolderId, fileId], (err, result) => {
        if (err) throw err;
        res.status(200).send({
            id: fileId,
            folder_id: newFolderId,
        });
    });
});

// 회원가입_전화번호 중복확인
app.post('/api/validate_phone', (req, res) => {
    const userPhone = req.body.user_phone;

    console.log('API 요청 수신: /api/validate_phone');
    console.log('전달된 전화번호:', userPhone);

    if (!userPhone) {
        return res.status(400).json({ success: false, error: "Invalid input", phone: userPhone });
    }

    const sqlQuery = "SELECT * FROM user_table WHERE user_phone = ?";
    db.query(sqlQuery, [userPhone], (err, result) => {
        if (err) {
            console.error('Query failed:', err);
            return res.status(500).json({ success: false, error: "Query failed" });
        }

        if (result.length > 0) {
            res.json({ existPhone: true });
        } else {
            res.json({ existPhone: false });
        }
    });
});

// 회원가입_정보 저장
app.post('/api/signup_info', (req, res) => {
    console.log('API 요청 수신: /api/signup_info');

    const userEmail = req.body.user_email;
    const userPhone = req.body.user_phone;
    const userPassword = req.body.user_password;
    // 비밀번호를 MD5로 해시
    const hashedPassword = crypto.createHash('md5').update(userPassword).digest('hex');

    console.log('전달된 이메일:', userEmail);
    console.log('전달된 전화번호:', userPhone);

    if (!userEmail || !userPhone || !userPassword) {
        return res.status(400).json({ success: false, error: 'You must fill all values.' });
    }

    const sqlQuery = `INSERT INTO user_table (user_email, user_phone, user_password) VALUES (?, ?, ?)`;
    db.query(sqlQuery, [userEmail, userPhone, hashedPassword], (err, result) => {
        if (err) {
            return res.status(500).json({ success: false, error: err.message });
        }
        return res.json({ success: true });
    });
});

// 로그인 처리
app.post('/api/login', (req, res) => {
    console.log('API 요청 수신: /api/login');

    const userEmail = req.body.user_email;
    const userPassword = req.body.user_password;

    // 비밀번호를 MD5로 해시
    const hashedPassword = crypto.createHash('md5').update(userPassword).digest('hex');

    if (!userEmail || !userPassword) {
        return res.status(400).json({ success: false, error: 'You must fill all values.' });
    }

    const sqlQuery = `SELECT * FROM user_table WHERE user_email = ? AND user_password = ?`;
    db.query(sqlQuery, [userEmail, hashedPassword], (err, result) => {
        if (err) {
            return res.status(500).json({ success: false, error: err.message });
        }

        if (result.length > 0) {
            return res.json({ success: true, userData: result[0] });
        } else {
            return res.json({ success: false, error: 'Invalid email or password' });
        }
    });
});

// 최신 강의 파일을 가져오는 API 엔드포인트
app.get('/api/getLectureFiles', (req, res) => {
    const sql = `SELECT * FROM LectureFiles ORDER BY created_at DESC LIMIT 3`;
    db.query(sql, (err, results) => {
        if (err) {
            res.status(500).send(err);
        } else {
            res.json({ files: results });
        }
    });
});

// 최신 콜론 파일을 가져오는 API 엔드포인트
app.get('/api/getColonFiles', (req, res) => {
    const sql = `SELECT * FROM ColonFiles ORDER BY created_at DESC LIMIT 3`;
    db.query(sql, (err, results) => {
        if (err) {
            res.status(500).send(err);
        } else {
            res.json({ files: results });
        }
    });
});

// 파일 이름 변경하기
app.put('/api/:fileType-files/:id', (req, res) => {
    const fileType = req.params.fileType;
    const fileId = req.params.id;
    const newName = req.body.file_name;
    const tableName = fileType === 'lecture' ? 'LectureFiles' : 'ColonFiles';
    const sql = `UPDATE ${tableName} SET file_name = ? WHERE id = ?`;

    db.query(sql, [newName, fileId], (err, result) => {
        if (err) throw err;
        res.status(200).send({
            id: fileId,
            file_name: newName,
        });
    });
});

// 파일 삭제하기
app.delete('/api/:fileType-files/:id', (req, res) => {
    const fileType = req.params.fileType;
    const id = req.params.id;
    const table = fileType === 'lecture' ? 'LectureFiles' : 'ColonFiles';
    const sql = `DELETE FROM ${table} WHERE id = ?`;
    db.query(sql, [id], (err, result) => {
        if (err) throw err;
        res.status(200).send('File deleted');
    });
});

// 파일 이동하기
app.put('/api/:fileType-files/move/:id', (req, res) => {
    const fileType = req.params.fileType;
    const fileId = req.params.id;
    const newFolderId = req.body.folder_id;
    const tableName = fileType === 'lecture' ? 'LectureFiles' : 'ColonFiles';
    const sql = `UPDATE ${tableName} SET folder_id = ? WHERE id = ?`;

    db.query(sql, [newFolderId, fileId], (err, result) => {
        if (err) throw err;
        res.status(200).send({
            id: fileId,
            folder_id: newFolderId,
        });
    });
});

// 다른 폴더 목록 가져오기
app.get('/api/getOtherFolders/:fileType/:currentFolderId', (req, res) => {
    const fileType = req.params.fileType;
    const currentFolderId = req.params.currentFolderId;
    const tableName = fileType === 'lecture' ? 'LectureFolders' : 'ColonFolders';
    const sql = `SELECT id, folder_name FROM ${tableName} WHERE id != ?`;

    db.query(sql, [currentFolderId], (err, result) => {
        if (err) throw err;
        res.send(result);
    });
});

// 파일 검색 API
app.get('/api/searchFiles', (req, res) => {
    const query = req.query.query;
    const sql = `
        SELECT * FROM LectureFiles WHERE file_name LIKE ? 
        UNION
        SELECT * FROM ColonFiles WHERE file_name LIKE ? 
        ORDER BY created_at DESC
    `;
    const searchQuery = `%${query}%`;
    db.query(sql, [searchQuery, searchQuery], (err, results) => {
        if (err) {
            res.status(500).send(err);
        } else {
            res.json({ files: results });
        }
    });
});

app.listen(3000, () => {
    console.log('Server started on port 3000');
});

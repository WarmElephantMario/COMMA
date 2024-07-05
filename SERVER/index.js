const express = require('express');
const mysql = require('mysql');
const bodyParser = require('body-parser');
const cors = require('cors');
// const { admin } = require('firebase-admin');
// const serviceAccount = "D:/comma/dev2_v1/COMMA/SERVER/google-services.json"

const app = express();
const port = 3000;

// $env: GOOGLE_APPLICATION_CREDENTIALS = "D:/comma/dev2_v1/COMMA/SERVER/google-services.json"

app.use(bodyParser.json());
app.use(cors());

const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'mysqlE271828@',
    database: 'comma'
});

db.connect((err) => {
    if (err) {
        throw err;
    }
    console.log('MySQL Connected...');
});



// const bucket = admin.storage().bucket();

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

app.listen(3000, () => {
    console.log('Server started on port 3000');
});

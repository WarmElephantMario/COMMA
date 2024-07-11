const express = require('express');
//const mysql = require('mysql');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const cors = require('cors');
const crypto = require('crypto');

const app = express();
const port = 3000;

app.use(bodyParser.json());
app.use(cors());

const db = mysql.createConnection({
    host: '10.240.4.249',
    user: 'comma',
    password: 'comma0812!',
    database: 'comma'
});

db.connect((err) => {
    if (err) {
        throw err;
    }
    console.log('MySQL Connected...');
});

// 사용자 ID 기반으로 강의 폴더 목록 가져오기
app.get('/api/lecture-folders/:userId', (req, res) => {
    const userId = req.params.userId;
    const sql = 'SELECT id, folder_name FROM LectureFolders WHERE user_id = ?';
    db.query(sql, [userId], (err, result) => {
        if (err) throw err;
        res.send(result);
    });
});

// 사용자 ID 기반으로 콜론 폴더 목록 가져오기
app.get('/api/colon-folders/:userId', (req, res) => {
    const userId = req.params.userId;
    const sql = 'SELECT id, folder_name FROM ColonFolders WHERE user_id = ?';
    db.query(sql, [userId], (err, result) => {
        if (err) throw err;
        res.send(result);
    });
});

// 강의 폴더 추가
app.post('/api/lecture-folders', (req, res) => {
    const { folder_name, user_id } = req.body;
    const sql = 'INSERT INTO LectureFolders (folder_name, user_id) VALUES (?, ?)';
    db.query(sql, [folder_name, user_id], (err, result) => {
        if (err) throw err;
        res.send({ id: result.insertId, folder_name, user_id });
    });
});

// 콜론 폴더 추가
app.post('/api/colon-folders', (req, res) => {
    const { folder_name, user_id } = req.body;
    const sql = 'INSERT INTO ColonFolders (folder_name, user_id) VALUES (?, ?)';
    db.query(sql, [`${folder_name} (:)`, user_id], (err, result) => {
        if (err) throw err;
        res.send({ id: result.insertId, folder_name: `${folder_name} (:)`, user_id });
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

// 강의 폴더 목록 가져오기 (특정 사용자)
app.get('/api/lecture-folders', (req, res) => {
    const userId = req.query.user_id;
    const sql = `
        SELECT 
            LectureFolders.id, 
            LectureFolders.folder_name, 
            COUNT(LectureFiles.id) AS file_count 
        FROM LectureFolders 
        LEFT JOIN LectureFiles ON LectureFolders.id = LectureFiles.folder_id 
        WHERE LectureFolders.user_id = ? 
        GROUP BY LectureFolders.id
    `;
    db.query(sql, [userId], (err, result) => {
        if (err) throw err;
        res.send(result);
    });
});

// 콜론 폴더 목록 가져오기 (특정 사용자)
app.get('/api/colon-folders', (req, res) => {
    const userId = req.query.user_id;
    const sql = `
        SELECT 
            ColonFolders.id, 
            ColonFolders.folder_name, 
            COUNT(ColonFiles.id) AS file_count 
        FROM ColonFolders 
        LEFT JOIN ColonFiles ON ColonFolders.id = ColonFiles.folder_id 
        WHERE ColonFolders.user_id = ? 
        GROUP BY ColonFolders.id
    `;
    db.query(sql, [userId], (err, result) => {
        if (err) throw err;
        res.send(result);
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

// 특정 폴더의 파일 목록 가져오기 (특정 사용자)
app.get('/api/:fileType-files/:folderId', (req, res) => {
    const folderId = req.params.folderId;
    const fileType = req.params.fileType;
    const userId = req.query.user_id;
    const tableName = fileType === 'lecture' ? 'LectureFiles' : 'ColonFiles';
    const joinTable = fileType === 'lecture' ? 'LectureFolders' : 'ColonFolders';
    const sql = `SELECT ${tableName}.* FROM ${tableName} INNER JOIN ${joinTable} ON ${tableName}.folder_id = ${joinTable}.id WHERE ${joinTable}.user_id = ? AND ${tableName}.folder_id = ?`;

    db.query(sql, [userId, folderId], (err, result) => {
        if (err) {
            console.error('Failed to fetch files:', err);
            return res.status(500).send('Failed to fetch files');
        }
        res.send(result);
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

// // 회원가입_정보 저장
// app.post('/api/signup_info', (req, res) => {
//     console.log('API 요청 수신: /api/signup_info');

//     const userEmail = req.body.user_email;
//     const userPhone = req.body.user_phone;
//     const userPassword = req.body.user_password;
//     // 비밀번호를 MD5로 해시
//     const hashedPassword = crypto.createHash('md5').update(userPassword).digest('hex');

//     console.log('전달된 이메일:', userEmail);
//     console.log('전달된 전화번호:', userPhone);

//     if (!userEmail || !userPhone || !userPassword) {
//         return res.status(400).json({ success: false, error: 'You must fill all values.' });
//     }

//     const sqlQuery = `INSERT INTO user_table (user_email, user_phone, user_password) VALUES (?, ?, ?)`;
//     db.query(sqlQuery, [userEmail, userPhone, hashedPassword], (err, result) => {
//         if (err) {
//             return res.status(500).json({ success: false, error: err.message });
//         }
//         return res.json({ success: true });
//     });
// });

// 회원가입_정보 저장
app.post('/api/signup_info', (req, res) => {
    console.log('API 요청 수신: /api/signup_info');

    const userEmail = req.body.user_email;
    const userPhone = req.body.user_phone;
    const userPassword = req.body.user_password;
    const hashedPassword = crypto.createHash('md5').update(userPassword).digest('hex');
    const usernickname = req.body.user_nickname;

    console.log('전달된 이메일:', userEmail);
    console.log('전달된 전화번호:', userPhone);
    console.log('생성된 닉네임:', usernickname); 

    if (!userEmail || !userPhone || !userPassword) {
        return res.status(400).json({ success: false, error: 'You must fill all values.' });
    }

    const sqlQuery = `INSERT INTO user_table (user_email, user_phone, user_password, user_nickname) VALUES (?, ?, ?, ?)`;
    db.query(sqlQuery, [userEmail, userPhone, hashedPassword, usernickname], (err, result) => {
        if (err) {
            return res.status(500).json({ success: false, error: err.message });
        }

        const userId = result.insertId; // 삽입된 사용자의 ID를 가져옴

        // 기본 폴더 생성
        const lectureFolderQuery = 'INSERT INTO LectureFolders (folder_name, user_id) VALUES (?, ?)';
        const colonFolderQuery = 'INSERT INTO ColonFolders (folder_name, user_id) VALUES (?, ?)';

        db.query(lectureFolderQuery, ['기본 폴더', userId], (err, result) => {
            if (err) {
                console.error('Failed to create lecture folder:', err);
            } else {
                console.log('Default lecture folder created');
            }
        });

        db.query(colonFolderQuery, ['기본 폴더 (:)', userId], (err, result) => {
            if (err) {
                console.error('Failed to create colon folder:', err);
            } else {
                console.log('Default colon folder created');
            }
        });

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

// // 최신 강의 파일을 가져오는 API 엔드포인트
// app.get('/api/getLectureFiles', (req, res) => {
//     const sql = `SELECT * FROM LectureFiles ORDER BY created_at DESC LIMIT 3`;
//     db.query(sql, (err, results) => {
//         if (err) {
//             res.status(500).send(err);
//         } else {
//             res.json({ files: results });
//         }
//     });
// });

// // 최신 콜론 파일을 가져오는 API 엔드포인트
// app.get('/api/getColonFiles', (req, res) => {
//     const sql = `SELECT * FROM ColonFiles ORDER BY created_at DESC LIMIT 3`;
//     db.query(sql, (err, results) => {
//         if (err) {
//             res.status(500).send(err);
//         } else {
//             res.json({ files: results });
//         }
//     });
// });

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

// 강의파일 생성
app.post('/api/lecture-files', (req, res) => {
    console.log('POST /api/lecture-files called');
    const { folder_id, file_name, file_url, lecture_name } = req.body;
  
    if (!folder_id || !file_name) {
      return res.status(400).json({ success: false, error: 'You must provide folder_id and file_name.' });
    }
  
    const sql = 'INSERT INTO LectureFiles (folder_id, file_name, file_url, lecture_name) VALUES (?, ?, ?, ?)';
    db.query(sql, [folder_id, file_name, file_url, lecture_name], (err, result) => {
      if (err) {
        return res.status(500).json({ success: false, error: err.message });
      }
      res.json({ success: true, id: result.insertId, folder_id, file_name, file_url, lecture_name });
    });
  });
  
//콜론폴더 생성 및 파일 생성
app.post('/api/create-colon-folder', (req, res) => {
    const { folderName, noteName, fileUrl, lectureName, user_id } = req.body;

    // Check if the folder already exists for the same user
    const checkFolderQuery = 'SELECT id FROM ColonFolders WHERE folder_name = ? AND user_id = ?';
    db.query(checkFolderQuery, [folderName, user_id], (err, results) => {
        if (err) {
            return res.status(500).json({ error: 'Failed to check folder existence' });
        }

        if (results.length > 0) {
            // Folder exists, use the existing folder id
            const folderId = results[0].id;

            // Insert file into the existing folder
            const insertFileQuery = 'INSERT INTO ColonFiles (folder_id, file_name, file_url, lecture_name, created_at) VALUES (?, ?, ?, ?, NOW())';
            db.query(insertFileQuery, [folderId, noteName, fileUrl, lectureName], (err, result) => {
                if (err) {
                    return res.status(500).json({ error: 'Failed to add file to folder' });
                }
                res.status(200).json({ message: 'File added to existing folder successfully', folder_id: folderId });
            });
        } else {
            // Folder does not exist, create a new folder
            const createFolderQuery = 'INSERT INTO ColonFolders (folder_name, user_id) VALUES (?, ?)';
            db.query(createFolderQuery, [folderName, user_id], (err, result) => {
                if (err) {
                    return res.status(500).json({ error: 'Failed to create folder' });
                }
                const folderId = result.insertId;

                // Insert file into the new folder
                const insertFileQuery = 'INSERT INTO ColonFiles (folder_id, file_name, file_url, lecture_name, created_at) VALUES (?, ?, ?, ?, NOW())';
                db.query(insertFileQuery, [folderId, noteName, fileUrl, lectureName], (err, result) => {
                    if (err) {
                        return res.status(500).json({ error: 'Failed to add file to folder' });
                    }
                    res.status(200).json({ message: 'Folder and file created successfully', folder_id: folderId });
                });
            });
        }
    });
});


//강의파일 created_at 가져오기
app.get('/api/get-file-created-at', (req, res) => {
    const { folderId, fileName } = req.query;

    const query = 'SELECT created_at FROM LectureFiles WHERE folder_id = ? AND file_name = ? LIMIT 1';
    db.query(query, [folderId, fileName], (err, result) => {
        if (err) {
            return res.status(500).json({ error: 'Failed to fetch created_at' });
        }
        if (result.length > 0) {
            res.status(200).json({ createdAt: result[0].created_at });
        } else {
            res.status(404).json({ error: 'File not found' });
        }
    });
});

//콜론 파일 created_at 가져오기
// Get colon file details
app.get('/api/get-colon-file', (req, res) => {
    const { folderName } = req.query;

    const query = `
        SELECT f.id, f.file_name, f.file_url, f.created_at
        FROM ColonFiles f
        JOIN ColonFolders c ON f.folder_id = c.id
        WHERE c.folder_name = ?
        ORDER BY f.created_at DESC
        LIMIT 1`;

    db.query(query, [folderName], (err, results) => {
        if (err) {
            return res.status(500).json({ error: 'Failed to fetch file details' });
        }
        if (results.length === 0) {
            return res.status(404).json({ error: 'File not found' });
        }
        res.status(200).json(results[0]);
    });
});

// 폴더 이름 가져오기 - 강의 폴더 또는 콜론 폴더 구분
app.get('/api/getFolderName/:fileType/:folderId', (req, res) => {
    const { fileType, folderId } = req.params;
    let table = fileType === 'lecture' ? 'LectureFolders' : 'ColonFolders';

    const sql = `SELECT folder_name FROM ${table} WHERE id = ?`;
    db.query(sql, [folderId], (err, result) => {
        if (err) {
            console.error('Error fetching folder name:', err);
            res.status(500).send({ error: 'Internal Server Error' });
            return;
        }
        if (result.length > 0) {
            res.json({ folder_name: result[0].folder_name });
        } else {
            res.status(404).send({ error: 'Folder not found' });
        }
    });

});

// 사용자별 최신 강의 파일을 가져오는 API 엔드포인트
app.get('/api/getLectureFiles/:userId', (req, res) => {
    const userId = req.params.userId;
    const sql = `
        SELECT LectureFiles.* FROM LectureFiles
        INNER JOIN LectureFolders ON LectureFiles.folder_id = LectureFolders.id
        WHERE LectureFolders.user_id = ?
        ORDER BY LectureFiles.created_at DESC
    `;
    db.query(sql, [userId], (err, results) => {
        if (err) {
            res.status(500).send(err);
        } else {
            res.json({ files: results });
        }
    });
});

// 사용자별 최신 콜론 파일을 가져오는 API 엔드포인트
app.get('/api/getColonFiles/:userId', (req, res) => {
    const userId = req.params.userId;
    const sql = `
    SELECT ColonFiles.* FROM ColonFiles
    INNER JOIN ColonFolders ON ColonFiles.folder_id = ColonFolders.id
    WHERE ColonFolders.user_id = ?
    ORDER BY ColonFiles.created_at DESC`;
    db.query(sql, [userId], (err, results) => {
        if (err) {
            res.status(500).send(err);
        } else {
            res.json({ files: results });
        }
    });
});
// 콜론 폴더 이름 가져오기
app.get('/api/get-folder-name', (req, res) => {
    const { folderId } = req.query;
    
    const sql = 'SELECT folder_name FROM LectureFolders WHERE id = ?';
    db.query(sql, [folderId], (err, results) => {
        if (err) {
            return res.status(500).json({ success: false, error: err.message });
        }

        if (results.length > 0) {
            res.status(200).json({ folder_name: results[0].folder_name });
        } else {
            res.status(404).json({ success: false, error: 'Folder not found' });
        }
    });
});


app.listen(port, () => {
    console.log(`Server started on port ${port}`);
});
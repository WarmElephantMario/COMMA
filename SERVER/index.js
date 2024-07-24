const express = require('express');
//const mysql = require('mysql');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const cors = require('cors');
const crypto = require('crypto');
const nodemailer = require('nodemailer');

const app = express();
const port = 3000;

app.use(bodyParser.json());
app.use(cors());

const db = mysql.createPool({
    host: 'database-comma.cx4q2cgwkin7.us-east-2.rds.amazonaws.com',
    user: 'comma',
    password: 'comma0812!',
    database: 'comma'
});

// 확인용 연결 테스트 (쿼리를 사용하여 연결 확인)
db.getConnection((err, connection) => {
    if (err) {
        console.error('Error connecting to MySQL:', err);
        return;
    }
    console.log('MySQL Connected...');
    connection.release(); // 연결 해제
});

// 사용자 ID 기반으로 강의 폴더 목록 가져오기
app.get('/api/lecture-folders', (req, res) => {
    const userKey = req.query.userKey;
    const currentFolderId = req.query.currentFolderId;
    const sql = 'SELECT id, folder_name FROM LectureFolders WHERE userKey = ?';
    db.query(sql, [userKey, currentFolderId], (err, result) => {
        if (err) throw err;
        res.send(result);
    });
});

// 사용자 ID 기반으로 콜론 폴더 목록 가져오기
app.get('/api/colon-folders/:userKey', (req, res) => {
    const userKey = req.params.userKey;
    const sql = 'SELECT id, folder_name FROM ColonFolders WHERE userKey = ?';
    db.query(sql, [userKey], (err, result) => {
        if (err) throw err;
        res.send(result);
    });
});

// 강의 폴더 추가
app.post('/api/lecture-folders', (req, res) => {
    const { folder_name, userKey } = req.body;
    const sql = 'INSERT INTO LectureFolders (folder_name, userKey) VALUES (?, ?)';
    db.query(sql, [folder_name, userKey], (err, result) => {
        if (err) throw err;
        res.send({ id: result.insertId, folder_name, userKey });
    });
});

// 콜론 폴더 추가
app.post('/api/colon-folders', (req, res) => {
    const { folder_name, userKey } = req.body;
    const sql = 'INSERT INTO ColonFolders (folder_name, userKey) VALUES (?, ?)';
    db.query(sql, [`${folder_name} (:)`, userKey], (err, result) => {
        if (err) throw err;
        res.send({ id: result.insertId, folder_name: `${folder_name} (:)`, userKey });
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
    const userKey = req.query.userKey;
    const sql = `
        SELECT 
            LectureFolders.id, 
            LectureFolders.folder_name, 
            COUNT(LectureFiles.id) AS file_count 
        FROM LectureFolders 
        LEFT JOIN LectureFiles ON LectureFolders.id = LectureFiles.folder_id 
        WHERE LectureFolders.userKey = ? 
        GROUP BY LectureFolders.id
    `;
    db.query(sql, [userKey], (err, result) => {
        if (err) throw err;
        res.send(result);
    });
});

// 콜론 폴더 목록 가져오기 (특정 사용자)
app.get('/api/colon-folders', (req, res) => {
    const userKey = req.query.userKey;
    const sql = `
        SELECT 
            ColonFolders.id, 
            ColonFolders.folder_name, 
            COUNT(ColonFiles.id) AS file_count 
        FROM ColonFolders 
        LEFT JOIN ColonFiles ON ColonFolders.id = ColonFiles.folder_id 
        WHERE ColonFolders.userKey = ? 
        GROUP BY ColonFolders.id
    `;
    db.query(sql, [userKey], (err, result) => {
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
    const userKey = req.query.userKey;
    const tableName = fileType === 'lecture' ? 'LectureFiles' : 'ColonFiles';
    const joinTable = fileType === 'lecture' ? 'LectureFolders' : 'ColonFolders';
    const sql = `SELECT ${tableName}.* FROM ${tableName} INNER JOIN ${joinTable} ON ${tableName}.folder_id = ${joinTable}.id WHERE ${joinTable}.userKey = ? AND ${tableName}.folder_id = ?`;

    db.query(sql, [userKey, folderId], (err, result) => {
        if (err) {
            console.error('Failed to fetch files:', err);
            return res.status(500).send('Failed to fetch files');
        }
        res.send(result);
    });
});

// 회원가입_이메일 중복확인
app.post('/api/validate_email', (req, res) => {
    const userEmail = req.body.user_email;

    console.log('API 요청 수신: /api/validate_email');
    console.log('전달된 이메일 주소:', userEmail);

    if (!userEmail) {
        return res.status(400).json({ success: false, error: "Invalid input", email: userEmail });
    }

    const sqlQuery = "SELECT * FROM user_table WHERE user_email = ?";
    db.query(sqlQuery, [userEmail], (err, result) => {
        if (err) {
            console.error('Query failed:', err);
            return res.status(500).json({ success: false, error: "Query failed" });
        }

        if (result.length > 0) {
            res.json({ existEmail: true });
        } else {
            res.json({ existEmail: false });
        }
    });
});


// 이메일 전송 설정
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: 'warmelephantmario@gmail.com',
        pass: 'yfqu msgv zqwq kuja',
    },
});

// 인증 코드 저장을 위한 메모리 저장소 
const verificationCodes = {};


//회원가입_인증번호 전송
app.post('/api/send_verification_code', (req, res) => {
    const userEmail = req.body.user_email;
    const verificationCode = Math.floor(100000 + Math.random() * 900000); // 6자리 랜덤 코드 생성

    const mailOptions = {
      from: 'warmelephantmario@gmail.com',
      to: userEmail,
      subject: 'Your Verification Code',
      text: `Your verification code is ${verificationCode}`,
    };
  
    transporter.sendMail(mailOptions, (error, info) => {
      if (error) {
        console.error('Error sending email: ', error);
        return res.status(500).json({ success: false, error: error.toString() });
      } else {
        console.log('Email sent: ' + info.response);
        verificationCodes[userEmail] = verificationCode; 
        return res.status(200).json({ success: true });
      }
    });
  });

  // 회원가입_인증번호 확인
app.post('/api/verify_code', (req, res) => {
    const { user_email, verification_code } = req.body;

    // 저장된 인증 코드와 비교
    if (verificationCodes[user_email] && verificationCodes[user_email] == verification_code) {
        delete verificationCodes[user_email]; // 사용된 인증 코드는 삭제
        return res.status(200).json({ success: true });
    } else {
        return res.status(400).json({ success: false, error: 'Invalid verification code' });
    }
});


// 회원가입_정보 저장
app.post('/api/signup_info', (req, res) => {
    console.log('API 요청 수신: /api/signup_info');

    const userId = req.body.user_id;
    const userEmail = req.body.user_email;
    const userPassword = req.body.user_password;
    const hashedPassword = crypto.createHash('md5').update(userPassword).digest('hex');
    const usernickname = req.body.user_nickname;

    console.log('전달된 아이디:', userId);
    console.log('전달된 이메일:', userEmail);
    console.log('생성된 닉네임:', usernickname);

    if (!userEmail || !userId || !userPassword) {
        return res.status(400).json({ success: false, error: 'You must fill all values.' });
    }

    const sqlQuery = `INSERT INTO user_table (user_id, user_email, user_password, user_nickname) VALUES (?, ?, ?, ?)`;
    db.query(sqlQuery, [userId, userEmail, hashedPassword, usernickname], (err, result) => {
        if (err) {
            return res.status(500).json({ success: false, error: err.message });
        }

        const userKey = result.insertId; // 삽입된 사용자의 ID를 가져옴

        // 기본 폴더 생성
        const lectureFolderQuery = 'INSERT INTO LectureFolders (folder_name, userKey) VALUES (?, ?)';
        const colonFolderQuery = 'INSERT INTO ColonFolders (folder_name, userKey) VALUES (?, ?)';

        db.query(lectureFolderQuery, ['기본 폴더', userKey], (err, result) => {
            if (err) {
                console.error('Failed to create lecture folder:', err);
            } else {
                console.log('Default lecture folder created');
            }
        });

        db.query(colonFolderQuery, ['기본 폴더 (:)', userKey], (err, result) => {
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

    const userId = req.body.user_id;
    const userPassword = req.body.user_password;

    // 비밀번호를 MD5로 해시
    const hashedPassword = crypto.createHash('md5').update(userPassword).digest('hex');

    if (!userId || !userPassword) {
        return res.status(400).json({ success: false, error: 'You must fill all values.' });
    }

    const sqlQuery = `SELECT * FROM user_table WHERE user_id = ? AND user_password = ?`;
    db.query(sqlQuery, [userId, hashedPassword], (err, result) => {
        if (err) {
            return res.status(500).json({ success: false, error: err.message });
        }


        if (result.length > 0) {
            return res.json({ success: true, userData: result[0] });
        } else {
            return res.json({ success: false, error: 'Invalid ID or password' });
        }
    });
});

// 회원 탈퇴
app.post('/api/delete_user', async (req, res) => {
    console.log('API 요청 수신: /api/delete_user');

    const userKey = req.body.userKey;
    console.log('Received userKey:', userKey);

    if (!userKey) {
        console.log('No userKey provided');
        return res.status(400).json({ success: false, error: "사용자를 찾을 수 없습니다" });
    }

    db.beginTransaction(async (err) => {
        if (err) {
            console.error('Transaction error:', err);
            return res.status(500).json({ success: false, error: 'Transaction error' });
        }

        try {
            // Delete related lecturefiles
            const [lectureFilesResult] = await db.promise().query(
                'DELETE FROM LectureFiles WHERE folder_id IN (SELECT id FROM LectureFolders WHERE userKey = ?)',
                [userKey]
            );
            console.log('Deleted lecturefiles:', lectureFilesResult.affectedRows);

            // Delete related colonfiles
            const [colonFilesResult] = await db.promise().query(
                'DELETE FROM ColonFiles WHERE folder_id IN (SELECT id FROM ColonFolders WHERE userKey = ?)',
                [userKey]
            );
            console.log('Deleted colonfiles:', colonFilesResult.affectedRows);

            // Delete related lecturefolders
            const [lectureFoldersResult] = await db.promise().query('DELETE FROM LectureFolders WHERE userKey = ?', [userKey]);
            console.log('Deleted lecturefolders:', lectureFoldersResult.affectedRows);

            // Delete related colonfolders
            const [colonFoldersResult] = await db.promise().query('DELETE FROM ColonFolders WHERE userKey = ?', [userKey]);
            console.log('Deleted colonfolders:', colonFoldersResult.affectedRows);

            // Delete the user
            const [userResult] = await db.promise().query('DELETE FROM user_table WHERE userKey = ?', [userKey]);
            console.log('Deleted user:', userResult.affectedRows);

            db.commit((commitErr) => {
                if (commitErr) {
                    db.rollback(() => {
                        console.error('Commit error:', commitErr);
                        return res.status(500).json({ success: false, error: 'Commit error' });
                    });
                } else {
                    console.log('User and related data deleted successfully.');
                    res.json({ success: true });
                }
            });
        } catch (error) {
            db.rollback(() => {
                console.error('Transaction error:', error);
                res.status(500).json({ success: false, error: 'Database error' });
            });
        }
    });
});



//회원 닉네임 변경하기
app.put('/api/update_nickname', (req, res) => {
    const userKey = req.body.userKey;
    const newNickname = req.body.user_nickname;

    console.log(`Received request to update nickname for userKey: ${userKey} to newNickname: ${newNickname}`);

    // 데이터베이스 업데이트 쿼리
    const query = 'UPDATE user_table SET user_nickname = ? WHERE userKey = ?';
    db.query(query, [newNickname, userKey], (err, result) => {
        if (err) {
            console.error(`Error updating nickname for userKey: ${userKey} - ${err.message}`);
            return res.status(500).send({ success: false, error: err.message });
        }

        console.log(`Query Result: `, result);  // 쿼리 결과 로그 추가
        if (result.affectedRows === 0) {
            console.log(`No rows updated for userKey: ${userKey}`);
            return res.status(404).send({ success: false, error: 'User not found' });
        }

        console.log(`Nickname updated successfully for userKey: ${userKey}`);
        res.send({ success: true });
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
    const userKey = req.query.userKey; // 쿼리 파라미터로 userKey를 가져옴
    const tableName = fileType === 'lecture' ? 'LectureFolders' : 'ColonFolders';
    const sql = `SELECT id, folder_name FROM ${tableName} WHERE userKey = ?`;

    db.query(sql, [currentFolderId, userKey], (err, result) => {
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

// 강의 파일 생성 (실시간 자막, 대체텍스트 동일)
// id(PK), folder_id, file_name, file_url, lecture_name, created_at, type, existColon (id) 저장함
// type은 0이면 대체, 1이면 실시간 자막.
// existColon은 처음엔 무조건 NULL로 삽입함
app.post('/api/lecture-files', (req, res) => {
    console.log('POST /api/lecture-files called');
    const { folder_id, file_name, file_url, lecture_name, type } = req.body;

    if (!folder_id || !file_name) {
        return res.status(400).json({ success: false, error: 'You must provide folder_id and file_name.' });
    }

    const sql = 'INSERT INTO LectureFiles (folder_id, file_name, file_url, lecture_name, type) VALUES (?, ?, ?, ?, ?)';
    db.query(sql, [folder_id, file_name, file_url, lecture_name, type], (err, result) => {
        if (err) {
            return res.status(500).json({ success: false, error: err.message });
        }
        res.json({ success: true, id: result.insertId, folder_id, file_name, file_url, lecture_name, type });
    });
});

// Lecture details 업데이트 엔드포인트
app.post('/api/update-lecture-details', (req, res) => {
    const { lecturefileId, file_url, lecture_name, type } = req.body;
  
    console.log('Received data:', { lecturefileId, file_url, lecture_name, type });
  
    if (!lecturefileId || !file_url || !lecture_name || type == null) {
      return res.status(400).send({ error: 'Missing required fields' });
    }
  
    const sql = 'UPDATE LectureFiles SET file_url = ?, lecture_name = ?, type = ? WHERE id = ?';
    db.query(sql, [file_url, lecture_name, type, lecturefileId], (err, results) => {
      if (err) {
        console.error('Database query error:', err);
        return res.status(500).send({ error: 'Database query error' });
      }
      res.send({ success: true, message: 'Lecture details updated successfully' });
    });
  });
  

//대체텍스트 파일 생성 시 responseUrl 저장
app.post('/api/alt-table', (req, res) => {
    console.log('POST /api/alt-table called');
    const { lecturefile_id, colonfile_id, alternative_text_url } = req.body;

    if (!lecturefile_id || !alternative_text_url) {
        return res.status(400).json({ success: false, error: 'You must provide lecturefile_id and alternative_text_url.' });
    }

    const sql = 'INSERT INTO Alt_table (lecturefile_id, colonfile_id, alternative_text_url) VALUES (?, ?, ?)';
    db.query(sql, [lecturefile_id, colonfile_id, alternative_text_url], (err, result) => {
        if (err) {
            return res.status(500).json({ success: false, error: err.message });
        }
        res.json({ success: true, lecturefile_id, colonfile_id, alternative_text_url });
    });
});

//콜론파일 폴더 생성 및 파일 생성
//아직 lecturefile에는 삽입전
app.post('/api/create-colon', (req, res) => {
    const { folderName, noteName, fileUrl, lectureName, type, userKey } = req.body;

    console.log('Received request to create colon folder:', { folderName, noteName, fileUrl, lectureName, type, userKey });

    // Check if the folder already exists for the same user
    const checkFolderQuery = 'SELECT id FROM ColonFolders WHERE folder_name = ? AND userKey = ?';
    db.query(checkFolderQuery, [folderName, userKey], (err, results) => {
        if (err) {
            console.error('Failed to check folder existence:', err);
            return res.status(500).json({ error: 'Failed to check folder existence' });
        }

        const insertFileAndReturnId = (folderId) => {
            // Insert file into the folder
            const insertFileQuery = 'INSERT INTO ColonFiles (folder_id, file_name, file_url, lecture_name, created_at, type) VALUES (?, ?, ?, ?, NOW(), ?)';
            db.query(insertFileQuery, [folderId, noteName, fileUrl, lectureName, type], (err, result) => {
                if (err) {
                    console.error('Failed to add file to folder:', err);
                    return res.status(500).json({ error: 'Failed to add file to folder' });
                }
                const colonFileId = result.insertId;
                console.log('File added to ColonFiles, file ID:', colonFileId);

                // Return the colonFileId instead of inserting into LectureFiles
                res.status(200).json({ message: 'File added to ColonFiles successfully', colonFileId: colonFileId, folder_id: folderId });
            });
        };

        if (results.length > 0) {
            // Folder exists, use the existing folder id
            const folderId = results[0].id;
            console.log('Folder exists, using existing folder ID:', folderId);
            insertFileAndReturnId(folderId);
        } else {
            // Folder does not exist, create a new folder
            const createFolderQuery = 'INSERT INTO ColonFolders (folder_name, userKey) VALUES (?, ?)';
            db.query(createFolderQuery, [folderName, userKey], (err, result) => {
                if (err) {
                    console.error('Failed to create folder:', err);
                    return res.status(500).json({ error: 'Failed to create folder' });
                }
                const folderId = result.insertId;
                console.log('Folder created successfully, new folder ID:', folderId);
                insertFileAndReturnId(folderId);
            });
        }
    });
});
//existColon에 삽입
app.post('/api/update-lecture-file', (req, res) => {
    const { lectureFileId, colonFileId } = req.body;

    const updateQuery = 'UPDATE LectureFiles SET existColon = ? WHERE id = ?';
    db.query(updateQuery, [colonFileId, lectureFileId], (err, result) => {
        if (err) {
            console.error('Failed to update lecture file:', err);
            return res.status(500).json({ error: 'Failed to update lecture file' });
        }
        res.status(200).json({ message: 'Lecture file updated successfully' });
    });
});

// 특정 lecturefileId에 해당하는 existColon 값 확인 API 엔드포인트
app.get('/api/check-exist-colon', (req, res) => {
    const lecturefileId = req.query.lecturefileId;
    console.log(`Received lecturefileId in existcolon: ${lecturefileId}`);

    if (!lecturefileId || isNaN(parseInt(lecturefileId, 10))) {
        console.log('Invalid lecturefileId');
        return res.status(400).json({ error: 'Invalid lecturefileId' });
    }

    const parsedLecturefileId = parseInt(lecturefileId, 10);

    const query = 'SELECT existColon FROM LectureFiles WHERE id = ?';
    console.log(`Executing query: ${query} with lecturefileId: ${parsedLecturefileId}`);
    
    db.query(query, [parsedLecturefileId], (err, results) => {
        if (err) {
            console.error('Failed to check existColon:', err);
            return res.status(500).json({ error: 'Failed to check existColon' });
        }

        if (results.length > 0) {
            console.log(`existColon value: ${results[0].existColon}`);
            res.status(200).json({ existColon: results[0].existColon });
        } else {
            console.log('LectureFile not found');
            res.status(404).json({ error: 'LectureFile not found' });
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
// app.get('/api/get-colon-file', (req, res) => {
//     const { folderName } = req.query;

//     const query = `
//         SELECT f.id, f.file_name, f.file_url, f.created_at
//         FROM ColonFiles f
//         JOIN ColonFolders c ON f.folder_id = c.id
//         WHERE c.folder_name = ?
//         ORDER BY f.created_at DESC
//         LIMIT 1`;

//     db.query(query, [folderName], (err, results) => {
//         if (err) {
//             return res.status(500).json({ error: 'Failed to fetch file details' });
//         }
//         if (results.length === 0) {
//             return res.status(404).json({ error: 'File not found' });
//         }
//         res.status(200).json(results[0]);
//     });
// });

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

// 강의파일 아이디 가져오기
app.get('/api/getFileId', (req, res) => {
    const fileUrl = req.query.file_url;
    const sql = 'SELECT id FROM LectureFiles WHERE file_url = ?';
    
    db.query(sql, [fileUrl], (err, results) => {
      if (err) {
        res.status(500).send(err);
      } else {
        if (results.length > 0) {
          res.json({ id: results[0].id });
        } else {
          res.status(404).send({ message: 'File not found' });
        }
      }
    });
  });

// 사용자별 최신 강의 파일을 가져오는 API 엔드포인트
app.get('/api/getLectureFiles/:userKey', (req, res) => {
    const userKey = req.params.userKey;
    const sql = `
        SELECT LectureFiles.* FROM LectureFiles
        INNER JOIN LectureFolders ON LectureFiles.folder_id = LectureFolders.id
        WHERE LectureFolders.userKey = ?
        ORDER BY LectureFiles.created_at DESC
    `;
    db.query(sql, [userKey], (err, results) => {
        if (err) {
            res.status(500).send(err);
        } else {
            res.json({ files: results });
        }
    });
});

// 사용자별 최신 콜론 파일을 가져오는 API 엔드포인트
app.get('/api/getColonFiles/:userKey', (req, res) => {
    const userKey = req.params.userKey;
    const sql = `
    SELECT ColonFiles.* FROM ColonFiles
    INNER JOIN ColonFolders ON ColonFiles.folder_id = ColonFolders.id
    WHERE ColonFolders.userKey = ?
    ORDER BY ColonFiles.created_at DESC`;
    db.query(sql, [userKey], (err, results) => {
        if (err) {
            res.status(500).send(err);
        } else {
            res.json({ files: results });
        }
    });
});

// 강의 폴더 이름 가져오기
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


// 대체 텍스트 URL 가져오기
app.get('/api/get-alternative-text-url', (req, res) => {
    const { lecturefileId } = req.query;
    console.log(`Received lecturefileId: ${lecturefileId}`);

    const sql = `
        SELECT alternative_text_url
        FROM Alt_table
        WHERE lecturefile_id = ?
    `;

    db.query(sql, [lecturefileId], (err, results) => {
        if (err) {
            return res.status(500).json({ success: false, error: err.message });
        }

        console.log(`Query results: ${JSON.stringify(results)}`);

        if (results.length > 0) {
            res.status(200).json({ alternative_text_url: results[0].alternative_text_url });
        } else {
            res.status(404).json({ success: false, message: 'No matching record found' });
        }
    });
});

// record_url을 가져오기
app.get('/api/get-record-url', (req, res) => {
    const { colonfileId } = req.query;
    console.log(`Received colonfileId: ${colonfileId}`);

    const sql = `
        SELECT record_url
        FROM Record_table
        WHERE colonfile_id = ?
    `;

    db.query(sql, [colonfileId], (err, results) => {
        if (err) {
            return res.status(500).json({ success: false, error: err.message });
        }

        console.log(`Query results: ${JSON.stringify(results)}`);

        if (results.length > 0) {
            res.status(200).json({ record_url: results[0].record_url });
        } else {
            res.status(404).json({ success: false, message: 'No matching record found' });
        }
    });
});

//해당 콜론파일 정보 가져오기
app.get('/api/get-colon-details', (req, res) => {
    const colonId = req.query.colonId;
    console.log(`Received colonId: ${colonId}`);

    if (!colonId || isNaN(parseInt(colonId, 10))) {
        console.log('Invalid colonId');
        return res.status(400).json({ error: 'Invalid colonId' });
    }
    const parsedColonId = parseInt(colonId, 10);

    const query = 'SELECT folder_id, file_name, file_url, lecture_name, created_at, type FROM ColonFiles WHERE id = ?';
    console.log(`Executing query: ${query} with colonId: ${parsedColonId}`);
    
    db.query(query, [parsedColonId], (err, results) => {
        if (err) {
            console.error('Failed to get colon details:', err);
            return res.status(500).json({ error: 'Failed to get colon details' });
        }

        if (results.length > 0) {
            console.log(`Colon details: ${JSON.stringify(results[0])}`);
            res.status(200).json(results[0]);
        } else {
            console.log('Colonfile not found');
            res.status(404).json({ error: 'Colonfile not found' });
        }
    });
});

// 콜론 폴더 이름 가져오기
app.get('/api/get-Colonfolder-name', (req, res) => {
    const { folderId } = req.query;
    const sql = 'SELECT folder_name FROM ColonFolders WHERE id = ?';
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

// 녹음종료 후 자막 스크립트 부분 데베에 저장
app.post('/api/insertRecordData', (req, res) => {
    const { lecturefile_id, colonfile_id, record_url } = req.body;

    if (!lecturefile_id || !record_url) {
        return res.status(400).json({ success: false, error: 'You must provide lecturefile_id and record_url.' });
    }

    const sql = 'INSERT INTO Record_table (lecturefile_id, colonfile_id, record_url) VALUES (?, ?, ?)';
    db.query(sql, [lecturefile_id, colonfile_id, record_url], (err, result) => {
        if (err) {
            return res.status(500).json({ success: false, error: err.message });
        }
        res.json({ success: true, id: result.insertId, lecturefile_id, colonfile_id, record_url });
    });
});


// 콜론 생성 후 Record_table 업데이트
app.post('/api/update-record-table', (req, res) => {
    const { lecturefile_id, colonfile_id } = req.body;
    const sql = 'UPDATE Record_table SET colonfile_id = ? WHERE lecturefile_id = ?';

    db.query(sql, [colonfile_id, lecturefile_id], (err, result) => {
        if (err) {
            console.error('Error updating record table:', err);
            res.status(500).json({ error: 'Failed to update record table' });
        } else {
            res.status(200).json({ success: true });
        }
    });
});

// Record_Table에 page 업데이트
app.post('/api/updateRecordPage', (req, res) => {
    const { page, id } = req.body;
    const sql = 'UPDATE Alt_table SET page = ? WHERE id = ?';
    db.query(sql, [page, id], (err, result) => {
        if (err) {
            console.error('Failed to update RecordPage:', err);
            res.status(500).send('Failed to insert RecordPage');
        } else {
            console.log('page inserted successfully:', result);
            res.send({ id: result.insertId, colonfile_id, page, url });
        }
    });
});

// DividedScript_Table에서 page , url(페이지 스크립트) 가져오기
app.get('/api/get-page-scripts', (req, res) => {
    const colonfile_id = req.query.colonfile_id;
    const sql = 'SELECT page, url FROM DividedScript_Table WHERE colonfile_id = ?';

    db.query(sql, [colonfile_id], (err, results) => {
        if (err) {
            console.error('페이지 스크립트 가져오기 실패:', err);
            res.status(500).send('페이지 스크립트 가져오기 실패');
        } else {
            res.send(results);
        }
    });
});

// 특정 lecturefile_id 행에 colonfile_id 업데이트하기
app.post('/api/update-alt-table', (req, res) => {
    const { lecturefileId, colonFileId } = req.body;
  
    console.log('Received data:', { lecturefileId, colonFileId }); // 로그 추가
  
    if (!lecturefileId || !colonFileId) {
      console.log('Missing required fields'); // 로그 추가
      return res.status(400).send({ error: 'Missing required fields' });
    }
  
    const sql = 'UPDATE Alt_table SET colonfile_id = ? WHERE lecturefile_id = ?';
    db.query(sql, [colonFileId, lecturefileId], (err, results) => {
      if (err) {
        console.error('Database query error:', err); // 로그 추가
        res.status(500).send('Internal server error');
      } else {
        if (results.affectedRows > 0) {
          console.log('Update successful'); // 로그 추가
          res.status(200).send('Update successful');
        } else {
          console.log('Lecturefile not found'); // 로그 추가
          res.status(404).send('Lecturefile not found');
        }
      }
    });
  });

// Alt_table의 특정 colonfile_id 행에서 URL 가져오기
app.get('/api/get-alt-url/:colonfile_id', (req, res) => {
    const colonfile_id = req.params.colonfile_id;
    console.log(`Received request for colonfile_id: ${colonfile_id}`); // 로그 추가
    const sql = 'SELECT alternative_text_url FROM Alt_table WHERE colonfile_id = ?';
  
    db.query(sql, [colonfile_id], (err, results) => {
      if (err) {
        console.error('Failed to fetch alternative text URL:', err);
        res.status(500).send('Failed to fetch alternative text URL');
      } else {
        console.log('Query results:', results); // 로그 추가
        if (results.length > 0) {
          console.log(`Found URL: ${results[0].alternative_text_url}`); // 로그 추가
          res.json({ alternative_text_url: results[0].alternative_text_url });
        } else {
          console.log('No URL found for the given colonfile_id'); // 로그 추가
          res.status(404).send('No URL found for the given colonfile_id');
        }
      }
    });
  });
  
  //쪼개 대체 삽입
  app.post('/api/alt-table2', (req, res) => {
    console.log('POST /api/alt-table2 called');
    const { lecturefile_id, alternative_text_url, page } = req.body;

    if (!lecturefile_id || !alternative_text_url || page === undefined) {
        return res.status(400).json({ success: false, error: 'You must provide lecturefile_id, url, and page.' });
    }

    const sql = 'INSERT INTO Alt_table2 (lecturefile_id, alternative_text_url, page) VALUES (?, ?, ?)';
    db.query(sql, [lecturefile_id, alternative_text_url, page], (err, result) => {
        if (err) {
            return res.status(500).json({ success: false, error: err.message });
        }
        res.json({ success: true, lecturefile_id, alternative_text_url, page });
    });
});


app.listen(port, () => {
    console.log(`Server started on port ${port}`);
});
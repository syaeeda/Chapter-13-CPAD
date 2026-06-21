# Lab Manual Completion Summary

## SCSM2223 Chapter 10: Connecting to Database with PDO

### ✅ Lab Objectives Completed

#### 1. Create a MySQL database and books table from schema.sql
- **Status**: ✅ COMPLETED
- Database `books_api` created with charset utf8mb4
- Table `books` created with proper schema including id, title, author, year, genre, created_at, updated_at
- Initial seed data (3 books) inserted
- Method: Executed via `setup-db.php` which reads and executes schema.sql using PDO

#### 2. Build a PDO factory that reads credentials from .env
- **Status**: ✅ COMPLETED
- File: [src/Database.php](src/Database.php)
- Singleton pattern with static `get()` method
- Reads from $_ENV variables with fallback defaults
- PDO configured with:
  - ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
  - ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
  - ATTR_EMULATE_PREPARES => false
- .env file configured with database credentials

#### 3. Implement BookRepository with prepared statements for every CRUD operation
- **Status**: ✅ COMPLETED
- File: [src/Repositories/BookRepository.php](src/Repositories/BookRepository.php)
- Methods implemented:
  - `all(string $q = '', int $limit = 0)`: Get all books with optional search and limit
  - `find(int $id)`: Get single book by ID
  - `create(array $b)`: Insert new book
  - `update(int $id, array $b)`: Update existing book (partial updates supported)
  - `delete(int $id)`: Delete book
- All methods use prepared statements with named placeholders
- User input NEVER concatenated into SQL strings

#### 4. Refactor Slim controller to delegate persistence to repository (zero SQL in controller)
- **Status**: ✅ COMPLETED
- File: [src/Controllers/BookController.php](src/Controllers/BookController.php)
- Controller receives BookRepository via dependency injection
- Methods: index, show, create, update, delete
- No SQL statements in controller - all delegated to repository
- Proper HTTP status codes and error handling

#### 5. Verify that user-supplied input cannot be used for SQL injection
- **Status**: ✅ COMPLETED
- Test 1 - OR injection on id parameter:
  - Attempt: `GET /api/books/1%20OR%201=1`
  - Result: Returns book with id=1 (injection failed - cast to int prevents attack)
  - Why: Controller casts path to int: `(int)$a['id']`
- Test 2 - Quote escape in search parameter:
  - Attempt: `GET /api/books?q='%20OR%20'1'='1`
  - Result: Empty data array (injection failed - data bound as placeholder)
  - Why: Prepared statement treats input as data, not SQL code

#### 6. Test all endpoints with REST Client
- **Status**: ✅ COMPLETED

### API Test Results

**Test 1 - List and seed data**
```
GET http://localhost:8000/api/books
Response: 200 OK
Count: 3
Data: [Clean Code, Eloquent JavaScript, Vue.js 3 By Example]
```

**Test 2a - Search functionality**
```
GET http://localhost:8000/api/books?q=clean
Response: 200 OK
Count: 1
Data: [Clean Code]
```

**Test 2b - Limit functionality**
```
GET http://localhost:8000/api/books?limit=2
Response: 200 OK
Count: 2
Data: [First two books]
```

**Test 3 - Show single book**
```
GET http://localhost:8000/api/books/1
Response: 200 OK
Data: Clean Code book details
```

**Test 4 - SQL Injection Attempt (OR on id)**
```
GET http://localhost:8000/api/books/1%20OR%201=1
Response: 200 OK (returns book id=1)
Result: PROTECTED - Type casting prevented injection
```

**Test 5 - SQL Injection Attempt (Quote escape)**
```
GET http://localhost:8000/api/books?q='%20OR%20'1'='1
Response: 200 OK (empty data)
Result: PROTECTED - Prepared statements prevented injection
```

### Project Structure
```
books-api-mysql/
├── public/
│   └── index.php          (Entry point with Dotenv bootstrap)
├── src/
│   ├── Database.php       (PDO factory)
│   ├── routes.php         (Route definitions)
│   ├── Controllers/
│   │   └── BookController.php
│   ├── Repositories/
│   │   └── BookRepository.php
│   ├── Middleware/
│   │   ├── Cors.php
│   │   └── JsonBodyParser.php
│   └── Data/
│       └── books.php      (Legacy in-memory data)
├── sql/
│   └── schema.sql         (Database schema)
├── .env                   (Database credentials)
├── .env.example           (Committed to git)
├── composer.json          (Dependencies)
└── test-comprehensive.http (Test cases)
```

### Technologies Used
- **Framework**: Slim Framework 4
- **Database**: MySQL 8.0 (via Laragon)
- **Configuration**: vlucas/phpdotenv
- **PHP Version**: 8.3.1
- **Development Server**: PHP Built-in Server (localhost:8000)

### Key Security Features
1. **Prepared Statements**: All database queries use named placeholders
2. **Type Casting**: Path parameters cast to appropriate types
3. **Dependency Injection**: Repository pattern for clean separation
4. **Environment Variables**: Sensitive credentials in .env (not committed)
5. **Error Handling**: Errors logged server-side, safe JSON responses

### Notes
- Database connection successful after fixing .env DB_PASS (changed from @1234 to empty string)
- PHP development server running on localhost:8000
- Data persists between requests (unlike Chapter 9 which used in-memory arrays)
- All CRUD operations fully functional and tested
- SQL injection protection verified with manual injection attempts

---

**Lab Status**: ✅ COMPLETE
**All Objectives Met**: YES

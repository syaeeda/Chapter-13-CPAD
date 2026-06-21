<?php
/**
 * Database initialization script
 * Reads schema.sql and executes it via PDO
 */

try {
    // Connect to MySQL server (without specifying a database initially)
    $pdo = new PDO('mysql:host=127.0.0.1;port=3306;charset=utf8mb4', 'root', '', [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    ]);
    
    // Read the schema file
    $schema = file_get_contents(__DIR__ . '/sql/schema.sql');
    
    // Split statements (simple approach - split by semicolon)
    $statements = array_filter(
        array_map('trim', explode(';', $schema)),
        fn($s) => !empty($s)
    );
    
    // Execute each statement
    foreach ($statements as $statement) {
        $pdo->exec($statement);
        echo "✓ Executed: " . substr($statement, 0, 50) . "...\n";
    }
    
    echo "\n✅ Database setup completed successfully!\n";
    
} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}

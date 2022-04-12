<?php
$servername = "db";
$username = "root";
$password = "haslohaslo123";
$db = 'test';
$port = 3306;

// Create connection
$conn = new mysqli($servername, $username, $password, $db, $port);
var_dump($conn);
// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
echo "Connected successfully";




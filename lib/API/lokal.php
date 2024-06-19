<?php
$host = "localhost";
$username = "root";
$password = "";
$database = "suryatest";

// Create connection
$conn = new mysqli($host, $username, $password, $database);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Kode SQL atau operasi lain dapat ditambahkan di sini
?>

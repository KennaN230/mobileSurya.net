<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
require_once 'lokal.php'; // Adjust to your database connection file

if (isset($_SERVER['REQUEST_METHOD']) && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $conn = new mysqli($host, $username, $password, $database);

    if ($conn->connect_error) {
        die("Koneksi gagal: " . $conn->connect_error);
    }

    $username = mysqli_real_escape_string($conn, $_POST["email"]);
    $password = mysqli_real_escape_string($conn, $_POST["password"]);

    $query = "SELECT * FROM konsumen WHERE email = '$username' AND password = '$password'";
    $result = $conn->query($query);

    if ($result->num_rows === 1) {
        $response = array('status' => 'success', 'message' => 'Login berhasil');
    } else {
        $response = array('status' => 'fail', 'message' => 'Login gagal');
    }
    echo json_encode($response);

    $conn->close();
} else {
    echo json_encode(array('status' => 'fail', 'message' => 'Invalid request method'));
}
?>

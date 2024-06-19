<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

require_once 'lokal.php'; // Adjust to your database connection file

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $conn = new mysqli($host, $username, $password, $database);

    if ($conn->connect_error) {
        die(json_encode(array('status' => 'fail', 'message' => 'Database connection failed: ' . $conn->connect_error)));
    }

    $email = mysqli_real_escape_string($conn, $_POST["email"]);
    $nama = mysqli_real_escape_string($conn, $_POST["nama"]);
    $noTelp = mysqli_real_escape_string($conn, $_POST["noTelp"]);
    $password = mysqli_real_escape_string($conn, $_POST["password"]);
    $tanggalLahir = mysqli_real_escape_string($conn, $_POST["tanggalLahir"]);
    $jenisKelamin = mysqli_real_escape_string($conn, $_POST["jenisKelamin"]);
    $alamat = mysqli_real_escape_string($conn, $_POST["alamat"]);

    // Check if email already exists
    $checkEmailQuery = "SELECT * FROM konsumen WHERE email = '$email'";
    $result = $conn->query($checkEmailQuery);

    if ($result->num_rows > 0) {
        echo json_encode(array('status' => 'fail', 'message' => 'Email already registered'));
    } else {
        $insertQuery = "INSERT INTO konsumen (email, nama, noTelp, password, tanggalLahir, jenisKelamin, alamat) VALUES ('$email', '$nama', '$noTelp', '$password', '$tanggalLahir', '$jenisKelamin', '$alamat')";

        if ($conn->query($insertQuery) === TRUE) {
            echo json_encode(array('status' => 'success', 'message' => 'Registration successful'));
        } else {
            echo json_encode(array('status' => 'fail', 'message' => 'Registration failed: ' . $conn->error));
        }
    }

    $conn->close();
} else {
    http_response_code(405);
    echo json_encode(array('status' => 'fail', 'message' => 'Invalid request method'));
}
?>

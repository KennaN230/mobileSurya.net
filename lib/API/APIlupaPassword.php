<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
header("Accept: */*");

require_once 'lokal.php'; // Sesuaikan dengan file koneksi database Anda

// Cek koneksi
if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

// Cek apakah email dan password diisi
if (!isset($_POST['email']) || empty($_POST['email']) || !isset($_POST['password']) || empty($_POST['password'])) {
    die(json_encode(["error" => "Email and password are required"]));
}

$email = $_POST['email'];
$password = $_POST['password'];

// Cek apakah email ada di dalam database
$sql = "SELECT * FROM konsumenn WHERE email = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();
$stmt->close();

if ($result->num_rows > 0) {
    // Email ditemukan, lakukan update password
    $updateSql = "UPDATE konsumenn SET password = '$password' WHERE email = ?";
    $updateStmt = $conn->prepare($updateSql);
    $updateStmt->bind_param("s", $email);
    if ($updateStmt->execute()) {
        echo json_encode(["success" => "Password reset successfully"]);
    } else {
        echo json_encode(["error" => "Failed to reset password"]);
    }
    $updateStmt->close();
} else {
    echo json_encode(["error" => "Email not found"]);
}

$conn->close();

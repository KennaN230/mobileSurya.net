<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

require_once 'lokal.php';

// Periksa apakah ada data POST yang dikirim
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Ambil data email dari body permintaan POST
    $email = $conn->real_escape_string($_POST['email']);

    // Query untuk mendapatkan data konsumen berdasarkan email
    $sql = "SELECT nama, noTelp, tanggalLahir, jenisKelamin, alamat, profile_image FROM konsumenn WHERE email = '$email'";
    $result = $conn->query($sql);

    // Cek jika ada hasil
    if ($result->num_rows > 0) {
        $konsumen = $result->fetch_assoc();
        header('Content-Type: application/json');
        echo json_encode($konsumen);
    } else {
        http_response_code(404);
        echo json_encode(array('message' => 'No consumer found.'));
    }
} else {
    http_response_code(405);
    echo json_encode(array('message' => 'Invalid request method.'));
}
?>

<?php
require_once 'lokal.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With');

$data = json_decode(file_get_contents("php://input"), true);

if (!$data) {
    echo json_encode(["message" => "No data received"]);
    exit;
}

if (isset($data['email']) && isset($data['paket']) && isset($data['harga']) && isset($data['tanggalBeli'])) {
    $email = $data['email'];
    $nama_produk = $data['paket'];
    $harga = $data['harga'];
    $tanggal_pembelian = $data['tanggalBeli'];

    $sql = "INSERT INTO transaksi (email, paket, harga, tanggalBeli) VALUES ('$email', '$nama_produk', $harga, '$tanggal_pembelian')";

    if ($conn->query($sql) === TRUE) {
        echo json_encode(["message" => "Transaksi berhasil disimpan"]);
    } else {
        echo json_encode(["message" => "Error: " . $sql . "<br>" . $conn->error]);
    }
} else {
    echo json_encode(["message" => "Invalid input", "data" => $data]);
}

$conn->close();
?>

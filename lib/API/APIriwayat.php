<?php
// Koneksi ke database
require_once 'lokal.php';

// Set headers to allow cross-origin requests and define content type
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// Validate if there is a POST request sent
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Check if email data exists in the POST request body
    if (isset($_POST['email'])) {
        // Sanitize and validate email input
        $email = $conn->real_escape_string($_POST['email']);

        // Query to get transaction history based on email
        $sql = "SELECT paket, harga, tanggalBeli FROM transaksi WHERE email = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param('s', $email);
        $stmt->execute();
        $result = $stmt->get_result();

        // Check if there are results
        if ($result->num_rows > 0) {
            $transactions = array();
            while ($row = $result->fetch_assoc()) {
                $row['harga'] = (int)$row['harga'];  // Ensure harga is an integer
                $transactions[] = $row;
            }
            echo json_encode($transactions);
        } else {
            echo json_encode(array('message' => 'No transactions found.'));
        }
    } else {
        echo json_encode(array('message' => 'Email is required.'));
    }
} else {
    echo json_encode(array('message' => 'Invalid request method.'));
}

// Close database connection
$stmt->close();
$conn->close();
?>
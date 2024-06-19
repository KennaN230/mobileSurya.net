<?php
// Koneksi ke database
require_once 'lokal.php';

// Set headers to allow cross-origin requests and define content type
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// Validate if there is a GET request
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Query to get product name and price
    $sql = "SELECT gambar, nama_produk, harga FROM produk";
    $result = $conn->query($sql);

    // Check if there are results
    if ($result->num_rows > 0) {
        $products = array();
        while ($row = $result->fetch_assoc()) {
            // Debugging: print the row data
            error_log("Row data: " . print_r($row, true));

            // Ensure harga is an integer
            $row['harga'] = (int)$row['harga'];

            // Validate image file extension
            $allowed_extensions = array("jpg", "jpeg", "png", "gif");
            $file_extension = pathinfo($row['gambar'], PATHINFO_EXTENSION);
            if (!in_array($file_extension, $allowed_extensions)) {
                $row['gambar'] = 'login.png'; // Set default image if invalid
            }

            $products[] = $row;
        }
        echo json_encode($products);
    } else {
        echo json_encode(array('message' => 'No products found.'));
    }
} else {
    echo json_encode(array('message' => 'Invalid request method.'));
}

// Close database connection
$conn->close();
?>

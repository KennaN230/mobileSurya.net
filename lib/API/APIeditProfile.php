<?php
header("Content-Type: application/json");

require_once 'lokal.php'; // Sesuaikan dengan file koneksi database Anda

// Cek koneksi
if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

// Cek apakah semua data yang diperlukan diunggah
$required_fields = ['email', 'nama', 'tanggalLahir', 'noTelp', 'jenisKelamin', 'alamat'];
$missing_fields = [];

foreach ($required_fields as $field) {
    if (!isset($_POST[$field])) {
        $missing_fields[] = $field;
    }
}

if (!empty($missing_fields)) {
    die(json_encode(["error" => "Incomplete form data: " . implode(', ', $missing_fields) . " is missing"]));
}

// Setel parameter dan eksekusi
$email = $_POST['email'];
$name = $_POST['nama'];
$dob = $_POST['tanggalLahir'];
$phone = $_POST['noTelp'];
$gender = $_POST['jenisKelamin'];
$address = $_POST['alamat'];

$upload_dir = 'C:/xampp/htdocs/surya4/assets/images/person/';
$image_path = $upload_dir . basename($_FILES['profile_image']['name']);
$image_file_type = strtolower(pathinfo($image_path, PATHINFO_EXTENSION));

// Batasi jenis file
$allowed_file_types = ['jpg', 'png', 'jpeg', 'gif'];

$image_uploaded = false;
if (isset($_FILES['profile_image'])) {
    // Periksa apakah file sudah ada
    if (file_exists($image_path)) {
        $image_uploaded = false;
    } else {
        // Periksa ukuran file
        if ($_FILES['profile_image']['size'] > 500000) {
            die(json_encode(["error" => "File is too large"]));
        }

        // Batasi jenis file
        if (!in_array($image_file_type, $allowed_file_types)) {
            die(json_encode(["error" => "Only JPG, JPEG, PNG & GIF files are allowed"]));
        }

        // Coba unggah file
        if (move_uploaded_file($_FILES['profile_image']['tmp_name'], $image_path)) {
            $image_uploaded = true;
        } else {
            die(json_encode(["error" => "There was an error uploading your file"]));
        }
    }
}

// Simpan path gambar di database jika berhasil diunggah
$profile_image_url = $image_uploaded ? basename($_FILES['profile_image']['name']) : null;

if ($profile_image_url) {
    $sql = "UPDATE konsumen SET nama = ?, tanggalLahir = ?, noTelp = ?, jenisKelamin = ?, alamat = ?, profile_image = ? WHERE email = ?";
    $stmt = $conn->prepare($sql);
    if (!$stmt) {
        die(json_encode(["error" => "Prepare statement failed: " . $conn->error]));
    }
    $stmt->bind_param("sssssss", $name, $dob, $phone, $gender, $address, $profile_image_url, $email);
} else {
    $sql = "UPDATE konsumen SET nama = ?, tanggalLahir = ?, noTelp = ?, jenisKelamin = ?, alamat = ? WHERE email = ?";
    $stmt = $conn->prepare($sql);
    if (!$stmt) {
        die(json_encode(["error" => "Prepare statement failed: " . $conn->error]));
    }
    $stmt->bind_param("ssssss", $name, $dob, $phone, $gender, $address, $email);
}

if ($stmt->execute()) {
    echo json_encode(["success" => "Record updated successfully"]);
} else {
    echo json_encode(["error" => "Error updating record: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>

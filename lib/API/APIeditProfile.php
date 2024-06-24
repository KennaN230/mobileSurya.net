<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
header("Accept: */*");

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

$upload_dir = 'C:/xampp/htdocs/surya4/assets/images/person/'; // Sesuaikan dengan lokasi penyimpanan gambar Anda
$profile_image_url = null;

if (isset($_FILES['profile_image']) && $_FILES['profile_image']['size'] > 0) {
    $image_path = $upload_dir . basename($_FILES['profile_image']['name']);
    $image_file_type = strtolower(pathinfo($image_path, PATHINFO_EXTENSION));

    // Batasi jenis file
    $allowed_file_types = ['jpg', 'png', 'jpeg', 'gif'];

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
        $profile_image_url = basename($_FILES['profile_image']['name']);
    } else {
        die(json_encode(["error" => "There was an error uploading your file"]));
    }
}

$sql = "UPDATE konsumenn SET nama = ?, tanggalLahir = ?, noTelp = ?, jenisKelamin = ?, alamat = ?";
$params = [$name, $dob, $phone, $gender, $address];

// Jika profile_image_url tidak null, tambahkan ke query update
if ($profile_image_url !== null) {
    $sql .= ", profile_image = ?";
    $params[] = $profile_image_url;
}

$sql .= " WHERE email = ?";
$params[] = $email;

$stmt = $conn->prepare($sql);
if (!$stmt) {
    die(json_encode(["error" => "Prepare statement failed: " . $conn->error]));
}

// Bind parameter dan eksekusi statement
$bind_types = str_repeat('s', count($params)); // Sesuaikan jenis data
$stmt->bind_param($bind_types, ...$params);

if ($stmt->execute()) {
    $updatedData = [
        "nama" => $name,
        "tanggalLahir" => $dob,
        "noTelp" => $phone,
        "jenisKelamin" => $gender,
        "alamat" => $address,
        "profile_image" => $profile_image_url // Jika ada
    ];
    echo json_encode(["success" => "Record updated successfully", "data" => $updatedData]);
} else {
    echo json_encode(["error" => "Error updating record: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>

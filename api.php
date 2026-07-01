<?php
// Module 6 Assignment Faculty Page api.php | Adrian Diaz | Andrew Ingeneri 
// Backend server script to access infinity web MySQL, handling CRUD and
// preventing SQL injection. 


// Format headers to output JSON
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Infinityfree Database Credentials
require_once 'db_config.php';

// Creating the PDO Connection
try {
    $conn = new PDO("mysql:host=" . $host . ";dbname=" . $db_name, $username, $password);
    // Set the PDO error mode to exception handling
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $exception) {
    echo json_encode(["error" => "Database Connection Failed: " . $exception->getMessage()]);
    exit();
}

// Checking for the HTTP Method and ID
$method = $_SERVER['REQUEST_METHOD'];
$id = isset($_GET['id']) ? $_GET['id'] : null;

// Read incoming JSON data from frontend fetch() calls
$data = json_decode(file_get_contents("php://input"));


// CRUD API ROUTER
switch($method) {
    
    // READ (Get all faculty or a specific faculty member)
    case 'GET':
        if ($id) {
            $stmt = $conn->prepare("SELECT * FROM faculty WHERE faculty_id = ?");
            $stmt->execute([$id]);
            $result = $stmt->fetch(PDO::FETCH_ASSOC);
            echo json_encode($result ? $result : ["error" => "Faculty not found"]);
        } else {
            $stmt = $conn->prepare("SELECT * FROM faculty");
            $stmt->execute();
            $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo json_encode($result);
        }
        break;

    // CREATE (Insert new faculty, with parameterized queries (?) marks in place)
    case 'POST':
        $stmt = $conn->prepare("INSERT INTO faculty (first_name, last_name, title, email, office_location, biography) VALUES (?, ?, ?, ?, ?, ?)");
        if($stmt->execute([$data->first_name, $data->last_name, $data->title, $data->email, $data->office_location, $data->biography])) {
            echo json_encode(["message" => "Faculty added successfully!"]);
        } else {
            http_response_code(500);
            echo json_encode(["error" => "Failed to create record"]);
        }
        break;

    // UPDATE (Edit bio or phone)
    case 'PUT':
        if ($id) {
            $stmt = $conn->prepare("UPDATE faculty SET biography = ?, phone = ? WHERE faculty_id = ?");
            if($stmt->execute([$data->biography, $data->phone, $id])) {
                echo json_encode(["message" => "Faculty updated successfully!"]);
            } else {
                http_response_code(500);
                echo json_encode(["error" => "Failed to update record"]);
            }
        } else {
            http_response_code(400);
            echo json_encode(["error" => "Missing faculty ID for update"]);
        }
        break;

    // DELETE (Remove faculty and trigger DB DEL Cascade)
    case 'DELETE':
        if ($id) {
            $stmt = $conn->prepare("DELETE FROM faculty WHERE faculty_id = ?");
            if($stmt->execute([$id])) {
                echo json_encode(["message" => "Faculty deleted successfully!"]);
            } else {
                http_response_code(500);
                echo json_encode(["error" => "Failed to delete record"]);
            }
        } else {
            http_response_code(400);
            echo json_encode(["error" => "Missing faculty ID for deletion"]);
        }
        break;
}
?>
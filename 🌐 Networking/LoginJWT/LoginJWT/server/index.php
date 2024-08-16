<?php

require('recipes.php');
require('login.php');

function handleRequest($request) {
    global $api;
    $method = $_SERVER['REQUEST_METHOD'] ?? '';
    $path = $_SERVER['REQUEST_URI'] ?? '';
    $query = json_decode(file_get_contents('php://input'), true);
    $body = $query;

    if ($method === 'POST' && $path === '/login') {
        $email = $query['email'];
        $password = $query['password'];
        
        return handleLogin($email, $password);
        
    } elseif ($method === 'GET' && $path === '/recipes') {

        $authHeader = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
        $token = str_replace('Bearer ', '', $authHeader);
        
        $decodedPayload = verifyJWT($token);
        if ($decodedPayload === false) {
            http_response_code(401);
            return [
                'error' => 'Invalid or expired token',
            ];
        }
        
        $userId = $decodedPayload['sub'];
        $recipes = getUserRecipes($userId);
        
        return ['recipes' => $recipes];
        
    } elseif ($method === 'POST' && $path === '/recipes') {
        
        $title = $body['title'];
        
        $authHeader = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
        $token = str_replace('Bearer ', '', $authHeader);
        $decodedPayload = verifyJWT($token);
        if ($decodedPayload === false) {
            http_response_code(401);
            return [
                'error' => 'Invalid or expired token',
            ];
        }
        
        $userId = $decodedPayload['sub'];
        
        $recipe = createRecipe($title, $userId);
        
        return ['recipe' => $recipe];
        
    } elseif ($method === 'GET' && $path === '/refreshToken') {
        $refreshToken = $query['refreshToken'];
        $user = verifyJWT($refreshToken);
        $newAccessToken = generateJWT($user);
        
        return ['accessToken' => $newAccessToken ];
        
    } elseif ($method === 'POST' && $path === '/signup') {

        $email = $body['email'];
        $password = $body['password'];
        $user = createUser($email, $password);
        
        return ['user' => $user];
        
    } elseif ($path === '/') {
        return [ 'greeting' => 'hello world' ];
    } else {
        return ['error' => 'Route not found',];
    }
}

header('Content-Type: application/json');
$response = handleRequest($_SERVER);
echo json_encode($response);
?>

<?php    
    function generateJWT($user, $time) {
        $header = json_encode(['alg' => 'HS256', 'typ' => 'JWT']);
        $header = base64_encode($header);
        
        $payload = json_encode([
            'sub' => $user['id'],
            'email' => $user['email'],
            'iat' => time(), 
            'exp' => time() + ($time),
        ]);
        $payload = base64_encode($payload);
        
        $signature = hash_hmac('sha256', "$header.$payload", 'your_secret_key');
        
        $accessToken = "$header.$payload.$signature";
        return $accessToken;
    }

    function verifyJWT($jwt) {
        list($header, $payload, $signature) = explode('.', $jwt);
        
        $decodedHeader = json_decode(base64_decode($header), true);
        $decodedPayload = json_decode(base64_decode($payload), true);
        
        $expectedSignature = hash_hmac('sha256', "$header.$payload", 'your_secret_key');
        if ($expectedSignature !== $signature) {
            return false; 
        }
        
        if (time() > $decodedPayload['exp']) {
            return false; 
        }
        
        return $decodedPayload; 
    }
    
    function test() {
        // replace with token given after auth
        $decoded = verifyJWT('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZW1haWwiOiJjcmlzdGlhbkByb2phcy5mciIsImlhdCI6MTcxMTY0MzcyOSwiZXhwIjoxNzExNjQ3MzI5fQ==.911ea559a4ddfd9bd01e75827792df15355162f81e1ed2a6b25e84db36b744d2');
        echo json_encode($decoded);
    }
?>
<?php
	require('users.php');
	require('jwt.php');
	
	function handleLogin($email, $password) {
		$user = getUserData($email, $password);
		
		if ($user !== null) {
			
			$accessToken = generateJWT($user, 60 * 60);
			$refreshToken = generateJWT($user, 60 * 60 * 24 *30);
			
			return [
				'accessToken' => $accessToken,
				'refreshToken' => $refreshToken,
			];
			
		} else {
			return [
				'error' => 'Invalid email or password',
			];
		}
	}
	
	
	function test_signup() {
		$response = handleLogin('samantha@johnson.com', '4321');
		echo json_encode($response);
	}
	
	// test()
?>
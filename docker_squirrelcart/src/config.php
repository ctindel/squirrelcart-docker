<?php
/************************************************************************************************************************************

	Squirrelcart configuration file
	
	Installer of cart needs to change the variables below to their appropriate values.
	Values should go between single quotes, with a semicolon at the end of the line.

	Example:
	$var_name = 'your value goes here';

	Do not add trailing slashes at the end of path values.
	
	Configuration section starts below this header
	
************************************************************************************************************************************/
//
// This is the web address (URL) to the root of your store. This URL should take you to the location 
// that you uploaded your cart page to (store.php by default). 
//	
// Correct Examples:    
// http://www.example.com
// http://www.example.com/shop
// http://192.168.0.1:8080
//
// Incorrect Examples:
// http://www.example.com/
// http://www.example.com/store.php
// /home/www/myacct 
//
$site_www_root = 'http://localhost:8000';

//
// This is the web address (URL) to the root of your store using SSL (https://).
// This is for secure transactions. If your server does not support SSL, you may leave this blank. 
//
// Correct Examples:
// https://www.example.com
// https://www.example.com/shop
// https://192.168.0.1
//
// Incorrect Examples:
// https://www.example.com/
// https://www.example.com/store.php
// /home/www/myacct
//
#$site_secure_root = 'https://localhost:8000';
	
//
// This is the filename of your main storefront page. It defaults to /store.php when first installed. 
//
// Correct Examples:
// /store.php
// /index.php
//
// Incorrect Examples:
// /shop/store.php
// http://www.example.com/index.php
//
$cart_page = '/store.php';

//
// This is the path to the folder you keep your images in, relative to the folder containing your cart_page. This is the folder that you upload the products, categories, and other image folders into 
//
// Correct Examples:
// /sc_images
// /images/store
//
// Incorrect Examples:
// sc_images/
// http://www.example.com/sc_images
//
$img_path = '/sc_images';

//
// This is the name or IP address of the server that is running MySQL. localhost is the default 
//
// Correct Examples:
// localhost
// 192.168.0.1
// server03:6842
//
// Incorrect Examples:
// http://www.example.com 
//
$sql_host = 'mysql';

//
// This is the username and password for the MySQL user that you created and added to your squirrelcart database
//
$sql_username = 'squirrelcart';
$sql_password = 'squirrelcart';

//
// This should be set to the name of the database Squirrelcart is using 
//
$db = 'squirrelcart';

/************************************************************************************************************************************
	
	Advanced Configuration Section

	The variables in this section are optional, and do not have to be changed for most installations

************************************************************************************************************************************/
//
// This is used to specify your SMTP server host name, should you need to. Most installs work fine with thie field left blank.
// You should only set this if Squirrelcart generates an error when attempting to send email. 
//
// Correct Examples:
// smtp.example.com Incorrect Examples:
// http://www.example.com 
//
$smtp_host = 'email-smtp.us-east-1.amazonaws.com';

//
// This tells Squirrelcart where your sc_data folder is located. The path should be relative to what you specified for $site_isp_root.
// The default value for this field is squirrelcart/sc_data. We recommend you move this folder so it is not within your public web root. 
//
// Correct Examples:
// squirrelcart/sc_data
// ../sc_data
//
// Incorrect Examples:
// /squirrelcart/sc_data
// squirrelcart/sc_data/
// http://www.example.com/squirrelcart/sc_data
//
$sc_data_path = 'squirrelcart/sc_data';
	
//
// The $curl_opts and $curl_ssl_opts variables can be used to add extra CURL options when requesting pages using CURL. 
// If your web server requires specific curl options for curl to function, regardless of whether or not the URL being 
// requested is secure (https://www.example.com) or not (http://www.example.com), add the options to the $curl_opts variable,
// and they will be used regardless of the URL being requested. 
// If your web server requires special curl options only when accessing secure URLs (https://www.example.com), add the options
// to the $curl_ssl_opts variable.
//
// The syntax for specifying the extra curl options is the same regardless of what variable you use.
//
// Example:
//		Your webhost provides the following code to you to set additional curl options:
//			curl_setopt ($ch, CURLOPT_HTTPPROXYTUNNEL, TRUE);
//			curl_setopt ($ch, CURLOPT_PROXYTYPE, CURLPROXY_HTTP);
//			curl_setopt ($ch, CURLOPT_PROXY, 'http://192.168.1.130:3128');
//			curl_setopt ($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
//
// 		To use these options in Squirrelcart, you would specify the following for $curl_opts:
//			$curl_opts = array(
//				CURLOPT_HTTPPROXYTUNNEL	=> TRUE,
//				CURLOPT_PROXYTYPE 		=> CURLPROXY_HTTP,
//				CURLOPT_PROXY			=> 'http://192.168.1.130:3128',
//				CURLOPT_SSL_VERIFYPEER	=> FALSE
//			);
//
// 		If your webhost instructed that these options are only needed for requesting secure URLs, you would set 
//		$curl_ssl_opts instead of $curl_opts.
//





/************************************************************************************************************************************
	
	End of Configuration Section

	do not modify anything below this section!!!!!!
	
************************************************************************************************************************************/
?>

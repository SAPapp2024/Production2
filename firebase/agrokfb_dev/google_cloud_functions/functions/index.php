<?php
require_once 'vendor/autoload.php';

use GlobalPayments\Api\ServiceConfigs\ServicesConfig;
use GlobalPayments\Api\ServicesContainer;
use GlobalPayments\Api\Entities\Exceptions\ApiException;
use GlobalPayments\Api\PaymentMethods\CreditCardData;

$config = new ServicesConfig();
$config->merchantId = "8023829701";
$config->accountId = "623370";
$config->sharedSecret = "secret";
$config->serviceUrl = "https://api.sandbox.elavonpaymentgateway.com/remote";
ServicesContainer::configure($config);
// create the card object
$card = new CreditCardData();
$card->number = "4263970000005262";
$card->expMonth = 12;
$card->expYear = 2025;
$card->cvn = "131";
$card->cardHolderName = "James Mason";
try {
    // process an auto-capture authorization
    $response = $card->charge(19.99)
      ->withCurrency("EUR")
      ->execute();
    echo $response;  
} catch (ApiException $e) {
    // TODO: Add your error handling here
    echo $e->getMessage();
}


return;

// header('Content-Type: application/json');

// $requestMethod = $_SERVER["REQUEST_METHOD"];

// $response = [];

// if ($requestMethod == 'POST') {
//     $inputData = json_decode(file_get_contents('php://input'), true);

//     // Basic validation
//     if ($inputData && isset($inputData['paymentInfo']) && isset($inputData['userInfo'])) {
      
//       $config = new ServicesConfig();
//       $config->merchantId = "8023829701";
//       $config->accountId = "0017340008023829701453";
//       $config->sharedSecret = "secret";
//       $config->serviceUrl = "https://api.sandbox.elavonpaymentgateway.com/remote";
//       ServicesContainer::configure($config);
      
//       // create the card object
//       $card = new CreditCardData();
//       $card->number = "4263970000005262";
//       $card->expMonth = 12;
//       $card->expYear = 2025;
//       $card->cvn = "131";
//       $card->cardHolderName = "James Mason";
      
//       try {
//          // process an auto-capture authorization
//          $response = $card->charge(19.99)
//             ->withCurrency("EUR")
//             ->execute();
//       } catch (ApiException $e) {
//          // TODO: Add your error handling here
//       }
      
//       if (isset($response)) {
//          $result = $response->responseCode; // 00 == Success
//          $message = $response->responseMessage; // [ test system ] AUTHORISED
      
//          // get the details to save to the DB for future requests
//          $orderId = $response->orderId; // N6qsk4kYRZihmPrTXWYS6g
//          $authCode = $response->authorizationCode; // 12345
//          $paymentsReference = $response->transactionId; // pasref: 14610544313177922
//          $schemeReferenceData = $response->schemeId; // MMC0F00YE4000000715
//       }

//         if ($paymentStatus === true) {
//             $response = [
//                 'status' => 'success',
//                 'message' => 'Payment processed successfully.'
//             ];
//         } else {
//             $response = [
//                 'status' => 'error',
//                 'message' => 'Payment processing failed.'
//             ];
//         }

//     } else {
//         $response = [
//             'status' => 'error',
//             'message' => 'Invalid data format. Ensure you send both paymentInfo and userInfo.'
//         ];
//     }
// } else {
//     $response = [
//         'status' => 'error',
//         'message' => 'Unsupported request method. Only POST is allowed.'
//     ];
// }

// echo json_encode($response);
<?php

$args = getopt("", array("action:", "domain:", "token:", "ispconfig_user:", "ispconfig_pass:", "soap_location:", "soap_uri:"));

$action = $args["action"];
$fulldomain = $args["domain"];
$token = $args["token"];

$soap_location = $args["soap_location"];
$soap_uri = $args["soap_uri"];

$username = $args["ispconfig_user"];
$password = $args["ispconfig_pass"];

$client = new SoapClient(
    null,
    array(
        'location' => $soap_location,
        'uri' => $soap_uri,
        'trace' => 1,
        'exceptions' => 1,
        'stream_context' => stream_context_create(
            array(
                'ssl' =>
                array(
                    'verify_peer' => false,
                    'verify_peer_name' => false
                )
            )
        )
    )
);

try {

    if ($session_id = $client->login($username, $password)) {
        //echo 'Logged in successfully. Session ID:' . $session_id . '<br />';
    }

    // Get all zone
    $zones = $client->dns_zone_get($session_id, -1);

    $zone_id = 0;
    $client_id = 0;
    $server_id = 0;

    foreach ($zones as $zone) {
        // Find zone that needs to update
        if (preg_match("/" . $zone["origin"] . "/", $fulldomain . ".")) {
            $zone_id = $zone["id"];
            $sys_userid = $zone["sys_userid"];
            $server_id = $zone["server_id"];
        }
    }

    //Get client id			   
    $client_id = $client->client_get_id($session_id, $sys_userid);

    if ($client_id == 0) {
        exit;
    }

    // Get all domain records of type txt
    // Bug it retrieves all domain records
    $dns_records = $client->dns_txt_get($session_id, -1);

    $dns_record_id = 0;

    foreach ($dns_records as $dns_record) {
        if ($dns_record["zone"] == $zone_id && $dns_record["type"] == "TXT" && $dns_record["name"] == "_acme-challenge.{$fulldomain}.") {
            $dns_record_id = $dns_record["id"];
        }
    }

    // Add if zero else update

    $date = new DateTime();

    switch ($action) {

        case "add":
            if ($dns_record_id == 0) {

                $dns_record = array(
                    "server_id" => $server_id,
                    "zone" => $zone_id,
                    "name" => "_acme-challenge.{$fulldomain}.",
                    "type" =>  "txt",
                    "data" => $token,
                    "aux" => 111,
                    "ttl" => 300,
                    "active" => 'y',
                    "stamp" => date_format($date, 'Y-m-d H:i:s'),
                    "serial" => date_format($date, 'Ymds')
                );

                $result = $client->dns_txt_add($session_id, $client_id, $dns_record);

                echo "Created record for domain {$fulldomain} with token $token\n";
            } else {

                $dns_record["data"] = $token;
                $dns_record["stamp"] = date_format($date, 'Y-m-d H:i:s');
                $dns_record["serial"] = date_format($date, 'YmdH');

                $result = $client->dns_txt_update($session_id, $client_id, $dns_record_id, $dns_record);
                echo "Updated the record for domain {$fulldomain} with token $token\n";
            }

            break;

        case "del":

            if ($dns_record_id > 0) {

                $result = $client->dns_txt_delete($session_id, $dns_record_id);

                if ($result) {
                    echo "The record was deleted from domain {$fulldomain} successfully\n";
                } else {
                    echo "Failed to delete the record for domain {$fulldomain}\n";
                }
            } else {

                echo "The record was not found for deletion\n";
            }

            break;
        default:
            echo "No action was specified as parameter\n";
            break;
    }

    if ($client->logout($session_id)) {
        //echo 'Logged out.<br />';
    }
} catch (SoapFault $e) {
    echo $client->__getLastResponse();
    die('SOAP Error: ' . $e->getMessage());
}

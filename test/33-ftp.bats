#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
setup() {
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
}


@test "Use FTP to create challenge file" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    ${CODE_DIR}/test/restart-ftpd
    if [[ ! -d /var/www/html/.well-known/acme-challenge ]]; then
        mkdir -p /var/www/html/.well-known/acme-challenge
        chgrp -R www-data /var/www/html/.well-known
        chmod -R g+w /var/www/html/.well-known
    fi

    CONFIG_FILE="getssl-http01.cfg"
    setup_environment
    init_getssl

    cat <<- EOF > ${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl_test_specific.cfg
ACL="ftp:ftpuser:ftpuser:${GETSSL_CMD_HOST}:/var/www/html/.well-known/acme-challenge"
FTP_OPTIONS="chmod 644 \\\$fromfile"
EOF

    create_certificate
    assert_success
    check_output_for_errors
}

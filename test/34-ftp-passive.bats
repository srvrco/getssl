#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
setup() {
    [ ! -f $BATS_RUN_TMPDIR/failed.skip ] || skip "skipping tests after first failure"
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
    if [ -n "${VSFTPD_CONF}" ]; then
        cp $VSFTPD_CONF ${VSFTPD_CONF}.getssl

        # enable passive and disable active mode
        # https://www.pixelstech.net/article/1364817664-FTP-active-mode-and-passive-mode
        cat <<- _FTP >> $VSFTPD_CONF
pasv_enable=YES
pasv_max_port=10100
pasv_min_port=10090
connect_from_port_20=NO
_FTP

        ${CODE_DIR}/test/restart-ftpd start
    fi
}


teardown() {
    [ -n "$BATS_TEST_COMPLETED" ] || touch $BATS_RUN_TMPDIR/failed.skip
    if [ -n "${VSFTPD_CONF}" ]; then
        cp ${VSFTPD_CONF}.getssl $VSFTPD_CONF
        ${CODE_DIR}/test/restart-ftpd stop
    fi
}


@test "Use Passive FTP to create challenge file" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    if [[ ! -d /var/www/html/.well-known/acme-challenge ]]; then
        mkdir -p /var/www/html/.well-known/acme-challenge
    fi

    # Always change ownership and permissions in case previous tests created the directories as root
    chgrp -R www-data /var/www/html/.well-known
    chmod -R g+w /var/www/html/.well-known

    CONFIG_FILE="getssl-http01.cfg"
    setup_environment
    init_getssl

    cat <<- EOF > ${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl_test_specific.cfg
ACL="ftp:ftpuser:ftpuser:${GETSSL_CMD_HOST}:/var/www/html/.well-known/acme-challenge"
EOF
    if [[ "$FTP_PASSIVE_DEFAULT" == "false" ]]; then
        cat <<- EOF3 >> ${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl_test_specific.cfg
FTP_OPTIONS="passive"
EOF3
    fi

    create_certificate
    assert_success
    assert_line --partial "ftp:ftpuser:ftpuser:"
    if [[ "$FTP_PASSIVE_DEFAULT" == "false" ]]; then
        assert_line --partial "Passive mode on"
    else
        refute_line --partial "Passive mode off"
    fi
    check_output_for_errors
}

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


@test "Use Passive FTP to create challenge file (FTP_OPTIONS)" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    if [[ ! -d /var/www/html/.well-known/acme-challenge ]]; then
        mkdir -p /var/www/html/.well-known/acme-challenge
    fi

    NEW_FTP="false"
    if [[ "$(ftp -? 2>&1 | head -1 | cut -c-6)" == "usage:" ]]; then
        NEW_FTP="true"
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
        if [[ "$NEW_FTP" == "true" ]]; then
            # Newer version of ftp, needs "passive on" instead of "passive"
            cat <<- EOF3 >> ${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl_test_specific.cfg
FTP_OPTIONS="passive on"
EOF3
        else
            cat <<- EOF4 >> ${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl_test_specific.cfg
FTP_OPTIONS="passive"
EOF4
        fi
    fi

    create_certificate
    assert_success
    assert_line --partial "ftp:ftpuser:ftpuser:"
    if [[ "$FTP_PASSIVE_DEFAULT" == "false" ]]; then
        if [[ "$NEW_FTP" == "true" ]]; then
            assert_line --partial "Passive mode: on"
        else
            assert_line --partial "Passive mode on"
        fi
    else
        refute_line --partial "Passive mode off"
    fi
    check_output_for_errors
}


@test "Use Passive FTP to create challenge file (FTP_ARGS)" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    if [[ ! -d /var/www/html/.well-known/acme-challenge ]]; then
        mkdir -p /var/www/html/.well-known/acme-challenge
    fi

    NEW_FTP="false"
    if [[ "$(ftp -? 2>&1 | head -1 | cut -c-6)" == "usage:" ]]; then
        NEW_FTP="true"
    fi

    if [[ -n "$(command -v ftp 2>/dev/null)" ]]; then
        FTP_COMMAND="ftp"
    elif [[ -n "$(command -v lftp 2>/dev/null)" ]]; then
        FTP_COMMAND="lftp"
    else
        echo "host doesn't have ftp or lftp installed"
        exit 1
    fi


    # Always change ownership and permissions in case previous tests created the directories as root
    chgrp -R www-data /var/www/html/.well-known
    chmod -R g+w /var/www/html/.well-known

    CONFIG_FILE="getssl-http01.cfg"
    setup_environment
    init_getssl

    if [[ "$FTP_COMMAND" == "ftp" ]]; then
        cat <<- EOF > ${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl_test_specific.cfg
ACL="ftp:ftpuser:ftpuser:${GETSSL_CMD_HOST}:/var/www/html/.well-known/acme-challenge"
FTP_ARGS="-p -v"
EOF
    else
        cat <<- EOF3 > ${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl_test_specific.cfg
ACL="ftp:ftpuser:ftpuser:${GETSSL_CMD_HOST}:/var/www/html/.well-known/acme-challenge"
FTP_ARGS="-d -e 'set ftp:passive-mode true'"
EOF3
    fi

    create_certificate
    assert_success
    assert_line --partial "ftp:ftpuser:ftpuser:"

    if [[ "$NEW_FTP" == "true" ]]; then
        assert_line --partial "Entering Extended Passive Mode"
    else
        assert_line --partial "Entering Passive Mode"
    fi
    check_output_for_errors
}

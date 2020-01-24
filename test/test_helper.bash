INSTALL_DIR=/root
CODE_DIR=/getssl


setup_environment() {
    # One-off test setup
    if [[ -d ${INSTALL_DIR}/.getssl ]]; then
        rm -r ${INSTALL_DIR}/.getssl
    fi

    if [ ! -f ${INSTALL_DIR}/pebble.minica.pem ]; then
        wget --no-clobber https://raw.githubusercontent.com/letsencrypt/pebble/master/test/certs/pebble.minica.pem 2>&1 # | sed 's/^/# /' >&3
        # cat /etc/pki/tls/certs/ca-bundle.crt /root/pebble.minica.pem > /root/pebble-ca-bundle.crt  # RHEL6?
        cat /etc/ssl/certs/ca-certificates.crt ${INSTALL_DIR}/pebble.minica.pem > ${INSTALL_DIR}/pebble-ca-bundle.crt
    fi

    curl -X POST -d '{"host":"'"$GETSSL_HOST"'", "addresses":["'"$GETSSL_IP"'"]}' http://10.30.50.3:8055/add-a
    cp ${CODE_DIR}/test/test-config/nginx-ubuntu-no-ssl /etc/nginx/sites-enabled/default
    service nginx restart >&3-
}


cleanup_environment() {
    curl -X POST -d '{"host":"'"$GETSSL_HOST"'", "addresses":["'"$GETSSL_IP"'"]}' http://10.30.50.3:8055/del-a
}


init_getssl() {
    # Run initialisation (create account key, etc)
    run ${CODE_DIR}/getssl -c "$GETSSL_HOST"
    assert_success
    [ -d "$INSTALL_DIR/.getssl" ]
}


create_certificate() {
    # Create certificate
    cp "${CODE_DIR}/test/test-config/${CONFIG_FILE}" "${INSTALL_DIR}/.getssl/${GETSSL_HOST}/getssl.cfg"
    run ${CODE_DIR}/getssl "$GETSSL_HOST"
    #!FIXME test certificate has been placed in the expected location
}


    
    LATEST_OCICLI=$(curl -L https://api.github.com/repos/oracle/oci-cli/releases | \
            jq -r 'sort_by(.name) | reverse | .[0].name') ;
    echo "LATEST_OCICLI=${LATEST_OCICLI}" ;
    bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)" \
            -s \
            --accept-all-defaults \
            --oci-cli-version ${LATEST_OCICLI}

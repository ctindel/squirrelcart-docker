#!/bin/bash -e

mkdir -p /home/centos/utils

# We do this in two sections because we want the first part to expxand 
#  the AWS variables
cat << EOF > /home/centos/utils/utils.sh
export verbose=false

export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION
export SC_ENV=$SC_ENV
export SC_SMTP_USERNAME=$SC_SMTP_USERNAME
export SC_SMTP_PASSWORD=$SC_SMTP_PASSWORD
export SC_AWS_REGION=$SC_AWS_REGION
export SC_AWS_S3_BUCKET=$SC_AWS_S3_BUCKET
EOF

cat - >> /home/centos/utils/utils.sh << 'EOF'
RETRY_COUNT=5

function debug_print() {
    if [ "$verbose" = true ] ; then
        echo $1
    fi
}

function check_run_cmd() {
    cmd=$1
    local error_str="ERROR: Failed to run \"$cmd\""
    if [[ $# -gt 1 ]]; then
        error_str=$2
    fi
    debug_print "About to run: $cmd"
    eval $cmd
    rc=$?; if [[ $rc != 0 ]]; then echo "$error_str"; cleanup; exit $rc; fi
}

function run_cmd() {
    cmd=$1
    debug_print "About to run: $cmd"
    eval "$cmd"
    rc=$?
    return $rc
}

function retry_run_cmd() {
    cmd=$1
    rc=0

    n=0
    until [ $n -ge $RETRY_COUNT ]
    do
        debug_print "Invocation $n of $cmd"
        eval "$cmd"
        rc=$?
        if [[ $rc == 0 ]]; then break; fi
        n=$[$n+1]
        sleep 1
    done
    if [[ $rc != 0 ]]; then cleanup_and_fail; fi
    return $rc
}

function cleanup_and_fail() {
    echo "ERROR: FAILED"
    exit 1
}
EOF

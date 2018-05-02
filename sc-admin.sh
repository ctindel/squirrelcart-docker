#!/bin/bash

export SC_AWS_REGION="us-east-2"
export TMP_DIR="/tmp/sc"
export SC_DOCKER_REGISTRY="ctindel"

SC_DOCKER_BUILD_CONTAINERS=(
"sc-mysql-build"
"sc-app-build"
)
SC_DOCKER_BUILD_IMAGES=(
"sc-mysql-build:$SC_ENV"
"sc-app-build:$SC_ENV"
)
SC_DOCKER_IMAGES=(
"$SC_DOCKER_REGISTRY/sc-mysql:$SC_ENV"
"$SC_DOCKER_REGISTRY/sc-app:$SC_ENV"
)

USAGE="SC Admin Usage: $0 [-v]
           build
           push
           local-deploy
           validate-environment"

declare -a SC_ADMIN_CMDS=(
    "build"
    "push"
    "local-deploy"
)

# These variables must be set external to this script for
#  for commands that are used by SA Demo Admins (in addition to the
#  variables required for normal users
declare -a SC_ADMIN_REQUIRED_EXT_ENV_VARS=(
    "SC_DIR"
    "SC_ENV"
    "AWS_DEFAULT_REGION"
    "AWS_ACCESS_KEY_ID"
    "AWS_SECRET_ACCESS_KEY"
)

function cleanup() {
    echo "Invoking cleanup, please wait..."
}

function ctrl_c_handler() {
    cleanup
    exit 1
}

function debug_print() {
    if [ "$verbose" = true ] ; then
        echo $1
    fi
}

function debug_print_ne() {
    if [ "$verbose" = true ] ; then
        echo -ne $1
    fi
}

function err_exit_usage() {
    echo $1
    exit 1
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

run_cmd() {
    cmd=$1
    debug_print "About to run: $cmd"
    eval "$cmd"
    rc=$?
    return $rc
}

retry_run_cmd() {
    cmd=$1
    rc=0

    n=0
    until [ $n -ge $RETRY_COUNT ]
    do
        if [ "$verbose" = true ] ; then
            echo "Invocation $n of $cmd"
        fi
        eval "$cmd"
        rc=$?
        if [[ $rc == 0 ]]; then break; fi
        n=$[$n+1]
        sleep 1
    done
    if [[ $rc != 0 ]]; then cleanup_and_fail; fi
    return $rc
}

# http://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
function trim() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"
    echo -n "$var"
}

# traditional system call return values-- used in an `if`, this will be true
# when returning 0. Very Odd.
function arrayContainsElement () {
    # odd syntax here for passing array parameters:
    # http://stackoverflow.com/questions/8082947/how-to-pass-an-array-to-a-bash-function
    local list=$1[@]
    local elem=$2

    # echo "list" ${!list}
    # echo "elem" $elem

    for i in "${!list}"
    do
        # echo "Checking to see if" "$i" "is the same as" "${elem}"
        if [ "$i" == "${elem}" ] ; then
            # echo "$i" "was the same as" "${elem}"
            return 0
        fi
    done

    # echo "Could not find element"
    return 1
}

docker_cleanup() {
    docker system prune
    # https://stackoverflow.com/questions/32723111/how-to-remove-old-and-unused-docker-images
    # https://gist.github.com/bastman/5b57ddb3c11942094f8d0a97d461b430
    #docker rm -v $(docker ps --filter status=exited -q 2>/dev/null) 2>/dev/null
    #docker rmi $(docker images --filter dangling=true -q 2>/dev/null) 2>/dev/null
    #docker volume rm $(docker volume ls -qf dangling=true) 2>/dev/null
}

# Let's make sure the AWS credentials exist and work
function validate_aws_credentials() {
    check_run_cmd "aws s3 ls --region $SC_AWS_REGION > /dev/null 2>&1" "ERROR: You need to install the awscli, more information here: http://docs.aws.amazon.com/cli/latest/userguide/installing.html"
}

function validate_docker() {
    check_run_cmd "docker images > /dev/null" "ERROR: You need to install docker"
}

function validate_required_tools() {
    validate_aws_credentials
    validate_docker
    check_run_cmd "mkdir -p $TMP_DIR"
}

# http://stackoverflow.com/questions/9714902/how-to-use-a-variables-value-as-other-variables-name-in-bash
function validate_admin_required_external_environment() {
    for var in "${SC_ADMIN_REQUIRED_EXT_ENV_VARS[@]}"
    do
        # http://stackoverflow.com/questions/307503/whats-a-concise-way-to-check-that-environment-variables-are-set-in-unix-shellsc
        # combined with this for the !var notation:
        # http://stackoverflow.com/a/11065196/4672086
        : ${!var?\"$var is a required external environment variable for admins, set these in your bash .profile\"}
        trimmed_var=$(trim ${!var})
        eval $var=\$trimmed_var
    done

    validate_aws_credentials
}

function build() {
    debug_print "BEGIN build"

    docker_cleanup

    trap "docker-compose -f docker-compose-build.yml rm -v --force" SIGINT SIGTERM
    check_run_cmd "docker-compose -f docker-compose-build.yml build --force-rm --pull --no-cache sc-mysql-build"
    check_run_cmd "docker-compose -f docker-compose-build.yml build --force-rm --pull --no-cache sc-app-build"
    check_run_cmd "docker-compose -f docker-compose-build.yml up -d --remove-orphans sc-app-build"
    check_run_cmd "docker commit sc-mysql-build $SC_DOCKER_REGISTRY/sc-mysql:$SC_ENV"
    check_run_cmd "docker commit sc-app-build $SC_DOCKER_REGISTRY/sc-app:$SC_ENV"
    check_run_cmd "docker-compose -f docker-compose-build.yml down"

    debug_print "END build"
}

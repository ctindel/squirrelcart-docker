#!/bin/bash

export SC_AWS_REGION="us-east-2"
export SC_AWS_S3_BUCKET="ctindel-squirrel"
export SC_AWS_SES_SMTP_ENDPOINT="email-smtp.us-east-1.amazonaws.com"
export TMP_DIR="/tmp/sc"
export SC_DOCKER_REGISTRY="ctindel"
SC_VER="squirrelcart-pro-v3.0.1"
SC_TARBALL="$SC_VER.tar.gz"

SC_DOCKER_BUILD_CONTAINERS=(
"sc-smtp-build"
"sc-mysql-build"
"sc-app-build"
)
SC_DOCKER_BUILD_IMAGES=(
"sc-smtp-build:$SC_ENV"
"sc-mysql-build:$SC_ENV"
"sc-app-build:$SC_ENV"
)
SC_DOCKER_IMAGES=(
"$SC_DOCKER_REGISTRY/sc-smtp:$SC_ENV"
"$SC_DOCKER_REGISTRY/sc-mysql:$SC_ENV"
"$SC_DOCKER_REGISTRY/sc-app:$SC_ENV"
)

USAGE="SC Admin Usage: $0 [-v]
           build-ami
           build-docker
           push-docker
           local-deploy
           validate-environment"

declare -a SC_ADMIN_CMDS=(
    "build-ami"
    "build-docker"
    "push-docker"
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
    check_run_cmd "docker-compose -f docker-compose-build.yml down"
    check_run_cmd "docker-compose -f docker-compose-build.yml rm -f"
    check_run_cmd "docker system prune -f"
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

function build_ami() {
    debug_print "BEGIN build_ami"

    check_run_cmd "cd packer/aws; packer build squirrelcart-docker.json; cd $SC_DIR"

    debug_print "END build_docker"
}

function build_docker() {
    debug_print "BEGIN build_docker"

    docker_cleanup

    latest_backup=$(aws s3 ls s3://$SC_AWS_S3_BUCKET/backup/ | grep PRE | awk '{print $2}' | sort | sed -e 's#/##g')

    check_run_cmd "sudo rm -rf $TMP_DIR/mysql_build_data && mkdir -p $TMP_DIR/mysql_build_data"
    check_run_cmd "docker-compose -f docker-compose-build.yml build --force-rm --pull --no-cache sc-smtp-build"
    check_run_cmd "docker-compose -f docker-compose-build.yml build --force-rm --pull --no-cache sc-mysql-build"
    check_run_cmd "docker-compose -f docker-compose-build.yml build --force-rm --pull --no-cache sc-app-build"
    check_run_cmd "docker-compose -f docker-compose-build.yml up -d sc-app-build"
    check_run_cmd "aws s3 cp s3://$SC_AWS_S3_BUCKET/backup/$latest_backup/$latest_backup-squirrelcart-hh.tar.gz $TMP_DIR/squirrelcart-hh.tar.gz"
    check_run_cmd "aws s3 cp s3://$SC_AWS_S3_BUCKET/backup/$latest_backup/$latest_backup-squirrelcart-hh.sql.gz $TMP_DIR/squirrelcart-hh.sql.gz"
    check_run_cmd "docker cp $TMP_DIR/squirrelcart-hh.sql.gz sc-app-build:$TMP_DIR"
    check_run_cmd "docker cp $TMP_DIR/squirrelcart-hh.tar.gz sc-app-build:$TMP_DIR"
    check_run_cmd "docker exec sc-app-build bash $TMP_DIR/src/install.sh"
    check_run_cmd "docker commit sc-smtp-build $SC_DOCKER_REGISTRY/sc-smtp:$SC_ENV"
    check_run_cmd "docker commit sc-mysql-build $SC_DOCKER_REGISTRY/sc-mysql:$SC_ENV"
    check_run_cmd "docker commit sc-app-build $SC_DOCKER_REGISTRY/sc-app:$SC_ENV"
    check_run_cmd "docker-compose -f docker-compose-build.yml down"
    check_run_cmd "sudo rm -rf $TMP_DIR/mysql_build_data"

    debug_print "END build_docker"
}

function push_docker() {
    debug_print "BEGIN push_docker"

    for image in "${SC_DOCKER_IMAGES[@]}"; do
        # Strip out the registry name
        image_name=$(echo $image | sed -e 's@.*/@@')
        echo "image_name = $image_name"
        # sc-app:dev
        tar_name=$(echo $image_name | tr ':' '-')
        tar_name+=".tar"
        # File name will have the environment name in it already
        # sc-app-dev.tar
        echo "tar_name = $tar_name"
        check_run_cmd "docker save $image -o $TMP_DIR/$tar_name"
        check_run_cmd "aws s3 cp --region $SC_AWS_REGION $TMP_DIR/$tar_name s3://$SC_AWS_S3_BUCKET/docker/"
    done

    debug_print "END push_docker"
}

function local_deploy() {
    debug_print "BEGIN local_deploy"

    local needs_download=false

    for image in "${SC_DOCKER_IMAGES[@]}"; do
        if [[ "$(docker images -q $image 2> /dev/null)" == "" ]]; then
            echo "Image $image is not present locally, will re-download images"
            needs_download=true
        fi
    done

    if [[ "$needs_download" == "true" ]]; then
        echo "Downloading docker images"

        check_run_cmd "mkdir -p $TMP_DIR"
        check_run_cmd "sudo rm -rf $TMP_DIR/mysql_data && mkdir -p $TMP_DIR/mysql_data"

        check_run_cmd "aws s3 cp --region $SC_AWS_REGION \"s3://$SC_AWS_S3_BUCKET/docker/sc-mysql-$SC_ENV.tar\" $TMP_DIR"
        check_run_cmd "aws s3 cp --region $SC_AWS_REGION \"s3://$SC_AWS_S3_BUCKET/docker/sc-app-$SC_ENV.tar\" $TMP_DIR"
        check_run_cmd "aws s3 cp --region $SC_AWS_REGION \"s3://$SC_AWS_S3_BUCKET/docker/sc-smtp-$SC_ENV.tar\" $TMP_DIR"

        check_run_cmd "docker load -i $TMP_DIR/sc-mysql-$SC_ENV.tar"
        check_run_cmd "docker load -i $TMP_DIR/sc-app-$SC_ENV.tar"
        check_run_cmd "docker load -i $TMP_DIR/sc-smtp-$SC_ENV.tar"
    fi

    check_run_cmd "docker-compose -f docker-compose-local.yml up -d"

    latest_backup=$(aws s3 ls s3://$SC_AWS_S3_BUCKET/backup/ | grep PRE | awk '{print $2}' | sort | sed -e 's#/##g')
    check_run_cmd "aws s3 cp s3://$SC_AWS_S3_BUCKET/backup/$latest_backup/$latest_backup-squirrelcart-hh.tar.gz $TMP_DIR/squirrelcart-hh.tar.gz"
    check_run_cmd "aws s3 cp s3://$SC_AWS_S3_BUCKET/backup/$latest_backup/$latest_backup-squirrelcart-hh.sql.gz $TMP_DIR/squirrelcart-hh.sql.gz"
    check_run_cmd "docker cp $TMP_DIR/squirrelcart-hh.sql.gz sc-app:$TMP_DIR"
    check_run_cmd "docker cp $TMP_DIR/squirrelcart-hh.tar.gz sc-app:$TMP_DIR"
    check_run_cmd "docker exec sc-app bash $TMP_DIR/src/install.sh"

    echo "When app is ready connect to http://localhost:8080 or for phpmyadmin http://localhost:8000"

    debug_print "END local_deploy"
}

function execute_admin_cmd() {
    check_run_cmd "mkdir -p $TMP_DIR"

    case $admin_cmd in
        "build-ami")
            build_ami
            ;;
        "build-docker")
            build_docker
            ;;
        "push-docker")
            push_docker
            ;;
        "local-deploy")
            local_deploy
            ;;
    esac
}

if [ "$#" == "0" ]; then
    echo "$USAGE"
    exit 1
fi

if [[ "$1" == "-v" ]]; then
    verbose=true
    shift
fi

admin_cmd=$1
shift

if ! arrayContainsElement SC_ADMIN_CMDS "$admin_cmd"; then
    err_exit_usage "Invalid admin command specific: $admin_cmd"
fi

while (( "$#" )); do
    if [[ "$1" == "--env" ]]; then
        export SC_ENV=$2
        if [[ $SC_ENV != "dev" && $SC_ENV != "staging" && $SC_ENV != "prod" ]]; then
            err_exit_usage "--env must be one of <dev | staging | prod>"
        fi
    fi

    if [[ "$1" == "-v" ]]; then
        verbose=true
        shift
        continue
    fi

    shift
    shift
done

trap ctrl_c_handler INT
validate_admin_required_external_environment
execute_admin_cmd

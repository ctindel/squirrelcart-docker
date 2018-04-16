#!/bin/bash

BUCKET_NAME="ctindel-centos-atomic-host-7"

check_run_cmd() {
    cmd=$1
    if [ "$verbose" = true ] ; then
        echo "About to run: $cmd"
    fi
    eval "$cmd"
    rc=$?; if [[ $rc != 0 ]]; then cleanup_and_fail; exit $rc; fi
}

run_cmd() {
    cmd=$1
    if [ "$verbose" = true ] ; then
        echo "About to run: $cmd"
    fi
    eval "$cmd"
    rc=$?
    return $rc
}

cleanup_and_fail() {
    echo "ERROR: FAILED"
    exit 1
}

sudo apt-get install -y qemu-img 

tmp_dir=/tmp/centos-atomic-host-7
mkdir -p $tmp_dir
check_run_cmd "curl https://ci.centos.org/artifacts/sig-atomic/centos-continuous/images-alpha/cloud/latest/images/centos-atomic-host-7.qcow2.gz -o $tmp_dir/centos-atomic-host-7.qcow2.gz"
check_run_cmd "gunzip -c $tmp_dir/centos-atomic-host-7.qcow2.gz > $tmp_dir/centos-atomic-host-7.qcow2"
check_run_cmd "qemu-img convert -p -S 4096 -f qcow2 -O raw $tmp_dir/centos-atomic-host-7.qcow2 $tmp_dir/disk.raw"
check_run_cmd "tar -C $tmp_dir -Szcvf $tmp_dir/centos-atomic-host-7.tar.gz disk.raw"
check_run_cmd "gsutil mb gs://${BUCKET_NAME}"
check_run_cmd "gsutil -o GSUtil:parallel_composite_upload_threshold=150M cp $tmp_dir/centos-atomic-host-7.tar.gz gs://${BUCKET_NAME}"
check_run_cmd "gcloud compute images create centos-atomic-host-7 --source-uri gs://${BUCKET_NAME}/centos-atomic-host-7.tar.gz"
check_run_cmd "gsutil -m rm -r gs://${BUCKET_NAME}"
check_run_cmd "gcloud compute instances create 'centosah' --machine-type 'g1-small' --image 'centos-atomic-host-7' --boot-disk-size '20' --boot-disk-type 'pd-ssd' --zone 'us-east1-c'"


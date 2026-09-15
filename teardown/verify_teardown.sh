#!/usr/bin/env bash
# Confirms nothing this lab created is still running/billable after
# ./destroy.sh, by asking AWS directly rather than trusting Terraform's
# exit code alone. Requires the AWS CLI to already be configured.
#
# Usage: ./verify_teardown.sh [project-name-prefix]
# Defaults to "cloud-misconfig-lab", matching variables.tf's project_name default.

set -euo pipefail

PREFIX="${1:-cloud-misconfig-lab}"
FOUND_SOMETHING=0

echo "== Checking for leftover resources tagged/named with prefix: $PREFIX =="

echo ""
echo "-- S3 buckets --"
BUCKETS=$(aws s3api list-buckets --query "Buckets[?starts_with(Name, '${PREFIX}')].Name" --output text)
if [ -n "$BUCKETS" ]; then
  echo "FOUND: $BUCKETS"
  FOUND_SOMETHING=1
else
  echo "none found"
fi

echo ""
echo "-- EC2 security groups --"
SGS=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=${PREFIX}*" --query "SecurityGroups[].GroupId" --output text)
if [ -n "$SGS" ]; then
  echo "FOUND: $SGS"
  FOUND_SOMETHING=1
else
  echo "none found"
fi

echo ""
echo "-- VPCs --"
VPCS=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=${PREFIX}*" --query "Vpcs[].VpcId" --output text)
if [ -n "$VPCS" ]; then
  echo "FOUND: $VPCS"
  FOUND_SOMETHING=1
else
  echo "none found"
fi

echo ""
echo "-- EBS volumes --"
VOLS=$(aws ec2 describe-volumes --filters "Name=tag:Name,Values=${PREFIX}*" --query "Volumes[].VolumeId" --output text)
if [ -n "$VOLS" ]; then
  echo "FOUND: $VOLS"
  FOUND_SOMETHING=1
else
  echo "none found"
fi

echo ""
echo "-- EBS snapshots --"
SNAPS=$(aws ec2 describe-snapshots --owner-ids self --filters "Name=tag:Name,Values=${PREFIX}*" --query "Snapshots[].SnapshotId" --output text)
if [ -n "$SNAPS" ]; then
  echo "FOUND: $SNAPS"
  FOUND_SOMETHING=1
else
  echo "none found"
fi

echo ""
echo "-- IAM roles --"
ROLES=$(aws iam list-roles --query "Roles[?starts_with(RoleName, '${PREFIX}')].RoleName" --output text)
if [ -n "$ROLES" ]; then
  echo "FOUND: $ROLES"
  FOUND_SOMETHING=1
else
  echo "none found"
fi

echo ""
if [ "$FOUND_SOMETHING" -eq 1 ]; then
  echo "Some resources are still present. Run 'terraform destroy' again from ../terraform,"
  echo "or delete the listed resources manually in the AWS console."
  exit 1
else
  echo "Clean. Nothing from this lab appears to still be running."
fi

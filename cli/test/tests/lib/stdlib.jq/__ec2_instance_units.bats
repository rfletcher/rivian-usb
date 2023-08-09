#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/jq_helpers

@test "jq stdlib: __ec2_instance_units: no arguments" {
  run_jq __ec2_instance_units

  assert_failure
}

@test "jq stdlib: __ec2_instance_units: typical arguments" {
  run_jq_stdin '"t3.nano"' __ec2_instance_units
  assert_success_json 0.25

  run_jq_stdin '"c5.8xlarge"' __ec2_instance_units
  assert_success_json 64

  run_jq_stdin '"r5.32xlarge"' __ec2_instance_units
  assert_success_json 256
}

@test "jq stdlib: __ec2_instance_units: unknown type" {
  run_jq_stdin '"t3.4xmassive"' __ec2_instance_units
  assert_success_json 0
}

#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/jq_helpers

@test "jq stdlib: __fromdateiso8601: 'Z' timezone format" {
  # standard time
  run_jq_stdin "\"2020-01-01T01:23:01Z\"" __fromdateiso8601
  assert_success_json 1577841781

  # saving time
  run_jq_stdin "\"2020-04-01T13:23:45Z\"" __fromdateiso8601
  assert_success_json 1585747425
}

@test "jq stdlib: __fromdateiso8601: with microseconds" {
  run_jq_stdin "\"2020-03-30T18:47:09.000Z\"" __fromdateiso8601

  assert_success_json 1585594029
}

@test "jq stdlib: __fromdateiso8601: '+00:00' timezone" {
  run_jq_stdin "\"2020-03-30T18:47:09+00:00\"" __fromdateiso8601

  assert_success_json 1585594029
}

@test "jq stdlib: __fromdateiso8601: '+0000' timezone" {
  run_jq_stdin "\"2020-03-30T18:47:09+0000\"" __fromdateiso8601

  assert_success_json 1585594029
}

@test "jq stdlib: __fromdateiso8601: '+00:00' with microseconds" {
  run_jq_stdin "\"2020-03-30T18:47:09.000+00:00\"" __fromdateiso8601

  assert_success_json 1585594029
}

@test "jq stdlib: __fromdateiso8601: non UTC timezone offset" {
  run_jq_stdin "\"2020-03-30T19:47:09+0100\"" __fromdateiso8601
  assert_success_json 1585594029

  run_jq_stdin "\"2020-03-30T19:47:09-0400\"" __fromdateiso8601
  assert_success_json 1585612029
}

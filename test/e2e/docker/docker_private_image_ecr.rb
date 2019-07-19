#!/bin/ruby
# rubocop:disable all

require_relative '../../e2e'

start_job <<-JSON
  {
    "id": "#{$JOB_ID}",

    "executor": "dockercompose",

    "compose": {
      "containers": [
        {
          "name": "main",
          "image": "501965974906.dkr.ecr.us-east-1.amazonaws.com/ecr-playground:latest"
        }
      ],

      "image_pull_credentials": [
        {
          "env_vars": [
            { "name": "DOCKER_CREDENTIAL_TYPE", "value": "#{Base64.encode64("AWS_ECR")}" },
            { "name": "AWS_REGION", "value": "#{Base64.encode64(ENV['AWS_REGION'])}" },
            { "name": "AWS_ACCESS_KEY_ID", "value": "#{Base64.encode64(ENV['AWS_ACCESS_KEY_ID'])}" },
            { "name": "AWS_SECRET_ACCESS_KEY", "value": "#{Base64.encode64(ENV['AWS_SECRET_ACCESS_KEY'])}" }
          ]
        }
      ]
    },

    "env_vars": [],

    "files": [],

    "commands": [
      { "directive": "echo Hello World" }
    ],

    "epilogue_always_commands": [],

    "callbacks": {
      "finished": "https://httpbin.org/status/200",
      "teardown_finished": "https://httpbin.org/status/200"
    }
  }
JSON

wait_for_job_to_finish

assert_job_log <<-LOG
  {"event":"job_started",  "timestamp":"*"}

  {"event":"cmd_started",  "timestamp":"*", "directive":"Setting up image pull credentials"}
  {"event":"cmd_output",   "timestamp":"*", "output":"Setting up credentials for ECR\\n"}
  {"event":"cmd_output",   "timestamp":"*", "output":"$(aws ecr get-login --no-include-email --region $AWS_REGION)\\n"}
  {"event":"cmd_output",   "timestamp":"*", "output":"WARNING! Using --password via the CLI is insecure. Use --password-stdin.\\n"}
  {"event":"cmd_output",   "timestamp":"*", "output":"WARNING! Your password will be stored unencrypted in /root/.docker/config.json.\\n"}
  {"event":"cmd_output",   "timestamp":"*", "output":"Configure a credential helper to remove this warning. See\\n"}
  {"event":"cmd_output",   "timestamp":"*", "output":"https://docs.docker.com/engine/reference/commandline/login/#credentials-store\\n"}
  {"event":"cmd_output",   "timestamp":"*", "output":"\\n"}
  {"event":"cmd_output",   "timestamp":"*", "output":"Login Succeeded\\n"}
  {"event":"cmd_output",   "timestamp":"*", "output":"\\n"}
  {"event":"cmd_finished", "timestamp":"*", "directive":"Setting up image pull credentials", "exit_code":0,"finished_at":"*","started_at":"*","timestamp":"*"}
  {"event":"cmd_started",  "timestamp":"*", "directive":"Pulling docker images..."}
  *** LONG_OUTPUT ***
  {"event":"cmd_finished", "timestamp":"*", "directive":"Pulling docker images...", "exit_code":0,"finished_at":"*","started_at":"*","timestamp":"*"}

  {"event":"cmd_started",  "timestamp":"*", "directive":"Exporting environment variables"}
  {"event":"cmd_finished", "timestamp":"*", "directive":"Exporting environment variables","exit_code":0,"finished_at":"*","started_at":"*"}
  {"event":"cmd_started",  "timestamp":"*", "directive":"Injecting Files"}
  {"event":"cmd_finished", "timestamp":"*", "directive":"Injecting Files","exit_code":0,"finished_at":"*","started_at":"*"}
  {"event":"cmd_started",  "timestamp":"*", "directive":"echo Hello World"}
  {"event":"cmd_output",   "timestamp":"*", "output":"Hello World\\n"}
  {"event":"cmd_finished", "timestamp":"*", "directive":"echo Hello World","exit_code":0,"finished_at":"*","started_at":"*"}
  {"event":"cmd_started",  "timestamp":"*", "directive":"export SEMAPHORE_JOB_RESULT=passed"}
  {"event":"cmd_finished", "timestamp":"*", "directive":"export SEMAPHORE_JOB_RESULT=passed","exit_code":0,"finished_at":"*","started_at":"*"}
  {"event":"job_finished", "timestamp":"*", "result":"passed"}
LOG
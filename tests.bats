#!/usr/bin/env bats

@test "http request redirects to https (domain + www.domain)" {
  run curl -s -o /dev/null -w "%{http_code}" http://one.example.com
  [[ $output = "301" ]]

  run curl -s -o /dev/null -w "%{redirect_url}" http://one.example.com
  [[ $output = "https://one.example.com/" ]]

  run curl -s -o /dev/null -w "%{http_code}" http://www.one.example.com
  [[ $output = "301" ]]

  run curl -s -o /dev/null -w "%{redirect_url}" http://www.one.example.com
  [[ $output = "https://www.one.example.com/" ]]
}

@test "https works with www. and without www." {
  run curl -L -s -k -o /dev/null -w "%{http_code}" https://one.example.com
  [[ $output = "200" ]]

  run curl -L -s -k -o /dev/null -w "%{http_code}" https://www.one.example.com
  [[ $output = "200" ]]
}
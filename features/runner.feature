Feature: Runner
  Scenario: Don't specify a reporter
    Given I am going to call a JHW runner with the following reporters:
      | name | file |
      | Console | |
      | File | notify-file |
      And I am going to get a notification file
    When I don't specify a reporter
      And I run the runner
    Then I should get the reporters

  Scenario: Specify another console reporter
    Given I am going to call a JHW runner with the following reporters:
      | name | file |
      | Verbose | |
      | File | notify-file |
      And I am going to get a notification file
    When I specify the reporter "Verbose"
      And I run the runner
    Then I should get the reporters
      And the reporter string should not have changed

  Scenario: Specify two reporters
    Given I am going to call a JHW runner with the following reporters:
      | name | file |
      | Verbose | |
      | Tap | tap-file |
      | File | notify-file |
      And I am going to get a notification file
    When I specify the reporter "Verbose Tap:tap-file"
      And I run the runner
    Then I should get the reporters


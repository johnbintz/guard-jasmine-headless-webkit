Feature: Runner
  Scenario: Don't specify a reporter
    Given I am going to call a JHW runner
      And I am going to get a notification file
    When I don't specify a reporter
      And I run the runner
      Then I should get the following reporters:
        | name | file |
        | Console | |
        | File | notify-file |


Feature: Flexmail
  As a Wagneer
  I want to be able to set up email configs
  So that we can create emailing forms
  
  Background:
    Given I log in as Joe User
    And I create Cardtype card "Testimony"    
    And I create Pointer card "Testimony+*type+*send" with content "[[Testemailconfig]]"
    And I create card "Testimony+*tform" with content
      """
      {{+name}} {{+email}} {{+Testimony}} {{+recipients}}
      """
    And I create Search card "search test+*rform" with content "{"type":"User"}"
    And I harden "search test+*rform"
    And I create email card "Testemailconfig"
      And I create Search card "Testemailconfig+*to" with content
        """
        {"referred_to_by":{"left":"_self","right":"recipients"}}
        """
      And I create Search card "Testemailconfig+*from" with content "{"left":"_self","right":"email"}"
      And I create Phrase card "Testemailconfig+*subject" with content "Subjectimus"
      And I create Phrase card "Testemailconfig+*bcc"
      And I create Basic card "Testemailconfig+*message" with content 
        """
        Pleistocles, {{_self+name|naked}} says: {{_self+Testimony|naked}} {{_self+search test|naked;item:name}}
        buena,
        Thaddeus
        """

    And I create Phrase card "A+email" with content "argumus@test.com"
    And I create Phrase card "B+email" with content "tacitus@test.com"
    # FIXME: apparently cucumber or webrat or something can't handle saving
    # multiple line entries. Everything I've tried so far has resulted in 
    # truncation after the first line.  which fucking bites.
    # so for now I will eunicize our tests and only check for one email delivery.
    And I create Pointer card "List1" with content 
      """
      [[A+email]]
      [[B+email]]
      """
    
  Scenario: Submitting a new Testimony
    When I create Testimony card "MoanE" with plusses:
      |name|email|Testimony|recipients|
      |Lee|lee@user.net|This is outrageous|[[List1]]|
    And "argumus@test.com" should receive 1 email
    When "argumus@test.com" opens the email with subject "Subjectimus"
    And it should be from "lee@user.net"
    Then He should see "Pleistocles" in the email
    And He should see "Lee" in the email
    And He should see "This is outrageous" in the email
    
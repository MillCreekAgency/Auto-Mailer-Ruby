# Insurance-Auto-Mailer

I Currently work at an insurance agency and part of my job is sending out renewals for Ocean Harbor Casualty. This consists of two parts, updating the policy on our online system (QQ Catalyst) and sending out a renewal email to let the insured know that their policy has been renewed

Im lazy and want to have the computer send the mail for me so I created a ruby script which takes in an Ocean Harbor pdf and spits out the information and formats an email to be sent

Currently the script can extract the insured's
- Name
- Address
- Policy Number
- Coverages
  - (Building, Other Structure, Personal Property, Loss of Use, Personal Liability, Medical Payments)
- Premium
- Deductible
- Hurricane Deductible
- Mortgagee
- Effective / Expire date

To use the script type in
```bash
ruby Insurance-Mailer.rb
```
Then when it asks for file name type your path to file
```bash
Enter filename:
/path/to/file
```
Then it will ask for an email address to send ('n' if no email available)
if an address is added it will then ask for your password as a way to confirm
after the email was sent (or in some cases skipped) it will print the rest of the information so that you can easily update the policy online

*In progress*
- Web driver

*To be added*
- If location of insured house is different from mailing address
- GUI?
- Dwelling coverage for OceanHarbor
- support for other policies
  - Narraganset Bay
  - Kensington
  - Kingston

# Safety and testing

This toolkit contains both read-only reporting scripts and one account-changing operation.

- Run the reporting scripts with a least-privilege account that has only the directory read permissions it needs.
- Review report contents before sharing. User, group, computer, and password-policy reports can reveal personal and organizational information.
- Store exports in access-controlled locations and apply your organization's retention policy.
- The account unlock script changes directory state. Preview it with `-WhatIf`, verify the target identity, and run it only with delegated permissions and an approved operational process.
- Test changes in a disposable/non-production domain before production use.
- Pester tests use mocks and parser checks. They do not validate connectivity, permissions, domain behavior, or replication in a real AD environment.

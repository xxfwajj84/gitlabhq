---
type: reference, howto
---

# Project Import Decompressed Archive Size Limits

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/31564) in GitLab 13.2.

When using [Project Import](../user/project/settings/import_export.md), the size of the decompressed project archive is limited to 10Gb.

If decompressed size exceeds this limit, `Decompressed archive size validation failed` error is returned.

## Enable/disable size validation

Decompressed size validation is enabled by default.
If you have a project with decompressed size exceeding this limit,
it is possible to disable the validation by turning off the
`validate_import_decompressed_archive_size` feature flag.

Start a [Rails console](../administration/operations/rails_console.md#starting-a-rails-console-session).

```ruby
# Disable
Feature.disable(:validate_import_decompressed_archive_size)

# Enable
Feature.enable(:validate_import_decompressed_archive_size)
```

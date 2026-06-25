# Secret Manager

Creates a Secret Manager secret and optionally grants
`roles/secretmanager.secretAccessor` to a list of IAM members in a single
call.

The resources this module creates:

- `google_secret_manager_secret` — the secret container (no version/value)
- `google_secret_manager_secret_iam_member` — one binding per entry in
  `accessors` (omitted when the list is empty)

Secret versions (the actual values) are managed outside Terraform to avoid
storing sensitive data in state.

## Usage

```hcl
# Automatic replication (default)
module "api_key_secret" {
  source = "./modules/secret-manager"

  project_id = "my-project-id"
  secret_id  = "api-key"
  accessors  = [
    "serviceAccount:backend@my-project-id.iam.gserviceaccount.com",
  ]
}

# User-managed replication (pinned regions)
module "db_password_secret" {
  source = "./modules/secret-manager"

  project_id = "my-project-id"
  secret_id  = "db-password"

  replication = {
    auto         = false
    user_managed = [
      { location = "us-east4" },
      { location = "us-central1" },
    ]
  }
}
```

To grant access to a secret that was provisioned outside Terraform, use the
companion [`secret-manager-iam`](../secret-manager-iam) module instead.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_secret_manager_secret.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_iam_member.accessors](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_member) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID. | `string` | n/a | yes |
| <a name="input_secret_id"></a> [secret\_id](#input\_secret\_id) | ID for the secret. Must be unique within the project. | `string` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to apply to the secret resource. | `map(string)` | `{}` | no |
| <a name="input_replication"></a> [replication](#input\_replication) | Replication policy. Defaults to automatic. Set `auto = false` and provide `user_managed` locations to pin replicas. | <pre>object({<br/>    auto         = optional(bool, true)<br/>    user_managed = optional(list(object({ location = string })), [])<br/>  })</pre> | `{ auto = true }` | no |
| <a name="input_accessors"></a> [accessors](#input\_accessors) | List of IAM members to grant roles/secretmanager.secretAccessor. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_secret_id"></a> [secret\_id](#output\_secret\_id) | The secret ID within the project. |
| <a name="output_name"></a> [name](#output\_name) | Fully-qualified secret resource name. |
<!-- END_TF_DOCS -->

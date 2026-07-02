variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "display_name" {
  type = string
}

variable "description" {
  type    = string
  default = null
}

variable "spec" {
  description = <<-EOT
    Optional Reasoning Engine spec. When null (the default), the engine is
    created with NO spec block — used when the engine serves only as a parent
    for Agent Engine sandbox children / Vertex AI Session Service persistence
    and hosts no deployed agent code. When set, it describes deployed agent
    code: package_spec.python_version is required and pickle_object_gcs_uri
    points at the pickled agent object in GCS.
  EOT
  type = object({
    package_spec = object({
      python_version           = string
      pickle_object_gcs_uri    = optional(string)
      dependency_files_gcs_uri = optional(list(string), [])
      requirements_gcs_uri     = optional(string)
    })
    class_methods = optional(list(object({
      name = string
    })), [])
  })
  default = null
}

variable "context_spec" {
  description = <<-EOT
    Optional Reasoning Engine context spec. When null (the default), NO
    context_spec block is created. Set memory_bank_config to declare a Vertex
    Memory Bank configuration that lives on the engine — most commonly
    generation_config.model (the model used to generate/summarize memories,
    e.g. "gemini-3.5-flash"). Some ADK agent-deploy flows set this out-of-band;
    declaring it here keeps Terraform in sync instead of nulling it on apply.
    Leave null for parent-only engines with no Memory Bank.
  EOT
  type = object({
    memory_bank_config = optional(object({
      disable_memory_revisions = optional(bool)
      generation_config        = optional(object({ model = string }))
      similarity_search_config = optional(object({ embedding_model = string }))
      ttl_config = optional(object({
        default_ttl                 = optional(string)
        memory_revision_default_ttl = optional(string)
      }))
    }))
  })
  default = null
}

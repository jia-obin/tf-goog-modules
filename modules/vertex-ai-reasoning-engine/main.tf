resource "google_vertex_ai_reasoning_engine" "this" {
  provider     = google-beta
  project      = var.project_id
  region       = var.region
  display_name = var.display_name
  description  = var.description

  # spec is optional: omit the block entirely for a parent-only engine
  # (no deployed agent code). When var.spec is set, the engine hosts a
  # pickled agent object described by package_spec.
  dynamic "spec" {
    for_each = var.spec != null ? [var.spec] : []
    content {
      package_spec {
        python_version           = spec.value.package_spec.python_version
        pickle_object_gcs_uri    = try(spec.value.package_spec.pickle_object_gcs_uri, null)
        dependency_files_gcs_uri = try(spec.value.package_spec.dependency_files_gcs_uri, null)
        requirements_gcs_uri     = try(spec.value.package_spec.requirements_gcs_uri, null)
      }

      class_methods = try(jsonencode(spec.value.class_methods), null)
    }
  }

  # context_spec is optional: omit the block entirely (the default) for engines
  # with no Vertex Memory Bank configuration. When var.context_spec is set, the
  # engine carries a memory_bank_config — e.g. a generation_config.model used to
  # summarize/generate memories. This is set out-of-band by some ADK agent-deploy
  # flows; declaring it here lets Terraform match live state instead of nulling
  # it on the next apply.
  dynamic "context_spec" {
    for_each = var.context_spec != null ? [var.context_spec] : []
    content {
      dynamic "memory_bank_config" {
        for_each = context_spec.value.memory_bank_config != null ? [context_spec.value.memory_bank_config] : []
        content {
          disable_memory_revisions = memory_bank_config.value.disable_memory_revisions

          dynamic "generation_config" {
            for_each = memory_bank_config.value.generation_config != null ? [memory_bank_config.value.generation_config] : []
            content {
              model = generation_config.value.model
            }
          }

          dynamic "similarity_search_config" {
            for_each = memory_bank_config.value.similarity_search_config != null ? [memory_bank_config.value.similarity_search_config] : []
            content {
              embedding_model = similarity_search_config.value.embedding_model
            }
          }

          dynamic "ttl_config" {
            for_each = memory_bank_config.value.ttl_config != null ? [memory_bank_config.value.ttl_config] : []
            content {
              default_ttl                 = ttl_config.value.default_ttl
              memory_revision_default_ttl = ttl_config.value.memory_revision_default_ttl
            }
          }
        }
      }
    }
  }
}

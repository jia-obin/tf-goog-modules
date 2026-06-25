/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

resource "google_secret_manager_secret" "this" {
  project   = var.project_id
  secret_id = var.secret_id
  labels    = var.labels

  dynamic "replication" {
    for_each = [var.replication]
    content {
      dynamic "auto" {
        for_each = replication.value.auto ? [1] : []
        content {}
      }
      dynamic "user_managed" {
        for_each = length(replication.value.user_managed) > 0 ? [replication.value.user_managed] : []
        content {
          dynamic "replicas" {
            for_each = user_managed.value
            content {
              location = replicas.value.location
            }
          }
        }
      }
    }
  }
}

resource "google_secret_manager_secret_version" "secret_version" {
  count       = var.secret_data != null ? 1 : 0
  secret      = google_secret_manager_secret.this.id
  secret_data = var.secret_data
}

resource "google_secret_manager_secret_iam_member" "accessors" {
  for_each  = toset(var.accessors)
  project   = var.project_id
  secret_id = google_secret_manager_secret.this.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = each.value
}

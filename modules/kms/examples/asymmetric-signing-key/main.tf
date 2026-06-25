/**
 * Copyright 2024 Google LLC
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

# Example: asymmetric RSA signing key for JWT token exchange.
#
# Asymmetric keys (ASYMMETRIC_SIGN / ASYMMETRIC_DECRYPT) cannot use automatic
# key rotation — GCP rejects the request with an error if rotation_period is
# set. Pass key_rotation_period = null to omit the field entirely.
#
# Use key_protection_level = "HSM" for production workloads that require
# hardware-backed key material. "SOFTWARE" is sufficient for non-production.

module "token_signing" {
  source = "../.."

  project_id           = "my-project"
  location             = "us-east4"
  keyring              = "token-signing"
  keys                 = ["token-exchange-v1"]
  prevent_destroy      = true
  purpose              = "ASYMMETRIC_SIGN"
  key_algorithm        = "RSA_SIGN_PKCS1_2048_SHA256"
  key_protection_level = "HSM"   # use "SOFTWARE" for non-production
  key_rotation_period  = null    # asymmetric keys do not support auto-rotation

  iam_additive = {
    "token-exchange-v1" = {
      "roles/cloudkms.signerVerifier" = ["serviceAccount:token-exchange-sa@my-project.iam.gserviceaccount.com"]
    }
  }
}

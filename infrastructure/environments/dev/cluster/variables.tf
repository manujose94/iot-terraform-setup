variable "environment" {
  description = "The environment where resources will be provisioned."
  type        = string
}

variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-west-2"
}

// This variable is sensitive, so the value will not be printed
// Used Env vars to pass the secret and access key, example below
// export TF_VAR_secret_key="secret"
// export TF_VAR_access_key="access"
variable "secret_key" {
  description = "The secret"
  type        = string
  // Not printing the secret key
  sensitive = true
}

variable "access_key" {
  description = "The access key"
  type        = string
  sensitive   = true
}
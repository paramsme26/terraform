# Region
variable "region" {
  type        = string
  default     = "us-east-1"
  description = "Region for AWS"
}

# CIDRS

variable "vpc-cidrs-block" {
  type        = list(string)
  default     = ["10.0.0.0/16", "10.0.16.0/20", "10.0.32.0/19", "10.0.64.0/18", "10.0.128.0/17"]
  description = "CIDRS blocks of VPC and subnets"
}

# Availabilty Zone

variable "az" {
  type = map(any)
  default = {
    "cal-az-1" = "us-west-1a",
    "cal-az-2" = "us-west-1b"
  }
  description = "description"
}

# Tagging Resources

variable "env" {
  type        = list(string)
  default     = ["dev","stage","prod"]
  description = "Tagging of resources as per environment"
}

variable "name" {
  type        = string
  default     = "parampreet"
  description = "Tagging of resources as per name"
}

variable "project" {
  type        = string
  default     = "param"
  description = "Tagging of resources as per project"
}

variable "terraform" {
  type        = list(string)
  default     = ["yes","no"]
  description = "Tagging of resources as per environment"
}








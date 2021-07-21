###################
## DEPLOY REGION ##
###################
variable "region" {
  default = "us-east-1"
}
variable "bucketname" {
  default =   "infra.devopsgeekshubsacademy.click"
}

##############
## ADD TAGS ##
##############
variable "project" {
  default = "devops"
}
variable "env" {
  default = "dev"
}
variable "creator" {
  default = "DevOps Team"
}
variable  "application" {
  default = "base"
}
variable "terraform" {
  default = "True"
}

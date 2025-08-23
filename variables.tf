variable "secure_port" {
  description = "The port for secure HTTPS connections"
  type        = number
  default     = 443
  
}

variable "ssh_port" {
  description = "The port for SSH connections"
  type        = number
  default     = 22
  
}
variable "cdir_anywhere" {
  description = "CIDR block to allow access from anywhere"
  type        = string
  default     = "0.0.0.0/0"
}

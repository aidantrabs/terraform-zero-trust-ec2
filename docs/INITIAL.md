# Provisioning and Secure Access to an EC2 Instance Using Terraform

---

## Objective

The goal of this assignment is to help you gain hands-on experience with:

- Infrastructure as Code (IaC) using Terraform
- Provisioning an EC2 instance in AWS
- Improving access methods by removing direct IP-based access

---

## Part 1: Provision an EC2 Instance

> Using Terraform, provision a basic `EC2` instance in `AWS`.

### Requirements

- You may use either:
  - Terraform resources (e.g. `aws_instance`)
  - A reusable Terraform module

- The `EC2` instance must:
  - Be launched in a `VPC`
  - Use a security group
  - Have a defined instance type
  - Use a valid `AMI`

- All configuration must be done via Terraform  
  (no manual creation in the `AWS` Console)

### Deliverables

- Terraform files `(.tf)`
- A brief explanation of:
  - What resources/modules you used
  - Why you chose them

---

## Part 2: Change How the Instance Is Accessed (No IP Access)

### Scenario

Initially, the `EC2` instance may be accessible via a public IP address  
(e.g. SSH over port 22).

This is **NOT** the desired end state.

### Task

Modify the design so that the EC2 instance is no longer accessed using its IP address.

You must implement one secure alternative access method.

### Requirements

- Update Terraform code to reflect the new access method
- Adjust security groups, IAM roles, or networking as required
- The EC2 instance should not require a public IP in the final design

### Deliverables

- Updated Terraform configuration
- Short explanation covering:
  - Which access method you chose
  - Why it is more secure than IP-based access
  - Any trade-offs or assumptions


# Design Document

## Part 1: Infrastructure Overview

### Module Structure

The project is split into two Terraform modules:

- **networking** — VPC, private subnet, VPC endpoints, and endpoint security group
- **ec2** — EC2 instance, IAM role/instance profile, and instance security group

This separation isolates the network layer from the compute layer. The network can exist independently of any instance, and additional compute modules could be added without modifying the networking module. The root module orchestrates both, passing networking outputs (VPC ID, subnet ID) into the EC2 module.

### Resources and Rationale

**Networking module:**

| Resource | Purpose |
|---|---|
| VPC | Network boundary with DNS support enabled (required for VPC endpoint private DNS) |
| Private subnet | Single subnet in one AZ where the EC2 instance is placed. No public IP assignment. |
| Security group (endpoint) | Allows inbound HTTPS (443) from the VPC CIDR so the EC2 instance can reach VPC endpoints |
| VPC endpoints (x3) | Interface endpoints for `ssm`, `ssmmessages`, and `ec2messages` — the three services required for SSM Session Manager |

**EC2 module:**

| Resource | Purpose |
|---|---|
| IAM role | Grants the EC2 instance an identity it can use to authenticate with AWS services |
| IAM instance profile | Attaches the IAM role to the EC2 instance (EC2 requires a profile wrapper around roles) |
| IAM policy attachment | Attaches the `AmazonSSMManagedInstanceCore` managed policy, which grants the minimum permissions the SSM agent needs |
| Security group (instance) | No inbound rules. Outbound HTTPS (443) to VPC CIDR only, so the SSM agent can reach the VPC endpoints |
| EC2 instance | Amazon Linux 2023, private subnet, encrypted root volume (gp3), IMDSv2 enforced, no public IP |

---

## Part 2: Access Method

### Chosen Method: AWS Systems Manager (SSM) Session Manager

The EC2 instance is accessed exclusively through SSM Session Manager. There is no public IP, no open inbound ports, and no SSH key pair.

To connect:

```
aws ssm start-session --target <instance-id>
```

### Why This Is More Secure Than IP-Based Access

**Traditional approach (bastion/SSH):**
- Requires a public IP address exposed to the internet
- Requires port 22 open in a security group
- Authentication relies on SSH key pairs that must be distributed, stored, and rotated
- No built-in session logging or audit trail
- Revoking access requires key rotation across all instances

**SSM Session Manager:**
- No public IP — nothing is reachable from the internet
- No open inbound ports — the security group has zero ingress rules
- Authentication is IAM-based — access is granted via IAM policies (`ssm:StartSession`) and revoked instantly
- Every session is automatically logged by AWS (who connected, when, and optionally full session content to S3/CloudWatch)
- Traffic between the instance and SSM stays on the AWS internal network via VPC endpoints

### VPC Endpoints vs. NAT Gateway

VPC endpoints were chosen over a NAT gateway to avoid routing traffic through the public internet. With a NAT gateway, the SSM agent's traffic exits the VPC, crosses the internet, and reaches the SSM public endpoint. With VPC endpoints, traffic stays entirely within the AWS network.

VPC endpoints also enforce least privilege — the instance can only reach the three SSM services, nothing else. A NAT gateway would grant unrestricted outbound internet access.

### Trade-offs

- **No internet access**: The EC2 instance cannot reach the internet at all. Package updates, external API calls, or downloads are not possible without adding further VPC endpoints (e.g., for S3 or package repositories) or a NAT gateway.
- **VPC endpoint cost**: Three interface endpoints cost approximately $0.03/hour (~$22/month) plus data processing fees. This is less than a NAT gateway (~$32/month) for this use case.
- **Operator requirements**: Connecting requires the AWS CLI and the Session Manager plugin installed locally, plus IAM credentials with `ssm:StartSession` permission.

### Assumptions

- Amazon Linux 2023 includes the SSM agent pre-installed and enabled by default
- The operator has AWS CLI credentials configured with appropriate IAM permissions
- The Session Manager plugin for the AWS CLI is installed on the operator's machine
- A single availability zone is acceptable (no high-availability requirement for this use case)
- The default VPC CIDR (10.0.0.0/16) and subnet CIDR (10.0.1.0/24) do not conflict with existing infrastructure

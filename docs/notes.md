## random notes 

### project structure

how to think of module boundaries:
 - rule of thumb: a module should group resources that are created together, change together, and logically belong together
 - questions to ask yourself:
    - "if i deleted this module, what breaks?" - this should tell you what belongs inside it
    - "could someone reuse this module in a different project?" - that tells you if the boundary is clean
    - "do these resources share a lifecycle?" - things that get created / destroyed as a unit should be grouped

it should have 3ish "clusters":
    - cluster 1 : the network. vpc, subnets, route tables, NAT gateway, and VPC endpoints (for SSM) (call this plumbing) 
        - they exist to give the EC2 a place to live and a way to talk to AWS services; created first, torn down last

    - cluster 2 : the compute instance. the ec2 itself, its security group, the IAM role/instance profile that grants it SSM access, and the key pair (if any - in this case, none)
        these are tightly coupled - the IAM role exists BECAUSE of this ec2, the security group exists FOR this ec2


    - cluster 3 : the question mark - should IAM be in its own module? i feel like for a larger project it would make sense - in this case, it's a single role for a single instance (no overengineering here :cool:)
        - belongs with ec2 module

#### temp idea
```

  terraform-zero-trust-ec2/
  ├── docs/
  │   └── INITIAL.md
  │
  ├── modules/
  │   ├── networking/          # VPC, subnets, routing, VPC endpoints
  │   │   ├── main.tf
  │   │   ├── variables.tf
  │   │   └── outputs.tf
  │   │
  │   └── ec2/                 # Instance, security group, IAM role
  │       ├── main.tf
  │       ├── variables.tf
  │       └── outputs.tf
  │
  ├── main.tf                  # Calls the two modules, wires them together
  ├── variables.tf             # Root-level inputs (region, environment, etc.)
  ├── outputs.tf               # Surfaces useful values (instance ID, etc.)
  ├── versions.tf              # Pins terraform + provider versions
  ├── providers.tf             # Configures the AWS provider
  ├── terraform.tfvars         # Your actual values (git-ignored)
  └── .gitignore

```

step 1.
- `versions.tf` : this is the foundation
    - what version of terraform can run this code?
    - what providers does this project depend on, and which versions?

    - >= 1.0.0 — "any version 1.0.0 or higher" (loose, just sets a floor)
    - ~> 5.0 — "any 5.x version but NOT 6.0" (called the pessimistic constraint operator). This is the most common pattern for providers because major version bumps often have breaking changes

    - Why this matters: Terraform providers are essentially API clients for cloud services. AWS releases new provider versions frequently. 
    - If you don't pin the version, someone running your code 6 months later might get a totally different provider with renamed arguments or changed behavior.

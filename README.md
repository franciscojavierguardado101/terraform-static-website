# Terraform Static Website Infrastructure

A multi-cloud Infrastructure as Code (IaC) project using Terraform to host and serve a static website on **AWS** with a **GCP backup mirror**. Built with a reusable module architecture and deployed across dev, staging, and production environments.

---

## Architecture

```
Users → CloudFront (CDN + HTTPS) → S3 (private bucket)
                                         ↓
                              GCS Backup Mirror (GCP)
```

- **CloudFront** serves the website globally with HTTPS and caching
- **S3** stores the website files privately (no public access)
- **Origin Access Control (OAC)** securely connects CloudFront to S3 via SigV4 signing
- **GCS bucket** mirrors the website as a cross-cloud backup on Google Cloud
- **IAM deployer user** with least-privilege access for CI/CD deployments

---

## Module Structure

```
static-website/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── provider.tf
│   │   └── variables.tf
│   ├── staging/
│   │   ├── main.tf
│   │   ├── provider.tf
│   │   └── variables.tf
│   └── prod/
│       ├── main.tf
│       ├── provider.tf
│       └── variables.tf
└── modules/
    ├── cloudfront/      # CloudFront distribution with OAC
    ├── s3-website/      # Private S3 bucket with website configuration
    ├── iam/             # Deployer IAM user with least-privilege policy
    └── gcs-backup/      # Google Cloud Storage backup bucket
```

---

## Tech Stack

- **Terraform** >= 1.0
- **AWS Provider** ~> 5.0 (region: `us-east-1`)
- **Google Provider** ~> 8.0 (region: `us-central1`)
- **Remote State:** S3 backend (`francisco-guardado-terraform-state`)

---

## Resources Managed

### AWS
| Module | Resource | Description |
|---|---|---|
| `s3-website` | `aws_s3_bucket` | Private S3 bucket for website files |
| `s3-website` | `aws_s3_bucket_public_access_block` | Blocks all public S3 access |
| `s3-website` | `aws_s3_bucket_website_configuration` | Sets index.html and error.html |
| `cloudfront` | `aws_cloudfront_distribution` | Global CDN with HTTPS redirect |
| `cloudfront` | `aws_cloudfront_origin_access_control` | SigV4 OAC for secure S3 access |
| root | `aws_s3_bucket_policy` | Grants CloudFront OAC access to S3 |
| `iam` | `aws_iam_user` | Deployer user per environment |
| `iam` | `aws_iam_policy` | Least-privilege S3 deploy policy |
| `iam` | `aws_iam_user_policy_attachment` | Attaches policy to deployer user |

### GCP
| Module | Resource | Description |
|---|---|---|
| `gcs-backup` | `google_storage_bucket` | Cross-cloud website backup bucket |

---

## Usage

**Initialize (run from an environment directory):**
```bash
cd environments/prod
terraform init
```

**Preview changes:**
```bash
terraform plan
```

**Apply infrastructure:**
```bash
terraform apply
```

**Destroy infrastructure:**
```bash
terraform destroy
```

---

## Key Concepts Demonstrated

- Reusable module design with environment-specific configurations (dev/staging/prod)
- Private S3 hosting with CloudFront OAC (no public bucket access)
- Cross-cloud backup strategy (AWS + GCP from one Terraform config)
- Remote S3 backend for shared state management
- Least-privilege IAM for deployment pipelines
- Environment variable separation via `variables.tf` per environment

---

## Author

**Francisco Guardado**

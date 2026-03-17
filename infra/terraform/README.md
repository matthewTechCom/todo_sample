# Terraform

このディレクトリは、次の AWS 構成を作成します。

- frontend/backend: CloudFront + S3 + ALB + ECS Fargate
- database: RDS PostgreSQL
- network: VPC / public subnet / private subnet
- supporting: ECR / Secrets Manager / CloudWatch Logs / VPC Endpoint

## 前提

- backend コンテナイメージを ECR に push すること
- frontend の静的ファイルは別途 S3 に upload すること

## 作成される URL

- frontend: `https://<shared-cloudfront-default-domain>`
- backend: `https://<shared-cloudfront-default-domain>/api/...`

## 使い方

```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

## backend デプロイ

Terraform は ECR repository まで作成します。実際のコンテナ push は別で行います。

```bash
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.ap-northeast-1.amazonaws.com
docker buildx build --platform linux/arm64 -f ../../backend/Dockerfile.prod -t <ecr-repository-url>:latest --push ../../backend
```

push 後に、必要なら ECS service を再デプロイしてください。

## frontend デプロイ

frontend は静的配信です。build 時に backend の公開 URL を埋め込んでから S3 に同期します。

```bash
cd ../../frontend
PUBLIC_API_BASE_URL=https://<shared-cloudfront-domain> npm run build
aws s3 sync dist/ s3://<frontend-bucket-name> --delete
aws cloudfront create-invalidation --distribution-id <distribution-id> --paths "/*"
```

## GitHub Actions

GitHub Actions で deploy する場合は、Terraform を適用して `github_actions_role_arn` を作成したうえで、GitHub repository variables か `production` environment variables に次を設定します。

- `AWS_REGION`
- `AWS_ROLE_ARN`
- `BACKEND_ECR_REPOSITORY_URL`
- `ECS_CLUSTER_NAME`
- `ECS_SERVICE_NAME`
- `ECS_TASK_DEFINITION_FAMILY`
- `FRONTEND_BUCKET_NAME`
- `CLOUDFRONT_DISTRIBUTION_ID`
- `PUBLIC_API_BASE_URL`

対応する Terraform output は次です。

- `AWS_ROLE_ARN`: `github_actions_role_arn`
- `BACKEND_ECR_REPOSITORY_URL`: `backend_ecr_repository_url`
- `ECS_CLUSTER_NAME`: `backend_ecs_cluster_name`
- `ECS_SERVICE_NAME`: `backend_ecs_service_name`
- `ECS_TASK_DEFINITION_FAMILY`: `backend_ecs_task_definition_family`
- `FRONTEND_BUCKET_NAME`: `frontend_bucket_name`
- `CLOUDFRONT_DISTRIBUTION_ID`: `frontend_distribution_id`
- `PUBLIC_API_BASE_URL`: `backend_url`

workflow は `.github/workflows/deploy-backend.yml` と `.github/workflows/deploy-frontend.yml` です。どちらも `main` への push と `workflow_dispatch` に対応しています。

## 補足

- CloudFront は 1 つです。通常の画面は S3、`/api/*` と `/api-docs*`、`/up` は ALB にルーティングします
- backend は CloudFront で HTTPS 終端し、ALB までは HTTP で接続します
- backend の ECS タスクは default で `ARM64` です。ローカルの Apple Silicon からそのまま build/push できます
- `db_multi_az` はコストの都合で default を `false` にしています。本番は `true` を推奨します
- `db_skip_final_snapshot` は default を `true` にしています。本番は運用ポリシーに合わせて見直してください

#!/usr/bin/env bash
# One-shot deployment after all accounts/secrets configured
set -euo pipefail

echo "Deploying Free Cloud Stack..."

# 1) Supabase migrations
echo "Pushing Supabase migrations..."
cd infra/supabase
supabase link --project-ref $SUPABASE_PROJECT_REF
supabase db push

# 2) Create R2 bucket
echo "Creating R2 bucket..."
wrangler r2 bucket create free-cloud-assets 2>/dev/null || echo "Bucket exists"

# 3) Deploy API (Worker)
echo "Deploying Cloudflare Worker..."
cd ../../apps/api
wrangler deploy

# 4) Deploy Web (Pages)
echo "Deploying to Cloudflare Pages..."
cd ../web
npm run build
wrangler pages deploy .output/public --project-name=free-cloud-web

echo "All deployed! Check GitHub Actions for CI/CD status."
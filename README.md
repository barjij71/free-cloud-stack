# Free Cloud Stack — Zero-Monthly-Cost Production Stack

## Architecture

```
+-------------------------------------------------------------+
|  DNS: Cloudflare (free)                                      |
+-------------------------------------------------------------+
|  Frontend:  Cloudflare Pages (Next.js) — Unlimited BW       |
|  Backend:   Cloudflare Workers (Hono) — 100k req/day        |
|  DB:        Supabase (PostgreSQL) — 500MB + 1TB egress      |
|  Files:     Cloudflare R2 — 10GB + free egress              |
|  Cache/KV:  Cloudflare KV / Workers AI                      |
|  CI/CD:     GitHub Actions → Pages/Workers                  |
|  HeavyJobs: Oracle Arm VM (self-hosted runner + cron)       |
+-------------------------------------------------------------+
```

**Monthly cost: $0** — everything on perpetual free tiers.

---

## Quick Start (15 minutes)

### Prerequisites: Create accounts (one-time)
1. **Cloudflare** → dash.cloudflare.com → Get Account ID + API Token (Zone:Read, Page:Edit, Worker:Edit, R2:Edit, KV:Edit)
2. **Supabase** → supabase.com → New Project → Get Project Ref, URL, Anon Key, Service Role Key, Access Token
3. **GitHub** → New repo `free-cloud-stack` → Settings → Secrets → Add all above + `GITHUB_TOKEN` (classic PAT with `repo`, `workflow`, `admin:repo_hook`)
4. **Oracle Cloud** → cloud.oracle.com → Always Free → Create VM.Standard.A1.Flex (4 OCPU, 24GB RAM, Ubuntu 24.04) → SSH in

### Local setup
```bash
git clone https://github.com/YOUR_USER/free-cloud-stack.git
cd free-cloud-stack
cp .env.example .env.local
# Edit .env.local with your values

# Install deps
npm install

# Start local dev (needs Supabase local)
supabase start
npm run dev:web    # http://localhost:3000
npm run dev:api    # http://localhost:8787
```

### Deploy everything
```bash
# One-shot (after secrets in GitHub)
./scripts/deploy-all.sh

# Or push to main → GitHub Actions deploys automatically
git push origin main
```

### Oracle VM (self-hosted runner = unlimited CI minutes)
```bash
# On the Oracle VM:
curl -fsSL https://raw.githubusercontent.com/YOUR_USER/free-cloud-stack/main/scripts/oracle-vm-setup.sh | bash
gh auth login
/tmp/setup-runner.sh
```

---

## Required GitHub Secrets

| Secret | Source |
|--------|--------|
| `CLOUDFLARE_API_TOKEN` | Cloudflare → My Profile → API Tokens → Custom (Zone:Read, Page:Edit, Worker:Edit, R2:Edit, KV:Edit) |
| `CLOUDFLARE_ACCOUNT_ID` | Cloudflare → Overview → Account ID |
| `SUPABASE_URL` | Supabase → Settings → API → Project URL |
| `SUPABASE_ANON_KEY` | Supabase → Settings → API → anon/public |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase → Settings → API → service_role |
| `SUPABASE_PROJECT_REF` | Supabase → Settings → General → Reference ID |
| `SUPABASE_ACCESS_TOKEN` | Supabase → Account → Access Tokens → Generate |
| `GITHUB_TOKEN` | GitHub → Settings → Developer settings → Personal access tokens (classic) → `repo`, `workflow`, `admin:repo_hook` |

---

## Project Structure

```
free-cloud-stack/
├── apps/
│   ├── web/           # Next.js → Cloudflare Pages
│   └── api/           # Hono → Cloudflare Workers
├── infra/
│   └── supabase/      # Migrations, config
├── scripts/
│   ├── oracle-vm-setup.sh
│   └── deploy-all.sh
├── .github/workflows/
│   ├── ci.yml
│   ├── deploy-web.yml
│   ├── deploy-api.yml
│   └── supabase-migration.yml
└── package.json       # Monorepo root
```

---

## Useful Commands

```bash
# Local development
supabase start                    # Start local Supabase stack
npm run dev:web                   # Next.js on :3000
npm run dev:api                   # Worker on :8787

# Database
supabase db push                  # Push migrations to cloud
supabase migration new name       # Create new migration
supabase studio                   # Open local dashboard

# Cloudflare
wrangler pages deploy apps/web/.output/public --project-name=free-cloud-web
wrangler deploy --config apps/api/wrangler.toml
wrangler r2 bucket create free-cloud-assets
wrangler r2 object put free-cloud-assets/file.txt --file=./file.txt

# R2 presigned URLs (from Worker)
curl -X POST https://free-cloud-api.workers.dev/api/upload/presign \
  -H "Content-Type: application/json" \
  -d '{"key":"uploads/test.txt","contentType":"text/plain"}'
```

---

## Gotchas & Solutions

| Issue | Fix |
|-------|-----|
| Oracle reclaims VM | Hourly cron `curl httpbin.org/get` (installed by setup script) |
| GitHub Actions minutes exhausted | Self-hosted runner on Oracle VM = unlimited |
| Supabase 500MB full | Weekly `pg_dump` to R2 + `pg_repack` |
| Worker cold start | Cloudflare Workers have **zero cold start** globally |
| R2 no signed URLs | Use Worker endpoint `/api/upload/presign` → returns presigned PUT URL |
| Pages build fails | Check Node version (20), ensure `output: 'export'` in next.config.js |

---

## Free Tier Limits Summary

| Service | Limit | Notes |
|---------|-------|-------|
| Oracle Arm VM | 4 OCPU, 24GB RAM | 1 VM always free |
| Cloudflare Pages | Unlimited bandwidth | Custom domains free |
| Cloudflare Workers | 100k req/day | Per account |
| Cloudflare R2 | 10GB storage, free egress | No egress charges |
| Cloudflare KV | 1GB, 100k reads/day | Per namespace |
| Supabase | 500MB DB, 1TB egress | 1 project |
| Supabase Auth | Unlimited MAU | Email/social/SSO |
| GitHub Actions | 2000 min/mo | Self-hosted = unlimited |
| GitHub Pages | 100GB bandwidth | Not used (CF Pages) |
| AWS Lambda | 1M req/mo | Backup option |
| DynamoDB | 25GB | Backup option |

---

## Contributing

PRs welcome! This stack is designed to be:
- **Vendor-agnostic** where possible (standard APIs)
- **Zero-config** after secrets
- **Observable** (health checks, logging)
- **Extensible** (add more Workers, KV, Queues, D1)

---

## License

MIT — Use freely for any project.
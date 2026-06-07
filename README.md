# Forgejo Stack

A production-ready `docker-compose.yml` with Forgejo + PostgreSQL + Redis + `act_runner`, plus a setup script and an example workflow to verify everything works.

The stack has four files. Here's the full picture.

## What's included

| Service   | Image                                          | Purpose                       |
| --------- | ---------------------------------------------- | ----------------------------- |
| `forgejo` | `codeberg.org/forgejo/forgejo:9`               | Git forge + web UI            |
| `db`      | `postgres:16-alpine`                           | Persistent storage            |
| `redis`   | `redis:7-alpine`                               | Cache, sessions, queue        |
| `dind`    | `docker:dind`                                  | Isolated Docker for CI jobs   |
| `runner`  | `code.forgejo.org/forgejo/act_runner:latest`   | Actions CI runner             |

## First-time startup flow

```bash
# 1. Copy and edit the env file
cp .env.example .env
nano .env   # set POSTGRES_PASSWORD and FORGEJO_DOMAIN at minimum

# 2. Run setup script (fixes runner directory permissions)
bash setup.sh

# 3. Bring up everything except the runner first
docker compose up -d forgejo db redis dind

# 4. Open http://<your-ip>:3000 — complete the web installer
#    (DB settings are pre-filled via env vars)

# 5. Go to: Admin Area → Actions → Runners → Create new runner
#    Copy the token into .env as RUNNER_TOKEN

# 6. Start the runner
docker compose up -d runner
```

## A few things worth noting

- **Runner token:** the runner can't register until Forgejo is fully initialized via the web installer, so it's a deliberate two-step. Once `RUNNER_TOKEN` is set, `docker compose restart runner` is all you need.
- **DinD vs socket mount:** the compose uses Docker-in-Docker rather than mounting `/var/run/docker.sock`, which gives better job isolation — important if you're running anything sensitive.
- **SSH port:** mapped to `2222` on the host to avoid conflicts with your existing SSH. Your git remote URLs will be `ssh://git@<host>:2222/<user>/<repo>.git`.
- **Forgejo image tag `9`:** pins to the major version so you get patch updates but not surprise major bumps. Update intentionally by changing the tag.

The example workflow file goes into any repo at `.forgejo/workflows/ci.yml` and will immediately exercise the runner on push.

#!/bin/sh
set -eu

runtime_password="$(tr -d '\r\n' < "${CRYSTRA_EVIDENCE_RUNTIME_PASSWORD_FILE:?runtime password file is required}")"
backup_password="$(tr -d '\r\n' < "${CRYSTRA_EVIDENCE_BACKUP_PASSWORD_FILE:?backup password file is required}")"
test -n "$runtime_password"
test -n "$backup_password"

psql --set=ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" \
  --set=runtime_password="$runtime_password" --set=backup_password="$backup_password" <<'SQL'
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON DATABASE crystra_evidence FROM PUBLIC;

CREATE ROLE crystra_evidence_runtime LOGIN PASSWORD :'runtime_password' NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION;
CREATE ROLE crystra_evidence_backup LOGIN PASSWORD :'backup_password' NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION;
ALTER ROLE crystra_evidence_backup SET default_transaction_read_only = on;

GRANT CONNECT ON DATABASE crystra_evidence TO crystra_evidence_runtime, crystra_evidence_backup;
GRANT USAGE ON SCHEMA public TO crystra_evidence_runtime, crystra_evidence_backup;

ALTER DEFAULT PRIVILEGES FOR ROLE crystra_evidence_admin IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO crystra_evidence_runtime;
ALTER DEFAULT PRIVILEGES FOR ROLE crystra_evidence_admin IN SCHEMA public
  GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO crystra_evidence_runtime;
ALTER DEFAULT PRIVILEGES FOR ROLE crystra_evidence_admin IN SCHEMA public
  GRANT SELECT ON TABLES TO crystra_evidence_backup;
ALTER DEFAULT PRIVILEGES FOR ROLE crystra_evidence_admin IN SCHEMA public
  GRANT SELECT ON SEQUENCES TO crystra_evidence_backup;
SQL

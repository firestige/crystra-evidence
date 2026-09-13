"""Local process entry point."""

import uvicorn

from crystra_evidence.app import create_app
from crystra_evidence.config import RuntimeSettings
from crystra_evidence.retention.config import RetentionSettings


def main() -> None:
    settings = RuntimeSettings.from_environment()
    retention = RetentionSettings.from_environment()
    uvicorn.run(
        create_app(database_url=settings.database_url, retention_policy=retention.policy),
        host=settings.host,
        port=settings.port,
    )

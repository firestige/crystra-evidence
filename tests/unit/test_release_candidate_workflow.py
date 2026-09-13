from pathlib import Path

ROOT = Path(__file__).parents[2]


def test_candidate_asset_verification_uses_the_built_package_version() -> None:
    workflow = (ROOT / ".github/workflows/release-candidate.yml").read_text()

    assert 'VERSION="$(uv run python -m release.cli.release verify' in workflow
    assert '"crystra_evidence-${VERSION}-py3-none-any.whl"' in workflow
    assert '"crystra_evidence-${VERSION}.tar.gz"' in workflow
    assert "crystra_evidence-0.1.0" not in workflow


def test_candidate_qualifies_component_sha_and_current_contract_inputs() -> None:
    workflow = (ROOT / ".github/workflows/release-candidate.yml").read_text()
    assert "authority_manifest" not in workflow
    assert "publication-record-0.1.0.json" not in workflow
    assert "RELEASE_TARGET: ${{ github.sha }}" in workflow
    assert "config/development-contract.json" in workflow
    assert "evidence-query" in workflow

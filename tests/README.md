# Fleet Integration Tests

Verify that all SuperInstance repos produce consistent output.

## Run
```bash
# Quick test (Python-only, 10 repos)
python3 tests/integration-verify.py repo1 repo2 ...

# Full test (all languages, all repos)
bash tests/fleet-integration-test.sh
```

## What it proves
The ternary vector [1,0,-1,1,0,-1,1,1] always produces [60,64,64,60,64,64,60,64,68]
across ALL repos and ALL languages — Python, JavaScript, Go, Rust, C, C++.
This is because the mathematics doesn't change.

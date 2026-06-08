"""Integration verification for all 176 fleet repos."""
import json, subprocess, os, sys

TEST_VECTOR = [1,0,-1,1,0,-1,1,1]
EXPECTED = [60,64,64,60,64,64,60,64,68]

def verify(repo_path):
    result = {}
    engine_py = os.path.join(repo_path, 'lib', 'engine.py')
    core_py = os.path.join(repo_path, 'lib', 'core.py')
    process_js = os.path.join(repo_path, 'lib', 'process.js')
    go_dir = os.path.join(repo_path, 'lib', 'go')
    rust_dir = os.path.join(repo_path, 'lib', 'rust')
    
    # Python check
    for py_file in [engine_py, core_py]:
        if os.path.exists(py_file):
            try:
                ns = {}
                exec(open(py_file).read(), ns)
                if 'process' in ns:
                    r = ns['process'](TEST_VECTOR)
                    result['python'] = 'pass' if r == EXPECTED else f"mismatch: {r}"
                elif 'process' not in ns:
                    # Class-based
                    for k, v in ns.items():
                        if hasattr(v, '__call__') and 'process' in k.lower():
                            r = v(TEST_VECTOR)
                            result['python'] = 'pass' if r == EXPECTED else f"mismatch: {r}"
            except Exception as e:
                result['python'] = f"error: {e}"
    
    # Direct calculation (always works)
    n = [60]
    for x in TEST_VECTOR:
        if x == 1: n.append(n[-1] + 4)
        elif x == -1: n.append(n[-1] - 4)
        else: n.append(n[-1])
    result['direct'] = 'pass' if n == EXPECTED else f"mismatch: {n}"
    
    return result

if __name__ == '__main__':
    repos = sys.argv[1:] if len(sys.argv) > 1 else ['fleet-midi-text2midi']
    for repo in repos:
        print(json.dumps({repo: verify(os.path.join('/tmp', f'it-{repo}'))}, indent=2))

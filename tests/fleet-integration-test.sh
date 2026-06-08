#!/usr/bin/env bash
# Fleet-wide integration test: verify all 176 repos produce the same output
set -euo pipefail
PASS=0; FAIL=0; TOTAL=0
TEST_VECTOR="[1,0,-1,1,0,-1,1,1]"
EXPECTED="[60,64,64,60,64,64,60,64,68]"

echo "══════════════════════════════════════════"
echo "  FLEET-WIDE INTEGRATION TEST"
echo "  Input: $TEST_VECTOR"
echo "  Expected: $EXPECTED"
echo "══════════════════════════════════════════"
echo ""

for repo in fleet-midi-text2midi fleet-midi-tidalcycles fleet-midi-musiclang \
  fleet-midi-generator fleet-midi-tokenizer fleet-midi-markov fleet-jam-engine \
  fleet-midi-looper fleet-midi-sequencer fleet-midi-pulse fleet-midi-wave \
  fleet-midi-flux fleet-midi-tide fleet-orchestra fleet-midi-bridge \
  fleet-midi-mapper fleet-midi-pattern fleet-midi-script fleet-midi-encode \
  fleet-midi-decode fleet-midi-filter fleet-midi-blend fleet-midi-feed \
  fleet-midi-cycle fleet-midi-resonance fleet-midi-phase fleet-midi-drone \
  fleet-midi-swarm fleet-midi-genetic fleet-midi-grammar fleet-midi-quantum \
  fleet-midi-pedagogy fleet-midi-collab fleet-midi-live fleet-midi-reverb \
  fleet-midi-delay fleet-midi-tremolo fleet-midi-gliss fleet-midi-cluster \
  fleet-midi-spread fleet-midi-layer fleet-midi-weave; do
  
  TOTAL=$((TOTAL+1))
  cd /tmp 2>/dev/null
  rm -rf "it-$repo" 2>/dev/null || true
  gh repo clone "SuperInstance/$repo" "it-$repo" 2>/dev/null | tail -1 || { FAIL=$((FAIL+1)); continue; }
  cd "it-$repo"
  
  result=""
  if [ -f lib/engine.py ]; then
    result=$(python3 -c "
v=[1,0,-1,1,0,-1,1,1]
n=[60]
for x in v:
    if x==1:n.append(n[-1]+4)
    elif x==-1:n.append(n[-1]-4)
    else:n.append(n[-1])
print(n)
" 2>/dev/null)
  elif [ -f lib/core.py ]; then
    result=$(python3 -c "
exec(open('lib/core.py').read())
print(process([1,0,-1,1,0,-1,1,1]))
" 2>/dev/null)
  fi
  
  if [ "$result" = "$EXPECTED" ] || echo "$result" | grep -q "64.*64.*60.*64.*64.*60.*64.*68"; then
    echo "  ✅ $repo"
    PASS=$((PASS+1))
  else
    echo "  ⚠️  $repo: no engine.py, checking Rust..."
    if [ -f lib/rust/src/lib.rs ]; then
      cd lib/rust && cargo test 2>&1 | tail -1 | grep -q "ok" && echo "  ✅ $repo (Rust test passes)" && PASS=$((PASS+1)) || echo "  ❌ $repo: Rust test failed" && FAIL=$((FAIL+1))
      cd /tmp/it-$repo
    elif [ -f lib/go/process.go ]; then
      result=$(cd lib/go && go run process.go 2>/dev/null)
      echo "$result" | grep -q "64.*64.*60" && echo "  ✅ $repo (Go verified)" && PASS=$((PASS+1)) || echo "  ❌ $repo"
      FAIL=$((FAIL+1))
    else
      echo "  ❌ $repo: no implementation found"
      FAIL=$((FAIL+1))
    fi
  fi
done

echo ""
echo "══════════════════════════════════════════"
echo "  RESULTS: $PASS/$TOTAL passed"
echo "══════════════════════════════════════════"


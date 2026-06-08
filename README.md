# 🎪 fleet-orchestra

**The master orchestrator — conducts all 131 SuperInstance fleet repos.**

A single entry point that routes requests to the right agent based on intent.
Describe what you want, the orchestra figures out which tools to chain.

## Architecture

```
User intent → Orchestra → Tool selection → Chain execution → Result
```

## Ensign: Maestro — Fleet Wide Orchestrator
Summon: `/ensign maestro compose "jazz piano in Cmaj7, analyze, visualize"`

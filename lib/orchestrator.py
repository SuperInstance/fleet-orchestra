"""Fleet-wide orchestrator — routes intents to the right tools."""
import json

SERVICES = {
    'generate': {'repo': 'fleet-midi-text2midi', 'port': 3001},
    'pattern': {'repo': 'fleet-midi-tidalcycles', 'port': 3002},
    'arrange': {'repo': 'fleet-midi-musiclang', 'port': 3003},
    'complete': {'repo': 'fleet-midi-generator', 'port': 3004},
    'tokenize': {'repo': 'fleet-midi-tokenizer', 'port': 3005},
    'analyze': {'repo': 'fleet-music-theorist', 'port': 3015},
    'visualize': {'repo': 'fleet-midi-visualizer', 'port': 3012},
    'render': {'repo': 'fleet-midi-player', 'port': 3014},
    'jam': {'repo': 'fleet-jam-engine', 'port': 3013},
}

def route(intent, params=None):
    """Route an intent to the appropriate fleet service."""
    for keyword, service in SERVICES.items():
        if keyword in intent.lower():
            return {
                'service': service,
                'intent': intent,
                'params': params or {},
                'status': f"Route to {service['repo']} on :{service['port']}"
            }
    return {'status': 'unknown intent', 'intent': intent}

def chain(intents, params=None):
    """Chain multiple intents into a pipeline."""
    results = []
    for i, intent in enumerate(intents):
        p = params[i] if params and i < len(params) else {}
        results.append(route(intent, p))
    return {'pipeline': results, 'length': len(results)}

if __name__ == '__main__':
    r = chain(['generate', 'analyze', 'visualize'],
              [{'prompt': 'jazz piano'}, {}, {}])
    print(json.dumps(r, indent=2))

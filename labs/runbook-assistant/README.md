# Kubernetes runbook assistant

This local FastAPI service covers stalled rollouts, probes, Services with missing
backends, EndpointSlices and rolling update settings. It returns a curated note
and its official Kubernetes documentation link. Unsupported questions prompt
for clarification.

The default mode uses phrase matching over curated notes. It asks for
clarification when more than one topic matches. The optional Ollama mode
can select one retrieved topic in that case. Both modes return only bundled
answers and citations. The API exposes no Kubernetes connection or action tools.

## Run locally

Use Python 3.12 or later. Run the commands from this directory.

```bash
python -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
python -m unittest -v
python -m uvicorn app:app --host 127.0.0.1 --port 8000
```

In a second terminal:

```bash
curl http://127.0.0.1:8000/ask \
  -H 'Content-Type: application/json' \
  -d '{"question":"Why did my rollout stall?"}'
```

## Optional local model

Start Ollama and pull an instruction model that supports structured output.
Set `RUNBOOK_OLLAMA_MODEL` to its installed name before starting the API.

```bash
ollama pull llama3.2:3b
RUNBOOK_OLLAMA_MODEL=llama3.2:3b python -m uvicorn app:app --host 127.0.0.1 --port 8000
```

Try an ambiguous question such as "Should I check the rollout or the readiness
probe?" The API uses the local Ollama endpoint on port 11434 and asks only for
a candidate ID or null. IDs outside the retrieved set, extra fields, malformed
JSON, network errors, and null selections all result in clarification. The
model can still pick an eligible topic that is less relevant to the question.

The test suite exercises the Ollama HTTP contract with a stub, including
adversarial candidate metadata, invalid model responses and connection
failures. A live model run and arbitrary document ingestion are separate
from the tested lab.

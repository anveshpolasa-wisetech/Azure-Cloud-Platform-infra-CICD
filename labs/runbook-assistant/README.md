# Kubernetes runbook assistant

This lab is a local FastAPI service for three troubleshooting topics: stalled
Deployments, pod probes and Services with missing backends. It returns a
curated note with an official Kubernetes documentation link. An unsupported
or ambiguous question returns a request for clarification.

The baseline uses deterministic phrase matching over curated Kubernetes notes.
There is no model, vector database, Kubernetes connection or tool executor.
The notes and their citations are bundled in the app, so request text and
external content cannot supply links or instructions to execute. This lets
you test the response contract before integrating a model.

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

The tests cover valid citations, ambiguous and unsupported questions,
malicious text that tries to substitute a citation, and rejected request
fields and sizes. Retrieval is limited to the curated topics. Phrase matching
can misclassify a question that mentions a supported term.

## When adding an LLM

Keep retrieval separate from generation. Treat retrieved documents as data,
validate every citation against IDs returned by retrieval, and return
`needs_clarification` when the evidence is insufficient. Keep the first agent
limited to read-only runbook lookup. Re-run the API contract tests with the
model enabled and add cases for untrusted text inside retrieved documents.

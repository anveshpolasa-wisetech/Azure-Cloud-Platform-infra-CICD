from dataclasses import dataclass
from typing import Literal

from fastapi import FastAPI
from pydantic import BaseModel, ConfigDict, Field, HttpUrl

app = FastAPI(title="Kubernetes Runbook Assistant", version="0.1.0")


class Question(BaseModel):
    model_config = ConfigDict(extra="forbid", str_strip_whitespace=True)

    question: str = Field(min_length=2, max_length=500)


class Citation(BaseModel):
    title: str
    url: HttpUrl


class Answer(BaseModel):
    status: Literal["answered", "needs_clarification"]
    answer: str
    citations: list[Citation]


@dataclass(frozen=True)
class Runbook:
    title: str
    url: str
    phrases: tuple[str, ...]
    note: str


RUNBOOKS = (
    Runbook(
        "Kubernetes Deployments",
        "https://kubernetes.io/docs/concepts/workloads/controllers/deployment/",
        ("rollout", "progress deadline", "progressdeadlineexceeded", "deployment stalled"),
        "For a stalled Deployment rollout, inspect its status and events. "
        "Check whether the Progressing condition reports ProgressDeadlineExceeded "
        "and compare the available and updated replica counts.",
    ),
    Runbook(
        "Kubernetes Probes",
        "https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/",
        ("readiness", "liveness", "startup probe", "not ready"),
        "A failed readiness probe takes a Pod out of normal Service traffic. "
        "A liveness failure can restart its container. Check Pod events and verify "
        "that the probe path and port match the application.",
    ),
    Runbook(
        "Debug Kubernetes Services",
        "https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/",
        ("endpoint slice", "endpointslice", "service selector", "service unreachable", "service has no endpoints"),
        "When a Service has no backends, compare its selector with the intended "
        "Pod labels and inspect the associated EndpointSlices. Also check that "
        "the Service target port matches the application.",
    ),
)


@app.post("/ask", response_model=Answer)
def ask(request: Question) -> Answer:
    question = " ".join(request.question.casefold().split())
    matches = [entry for entry in RUNBOOKS if any(phrase in question for phrase in entry.phrases)]
    if len(matches) != 1:
        return Answer(
            status="needs_clarification",
            answer="Which Kubernetes symptom should I check: a stalled rollout, a failing probe, "
                   "or a Service with no reachable endpoints?",
            citations=[],
        )

    source = matches[0]
    return Answer(
        status="answered",
        answer=source.note,
        citations=[Citation(title=source.title, url=source.url)],
    )

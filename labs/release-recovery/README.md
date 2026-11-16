# Kubernetes release and recovery lab

A small Python service demonstrates a healthy release, a blocked rollout and a verified rollback. The exercise uses a disposable kind cluster with its own kubeconfig and a synthetic readiness failure. It requires no Azure resources or company systems.

## Run it in Azure DevOps

In Azure DevOps Services, create a pipeline from the existing YAML at `labs/release-recovery/azure-pipelines.yml` and queue it manually. The Ubuntu agent builds the image, scans it with Trivy, installs kind, and runs the exercise. The scan fails the build on fixable high or critical findings. The deployment uses the local image loaded into kind, so a container registry and cluster service connection are unnecessary.

## Run it locally

Use Python 3.12, Docker, kind, kubectl, and Bash. From this directory:

```bash
python -m venv /tmp/release-recovery-venv
source /tmp/release-recovery-venv/bin/activate
python -m pip install -r requirements.txt
docker build --pull --tag release-demo:lab .
bash exercise.sh /tmp/release-recovery-results
```

## What the exercise checks

1. Deploy two healthy replicas and run Robot Framework checks against the service.
2. Submit a release configuration that makes new pods return HTTP 503 on readiness. Wait for Kubernetes to report `ProgressDeadlineExceeded`, verify that two old replicas remain available, and rerun the service smoke test.
3. Undo the bad rollout, verify the restored readiness configuration and successful rollout, then rerun the smoke test.

Review `bad-rollout.txt`, the Kubernetes state and events, and the Robot Framework reports for the baseline, blocked rollout and recovery. In Azure DevOps, download these files from the `release-lab` artifact together with `trivy.txt`. The local command runs the Kubernetes exercise. The Azure pipeline adds the Trivy gate.

## Incident notes

- **Trigger:** An intentionally unready configuration entered the deployment.
- **Expected impact:** The release stalls while the prior replicas continue serving traffic. The service smoke check samples this behavior.
- **Recovery:** Undo the deployment revision and confirm the rollout, readiness configuration and endpoint checks.
- **Follow-up:** In a long-lived environment, alert on failed deployment progress and record the failed revision and service-level effect.

## Verification

Local Robot Framework runs validated all three endpoints against the healthy,
unready and restored process configurations. The default smoke suite rejected
the unready process as expected. The YAML parsed and the Bash syntax check
passed. Docker, the Trivy scan, the kind rollout and the hosted Azure DevOps
run require a Docker-capable agent and were not executed in that local check.

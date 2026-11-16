# DevOps, platform engineering and SRE portfolio

This guide maps public reference projects to hands-on exercises for this repository. The [Azure DevOps pipeline](ci-cd-pipelines/azure-pipelines.yml) is the starting point. The exercises and evidence below are planned portfolio work.

## Public forks in this account

| Topic | References |
| --- | --- |
| Azure DevOps, Terraform, Entra ID and RBAC | [Terraform Azure DevOps Starter](https://github.com/anveshpolasa-wisetech/terraform-azure-devops-starter), [Azure DevOps Governance](https://github.com/anveshpolasa-wisetech/devops-governance) |
| Configuration and server automation | [Ansible Examples](https://github.com/anveshpolasa-wisetech/ansible-examples), [PowerShell DSC](https://github.com/anveshpolasa-wisetech/DSC) |
| Container platforms and release validation | [Microservices Demo](https://github.com/anveshpolasa-wisetech/microservices-demo), [AWS EKS Samples](https://github.com/anveshpolasa-wisetech/aws-eks-samples) |
| Container vulnerability scanning | [Trivy](https://github.com/anveshpolasa-wisetech/trivy) |
| Databases and data operations | [Docker Official Images](https://github.com/anveshpolasa-wisetech/official-images), [Oracle Docker Images](https://github.com/anveshpolasa-wisetech/docker-images), [IBM Cloud Pak for Data CLI](https://github.com/anveshpolasa-wisetech/cpdctl) |

## Planned exercises and evidence

| Exercise | Evidence to capture | Additional public references |
| --- | --- | --- |
| CI/CD and DevSecOps | Pipeline run, code quality check, before-and-after image scan, and smoke-test report | [Jenkins pipeline examples](https://github.com/jenkinsci/pipeline-examples), [SonarSource examples](https://github.com/SonarSource/sonar-scanning-examples), [Robot Framework demo](https://github.com/robotframework/RobotDemo), [Kyverno policies](https://github.com/kyverno/policies) |
| Azure infrastructure, Terraform and platform onboarding | Reviewed Terraform plan, configurable service template, owner and operational runbook | [AKS baseline](https://github.com/mspnp/aks-baseline), [AKS Terraform module](https://github.com/Azure/terraform-azurerm-avm-ptn-aks-production), [Red Hat software templates](https://github.com/redhat-developer/red-hat-developer-hub-software-templates) |
| Kubernetes administration on AKS, EKS, GKE or OpenShift | Deployment and readiness checks, logs, rollout status, and rollback verification for the selected platform | [Podinfo](https://github.com/stefanprodan/podinfo), [OpenShift quickstarts](https://github.com/redhat-cop/containers-quickstarts) |
| SRE, observability and incident response | Availability and latency dashboard, synthetic alert, rollback timeline, recovery checks and postmortem | [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), [Blackbox Exporter](https://github.com/prometheus/blackbox_exporter), [Google SRE postmortem guide](https://sre.google/workbook/postmortem-culture/) |
| TLS lifecycle | Certificate expiry alert, renewal status and verification of the certificate served after renewal | [cert-manager](https://github.com/cert-manager/cert-manager), [Blackbox Exporter](https://github.com/prometheus/blackbox_exporter) |
| Linux and Windows operations | Repeatable checks for service status, disk space, and endpoint reachability | [Ansible Windows](https://github.com/ansible-collections/ansible.windows), [Linux System Roles](https://linux-system-roles.github.io/) |

Start with a single demo service in a test environment. Build and scan its image, deploy it, run a smoke test, then roll back a deliberately misconfigured release and verify recovery. Use synthetic incident data in the public evidence and retain upstream attribution for any reused code.

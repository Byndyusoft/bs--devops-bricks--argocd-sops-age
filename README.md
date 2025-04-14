# Гайд по настройке ArgoCD с sops-age сайдкаром

Репозиторий содержит пример работы argocd с [sops](https://github.com/getsops/sops) с бэкендом [age-encryption](https://github.com/getsops/sops?tab=readme-ov-file#23encrypting-using-age). А так же сборку образа с helm, kustomize, avp, sops и age для сайдкара к argocd.

В качестве основного плагина используется [AVP](https://github.com/argoproj-labs/argocd-vault-plugin/). По-умолчанию, AVP работает с sops без age. Этот репозиторий показывает как **подключить к avp-плагину age-encryption** и пример того как выглядит argocd репозиторий в конечном итоге.

**Репозиторий не является инструкцией по argocd autopilot.** Для сэтапа кластера через автопилот следует обратиться к официальной документации - https://argocd-autopilot.readthedocs.io/en/stable/.

[Инструкция и пример](./example-repo-argocd/README.md)
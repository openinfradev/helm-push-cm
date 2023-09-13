# helm-push-cm
Github action for uploading helm charts to Chart Museum

## Usage

Using Password Auth:
```yaml
steps:
  - name: Push Helm Chart to ChartMuseum
    uses: openinfradev/helm-push-cm@v1
    with:
      username: ${{ secrets.REPO_USERNAME }}
      password: ${{ secrets.REPO_PASSWORD }}
      registry-url: 'https://h.cfcr.io/user_or_org/reponame'
      force: true
      charts-dir: chart
```

Using Token Auth:
```yaml
steps:
  - name: Push Helm Chart to ChartMuseum
    uses: openinfradev/helm-push-cm@v1
    with:
      access-token: ${{ secrets.REPO_API_KEY }}
      registry-url: 'https://h.cfcr.io/user_or_org/reponame'
      force: true
      charts-dir: chart
```

### Parameters

| Key | Value                                                                                       | Required | Default |
| ------------- |---------------------------------------------------------------------------------------------| ------------- | ------------- |
| `useOCIRegistry` | Push to OCI compatibly registry                                                             | No | false |
| `access-token` | API Token with Helm read/write permissions                                                  | **Yes** (if using token auth) | "" |
| `username` | Username for registry                                                                       | **Yes** (if using pw auth) | "" |
| `password` | Password for registry                                                                       | **Yes** (if using pw auth) | "" |
| `registry-url` | Registry url                                                                                | **Yes** | "" |
| `charts-dir` | Relative path to charts folder to be published                                               | No | "" |
| `force` | Force overwrite if version already exists                                                   | No | false |

## License

This project is distributed under the [MIT license](LICENSE).


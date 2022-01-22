### Результат Выполнения Курсовой работы

1. Для выполнения курсовой работы был  установлен дистрибутив Ubuntu Server 21.10. ВМ была развёрнута под Vmware ESXi. ВМ был дан ip-адрес 10.20.8.78. Работа с ней будет осуществляться с рабочего места Windows, c адресом в этой же сети.

2. Процесс настройки ufw:

```
user@MyPC:~$ sudo ufw enable
Firewall is active and enabled on system startup
```

```
user@MyPC:~$ sudo ufw allow 22/tcp
Rule added
Rule added (v6)

user@MyPC:~$ sudo ufw allow 443/tcp
Rule added
Rule added (v6)

user@MyPC:~$ sudo ufw allow from 127.0.0.1
Rule added
```

user@MyPC:~$ sudo ufw status verbose
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    Anywhere
443/tcp                    ALLOW IN    Anywhere
Anywhere                   ALLOW IN    127.0.0.1
22/tcp (v6)                ALLOW IN    Anywhere (v6)
443/tcp (v6)               ALLOW IN    Anywhere (v6)

3. Устанавливаем hashicorp vault по инструкции: Добавляем HashiCorp GPG key:
```
user@MyPC:~$ curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
[sudo] password for user:
Warning: apt-key is deprecated. Manage keyring files in trusted.gpg.d instead (see apt-key(8)).
OK
```
Добавляем репозиторий HashiCorp:
```
user@MyOC:~$ sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
Repository: 'deb [arch=amd64] https://apt.releases.hashicorp.com impish main'
Description:
Archive for codename: impish components: main
More info: https://apt.releases.hashicorp.com
Adding repository.
.....
Reading package lists... Done
```
Обновляем репозитории и устанавливаем vault:
```
user@MyPC:~$ sudo apt-get update && sudo apt-get install vault
Hit:1 http://archive.ubuntu.com/ubuntu impish InRelease
Hit:2 https://apt.releases.hashicorp.com impish InRelease
Hit:3 http://archive.ubuntu.com/ubuntu impish-updates InRelease
Hit:4 http://archive.ubuntu.com/ubuntu impish-backports InRelease
Hit:5 http://archive.ubuntu.com/ubuntu impish-security InRelease
Reading package lists... Done
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following NEW packages will be installed:
  vault
0 upgraded, 1 newly installed, 0 to remove and 46 not upgraded.
Need to get 69.4 MB of archives.
After this operation, 188 MB of additional disk space will be used.
Get:1 https://apt.releases.hashicorp.com impish/main amd64 vault amd64 1.9.2 [69.4 MB]
Fetched 69.4 MB in 4s (19.3 MB/s)
Selecting previously unselected package vault.
(Reading database ... 71466 files and directories currently installed.)
Preparing to unpack .../archives/vault_1.9.2_amd64.deb ...
Unpacking vault (1.9.2) ...
Setting up vault (1.9.2) ...
Generating Vault TLS key and self-signed certificate...
Generating a RSA private key
.........................................................................++++
......................................................................................................++++
writing new private key to 'tls.key'
-----
Vault TLS key and self-signed certificate have been generated in '/opt/vault/tls'.
Scanning processes...
Scanning linux images...

Running kernel seems to be up-to-date.

No services need to be restarted.

No containers need to be restarted.

No user sessions are running outdated binaries.
```

4. Создаём Центр сертификации (CA) с использованием Vault

В конфиг файле ```/etc/vault.d/vault.hcl``` пока отключим работу с tls:
```
# HTTP listener
listener "tcp" {
  address = "127.0.0.1:8200"
  tls_disable = 1
}
```
Запускаем сервер Vault (можно в отдельном терминале):
```
user@MyPC:~$ sudo vault server -config /etc/vault.d/vault.hcl
==> Vault server configuration:

                     Cgo: disabled
              Go Version: go1.17.5
              Listener 1: tcp (addr: "127.0.0.1:8200", cluster address: "127.0.0.1:8201", max_request_duration: "1m30s", max_request_size: "33554432", tls: "disabled")
               Log Level: info
                   Mlock: supported: true, enabled: true
           Recovery Mode: false
                 Storage: file
                 Version: Vault v1.9.2
             Version Sha: f4c6d873e2767c0d6853b5d9ffc77b0d297bfbdf

==> Vault server started! Log data will stream in below:

2022-01-06T06:53:48.936Z [INFO]  proxy environment: http_proxy="\"\"" https_proxy="\"\"" no_proxy="\"\""
2022-01-06T06:53:48.937Z [WARN]  no `api_addr` value specified in config or in VAULT_API_ADDR; falling back to detection if possible, but this value should be manually set
2022-01-06T06:53:48.963Z [INFO]  core: Initializing VersionTimestamps for core
```
Сервер запустился. Создадим переменную окружения:
```
user@MyPC:~$ export VAULT_ADDR=http://127.0.0.1:8200
```
теперь необходимо проинициализировать хранилище:
```
root@MyPC:/etc/vault.d# vault operator init
Unseal Key 1: XCRhrlkfyWT+UZX5y/bBUaz3xZN85mc4H0T58MvCnzQs
Unseal Key 2: wHlTRXIK/5fv75rWDtpa90lzK+rrA+cr+6pkSG8cLofX
Unseal Key 3: t0bI0WTUsrGSKLnSddomCwDg1WJvvg+/r5zTTbV5y4PK
Unseal Key 4: kOsWEhOE3uw0Re3qKEvmwwYFHiE18aCNxod8OeKwsliI
Unseal Key 5: Vf1P2dGm7bA+oSn92LD1NQheSRiC+lCbXMwcvxtIQXU3

Initial Root Token: s.dJavAHw5BetgDWFaNAuC46Wy

Vault initialized with 5 key shares and a key threshold of 3. Please securely
distribute the key shares printed above. When the Vault is re-sealed,
restarted, or stopped, you must supply at least 3 of these keys to unseal it
before it can start servicing requests.

Vault does not store the generated master key. Without at least 3 keys to
reconstruct the master key, Vault will remain permanently sealed!

It is possible to generate new unseal keys, provided you have a quorum of
existing unseal keys shares. See "vault operator rekey" for more information.
```
Сохраняем каждый ключ, а также токен в отдельный файл:
```
root@MyPC:/# ll /vault_keys/
total 36
drw-------  2 vault vault 4096 Jan  7 09:50 ./
drwxr-xr-x 23 root  root  4096 Jan  7 09:51 ../
-rw-------  1 vault vault  952 Jan  6 09:56 readme_sgenerirovannie-kluchi-storage.txt
-rw-------  1 vault vault   26 Jan  7 09:49 root_token.key
-rw-------  1 vault vault   44 Jan  7 09:49 unseal_key_1.key
-rw-------  1 vault vault   44 Jan  7 09:49 unseal_key_2.key
-rw-------  1 vault vault   44 Jan  7 09:50 unseal_key_3.key
-rw-------  1 vault vault   44 Jan  7 09:50 unseal_key_4.key
-rw-------  1 vault vault   44 Jan  7 09:50 unseal_key_5.key
```
Распечатываем хранилище пока вручную. Для этого надо 3 раза выполнить команду и ввести три разных ключа:
```
root@MyPC:/etc/vault.d# vault operator unseal
Unseal Key (will be hidden):
Key                Value
---                -----
Seal Type          shamir
Initialized        true
Sealed             true
Total Shares       5
Threshold          3
Unseal Progress    1/3
Unseal Nonce       f5e4f35f-026c-338b-b263-8d94b7c507c9
Version            1.9.2
Storage Type       file
HA Enabled         false

root@MyPC:/etc/vault.d# vault operator unseal
Unseal Key (will be hidden):
Key                Value
---                -----
Seal Type          shamir
Initialized        true
Sealed             true
Total Shares       5
Threshold          3
Unseal Progress    2/3
Unseal Nonce       f5e4f35f-026c-338b-b263-8d94b7c507c9
Version            1.9.2
Storage Type       file
HA Enabled         false

root@MyPC:/etc/vault.d# vault operator unseal
Unseal Key (will be hidden):
Key             Value
---             -----
Seal Type       shamir
Initialized     true
Sealed          false
Total Shares    5
Threshold       3
Version         1.9.2
Storage Type    file
Cluster Name    vault-cluster-bbcc10c7
Cluster ID      5618ba34-1e03-641d-9dca-fa292bf81084
HA Enabled      false
```
Теперь Sealed false .
Cервер vault готов к работе.

Теперь надо залогиниться на сервер, используя Initial_Root_Token, который тоже был выдан при инициализации вместе с ключами, и можно начать работать с ним:
```
root@MyPC/vault.d# vault login s.dJavAHw5BetgDWFaNAuC46Wy
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                s.dJavAHw5BetgDWFaNAuC46Wy
token_accessor       r1MOsWQFYGn2oJb3s9sKDFal
token_duration       ∞
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]
```

4.1 Включаем pki хранилище секретов для корневого CA:
```
user@Mypc:~$ vault secrets enable pki
Success! Enabled the pki secrets engine at: pki/
```
Настраиваем максимальное время жизни сертификатов, выпускаемых этим pki:
```
user@MyPC:~$ vault secrets tune -max-lease-ttl=87600h pki
Success! Tuned the secrets engine at: pki/
```
Выпускаем корневой CA сертификат:
```
user@MyPC:~$ vault write -field=certificate pki/root/generate/internal \
     common_name="example.com" \
     ttl=87600h > CA_cert.crt
user@MyPC:~$ ls
CA_cert.crt
```
Конфигурируем pki urls:
```
user@MyPC:~$ vault write pki/config/urls \
     issuing_certificates="$VAULT_ADDR/v1/pki/ca" \
     crl_distribution_points="$VAULT_ADDR/v1/pki/crl"
Success! Data written to: pki/config/urls
```

4.2 Теперь создаём промежуточный центр сертификации:
```
user@MyPC:~$ vault secrets enable -path=pki_int pki
Success! Enabled the pki secrets engine at: pki_int/
```
Настраиваем максимальное время жизни для сертификатов в pki_int:
```
user@MyPC:~$ vault secrets tune -max-lease-ttl=43800h pki_int
Success! Tuned the secrets engine at: pki_int/
```
Создаём сертификат промежуточного центра сертификации и сохраняем его в pki_intermediate.csr
```
user@MyPC:~$ vault write -format=json pki_int/intermediate/generate/internal \
     common_name="example.com Intermediate Authority" \
     | jq -r '.data.csr' > pki_intermediate.csr
```
Подписываем сертификат промежуточного цс с помощью корневого CA и сохраняем его в intermediate.cert.pem:
```
user@MyPC:~$ vault write -format=json pki/root/sign-intermediate csr=@pki_intermediate.csr \
     format=pem_bundle ttl="43800h" \
     | jq -r '.data.certificate' > intermediate.cert.pem
user@MyPC:~$ ls
CA_cert.crt  intermediate.cert.pem  pki_intermediate.csr
```
Импортируем подписанный сертификат промежуточного цс в vault:
```
user@MyPC:~$ vault write pki_int/intermediate/set-signed certificate=@intermediate.cert.pem
Success! Data written to: pki_int/intermediate/set-signed
```

4.3 Создаём роль.
```
user@MyPC:~$ vault write pki_int/roles/example-dot-com \
     allowed_domains="example.com" \
     allow_subdomains=true \
     max_ttl="720h"
Success! Data written to: pki_int/roles/example-dot-com
```

4.4 Запрашиваем генерацию сертификата для веб-сервера для домена test.example.com
```
user@MyPC:~$ vault write pki_int/issue/example-dot-com common_name="test.example.com" ttl="720h"
Key                 Value
---                 -----
ca_chain            [-----BEGIN CERTIFICATE-----
MIIDpjCCAo6gAwIBAgIUDQxMDQzNDBaFw0yMjAyMDMxMDQ0MTBaMBsxGTAXBgNVBAMTEHRl
c3QuZXhhbXBsZS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC2
ybao6x9PuQb00sKILoPA8cIB...
-----END CERTIFICATE-----]
certificate         -----BEGIN CERTIFICATE-----
MIIDZjCCAk6gAwIBAgIUDo6BKm29ZmVMxwnEz8wSZHurc2AwDQYJKoZIhvcNAQEL
BQAwLTErMCkGA1UEAxMiZXhhb...
-----END CERTIFICATE-----
expiration          1643885050
issuing_ca          -----BEGIN CERTIFICATE-----
MIIDpjCCAo6gAwIBAgIUcnvFwyd/jXuWtysR5kyWJ4uK15IwDQYJKoZIhvcNAQEL
BQAwFjEUMBIGA1UEAxMLZXhh...
-----END CERTIFICATE-----
private_key         -----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAtsm2qOsfT7kG9NLCiC6DwPHCAQdxDSwA2lpwkhAmU06/AcH5
k2G4raLrLrqiyAMqnVkNtCgQ...
-----END RSA PRIVATE KEY-----
private_key_type    rsa
serial_number       0e:8e:81:2a:6d:bd:66:65:4c:c7:09:c4:cf:cc:12:64:7b:ab:73:60
```
Хочется сразу отметить, что при использовании команды vault write если добавить ключ -format=json то вывод результата будет ф формате json, например так:
```
root@MyPC:~# vault write -format=json pki_int/issue/example-dot-com common_name="test.example.com" ttl="720h"
{
  "request_id": "76a837a7-8f3a-5cd3-4b88-28a065671f64",
  "lease_id": "",
  "lease_duration": 0,
  "renewable": false,
  "data": {
    "ca_chain": [
      "-----BEGIN CERTIFICATE-----\nMIIDpjCCAo6gAwIBAgIUZpGi9YfQKrx5J02vcMd84kclAIcwDQYJKoZIhvcNAQEL\nBQAwFjEUMBIGA1UEAxMLZXhhbXBsZS5jb20wHhcNMjIwMTA2MDcyNTQ4WhcNMjcw\nMTA1MDcyNjE4WjAtMSswKQYDVQQDEyJleGFtcGxlLmNvbSBJbnRlcm1lZGlhdGUg\nQXV0aG9yaXR5MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5a8Odygy\nnLnT0uJnPL1BioJfIZQ1oDWh2UkLfRS95wBWiSd4NgbjLlc7AgTmnC2PtgQD67UL\n+xcOGcb3i+GwBbO/WMZ4gxoS5dnw/x3h7jcFCjJzVgWfpKOV5WjImnTXMsbHZL1Y\namJlMAhfgBQJZZ4wqWESRTRKniRuRM6PYD4pRUn9Cop+lL1w1B/3C8AwKZxp/GNM\nokIa0BwtZ9gvx2wzRXV5+619t22NYgL7uIPhjnnMjtwFQtjarhRff0ZKllZKNg21\n9uuKTi2DYA3IQjfi2dmSE2Xxsz5E8xQeRt3zJKc1S6kHVbjgNpmedUKRQ6w+7GCh\nAXfEs5al2pOLKQIDAQABo4HUMIHRMA4GA1UdDwEB/wQEAwIBBjAPBgNVHRMBAf8E\nBTADAQH/MB0GA1UdDgQWBBRxq3kCtelo9DzYFyoT+Xh9jM2SYTAfBgNVHSMEGDAW\ngBQMoTsFBPJ0tQ0hgpgIwIcSVdYKeTA7BggrBgEFBQcBAQQvMC0wKwYIKwYBBQUH\nMAKGH2h0dHA6Ly8xMjcuMC4wLjE6ODIwMC92MS9wa2kvY2EwMQYDVR0fBCowKDAm\noCSgIoYgaHR0cDovLzEyNy4wLjAuMTo4MjAwL3YxL3BraS9jcmwwDQYJKoZIhvcN\nAQELBQADggEBAGAgYy0BtupE8aCHSzujF+GborFHkSObRyNkKqcMAw9x+Z2GgiwR\n0WBM5djsmWlq06IoGIG4gXI+sTHybUejpgqBHZLgyzacUNqbtkgn4MhSDW5JV/Z+\nZtab2NAsih+6xLA8rA62f7ZAmNnvH098HzV+yLVTJeY2j/jyPRvno5GYXKVaYpFo\nkVhsUgD5JdRcqHvXgN6fHDIn3ehSsFeYfukErxgVdaileOhSRMhEIs9N7N/94jSP\nxg0lo5Qh+OD0e842t0BwQT19tUAdMEcaDbQsH8PeJh8AAko5DzDY0k+Rb4zrkbRj\n5R0QOuK+2+lwT1PDa2YxF095T78Mbtgvn9o=\n-----END CERTIFICATE-----"
    ],
    "certificate": "-----BEGIN CERTIFICATE-----\nMIIDZjCCAk6gAwIBAgIUD47SMApLNEPr9McP8PYYW4AAOswwDQYJKoZIhvcNAQEL\nBQAwLTErMCkGA1UEAxMiZXhhbXBsZS5jb20gSW50ZXJtZWRpYXRlIEF1dGhvcml0\neTAeFw0yMjAxMDYwNzI3MDlaFw0yMjAyMDUwNzI3MzlaMBsxGTAXBgNVBAMTEHRl\nc3QuZXhhbXBsZS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDH\nHpGBju/LrW3O8z6qg25ImAJMB7gT5fhDZHAUnTkWb3hFWGTWjsxozZoJZYTqtQ7u\nW3SEGWpUdpsZ5AdHP1ARZljfHh9mixtlLI0F8bO39B4GIQERWXKnQvZqgh+nDrIM\nvxh55t3B6fR+cioef8wU83ZOtPPETPKu4ijQlE5UoLfZUbIynWQHhBgPR/ZPmVYG\njkvQoFQIRrpgV2oENY6SOTBnw1MV7tpMNfEfZYooP9nw7iZE2xGmkTat21G1HQQ7\nTTrXMGd/J0li6QuCJ2/adjoNGvXtKV1YJHpuveEt1zdLZ2uzIXGWLwYdEi3Dm1YT\nGa1t++VfHa6eZonZflUXAgMBAAGjgY8wgYwwDgYDVR0PAQH/BAQDAgOoMB0GA1Ud\nJQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjAdBgNVHQ4EFgQUJuu3UggCpJBeJTaF\nKYy+AqJzgWUwHwYDVR0jBBgwFoAUcat5ArXpaPQ82BcqE/l4fYzNkmEwGwYDVR0R\nBBQwEoIQdGVzdC5leGFtcGxlLmNvbTANBgkqhkiG9w0BAQsFAAOCAQEAetIauW57\nkXcIZZqSY+17GY/OV6ptmO47B9jXuov56j69xVIONsJcVmNO63oXUyDHlfdcmyiN\nHKu4Y6WOHBOg0duqODu5P6m98v4bGbtJ8bgrjKMyhQ4G6DaFxVD1xVuy4D8Kk0ct\nHw3DHlseDEZQ4WXd82jgOMMhTsbEcjXXUqJL3H6TiTYmfM0zliww2Q77YICMGXnG\nTdl1FnLKyw8iLY4lySRHUxdvhdVQsLoevXS705wTHd4y8RZKH6J8nTXHwFGObKIT\nuTfmKLDNgvk1Le2H5iFv4IZmAF7c7KyUA8CN7ezJOk1ZvaiOTraPHRjwAjDlDxoS\nNhotcb6tVh7Hgw==\n-----END CERTIFICATE-----",
    "expiration": 1644046059,
    "issuing_ca": "-----BEGIN CERTIFICATE-----\nMIIDpjCCAo6gAwIBAgIUZpGi9YfQKrx5J02vcMd84kclAIcwDQYJKoZIhvcNAQEL\nBQAwFjEUMBIGA1UEAxMLZXhhbXBsZS5jb20wHhcNMjIwMTA2MDcyNTQ4WhcNMjcw\nMTA1MDcyNjE4WjAtMSswKQYDVQQDEyJleGFtcGxlLmNvbSBJbnRlcm1lZGlhdGUg\nQXV0aG9yaXR5MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5a8Odygy\nnLnT0uJnPL1BioJfIZQ1oDWh2UkLfRS95wBWiSd4NgbjLlc7AgTmnC2PtgQD67UL\n+xcOGcb3i+GwBbO/WMZ4gxoS5dnw/x3h7jcFCjJzVgWfpKOV5WjImnTXMsbHZL1Y\namJlMAhfgBQJZZ4wqWESRTRKniRuRM6PYD4pRUn9Cop+lL1w1B/3C8AwKZxp/GNM\nokIa0BwtZ9gvx2wzRXV5+619t22NYgL7uIPhjnnMjtwFQtjarhRff0ZKllZKNg21\n9uuKTi2DYA3IQjfi2dmSE2Xxsz5E8xQeRt3zJKc1S6kHVbjgNpmedUKRQ6w+7GCh\nAXfEs5al2pOLKQIDAQABo4HUMIHRMA4GA1UdDwEB/wQEAwIBBjAPBgNVHRMBAf8E\nBTADAQH/MB0GA1UdDgQWBBRxq3kCtelo9DzYFyoT+Xh9jM2SYTAfBgNVHSMEGDAW\ngBQMoTsFBPJ0tQ0hgpgIwIcSVdYKeTA7BggrBgEFBQcBAQQvMC0wKwYIKwYBBQUH\nMAKGH2h0dHA6Ly8xMjcuMC4wLjE6ODIwMC92MS9wa2kvY2EwMQYDVR0fBCowKDAm\noCSgIoYgaHR0cDovLzEyNy4wLjAuMTo4MjAwL3YxL3BraS9jcmwwDQYJKoZIhvcN\nAQELBQADggEBAGAgYy0BtupE8aCHSzujF+GborFHkSObRyNkKqcMAw9x+Z2GgiwR\n0WBM5djsmWlq06IoGIG4gXI+sTHybUejpgqBHZLgyzacUNqbtkgn4MhSDW5JV/Z+\nZtab2NAsih+6xLA8rA62f7ZAmNnvH098HzV+yLVTJeY2j/jyPRvno5GYXKVaYpFo\nkVhsUgD5JdRcqHvXgN6fHDIn3ehSsFeYfukErxgVdaileOhSRMhEIs9N7N/94jSP\nxg0lo5Qh+OD0e842t0BwQT19tUAdMEcaDbQsH8PeJh8AAko5DzDY0k+Rb4zrkbRj\n5R0QOuK+2+lwT1PDa2YxF095T78Mbtgvn9o=\n-----END CERTIFICATE-----",
    "private_key": "-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEAxx6RgY7vy61tzvM+qoNuSJgCTAe4E+X4Q2RwFJ05Fm94RVhk\n1o7MaM2aCWWE6rUO7lt0hBlqVHabGeQHRz9QEWZY3x4fZosbZSyNBfGzt/QeBiEB\nEVlyp0L2aoIfpw6yDL8Yeebdwen0fnIqHn/MFPN2TrTzxEzyruIo0JROVKC32VGy\nMp1kB4QYD0f2T5lWBo5L0KBUCEa6YFdqBDWOkjkwZ8NTFe7aTDXxH2WKKD/Z8O4m\nRNsRppE2rdtRtR0EO0061zBnfydJYukLgidv2nY6DRr17SldWCR6br3hLdc3S2dr\nsyFxli8GHRItw5tWExmtbfvlXx2unmaJ2X5VFwIDAQABAoIBACefRJMET2E3PH+O\n1ax2hM57ORHKA24qN9GpPchMVNzLB6K86SvstG4yY3F1OxK9PqBdoHzc1dTC2TA4\nuN4LkjI0LIERbGwqSCREzjcdloaHVCYiESVTqEXyRDiDdir2+KUirYssTnpUxKsY\nqprxETomDCezSEKKkUwNgtOmf0PFcZVuuj7Xu2d0ZEtEmCWletBVdIkx9f5qfV/2\n/9DB02LHKb1A2O/VJlaIiDWXnlHtJ47yGf6ggwzaiWStKaHv58y514Dr5TnXto4v\ne0Ac+5+B7jtEaGTU30W7mTIdQjqyPL9vhzsZ046A4jlIwtCiWjo26kHFMAdfyO8+\nz5xoVGkCgYEA4aMpyKAjU4opshhY9+d91b50xcPccwAG2ZtLCwwe1lbEdj5AA9KG\n3GvWnbLnTJQS12k2y9X235gvUT5UlQFxI72gdKEQCNmP5q630YhX332DR3Rg2B9K\nBMJpE03unFefoo+5QLrvJDABvDMif6tPk0OekrLql0YoxTBvKz40dcsCgYEA4enn\nxD5cauxY7lLxhJhn0Kby0Kb4x3xVjdeNbO5b7wJDCFJ9W536qqtfct6HjAzpvyMT\n7m6bS2lWkIy0r5EwmmrqT6D8ipW2KIByIrjFTWnu98FohP8ZqniVXEw+J31/iYzb\nPuvZDLXjJmsz5MwMVn+aHHbh69YZZg/2GK3IFGUCgYAnGdxazQ1yI6Y4G6oHQ9F1\noeygfOGN+Do3qYamonIRmLWw+/ah8vC17+YgK+mTRrHBLJV3W1vNwZSpkpCbxcUy\neWD99Q9PSUx7oFlwcR0xOJHwZwWFTl7IVlxZIQ8xfqnGRPvIcNySO9OBJqda0ngW\nwAgRyfmHP3w/N7Z8GuqCYwKBgQCFtdCEWTiP3GViYVsrVJ0VZMqQblMOlut4MV02\nXPmyw87y7QffIujK/PVYYpctcDMk+tkAJRzrDGS811rWEwQGUUNvb+QpDiUrYaKs\nJFo60Hks0J9RID+LoyUb5NBgxSmoOuNFIYhsunbANXEYeSDQTWPkdwSOdkDAJLBO\nuQST9QKBgQCQ98CLEy7QgDLP3lJxWnKal8n2GkDi+TqfjLTGkPWXB9qtHZAFNRVc\no/f1umu5/FuGOY8CpbT0ufLmrvxiSPvCRNIujqUYRIK1AriAL1TmAtKAthqSs9bf\nNjWo9arqUPWFJBy04Hy2+2fseA06kaz9TqnsWwrROt3+EwKC2rnlkQ==\n-----END RSA PRIVATE KEY-----",
    "private_key_type": "rsa",
    "serial_number": "0f:8e:d2:30:0a:4b:34:43:eb:f4:c7:0f:f0:f6:18:5b:80:00:3a:cc"
  },
  "warnings": null
}
```
Поэтому будем использовать это, чтобы вывести сгенерированный сертификат и ключ в отдельные файлы.

Cкрипт regenerate_certs.sh:
```bash
#!/usr/bin/env bash

export VAULT_ADDR=http://127.0.0.1:8200

ROOT_TOKEN=`cat /vault_keys/root_token.key`
vault login $ROOT_TOKEN

echo Zapros Certificate for test.example.com

json_cert=`vault write -format=json pki_int/issue/example-dot-com common_name="test.example.com" ttl="720h"`

echo Poluchena JSON struktuta
echo $json_cert

echo Izvlekaem Certificate
echo $json_cert | jq -r '.data.certificate' > /vault_certificates_for_nginx/test.example.com.crt
echo $json_cert | jq -r '.data.issuing_ca' >> /vault_certificates_for_nginx/test.example.com.crt

echo Izvlekaem Private key
echo $json_cert | jq -r '.data.private_key' > /vault_certificates_for_nginx/test.example.com.key

echo Restart Nginx
systemctl restart nginx
```
Скрипт логиниться на vault (используя токен из файла) запрашивать у vault новый сертификат для домена test.example.com, затем при помощи утилиты jq будет выгружать полученный сертификат, а также сертификат промежуточного ЦС в файл test.example.com.crt и ключ в файл test.example.com.key. Файлы будут создаваться в папке /vault_certificates_for_nginx.

5. Устанавливаем корневой сертификат созданного центра сертификации в доверенные в хостовой системе. Для этого на компьютер, с которого мы планируем заходить на наш веб-сервер, мы копируем файл CA_cert.crt, содержащий корневой сертификат нашего ЦС. Затем устанавливаем сертификат в раздел Доверенные корневые центры сертификации.

6. Устанавливаем nginx.
Проверяем, что он запустился:
```
user@MyPC:~$ systemctl nginx status
Unknown command verb nginx.
user@MyPC:~$ systemctl status nginx
● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
     Active: active (running) since Tue 2022-01-11 12:31:21 UTC; 3min 38s ago
       Docs: man:nginx(8)
    Process: 70929 ExecStartPre=/usr/sbin/nginx -t -q -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
    Process: 70930 ExecStart=/usr/sbin/nginx -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
   Main PID: 71025 (nginx)
      Tasks: 3 (limit: 4627)
     Memory: 3.8M
        CPU: 29ms
     CGroup: /system.slice/nginx.service
             ├─71025 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
             ├─71028 nginx: worker process
             └─71029 nginx: worker process

Jan 11 12:31:21 MyPC systemd[1]: Starting A high performance web server and a reverse proxy server...
Jan 11 12:31:21 MyPC systemd[1]: Started A high performance web server and a reverse proxy server.
```
Проверяем, какие порты слушает nginx с дефолтными настройками:
```
user@MyPC:~$ sudo netstat -apn | grep nginx
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      71025/nginx: master
tcp6       0      0 :::80                   :::*                    LISTEN      71025/nginx: master
unix  3      [ ]         STREAM     CONNECTED     198285   71025/nginx: master
unix  3      [ ]         STREAM     CONNECTED     198282   71025/nginx: master
unix  3      [ ]         STREAM     CONNECTED     198283   71025/nginx: master
unix  3      [ ]         STREAM     CONNECTED     198284   71025/nginx: master
```

Видим, что пока-что только 80 порт, то есть http. Далее мы перенастроим его на работу по https на порту 443.

Временно откроем фаервол на пропуск входящих соединений на порт 80:
```
user@MyPC:~$ sudo ufw allow 80/tcp
Rule added
Rule added (v6)
```
На Компьютере с которого мы будем пробовать открывать веб на этом сервере пропишем запись в файл hosts: 10.20.8.78 test.example.com

![1](img_1.png)

Открывается по http через 80й порт.

7. Перенастраиваем на 443 / https.
Открываем конфиг ```/etc/nginx/nginx.conf``` и в разделе http вписываем настройку сервера, указывая пути к файлу сертификата и ключа:
```
server {
    listen              443 ssl;
    server_name         test.example.com;
    ssl_certificate     /vault_certificates_for_nginx/test.example.com.crt;
    ssl_certificate_key /vault_certificates_for_nginx/test.example.com.key;
    ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers         HIGH:!aNULL:!MD5;
}
```
Перезапускаем nginx и видим, что теперь порт 443 уже прослушивается:
```
root@MyPC:/etc/nginx# sudo netstat -apn | grep nginx
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      150431/nginx: maste
tcp        0      0 0.0.0.0:443             0.0.0.0:*               LISTEN      150431/nginx: maste
tcp6       0      0 :::80                   :::*                    LISTEN      150431/nginx: maste
unix  3      [ ]         STREAM     CONNECTED     682513   150431/nginx: maste
unix  3      [ ]         STREAM     CONNECTED     682514   150431/nginx: maste
unix  3      [ ]         STREAM     CONNECTED     682515   150431/nginx: maste
unix  3      [ ]         STREAM     CONNECTED     682512   150431/nginx: maste
```

8. Открываем https://test.example.com/  браузер не ругается и проверяем корректность сертификата и его путь сертификации.
![2](img_2.png)

9. скрипт создан ранее

10. Настраиваем автозапуск скрипта перегенерации сертификатов с помощью Cron Для этого открываем файл /etc/ctontab и добавляем туда строчку:
```
57 0 11 * * root /vault_scripts/regenerate_certs.sh >> /var/log/regenerate_certs.log
```
запускает скрипт regenerate_certs.sh каждый месяц 11 числа в 0:57.

Для проверки авто генерации сертификатов мы удалим содержимое папки /vault_certificates_for_nginx

Перезапускаем cron:
```
root@MyPC:/etc# systemctl restart cron
```
Проверим статус cron
```
root@MyPC:/etc# systemctl status cron
● cron.service - Regular background program processing daemon
     Loaded: loaded (/lib/systemd/system/cron.service; enabled; vendor preset: enabled)
     Active: active (running) since Tue 2022-01-13 00:55:42 MSK; 1min 18s ago
       Docs: man:cron(8)
   Main PID: 3421 (cron)
      Tasks: 1 (limit: 4627)
     Memory: 344.0K
        CPU: 3ms
     CGroup: /system.slice/cron.service
             └─3421 /usr/sbin/cron -f -P

Jan 13 00:55:42 MyPC systemd[1]: Started Regular background program processing daemon.
Jan 13 00:55:42 MyPC cron[3421]: (CRON) INFO (pidfile fd = 3)
Jan 13 00:55:42 MyPC cron[3421]: (CRON) INFO (Skipping @reboot jobs -- not system startup)
```
Проверим статус крона после ожидаемого времени запуска скрипта:
```
root@MyPC:/etc# systemctl status cron
● cron.service - Regular background program processing daemon
     Loaded: loaded (/lib/systemd/system/cron.service; enabled; vendor preset: enabled)
     Active: active (running) since Tue 2022-01-13 00:55:42 MSK; 1min 23s ago
       Docs: man:cron(8)
   Main PID: 3421 (cron)
      Tasks: 1 (limit: 4627)
     Memory: 368.0K
        CPU: 276ms
     CGroup: /system.slice/cron.service
             └─3421 /usr/sbin/cron -f -P

Jan 13 00:55:42 MyPC systemd[1]: Started Regular background program processing daemon.
Jan 13 00:55:42 MyPC cron[3421]: (CRON) INFO (pidfile fd = 3)
Jan 13 00:55:42 MyPC cron[3421]: (CRON) INFO (Skipping @reboot jobs -- not system startup)
Jan 13 00:57:01 MyPC CRON[3470]: pam_unix(cron:session): session opened for user root by (uid=0)
Jan 13 00:57:01 MyPC CRON[3471]: (root) CMD (/vault_scripts/regenerate_certs.sh >> /var/log/regenerate_certs.log)
Jan 13 00:57:02 MyPC CRON[3470]: pam_unix(cron:session): session closed for user root
```
Видим, что скрипт запускался в назначенное время. Проверяем, что сертификат и ключ создались:
```
root@MyPC:/etc# ll /vault_certificates_for_nginx/
total 16
drwxrwxrwx  2 vault vault 4096 Jan 13 00:48 ./
drwxr-xr-x 24 root  root  4096 Jan 13 00:32 ../
-rw-r--r--  1 root  root  2567 Jan 13 00:57 test.example.com.crt
-rw-r--r--  1 root  root  1679 Jan 13 00:57 test.example.com.key
```
Проверяем, что nginx перезапустился сриптом в то же время:

```
root@MyPC:/etc# systemctl status nginx
● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
     Active: active (running) since Tue 2022-01-13 00:57:02 MSK; 14min ago
       Docs: man:nginx(8)
    Process: 3493 ExecStartPre=/usr/sbin/nginx -t -q -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
    Process: 3494 ExecStart=/usr/sbin/nginx -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
   Main PID: 3495 (nginx)
      Tasks: 3 (limit: 4627)
     Memory: 3.3M
        CPU: 43ms
     CGroup: /system.slice/nginx.service
             ├─3495 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
             ├─3496 nginx: worker process
             └─3497 nginx: worker process

Jan 13 00:57:02 MyPC systemd[1]: Starting A high performance web server and a reverse proxy server...
Jan 13 00:57:02 MyPC systemd[1]: Started A high performance web server and a reverse proxy server.
```

Проверяем, что страничка открывается без ошибок и сертификат именно этот:
![3](img_4.png)


11. Автозапуск vault. Возможно в продакшн-среде сервер vault должен всё-таки запускаться, останавливаться, а главное распечатываться только вручную, обдуманными действиями персонала, но мы на всякий случай предусмотрим автоматизацию на случай внезапной перезагрузки сервера. Для автоматического запуска vault воспользуемся systemd.
```
sudo systemctl enable vault.service
```
Unit-файл находится тут ```/lib/systemd/system/vault.service```. Допишем сюда строку ```ExecStartPost=/vault_scripts/unseal_vault.sh```, чтобы после успешного запуска Vault, запускался наш скрипт распечатывания vault.
```
root@MyPC:/lib/systemd/system# cat /lib/systemd/system/vault.service
[Unit]
Description="HashiCorp Vault - A tool for managing secrets"
Documentation=https://www.vaultproject.io/docs/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/vault.d/vault.hcl
StartLimitIntervalSec=60
StartLimitBurst=3

[Service]
EnvironmentFile=/etc/vault.d/vault.env
User=vault
Group=vault
ProtectSystem=full
ProtectHome=read-only
PrivateTmp=yes
PrivateDevices=yes
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=/usr/bin/vault server -config=/etc/vault.d/vault.hcl
ExecStartPost=/vault_scripts/unseal_vault.sh
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
KillSignal=SIGINT
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
LimitNOFILE=65536
LimitMEMLOCK=infinity

[Install]
WantedBy=multi-user.target
```

```
root@MyPC:/home/user# cat /vault_scripts/unseal_vault.sh
#!/usr/bin/env bash
sleep 15

UNSEAL_KEY1=`cat /vault_keys/unseal_key_1.key`
UNSEAL_KEY2=`cat /vault_keys/unseal_key_2.key`
UNSEAL_KEY3=`cat /vault_keys/unseal_key_3.key`
UNSEAL_KEY4=`cat /vault_keys/unseal_key_4.key`
UNSEAL_KEY5=`cat /vault_keys/unseal_key_5.key`

export VAULT_ADDR=http://127.0.0.1:8200

echo Pitaemsya unseal vault
vault operator unseal $UNSEAL_KEY1 &&
vault operator unseal $UNSEAL_KEY2 &&
vault operator unseal $UNSEAL_KEY3
```
создание переменной окружения в файл ```/etc/environment```, чтобы после перезапуска она появилась:
```
root@MyPC:/etc# echo VAULT_ADDR=http://127.0.0.1:8200 >> /etc/environment
```
Перезапускаем сервер. Смотрим состояние vault:
```
root@MyPC:/home/user# systemctl status vault
● vault.service - "HashiCorp Vault - A tool for managing secrets"
     Loaded: loaded (/lib/systemd/system/vault.service; enabled; vendor preset: enabled)
     Active: active (running) since Tue 2022-01-13 02:09:27 MSK; 1min 44s ago
       Docs: https://www.vaultproject.io/docs/
    Process: 942 ExecStartPost=/vault_scripts/unseal_vault.sh (code=exited, status=0/SUCCESS)
   Main PID: 941 (vault)
      Tasks: 8 (limit: 4627)
     Memory: 193.4M
        CPU: 1.556s
     CGroup: /system.slice/vault.service
             └─941 /usr/bin/vault server -config=/etc/vault.d/vault.hcl

Jan 13 02:09:27 MyPC unseal_vault.sh[1453]: Initialized     true
Jan 13 02:09:27 MyPC unseal_vault.sh[1453]: Sealed          false
Jan 13 02:09:27 MyPC unseal_vault.sh[1453]: Total Shares    5
Jan 13 02:09:27 MyPC unseal_vault.sh[1453]: Threshold       3
Jan 13 02:09:27 MyPC unseal_vault.sh[1453]: Version         1.9.2
Jan 13 02:09:27 MyPC unseal_vault.sh[1453]: Storage Type    file
Jan 13 02:09:27 MyPC unseal_vault.sh[1453]: Cluster Name    vault-cluster-bbcc10c7
Jan 13 02:09:27 MyPC unseal_vault.sh[1453]: Cluster ID      5618ba34-1e03-641d-9dca-fa292bf81084
Jan 13 02:09:27 MyPC unseal_vault.sh[1453]: HA Enabled      false
Jan 13 02:09:27 MyPC systemd[1]: Started "HashiCorp Vault - A tool for managing secrets".


root@MyPC:/home/user# vault status
Key             Value
---             -----
Seal Type       shamir
Initialized     true
Sealed          false
Total Shares    5
Threshold       3
Version         1.9.2
Storage Type    file
Cluster Name    vault-cluster-bbcc10c7
Cluster ID      5618ba34-1e03-641d-9dca-fa292bf81084
HA Enabled      false
```
Cкрипты отработали и vault не только перезапустился, но и распечатался Sealed false.

#Итоги. Vault установлен. Настроен на автоматический запуск при перезапуске сервера, также происходит распечатка его хранилища. Настроена перегенерация сертификатов для nginx в определённое время. Сайт test.example.com открывается без ошибок.

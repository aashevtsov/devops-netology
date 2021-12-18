1.
 Установил приложение.
 Зарегистрировался в их системе.
 Установил приложение также для телефона.
 Сохранил пароль от bitbucket.
 Вижу его и в плагине на компьютере и в мобильном приложении.

2.
 Включил двухфакторную аутентификацию.
 Подключил Google Authenticator. 
 При входе в плагин с нового устройства запрашивается OTP.

3.
 Устанвливаю apache2<br>
 Генерирую сертификат 
 ```
sudo openssl req -new -x509 -days 1461 -nodes -out cert.pem -keyout cert.key -subj "/C=RU/ST=SPb/L=SPb/O=Global Security/OU=IT Department/CN=test.dmosk.local/CN=test"
```
 По ссылке https://ssl-cionfig.mozilla.org/#server=apache&version=2.4.41&config=intermediate&openssl=1.1.1k&guideline=5.6 генерирую кусок конфига и исправляю пути к сертификату и ключу.
```
# generated 2021-12-08, Mozilla Guideline v5.6, Apache 2.4.41, OpenSSL 1.1.1k, intermediate configuration
# https://ssl-config.mozilla.org/#server=apache&version=2.4.41&config=intermediate&openssl=1.1.1k&guideline=5.6

# this configuration requires mod_ssl, mod_socache_shmcb, mod_rewrite, and mod_headers
<VirtualHost *:80>
    RewriteEngine On
    RewriteCond %{REQUEST_URI} !^/\.well\-known/acme\-challenge/
    RewriteRule ^(.*)$ https://%{HTTP_HOST}$1 [R=301,L]
</VirtualHost>

<VirtualHost *:443>
    SSLEngine on

#   curl https://ssl-config.mozilla.org/ffdhe2048.txt >> /path/to/signed_cert_and_intermediate_certs_and_dhparams
    SSLCertificateFile      /etc/ssl/certs/apache-selfsigned.crt
    SSLCertificateKeyFile   /etc/ssl/private/apache-selfsigned.key

# enable HTTP/2, if available
    Protocols h2 http/1.1

# HTTP Strict Transport Security (mod_headers is required) (63072000 seconds)
    Header always set Strict-Transport-Security "max-age=63072000"
</VirtualHost>

# intermediate configuration
    SSLProtocol             all -SSLv3 -TLSv1 -TLSv1.1
    SSLCipherSuite          ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHA
CHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
    SSLHonorCipherOrder     off
    SSLSessionTickets       off

    SSLUseStapling On
    SSLStaplingCache "shmcb:logs/ssl_stapling(32768)"
```
 Проверяем корректность
 ```
 ~  apachectl configtest   
AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 127.0.1.1. Set the 'ServerName' directive globally to suppress this message
Syntax OK
 ~  

 ```
У себя, в файле hosts направляю домен example.com на адрес сервера.


4.

git clone --depth 1 https://github.com/drwetter/testssl.sh.git<br>
cd testssl.sh<br>
./testssl.sh https://pikabu.ru/<br>

<details>
<summary>testssl.sh</summary>

```
###########################################################
    testssl.sh       3.1dev from https://testssl.sh/dev/
    (2201a28 2021-12-13 18:24:34 -- )

      This program is free software. Distribution and
             modification under GPLv2 permitted.
      USAGE w/o ANY WARRANTY. USE IT AT YOUR OWN RISK!

       Please file bugs @ https://testssl.sh/bugs/

###########################################################

 Using "OpenSSL 1.0.2-chacha (1.0.2k-dev)" [~183 ciphers]
 on MyPC:./bin/openssl.Linux.x86_64
 (built: "Jan 18 17:12:17 2019", platform: "linux-x86_64")


Testing all IPv4 addresses (port 443): 91.228.152.42 91.228.155.94 91.228.155.121 185.26.98.252 212.224.112.193 5.187.0.134 185.26.99.7 5.187.1.183
-----------------------------------------------------
 Start 2021-12-18 14:38:33        -->> 91.228.152.42:443 (pikabu.ru) <<--

 Further IP addresses:   91.228.155.94 91.228.155.121 185.26.98.252
                         212.224.112.193 5.187.0.134 185.26.99.7 5.187.1.183 
 rDNS (91.228.152.42):   dsde71.fornex.org.
 Service detected:       HTTP


 Testing protocols via sockets except NPN+ALPN 

 SSLv2      not offered (OK)
 SSLv3      not offered (OK)
 TLS 1      offered (deprecated)
 TLS 1.1    offered (deprecated)
 TLS 1.2    offered (OK)
 TLS 1.3    not offered and downgraded to a weaker protocol
 NPN/SPDY   h2, http/1.1 (advertised)
 ALPN/HTTP2 h2, http/1.1 (offered)

 Testing cipher categories 

 NULL ciphers (no encryption)                      not offered (OK)
 Anonymous NULL Ciphers (no authentication)        not offered (OK)
 Export ciphers (w/o ADH+NULL)                     not offered (OK)
 LOW: 64 Bit + DES, RC[2,4], MD5 (w/o export)      not offered (OK)
 Triple DES Ciphers / IDEA                         offered
 Obsoleted CBC ciphers (AES, ARIA etc.)            offered
 Strong encryption (AEAD ciphers) with no FS       offered (OK)
 Forward Secrecy strong encryption (AEAD ciphers)  offered (OK)


 Testing server's cipher preferences 

 Has server cipher order?     yes (OK)
 Negotiated protocol          TLSv1.2
 Negotiated cipher            ECDHE-RSA-AES128-GCM-SHA256, 256 bit ECDH (P-256)
 Cipher per protocol

Hexcode  Cipher Suite Name (OpenSSL)       KeyExch.   Encryption  Bits     Cipher Suite Name (IANA/RFC)
-----------------------------------------------------------------------------------------------------------------------------
SSLv2
 - 
SSLv3
 - 
TLSv1 (server order)
 xc013   ECDHE-RSA-AES128-SHA              ECDH 256   AES         128      TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA                 
 xc014   ECDHE-RSA-AES256-SHA              ECDH 256   AES         256      TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA                 
 x33     DHE-RSA-AES128-SHA                DH 4096    AES         128      TLS_DHE_RSA_WITH_AES_128_CBC_SHA                   
 x39     DHE-RSA-AES256-SHA                DH 4096    AES         256      TLS_DHE_RSA_WITH_AES_256_CBC_SHA                   
 xc012   ECDHE-RSA-DES-CBC3-SHA            ECDH 256   3DES        168      TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA                
 x16     EDH-RSA-DES-CBC3-SHA              DH 4096    3DES        168      TLS_DHE_RSA_WITH_3DES_EDE_CBC_SHA                  
 x2f     AES128-SHA                        RSA        AES         128      TLS_RSA_WITH_AES_128_CBC_SHA                       
 x35     AES256-SHA                        RSA        AES         256      TLS_RSA_WITH_AES_256_CBC_SHA                       
 x0a     DES-CBC3-SHA                      RSA        3DES        168      TLS_RSA_WITH_3DES_EDE_CBC_SHA                      
TLSv1.1 (server order)
 xc013   ECDHE-RSA-AES128-SHA              ECDH 256   AES         128      TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA                 
 xc014   ECDHE-RSA-AES256-SHA              ECDH 256   AES         256      TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA                 
 x33     DHE-RSA-AES128-SHA                DH 4096    AES         128      TLS_DHE_RSA_WITH_AES_128_CBC_SHA                   
 x39     DHE-RSA-AES256-SHA                DH 4096    AES         256      TLS_DHE_RSA_WITH_AES_256_CBC_SHA                   
 xc012   ECDHE-RSA-DES-CBC3-SHA            ECDH 256   3DES        168      TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA                
 x16     EDH-RSA-DES-CBC3-SHA              DH 4096    3DES        168      TLS_DHE_RSA_WITH_3DES_EDE_CBC_SHA                  
 x2f     AES128-SHA                        RSA        AES         128      TLS_RSA_WITH_AES_128_CBC_SHA                       
 x35     AES256-SHA                        RSA        AES         256      TLS_RSA_WITH_AES_256_CBC_SHA                       
 x0a     DES-CBC3-SHA                      RSA        3DES        168      TLS_RSA_WITH_3DES_EDE_CBC_SHA                      
TLSv1.2 (server order)
 xc02f   ECDHE-RSA-AES128-GCM-SHA256       ECDH 256   AESGCM      128      TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256              
 xc030   ECDHE-RSA-AES256-GCM-SHA384       ECDH 256   AESGCM      256      TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384              
 x9e     DHE-RSA-AES128-GCM-SHA256         DH 4096    AESGCM      128      TLS_DHE_RSA_WITH_AES_128_GCM_SHA256                
 x9f     DHE-RSA-AES256-GCM-SHA384         DH 4096    AESGCM      256      TLS_DHE_RSA_WITH_AES_256_GCM_SHA384                
 xc027   ECDHE-RSA-AES128-SHA256           ECDH 256   AES         128      TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256              
 xc028   ECDHE-RSA-AES256-SHA384           ECDH 256   AES         256      TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384              
 xc013   ECDHE-RSA-AES128-SHA              ECDH 256   AES         128      TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA                 
 xc014   ECDHE-RSA-AES256-SHA              ECDH 256   AES         256      TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA                 
 x67     DHE-RSA-AES128-SHA256             DH 4096    AES         128      TLS_DHE_RSA_WITH_AES_128_CBC_SHA256                
 x33     DHE-RSA-AES128-SHA                DH 4096    AES         128      TLS_DHE_RSA_WITH_AES_128_CBC_SHA                   
 x6b     DHE-RSA-AES256-SHA256             DH 4096    AES         256      TLS_DHE_RSA_WITH_AES_256_CBC_SHA256                
 x39     DHE-RSA-AES256-SHA                DH 4096    AES         256      TLS_DHE_RSA_WITH_AES_256_CBC_SHA                   
 xc012   ECDHE-RSA-DES-CBC3-SHA            ECDH 256   3DES        168      TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA                
 x16     EDH-RSA-DES-CBC3-SHA              DH 4096    3DES        168      TLS_DHE_RSA_WITH_3DES_EDE_CBC_SHA                  
 x9c     AES128-GCM-SHA256                 RSA        AESGCM      128      TLS_RSA_WITH_AES_128_GCM_SHA256                    
 x9d     AES256-GCM-SHA384                 RSA        AESGCM      256      TLS_RSA_WITH_AES_256_GCM_SHA384                    
 x3c     AES128-SHA256                     RSA        AES         128      TLS_RSA_WITH_AES_128_CBC_SHA256                    
 x3d     AES256-SHA256                     RSA        AES         256      TLS_RSA_WITH_AES_256_CBC_SHA256                    
 x2f     AES128-SHA                        RSA        AES         128      TLS_RSA_WITH_AES_128_CBC_SHA                       
 x35     AES256-SHA                        RSA        AES         256      TLS_RSA_WITH_AES_256_CBC_SHA                       
 x0a     DES-CBC3-SHA                      RSA        3DES        168      TLS_RSA_WITH_3DES_EDE_CBC_SHA                      
TLSv1.3
 - 


 Testing robust forward secrecy (FS) -- omitting Null Authentication/Encryption, 3DES, RC4 

 FS is offered (OK)           ECDHE-RSA-AES256-GCM-SHA384
                              ECDHE-RSA-AES256-SHA384 ECDHE-RSA-AES256-SHA
                              DHE-RSA-AES256-GCM-SHA384 DHE-RSA-AES256-SHA256
                              DHE-RSA-AES256-SHA ECDHE-RSA-AES128-GCM-SHA256
                              ECDHE-RSA-AES128-SHA256 ECDHE-RSA-AES128-SHA
                              DHE-RSA-AES128-GCM-SHA256 DHE-RSA-AES128-SHA256
                              DHE-RSA-AES128-SHA 
 Elliptic curves offered:     secp256k1 prime256v1 secp384r1 secp521r1 
 DH group offered:            Unknown DH group (4096 bits)

 Testing server defaults (Server Hello) 

 TLS extensions (standard)    "server name/#0" "renegotiation info/#65281"
                              "EC point formats/#11" "status request/#5"
                              "heartbeat/#15" "next protocol/#13172"
                              "application layer protocol negotiation/#16"
 Session Ticket RFC 5077 hint no -- no lifetime advertised
 SSL Session ID support       yes
 Session Resumption           Tickets no, ID: yes
 TLS clock skew               Random values, no fingerprinting possible 
 Client Authentication        none

  Server Certificate #1
   Signature Algorithm          SHA256 with RSA
   Server key size              RSA 4096 bits (exponent is 65537)
   Server key usage             Digital Signature, Key Encipherment
   Server extended key usage    TLS Web Server Authentication, TLS Web Client Authentication
   Serial                       03CEA33D902ED916B198CE73F89ECC1E0B60 (OK: length 18)
   Fingerprints                 SHA1 51BC2F95D994F1C66873BD84FACC4E631C1E95E4
                                SHA256 7AA2841953B89275086E52B3AF6B824B561270F6B23839EF18CAB71FAD07F7C2
   Common Name (CN)             pikabu.ru  (CN in response to request w/o SNI: *.pikabu.ru )
   subjectAltName (SAN)         pikabu.ru www.pikabu.ru 
   Trust (hostname)             Ok via SAN and CN (works w/o SNI)
   Chain of trust               Ok   
   EV cert (experimental)       no 
   Certificate Validity (UTC)   expires < 30 days (16) (2021-10-06 06:00 --> 2022-01-04 06:00)
   ETS/"eTLS", visibility info  not present
   Certificate Revocation List  --
   OCSP URI                     http://r3.o.lencr.org
   OCSP stapling                offered, not revoked
   OCSP must staple extension   --
   DNS CAA RR (experimental)    not offered
   Certificate Transparency     yes (certificate extension)
   Certificates provided        3
   Issuer                       R3 (Let's Encrypt from US)
   Intermediate cert validity   #1: ok > 40 days (2025-09-15 16:00). R3 <-- ISRG Root X1
                                  #2: ok > 40 days (2024-09-30 18:14). ISRG Root X1 <-- DST Root CA X3
   Intermediate Bad OCSP (exp.) Ok

  Server Certificate #2 (in response to request w/o SNI)
   Signature Algorithm          SHA256 with RSA
   Server key size              RSA 2048 bits (exponent is 65537)
   Server key usage             Digital Signature, Key Encipherment
   Server extended key usage    TLS Web Server Authentication, TLS Web Client Authentication
   Serial                       03E6BE4C457696AAB9DB7CC9AEAAE95E59CF (OK: length 18)
   Fingerprints                 SHA1 38D8E9AD564CF9BB77C40AA4D53FBDC739C7B47C
                                SHA256 01584215E3BE1DDEDE962623A08E290CB17B5D9EDFE9D8960C7F062BEAD06B9E
   Common Name (CN)             *.pikabu.ru 
   subjectAltName (SAN)         *.pikabu.ru pikabu.ru 
   Trust (hostname)             Ok via SAN
   Chain of trust               Ok   
   EV cert (experimental)       no 
   Certificate Validity (UTC)   49 >= 30 days (2021-11-08 06:25 --> 2022-02-06 06:25)
   ETS/"eTLS", visibility info  not present
   Certificate Revocation List  --
   OCSP URI                     http://r3.o.lencr.org
   OCSP stapling                offered, not revoked
   OCSP must staple extension   --
   DNS CAA RR (experimental)    not offered
   Certificate Transparency     yes (certificate extension)
   Certificates provided        3
   Issuer                       R3 (Let's Encrypt from US)
   Intermediate cert validity   #1: ok > 40 days (2025-09-15 16:00). R3 <-- ISRG Root X1
                                  #2: ok > 40 days (2024-09-30 18:14). ISRG Root X1 <-- DST Root CA X3
   Intermediate Bad OCSP (exp.) Ok


 Testing HTTP header response @ "/" 

 HTTP Status Code             200 OK
 HTTP clock skew              0 sec from localtime
 Strict Transport Security    365 days=31536000 s, just this domain
 Public Key Pinning           --
 Server banner                nginx
 Application banner           --
 Cookie(s)                    11 issued: 1/11 secure, 1/11 HttpOnly
 Security headers             X-Frame-Options: sameorigin
                              Cache-Control: no-cache
                              Pragma: no-cache
 Reverse Proxy banner         --


 Testing vulnerabilities 

 Heartbleed (CVE-2014-0160)                not vulnerable (OK), timed out
 CCS (CVE-2014-0224)                       not vulnerable (OK)
 Ticketbleed (CVE-2016-9244), experiment.  not vulnerable (OK), no session ticket extension
 ROBOT                                     not vulnerable (OK)
 Secure Renegotiation (RFC 5746)           supported (OK)
 Secure Client-Initiated Renegotiation     not vulnerable (OK)
 CRIME, TLS (CVE-2012-4929)                not vulnerable (OK)
 BREACH (CVE-2013-3587)                    potentially NOT ok, "gzip" HTTP compression detected. - only supplied "/" tested
                                           Can be ignored for static pages or if no secrets in the page
 POODLE, SSL (CVE-2014-3566)               not vulnerable (OK), no SSLv3 support
 TLS_FALLBACK_SCSV (RFC 7507)              Downgrade attack prevention supported (OK)
 SWEET32 (CVE-2016-2183, CVE-2016-6329)    VULNERABLE, uses 64 bit block ciphers
 FREAK (CVE-2015-0204)                     not vulnerable (OK)
 DROWN (CVE-2016-0800, CVE-2016-0703)      not vulnerable on this host and port (OK)
                                           make sure you don't use this certificate elsewhere with SSLv2 enabled services
                                           https://censys.io/ipv4?q=7AA2841953B89275086E52B3AF6B824B561270F6B23839EF18CAB71FAD07F7C2 could help you to find out
 LOGJAM (CVE-2015-4000), experimental      not vulnerable (OK): no DH EXPORT ciphers, no common prime detected
 BEAST (CVE-2011-3389)                     TLS1: ECDHE-RSA-AES128-SHA
                                                 ECDHE-RSA-AES256-SHA
                                                 DHE-RSA-AES128-SHA
                                                 DHE-RSA-AES256-SHA
                                                 ECDHE-RSA-DES-CBC3-SHA
                                                 EDH-RSA-DES-CBC3-SHA
                                                 AES128-SHA AES256-SHA
                                                 DES-CBC3-SHA 
                                           VULNERABLE -- but also supports higher protocols  TLSv1.1 TLSv1.2 (likely mitigated)
 LUCKY13 (CVE-2013-0169), experimental     potentially VULNERABLE, uses cipher block chaining (CBC) ciphers with TLS. Check patches
 Winshock (CVE-2014-6321), experimental    not vulnerable (OK) - CAMELLIA or ECDHE_RSA GCM ciphers found
 RC4 (CVE-2013-2566, CVE-2015-2808)        no RC4 ciphers detected (OK)


 Running client simulations (HTTP) via sockets 

 Browser                      Protocol  Cipher Suite Name (OpenSSL)       Forward Secrecy
------------------------------------------------------------------------------------------------
 Android 4.4.2                TLSv1.2   ECDHE-RSA-AES128-GCM-SHA256       256 bit ECDH (P-256)
 Android 5.0.0                TLSv1.2   ECDHE-RSA-AES128-GCM-SHA256       256 bit ECDH (P-256)
 Android 6.0                  TLSv1.2   ECDHE-RSA-AES128-GCM-SHA256       256 bit ECDH (P-256)
 Android 7.0 (native)         TLSv1.2   ECDHE-RSA-AES128-GCM-SHA256       256 bit ECDH (P-256)
 Android 8.1 (native)         TLSv1.2   ECDHE-RSA-AES128-GCM-SHA256       256 bit ECDH (P-256)
 Android 9.0 (native)         TLSv1.2   ECDHE-RSA-AES128-GCM-SHA256       256 bit ECDH (P-256)
 Android 10.0 (native)        TLSv1.2   ECDHE-RSA-AES128-GCM-SHA256       256 bit ECDH (P-256)
 Chrome 74 (Win 10)           TLSv1.2   ECDHE-RSA-AES128-GCM-SHA256       256 bit ECDH (P-256)
 Chrome 79 (Win 10)           TLSv1.2   ECDHE-RSA-AES128-GCM-SHA256       256 bit ECDH (P-256)
 Firefox 66 (Win 8.1/10)      TLSv1.2   ECDHE-RSA-AES128-GCM-SHA256       256 bit ECDH (P-256)
 Firefox 71 (Win 10)          TLSv1.2   ECDHE-RSA-AES128-GCM-SHA256       256 bit ECDH (P-256)
 IE 6 XP                      No connection
 IE 8 Win 7                   TLSv1.0   ECDHE-RSA-AES128-SHA              256 bit ECDH (P-256)
 IE 8 XP                      TLSv1.0   DES-CBC3-SHA                      No FS
 IE 11 Win 7                  TLSv1.2   DHE-RSA-AES128-GCM-SHA256         4096 bit DH  
 IE 11 Win 8.1                TLSv1.2   DHE-RSA-AES128-GCM-SHA256         4096 bit DH  
 IE 11 Win Phone 8.1          TLSv1.2   ECDHE-RSA-AES128-SHA256           256 bit ECDH (P-256)
 IE 11 Win 10                 TLSv1.2   ECDHE-RSA-AES128-GCM-SHA256       256 bit ECDH (P-256)
 Edge 15 Win 10               TLSv1.2   ECDHE-RSA-AES128-GCM-SHA256       256 bit ECDH (P-256)
 Edge 17 (Win 10)             TLSv1.2   ECDHE-RSA-AES128-GCM-SHA256       256 bit ECDH (P-256)
 Opera 66 (Win 10)            TLSv1.2   ECDHE-RSA-AES128-GCM-SHA256       256 bit ECDH (P-256)
 Safari 9 iOS 9               TLSv1.2   ECDHE-RSA-AES128-GCM-SHA256       256 bit ECDH (P-256)
 Safari 9 OS X 10.11          TLSv1.2   ECDHE-RSA-AES128-GCM-SHA256       256 bit ECDH (P-256)
 Safari 10 OS X 10.12         TLSv1.2   ECDHE-RSA-AES128-GCM-SHA256       256 bit ECDH (P-256)
 Safari 12.1 (iOS 12.2)       TLSv1.2   ECDHE-RSA-AES128-GCM-SHA256       256 bit ECDH (P-256)
 Safari 13.0 (macOS 10.14.6)  TLSv1.2   ECDHE-RSA-AES128-GCM-SHA256       256 bit ECDH (P-256)
 Apple ATS 9 iOS 9            TLSv1.2   ECDHE-RSA-AES128-GCM-SHA256       256 bit ECDH (P-256)
 Java 6u45                    No connection
 Java 7u25                    TLSv1.0   ECDHE-RSA-AES128-SHA              256 bit ECDH (P-256)
 Java 8u161                   TLSv1.2   ECDHE-RSA-AES128-GCM-SHA256       256 bit ECDH (P-256)
 Java 11.0.2 (OpenJDK)        TLSv1.2   ECDHE-RSA-AES128-GCM-SHA256       256 bit ECDH (P-256)
 Java 12.0.1 (OpenJDK)        TLSv1.2   ECDHE-RSA-AES128-GCM-SHA256       256 bit ECDH (P-256)
 OpenSSL 1.0.2e               TLSv1.2   ECDHE-RSA-AES128-GCM-SHA256       256 bit ECDH (P-256)
 OpenSSL 1.1.0l (Debian)      TLSv1.2   ECDHE-RSA-AES128-GCM-SHA256       256 bit ECDH (P-256)
 OpenSSL 1.1.1d (Debian)      TLSv1.2   ECDHE-RSA-AES128-GCM-SHA256       256 bit ECDH (P-256)
 Thunderbird (68.3)           TLSv1.2   ECDHE-RSA-AES128-GCM-SHA256       256 bit ECDH (P-256)


 Rating (experimental) 

 Rating specs (not complete)  SSL Labs's 'SSL Server Rating Guide' (version 2009q from 2020-01-30)
 Specification documentation  https://github.com/ssllabs/research/wiki/SSL-Server-Rating-Guide
 Protocol Support (weighted)  95 (28)
 Key Exchange     (weighted)  90 (27)
 Cipher Strength  (weighted)  90 (36)
 Final Score                  91
 Overall Grade                B
 Grade cap reasons            Grade capped to B. TLS 1.1 offered
                              Grade capped to B. TLS 1.0 offered

```
</details> 

5,6.<br>
 ssh-keygen<br>
 Копируетм ключ публичный id_rsa на удаленный сервер<br>
 в папке ~/.ssh можно создать файл config, изменить порт подключения для безопасности<br> 
 ```
Host *.*.*.*
Port 2007
User shev
IdentityFile ~/.ssh/id_rsa
BatchMode yes

```
 после этого подключаюсь 
```
ssh *.*.*.*.
```

7.
sudo tcpdump -i wlp4s0 -c 100 not port 22 and not port 53 -w test.pcap<br>
tcpdump: listening on wlp4s0, link-type EN10MB (Ethernet), capture size 262144 bytes<br>
<br>
^C42 packets captured<br>
42 packets received by filter<br>
0 packets dropped by kernel<br>

!.[9].(8.png)

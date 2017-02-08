---
layout: default
---

# Setting up a Remote Workspace

To setup a Remote Workspace, you will need to first start with a computer that
has the following software installed on it:

* Windows 10 or Windows Server 2012 R2 or Windows Server 2016
* [.NET Framework 4.6.1](https://www.microsoft.com/en-us/download/details.aspx?id=49981) or greater

## Installing the SSL certificate

All communications with the remote computer *must* be via the *https* protocol.
In order to encrypt communications between the client and the server, you must
install an SSL certificate on the server computer.

There are two types of certificates that you can create: a self signed
certificate, and a certificate signed by a trusted third party (a [certificate
authority](https://en.wikipedia.org/wiki/Certificate_authority)). The former is
the equivalent of issuing your own ID card. The latter is the equivalent of
going to your government and obtaining an official ID card. The latter almost
always involves more process (to verify the authenticity of the request) and
optionally the payment of fees.

### Obtaining a self-signed certificate

We provide instructions below on creating a self-signed certificate. If you
install a self-signed certificate on your R server, we will always show a
warning that tells you that the certificate wasn't issued from a trusted 3rd
party. The reason why this is important is that an attacker can substitute their
own certificate and capture all of the traffic between the client and the
server. This is why self-signed certificate should only ever be used for testing
scenarios and never in production.

To issue a self-signed certificate, you will first need to log onto the server
computer using an administrator account. Open a new administrator PowerShell
command prompt and issue the following command, replacing
`"remote-machine-name"` with the fully qualified domain name of your server
computer. 

```
New-SelfSignedCertificate -CertStoreLocation Cert:\LocalMachine\My -DnsName "remote-machine-name"
```

If you have never run Powershell before on the server computer, you will need to
enable running of commands explicitly:

```
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
```



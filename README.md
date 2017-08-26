# scripts

O script faz uma consulta no whois para retornar os prefixos ipv4
e em seguida realiza consulta nos LG da Seabone e Level3 buscando unicamente o ap-path:

```{r, engine='bash', count_lines}
curl -s https://raw.githubusercontent.com/maviaelsilva/scripts/master/bgp_prefix_by_asn.sh | bash /dev/stdin 999999
```

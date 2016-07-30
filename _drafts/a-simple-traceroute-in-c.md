---
title: A Simple Traceroute in C
date: 2016-07-30 12:13:50.481000000 Z
tags:
- C
---

Traceroute

```c

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/time.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <netdb.h>
#include <fcntl.h>
#include <arpa/inet.h>

#define PORT 33434
#define MAXHOPS 64

#define BUFFSIZE 1024
char buff[BUFFSIZE];


char *host2ip(const char *host)
{
    struct hostent *he = gethostbyname(host);
    struct in_addr **addr_list;
    addr_list = (struct in_addr **) he->h_addr_list;
    for( int i = 0; addr_list[i] != NULL; i++ )
    {
        return inet_ntoa(*addr_list[i]);
    }
    return "ERROR";
}


int main(int argc, char const *argv[])
{
    char ip[100] = "";
    if( argc>1 )
    {
        strcpy(ip, host2ip(argv[1]));
        printf("Tracing route to: %s\n", ip);
    }
    else
    {
        printf("No IP given.\n");
        return -1;
        // strcpy(ip,"160.45.170.10"); // fu-berlin.de
        // strcpy(ip,"74.125.224.72"); // google.com
    }

    struct sockaddr_in my_addr;
    my_addr.sin_family = AF_INET;
    my_addr.sin_port = htons(PORT);
    my_addr.sin_addr.s_addr = inet_addr("127.0.0.1"); // localhost
    memset(my_addr.sin_zero, '\0', sizeof my_addr.sin_zero);

    struct sockaddr_in dest_addr;
    dest_addr.sin_family = AF_INET;
    dest_addr.sin_port = htons(PORT);
    dest_addr.sin_addr.s_addr = inet_addr(ip);
    memset(dest_addr.sin_zero, '\0', sizeof dest_addr.sin_zero);

    struct sockaddr_in cli_addr;
    socklen_t cli_len = sizeof(struct sockaddr_in);;

    int ttl = 1;
    clock_t c0 = clock();
    clock_t c1;
    while( ttl <= MAXHOPS )
    {
        int sender = socket(PF_INET, SOCK_DGRAM, 0);
        int recver = socket(PF_INET, SOCK_RAW, IPPROTO_ICMP);
        int opt = setsockopt(sender, IPPROTO_IP, IP_TTL, &ttl, sizeof ttl);
        if( sender<0 || recver<0 || opt<0 )
        {
            perror("socket");
            return -2;
        }
        // printf("sockets set up\n");

        if( sendto(sender, buff, sizeof buff, 0, (struct sockaddr *)&dest_addr, sizeof dest_addr)<0 )
        {
            perror("sendto");
            return -3;
        }
        // printf("test package sent\n");

        if ( recvfrom(recver, buff, sizeof buff, 0, (struct sockaddr *)&cli_addr, &cli_len)<0 )
        {
            perror("recfrom");
            return -4;
        }
        else
        {
            // printf("received header\n");
            inet_ntop(AF_INET, &cli_addr.sin_addr, buff, INET_ADDRSTRLEN);
            c1 = clock();
            double dur = (c1 - c0) * 1000. / CLOCKS_PER_SEC;
            printf("%2d %18s\t %2.2f ms\n", ttl, buff, dur);
            if( !strncmp(buff, ip, sizeof ip) )
                break;
            ttl++;
        }
    }
}
```

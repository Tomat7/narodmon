
#include <errno.h>
#include <libconfig.h>
#include <modbus/modbus.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <syslog.h>

#define MB_CONFIG_FILE "plc39.cfg"
#define NB_REGS 12
//#define MB_READ_ONE_REG

/* Данный пример читает конфигурационный файл и выводит его составляющие  */

int main(int argc, char **argv)
{
// ======= SYSLOG test ======
  openlog("Modbus", LOG_NDELAY, LOG_DAEMON);
  syslog(LOG_DEBUG, "Start test logging ...");
//  closelog();
// =======

    /* используются свои типы. */
    config_t cfg;
//    config_setting_t *setting;
    config_setting_t *regs;
    modbus_t *mb;
    int rc = 0;
    uint16_t *myregs;
    uint16_t allregs[NB_REGS];
    const char *str;
    char sl[80];


    config_init(&cfg); /* обязательная инициализация */

    /* Читаем файл. Если ошибка, то завершаем работу */
    if (!config_read_file(&cfg, MB_CONFIG_FILE))
    {
        fprintf(stderr, "%s:%d - %s\n", config_error_file(&cfg), config_error_line(&cfg),
                config_error_text(&cfg));
        config_destroy(&cfg);
        return (EXIT_FAILURE);
    }

    /* Поиск некого значения "name". */
    if (config_lookup_string(&cfg, "name", &str))
        printf("%s  ", str);
    else
        fprintf(stderr, "No 'name' ");
    strcat(sl, str);
    strcat(sl, " ");

    if (config_lookup_string(&cfg, "title", &str))
        printf("%s  ", str);
    else
        fprintf(stderr, "No 'title' ");
    strcat(sl, str);
    strcat(sl, " ");
    
    if (config_lookup_string(&cfg, "ip", &str))
        printf("%s  ", str);
    else
    {
        fprintf(stderr, "No 'ip' ");
        return (-1);
    }
    strcat(sl, str);
    strcat(sl, " ");
    
    printf("\n%s ", sl);
    syslog(LOG_DEBUG, "%s", sl);

    mb = modbus_new_tcp(str, 502);

    /* Save original timeout */
    uint32_t old_response_to_sec;
    uint32_t old_response_to_usec;
    modbus_get_response_timeout(mb, &old_response_to_sec, &old_response_to_usec);
    printf("Current timeouts: %d sec %d usec. \n", old_response_to_sec, old_response_to_usec);
    
    if (modbus_connect(mb) == -1)
    {
        fprintf(stderr, "MB connection failed: %s\n", modbus_strerror(errno));
        modbus_free(mb);
        return -1;
    }

    /* get ALL HOLDING registers by ONE request */
    rc = modbus_read_registers(mb, 0, NB_REGS, allregs);
    if (rc == -1)
    {
        fprintf(stderr, "MB multi-read error: %s \n", modbus_strerror(errno));
        return -1;
    }

    /* get registers configuration */
    regs = config_lookup(&cfg, "regs");
    if (regs)
    {
        int nbregs = config_setting_length(regs);
        printf(" %d  %d\n\n", nbregs, rc);

        myregs = (uint16_t *)malloc(nbregs * sizeof(uint16_t));
        memset(myregs, 0, nbregs * sizeof(uint16_t));

        for (int i = 0; i < nbregs; ++i)
        {
            config_setting_t *reg = config_setting_get_elem(regs, i);
            const char *rname, *access;
            int addr;

            if (!(config_setting_lookup_string(reg, "rname", &rname) &&
                  config_setting_lookup_string(reg, "access", &access) &&
                  config_setting_lookup_int(reg, "addr", &addr)))
	    {
		fprintf(stderr, "Error reading REG-config %d \n", i);
		syslog(LOG_DEBUG, "Error reading REG-config %d \n", i);
                continue;
	    }

            *(myregs + i) = allregs[addr];

            if (strcmp(access, "rw") == 0)
	    {
                printf("   %-10s  %-5s  %3d %7d\n", rname, access, addr, (uint16_t) * (myregs + i));
                syslog(LOG_DEBUG, "   %-10s  %-5s  %3d %7d\n", rname, access, addr, (uint16_t) * (myregs + i));
	    }
            else
	    {
                printf("   %-10s  %-5s  %3d %7d\n", rname, access, addr, (int16_t) * (myregs + i));
	        syslog(LOG_DEBUG, "   %-10s  %-5s  %3d %7d\n", rname, access, addr, (int16_t) * (myregs + i));
	    }
        }
    }
    /* end reading HOLDING registers */

    putchar('\n');

    modbus_close(mb);
    modbus_free(mb);
    free(myregs);
    config_destroy(&cfg);
    /* Освободить память обязательно, если это не конец программы */
  closelog();

    return (EXIT_SUCCESS);
}

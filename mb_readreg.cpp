
#include <errno.h>
//#include <libconfig.h>
#include <modbus/modbus.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <syslog.h>

#define MB_IPADDR "192.168.1.32"
#define MB_MYREG 4
//#define MB_FLOAT

int main(int argc, char** argv)
{
  // ======= SYSLOG test ======
  openlog("Modbus", LOG_NDELAY, LOG_LOCAL0);
  //  syslog(LOG_DEBUG, "Start test logging ...");
  //  closelog();
  // =======

  //    for (;;) {}
  //    while
  //    do til

  if (argc != 4) {
    printf("Read one holding REGISTER by Modbus-TCP from slave on IP_ADDR\n");
    printf("and print result in FORMAT (i for INTEGER, f for FLOAT).\n");
    printf("Usage: %s IP_ADDR REGISTER FORMAT\n", argv[0]);
    return -1;
  }

  modbus_t* mb;
  int rc = 0;
  uint16_t myreg;
  uint16_t* myregs;
  myregs = &myreg;

  //  const char *str;
  //  char sl[80];
  float temp;

  //  printf("\n%s ", sl);

  const char* ip = argv[1];
  int reg = atoi(argv[2]);

  syslog(LOG_INFO, "trying %s H-reg: %d", ip, reg);

  mb = modbus_new_tcp(ip, 502);

  if (modbus_connect(mb) == -1) {
    fprintf(stderr, "MB connection failed: %s\n", modbus_strerror(errno));
    modbus_free(mb);
    syslog(LOG_ERR, "error connecting %s", ip);
    return -1;
  } // else

  //      printf("new OK\n");

  rc = modbus_read_registers(mb, reg, 1, myregs);

  if (rc == -1) {
    fprintf(stderr, "MB one-read error: %s \n", modbus_strerror(errno));
    syslog(LOG_ERR, "error readinging %s H-reg: %d", ip, reg);
    return -1;
  } // else

  //      printf("read OK\n");

  if (strcmp(argv[3], "f") == 0) {
    temp = ((int16_t)*myregs) / (float)100.0;
    printf("%.2f\n", temp);
  } else
    printf("%d\n", (int16_t)*myregs);

  //  printf("%7d  %.2f\n", (int16_t)*myregs, temp);

  //  syslog(LOG_DEBUG, "   %-10s  %-5s  %3d %7d\n", rname, access, addr,
  //         (uint16_t) * (myregs + i));
  /* end reading HOLDING registers */

  //  putchar('\n');

  modbus_close(mb);
  modbus_free(mb);
  //  free(myregs);

  /* Освободить память обязательно, если это не конец программы */
  closelog();

  return (EXIT_SUCCESS);
}

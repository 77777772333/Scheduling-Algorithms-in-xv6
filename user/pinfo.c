#include "kernel/types.h"
#include "user/user.h"
#include "kernel/stat.h"

int
main(void)
{
  struct pinfo_all info;
  int n = getpinfo(&info);
  printf("PID\tSTATE\tQ\tREMAIN\n");
  for (int i = 0; i < n; i++) {
    printf("%d\t%d\t%d\t%d\n",
      info.infos[i].pid,
      info.infos[i].state,
      info.infos[i].queue_level,
      info.infos[i].remaining_ticks);
  }
  exit(0);
}

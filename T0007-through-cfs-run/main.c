#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include "sched_utils.h"

void *periodic_change(void* param)
{
        int pid = *((int*) param);
        for (int i = 0;; ++i) {
                unsigned int flags = 0;
                struct sched_attr attr;
                attr.size = sizeof(attr);
                attr.sched_flags = 0;
                attr.sched_nice = 0;
                attr.sched_priority = 0;
                if (i%2){
                        /* This creates a 10ms/30ms reservation */
                        attr.sched_policy = SCHED_DEADLINE;
                        attr.sched_runtime = 30 * 1000 * 1000;
                        attr.sched_period = attr.sched_deadline = 40 * 1000 * 1000;
                } else {
                        attr.sched_policy = SCHED_OTHER;
                }
                if (sched_setattr(pid, &attr, flags) < 0)
                        perror("sched_setattr()");
                sleep(1);
        }
        return NULL;
}


int main (void)
{
        pthread_t tid;
        int pid = getpid();
        pthread_create(&tid, NULL, periodic_change, (void *) &pid);

        for(;;);
        return 0;
}




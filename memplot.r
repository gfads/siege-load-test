#!/usr/bin/env Rscript

library(ggplot2)

pdf(NULL) # Avoid creating Rplots.pdf file

scenarios <- sub('.log', '', list.files('./mem'))
plotsdir <- './plots/'
dir.create(plotsdir, showWarnings=FALSE)

no_tracing <- read.csv(file='./mem/no_tracing.log', head=FALSE)$V1
instrumented <- read.csv(file='./mem/instrumented.log', head=FALSE)$V1
rbinder <- read.csv(file='./mem/rbinder.log', head=FALSE)$V1

a <- rbind(
           cbind(seq(1,length(no_tracing)), no_tracing, rep(1)),
           cbind(seq(1,length(instrumented)), instrumented, rep(2)),
           cbind(seq(1,length(rbinder)), rbinder, rep(3))
           )

df <- as.data.frame(a)
colnames(df) <- c("time", "memory", "scenario")
df$scenario <- as.factor(df$scenario)

theme_set(theme_bw())
p <- ggplot(df, aes(x=time, y=memory, group=scenario, shape=scenario)) +
  #geom_line() +
  geom_point() +
  labs(x="Time (s)", y="Memory Consumption (MB)") +
  scale_shape_manual(name="Scenario",
                     values=c(1, 6, 17),
                     labels=c("No Tracing",
                              "Instrumented Microservices",
                              "Proxies + Syscalls Monitoring")
                     )

ggsave(filename=paste(plotsdir, 'mem.pdf', sep=''), width=10)

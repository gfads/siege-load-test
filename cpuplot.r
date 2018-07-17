#!/usr/bin/env Rscript

library(ggplot2)

pdf(NULL) # Avoid creating Rplots.pdf file

print_table_data <- function(no_tracing, instrumented, rbinder) {
  means <- c(round(mean(no_tracing),   digits = 2),
             round(mean(instrumented), digits = 2),
             round(mean(rbinder)     , digits = 2))
  overhead <- c(0,
                round(means[2] / means[1], digits = 2),
                round(means[3] / means[1], digits = 2))
  print(data.frame(means, overhead))
}

scenarios <- sub('.log', '', list.files('./cpu'))
plotsdir <- './plots/'
dir.create(plotsdir, showWarnings=FALSE)

no_tracing <- read.csv(file='./cpu/no_tracing.log', head=FALSE)$V1
instrumented <- read.csv(file='./cpu/instrumented.log', head=FALSE)$V1
rbinder <- read.csv(file='./cpu/rbinder.log', head=FALSE)$V1

print_table_data(no_tracing, instrumented, rbinder)

# Aggregate data.
reps <- rep(1:(length(no_tracing)/60), each=60)
reps <- append(reps, rep(reps[length(reps)], (length(no_tracing)-length(reps))))
no_tracing <- aggregate(no_tracing, FUN=mean, by=list(reps))[,2]

reps <- rep(1:(length(instrumented)/60), each=60)
reps <- append(reps, rep(reps[length(reps)], (length(instrumented)-length(reps))))
instrumented <- aggregate(instrumented, FUN=mean, by=list(reps))[,2]

reps <- rep(1:(length(rbinder)/60), each=60)
reps <- append(reps, rep(reps[length(reps)], (length(rbinder)-length(reps))))
rbinder <- aggregate(rbinder, FUN=mean, by=list(reps))[,2]

a <- rbind(
           cbind(seq(1,length(no_tracing)), no_tracing, rep(1)),
           cbind(seq(1,length(instrumented)), instrumented, rep(2)),
           cbind(seq(1,length(rbinder)), rbinder, rep(3))
           )

df <- as.data.frame(a)
colnames(df) <- c("time", "cpu", "scenario")
df$scenario <- as.factor(df$scenario)

theme_set(theme_bw())
p <- ggplot(df, aes(x=time, y=cpu, shape=scenario)) +
  geom_line() +
  geom_point() +
  labs(x="Time (min)", y="CPU Usage (%)") +
  scale_shape_manual(name="Scenario",
                     values=c(1, 6, 17),
                     labels=c("No Tracing",
                              "Instrumented Microservices",
                              "Rbinder")
                     ) +
  theme(legend.position="top")

ggsave(filename=paste(plotsdir, 'cpu.pdf', sep=''), height=3)

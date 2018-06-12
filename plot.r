#!/usr/bin/env Rscript

pdf(NULL) # Avoid creating Rplots.pdf

library(ggplot2)

scenarios <- sub('.log', '', list.files('./log'))
means = c()
errs = c()
plotsdir <- './plots/'
dir.create(plotsdir, showWarnings=FALSE)

for(scenario in scenarios) {
  filename <- paste('./log/', scenario, '.log', sep='')
  data <- read.csv(file=filename, head=FALSE)
  error <- qt(0.975, df=length(data$V1)-1)*sd(data$V1)/sqrt(length(data$V1))

  means[scenario] = mean(data$V1)
  errs[scenario] = error

  # Boxplot.
  png(filename=paste(plotsdir, scenario, '-boxplot.png', sep=''))
  boxplot(data$V1)
  dev.off()
}

# Bar plot with error bars.
scenarios <- c('Instrumented Microservices', 'No Tracing', 'Rbinder')
plotdata <- data.frame(scenarios, means, errs)
colnames(plotdata) <- c('scenario', 'mean', 'err')
print(plotdata)
theme_set(theme_bw())
fills <- c("instr", "no_tracing", "rbinder")
plot <- ggplot(data=plotdata, aes(x=scenario, y=mean, fill=fills)) +
                geom_bar(stat="identity", colour="black", width=.5) +
                geom_errorbar(aes(ymin=mean-err, ymax=mean+err),
                              width=.2,
                              position=position_dodge(.9))
plot + labs(x="", y="Response Time (s)") +
  scale_fill_manual("legend",
                    values = c("instr"="white",
                               "rbinder"="white",
                               "no_tracing"="white"),
                    guide=FALSE)
ggsave(filename=paste(plotsdir, 'means.pdf', sep=''), height=3)

# Overhead bar plot.
overhead = c()
overerrs = c()
overhead["instrumented"] = means["instrumented"] / means["no_tracing"]
overhead["rbinder"] = means["rbinder"] / means["no_tracing"]
overerrs["instrumented"] = errs["instrumented"] / means["no_tracing"]
overerrs["rbinder"] = errs["rbinder"] / means["no_tracing"]
scenarios <- c("Instrumented Microservices", "Proxies + Syscalls Monitoring")
overdata <- data.frame(scenarios, overhead, overerrs)
colnames(overdata) <- c('scenario', 'overhead', 'err')
print(means["no_tracing"])
print(overdata)
fills <- c("instr", "rbinder")
plot <- ggplot(data=overdata, aes(x=scenario, y=overhead, fill=fills)) +
                geom_bar(stat="identity", colour="black") +
                geom_errorbar(aes(ymin=overhead-err, ymax=overhead+err),
                              width=.2,
                              position=position_dodge(.9))

plot + labs(x="", y="Response Time Overhead") +
  coord_cartesian(ylim=c(0, 1.3)) +
  scale_fill_manual("legend", values = c("instr" = "white", "rbinder" = "gray"), guide=FALSE)
ggsave(filename=paste(plotsdir, 'overhead.pdf', sep=''), height=3)

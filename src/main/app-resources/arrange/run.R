#!/usr/bin/Rscript --vanilla --slave --quiet

# import rciop package
library("rciop")

# retrieve the parameters value from workflow or job default value
period <- rciop.getparam('period')

rciop.log("INFO", paste("The period is:", period, sep=" "))

OUTDIR <- paste(TMPDIR, "output", sep="/")

msg.trap <- capture.output(suppressMessages(library(ff)))

dir.create(OUTDIR)

setwd(OUTDIR)

f <- file("stdin")
open(f)
hdfs.df <- read.csv(f, sep=',')

colnames(hdfs.df) <- c('hdfs_path')

hdfs.df$date <- as.Date(substr(splitPathFile(as.character(hdfs.df$hdfs_path))$file,15,22), format='%Y%m%d')

hdfs.df$period <- cut(hdfs.df$date, breaks=period)

df.split <- split(hdfs.df, hdfs.df$period)

msg.trap <- capture.output(suppressMessages(Map(write.table, x=df.split, file=paste(names(df.split), 'tsv', sep='.'), row.names=F, col.names=F, quote=F)))

res <- rciop.publish(OUTDIR, TRUE, FALSE)

write(res$output, "")

if (res$exit.code==0) { published <- res$output }

rciop.log("DEBUG", paste("published:", published, sep=" "))

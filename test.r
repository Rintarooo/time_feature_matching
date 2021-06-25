getwd()
setwd("/Users/satourintarou/Documents/AIST/Course/ExperimentDesignInCS/homework/hw2/data")

orb <- read.csv("orb.csv", header = F)
orb
akaze <- read.csv("akaze.csv", header = F)
akaze
brisk <- read.csv("brisk.csv", header = F)
brisk

mean(orb$V1)
mean(akaze$V1)
mean(brisk$V1)

n_sample <- 100
dataf = data.frame(runtime = c(orb$V1, akaze$V1, brisk$V1), 
	algorithm = rep(c("ORB", "AKAZE", "BRISK"), each = n_sample))
head(dataf)
tail(dataf)
summary(dataf)
typeof(dataf$runtime)
typeof(dataf$algorithm)
names(dataf)

# calculation sample size
delta <- 5
power <- 0.80
alpha <- 0.05
sigma <- sd(orb$V1)
power.t.test(power = power, delta = delta, sd = sigma, sig.level = alpha, type = 'one.sample', alternative = "two.sided")
sigma <- sd(akaze$V1)
power.t.test(power = power, delta = delta, sd = sigma, sig.level = alpha, type = 'one.sample', alternative = "two.sided")
sigma <- sd(brisk$V1)
power.t.test(power = power, delta = delta, sd = sigma, sig.level = alpha, type = 'one.sample', alternative = "two.sided")


# box plot
library("ggplot2")# install.packages("ggplot2")
# png("boxplot.png")
p <- ggplot(data = dataf, aes(x = algorithm , y = runtime, fill=algorithm)) + geom_boxplot()
pp <- p + ggtitle("Run time of matching 50 feature points in 3 different algorithm")
ppp <- pp + geom_point()
pppp <- ppp + ylab("run time[ms]")
pppp
# dev.off()

# anova 
model <- aov(runtime ~ algorithm, data = dataf)
summary.aov(model)

# normality assumption
shapiro.test(model$residuals)
library(car)
# png("qqplot.png")
qqPlot(model$residuals, pch = 16, lwd = 3, cex = 2, las = 1)
# dev.off()

# Homoscedasticity
fligner.test(runtime ~ algorithm, data = dataf)
# png("fligner.png")
plot(x = model$fitted.values, y = model$residuals, xlab = "fitted values", ylab = "residuals")
# dev.off()

# post-hoc test
tukey <- TukeyHSD(aov(dataf$runtime ~ dataf$algorithm), conf.level=0.95)
tukey
# png("tukey.png")
plot(tukey)
# dev.off()
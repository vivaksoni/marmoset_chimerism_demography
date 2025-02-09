#Perform cross validation to identify optimal tolerance
library(abc)
library(spatstat)


#stats without filtering
t_abc <- head(read.table("empirical_inference/ABC/readyForABC.stats", h=T, sep='\t'), 1154)
t_par <- head(read.table("empirical_inference/ABC/params/params",
                         sep='\t', col.names = c('param','Nanc','Nbot','T','Ncurr')), 1154)
#get time and make stats:
t_par <- cbind(t_par[,c(2:5)])
t_sim_stats <- cbind(t_abc[,c(2:45)])

cv_ridge <- cv4abc(t_par, t_sim_stats, nval=1101, tols=0.05, statistic="median", method="ridge", transf="none")
summary(cv_ridge)
plot(cv_ridge)

cv_nnet <- cv4abc(t_par, t_sim_stats,nval=100, tols=c(0.05, 0.08, 0.1), statistic="median", method="neuralnet", transf="none")
summary(cv_nnet)
plot(cv_nnet)

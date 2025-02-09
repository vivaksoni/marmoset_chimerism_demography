library(abc)
library(spatstat)
library(weights)

#stats without filtering
t_abc <- head(read.table("empirical_inference/ABC/readyForABC.stats", h=T, sep='\t'), 1154)
t_par <- head(read.table("empirical_inference/ABC/params",
                         sep='\t', col.names = c('param','Nanc','Nbot','T','Ncurr')), 1154)
#get time and make stats:
t_par <- cbind(t_par[,c(2:5)])
t_sim_stats <- cbind(t_abc[,c(2:45)])

t_emp_stats <- read.table("empirical_inference/ABC/10kb_ABC.stats", h=T)

rej <- abc(target=t_emp_stats, param=t_par, sumstat=t_sim_stats, tol=0.1, method="rejection")
summary(rej)

nnet <- abc(target=t_emp_stats, param=t_par, sumstat=t_sim_stats, tol=0.08, method="neuralnet")
summary(nnet)

hist(nnet, breaks=10)
hist(rej, breaks=10)
df <- nnet$adj.values

par(mfrow=c(2,2))
m_adj_values <- nnet$adj.values
m_weights <- nnet$weights

#Inference performed multiple times and then taking a mean:
num_reps <- 50
Nanc <- c() 
Nbot <- c()
Tbot <- c()
Ncurr <- c()
i = 1
while(i<=num_reps){
  print (i)
  nnet <- abc(target=t_emp_stats, param=t_par, sumstat=t_sim_stats, tol=0.05, method="neuralnet")
  if (i==1){
    m_adj_values <- nnet$adj.values
    m_weights <- nnet$weights
  }
  else{
    m_adj_values <- rbind(m_adj_values, nnet$adj.values)
    m_weights <- c(m_weights, nnet$weights)
  }
  #calculating errors:
  est1 <- weighted.median(nnet$adj.values[,1], nnet$weights, na.rm = TRUE)
  est2 <- weighted.median(nnet$adj.values[,2], nnet$weights, na.rm = TRUE)
  est3 <- weighted.median(nnet$adj.values[,3], nnet$weights, na.rm = TRUE)
  est4 <- weighted.median(nnet$adj.values[,4], nnet$weights, na.rm = TRUE)
  
  if (est1 < 0){Nanc <- c(Nanc, 0.0)}
  else{Nanc <- c(Nanc, est1)}
  if (est2 < 0){Nbot <- c(Nbot, 0.0)}
  else{Nbot <- c(Nbot, est2)}
  if (est3 < 0){Tbot <- c(Tbot, 0.0)}
  else{Tbot <- c(Tbot, est3)}
  if (est4 < 0){Ncurr <- c(Ncurr, 0.0)}
  else{Ncurr <- c(Ncurr, est4)}
  i = i + 1
}

Nanc_pos <- wtd.hist(x=m_adj_values[,1], weight=m_weights, plot=F)
Nbot_pos <- wtd.hist(x=m_adj_values[,2], weight=m_weights, plot=F)
Tbot_pos <- wtd.hist(x=m_adj_values[,3], weight=m_weights, plot=F)
Ncurr_pos <- wtd.hist(x=m_adj_values[,4], weight=m_weights, plot=F)
#Write posteriors to file
write.table(m_adj_values, "empirical_inference/ABC/posteriors.txt", 
            sep='\t', quote=FALSE, row.names=FALSE)

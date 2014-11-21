\name{icc_beta}
\alias{icc_beta}
\docType{package}
\title{
Intraclass correlation used to assess variability of lower-order relationships across higher-order processes/units.
}
\description{
A function and vignettes for computing the intraclass correlation described in Aguinis & Culpepper (in press). iccbeta quantifies the share of variance in an outcome variable that is attributed to heterogeneity in slopes due to higher-order processes/units. 
}
\usage{
icc_beta(X, l2id, T, vy)	
}

\arguments{
\item{X}{The design \code{matrix} of fixed effects from a lmer model.}

\item{l2id}{A \code{vector} that identifies group membership. The vector must be coded as a sequence of integers from 1 to J, the number of groups.}

\item{T}{A \code{matrix} of the estimated variance-covariance matrix of a lmer model fit.}

\item{vy}{The variance of the outcome variable.}
}

\author{
Steven Andrew Culpepper,
Herman Aguinis

Maintainer: Steven Andrew Culpepper <sculpepp@illinois.edu>
}

\references{
Aguinis, H., & Culpepper, S.A. (in press). An expanded decision making procedure for examining cross-level interaction effects with multilevel modeling. \emph{Organizational Research Methods}. Available at: \url{http://mypage.iu.edu/~haguinis/pubs.html}
}
\seealso{
\code{\link[lme4]{lmer}}, \code{\link{model.matrix}}, \code{\link[lme4]{VarCorr}}, \code{\link[RLRsim]{LRTSim}}, \code{\link{Hofmann}}, \code{\link{simICCdata}}
}
\examples{
\dontrun{
#Simulated Data Example from Aguinis & Culpepper (in press)
data(simICCdata)
  require(lme4)
  
  #computing icca
  vy = var(simICCdata$Y)
  lmm0 <- lmer(Y ~ (1|l2id),data=simICCdata,REML=F)
  VarCorr(lmm0)$l2id[1,1]/vy
    
  #Estimating random slopes model
  lmm1  <- lmer(Y~I(X1-m_X1)+I(X2-m_X2) +(I(X1-m_X1)+I(X2-m_X2)|l2id),data=simICCdata2,REML=F)
  X = model.matrix(lmm1)
  p=ncol(X)
  T1  = VarCorr(lmm1) $l2id[1:p,1:p]
  #computing iccb
  #Notice '+1' because icc_beta assumes l2ids are from 1 to 30.
  icc_beta(X,simICCdata2$l2id+1,T1,vy)$rho_beta
  
#Hofmann et al. (2000) Example
data(Hofmann)
  require(lme4)

  #Random-Intercepts Model
  lmmHofmann0 = lmer(helping ~ (1|id),data=Hofmann)
  vy_Hofmann = var(Hofmann[,'helping'])
  #computing icca
  VarCorr(lmmHofmann0)$id[1,1]/vy_Hofmann

  #Estimating Group-Mean Centered Random Slopes Model, no level 2 variables
  lmmHofmann1  <- lmer(helping ~ mood_grp_cent + (mood_grp_cent |id),data=Hofmann,REML=F)
  X_Hofmann = model.matrix(lmmHofmann1)
  P = ncol(X_Hofmann)
  T1_Hofmann  = VarCorr(lmmHofmann1)$id[1:P,1:P]
  #computing iccb
  icc_beta(X_Hofmann,Hofmann[,'id'],T1_Hofmann,vy_Hofmann)$rho_beta
  
  #Performing LR test
  library('RLRsim')
  lmmHofmann1a  <- lmer(helping ~ mood_grp_cent + (1 |id),data=Hofmann,REML=F)
  obs.LRT <- 2*(logLik(lmmHofmann1)-logLik(lmmHofmann1a))[1]
  X <- getME(lmmHofmann1,"X")
  Z <- t(as.matrix(getME(lmmHofmann1,"Zt")))
  sim.LRT <- LRTSim(X, Z, 0, diag(ncol(Z)))
  (pval <- mean(sim.LRT > obs.LRT))
}  
}
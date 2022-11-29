# Load required packages-------------------------------------------------------

library(unmarked)
library(dplyr)
library(ggplot2)

# Simulate a dataset similar to real data--------------------------------------

set.seed(1)

# Ideally this should be done before collecting any data

design <- list(
  M = 50*15, # number of "sites" (in this case site-years)
  Jdist = 2,      # number of distance bins
  Jrem = 3       # number of removal periods
)

# Distance breaks
db <- c(0,25,50)

# Models, defined as a list of formulas
# Habitat and year covariate on lambda, detection models are intercept-only
# Random effect of point
forms <- list(lambda = ~Habitat+Year+(1|Point), dist=~1, rem=~1)

# Coefficients
# Assuming an abundance of ~ 5 individuals at baseline (habitat A)
# Then we specify that  B has an abundance of 6 individuals
coefs <- list(lambda = c(intercept=log(5), HabitatB=0.18,
                         # 2% decline in abundance per year
                         Year=log(0.98),
                         # standard deviation on point random effect
                         Point=0.1),
              # detection sigma = median distance
              dist = c(intercept=log(median(db))),
              # removal p = ~0.27
              rem = c(intercept=-1))

# Functions to control simulated covariates

# Give each site 15 years of data
yr_function <- function(n){
  stopifnot(n %% 15 == 0)
  sites <- n/15
  rep(0:14, sites) # 15 years of surveys
}

# Site ID
point_function <- function(n){
  stopifnot(n %% 15 == 0)
  sites <- n/15
  factor(rep(1:sites, each=15))
}

# Give each site a fixed habitat type
hab_function <- function(n){
  stopifnot(n %% 15 == 0)
  sites <- n/15
  hab <- sample(c("A","B"), sites, replace=TRUE)
  factor(rep(hab, each=15))
}

guide <- list(Point = list(dist=point_function),
              Year = list(dist=yr_function),
              Habitat = list(dist=hab_function))

# Simulate a dataset
umf_sim <- simulate("gdistremoval", formulas=forms, design=design, coefs=coefs,
                    guide=guide, unitsIn='m', dist.breaks=db,
                    output='abund')

head(umf_sim)

# Fit model to dataset to check
out <- gdistremoval(lambdaformula=~Habitat+Year+(1|Point), distanceformula=~1,
                    removalformula=~1, data=umf_sim, output='abund')

# Results are similar to specified coefficients
out


# Power analysis---------------------------------------------------------------

# Use the simulated dataset as the basis for power analysis

# Determine power to detect differences in density
# among 2 different habitat types (as specified above 5/6 per sample area)
# and power to detect a declining trend

# This ought to be done before collecting data, but for this example
# the data are already collected, so we're calculating power
# for the sample size that was actually collected

# We'll test for power to detect the differences in abundance
# among habitats that we specified above (contained in coefs vector)
# Our simulated dataset from above, out, is used to provide the desired
# sample size and other model settings (such as distance breaks, units, etc.)

pa <- powerAnalysis(out, coefs=coefs, nsim=100)

# Mediocre power to detect habitat differences at this sample size (0.71)
# Reasonable power to detect the yearly trend (0.81)

# Read in real data------------------------------------------------------------

# First read in the raw data:
acfl <- read.csv("acfl_roanoke_river.csv")
head(acfl)

# Use only those years with complete sampling
acfl <- acfl[acfl$Year %in% c(2022:2019, 2016:2005), ]


# Process real data------------------------------------------------------------

# Distance data

# Each row represents one unique distance/time bin with a count of observed ACFL
# (which can be 0, so no need to fill in the blanks).
distdata <- acfl %>%
  group_by(TransectName, Point, Year, DOY, Habitat) %>%
  summarize(dist25=sum(Count[DistanceBin=="L25"], na.rm=TRUE),
            dist50=sum(Count[DistanceBin=="G25"], na.rm=TRUE), .groups='drop')
head(distdata)

# Removal data
# The time bins are labelled 3 (0-3 min), 5 (3-5 min), and 10 (5-10 min).
# Need to remember to account for the different time lengths of each period later.
remdata <- acfl %>%
  group_by(TransectName, Point, Year, DOY, Habitat) %>%
  summarize(per3=sum(Count[TimeBin==3], na.rm=TRUE),
            per5=sum(Count[TimeBin==5], na.rm=TRUE),
            per10=sum(Count[TimeBin==10], na.rm=TRUE), .groups='drop')
head(remdata)

# Check that the counts of observations match between distance and removal
dsum <- apply(distdata[,6:7], 1, sum)
rsum <- apply(remdata[,6:8], 1, sum)
all(dsum==rsum)

# Make unmarkedFrame
# No observation covariates, since there aren't any unique covariates by removal period
# Site covariates
site_covs <- distdata[,c("TransectName", "Point", "Year", "DOY", "Habitat")]
site_covs$Habitat <- factor(site_covs$Habitat, levels=c("River Levee",
                            "Hardwood Plantation"))
site_covs$Year <- site_covs$Year - min(site_covs$Year) # Set first year (2005) as Year 0

# y matrices distance/removal
ydist <- as.matrix(distdata[,6:7])
yrem <- as.matrix(remdata[,6:8])

# Distance bin breaks
db <- c(0,25,50)

# Lengths of removal periods in minutes
per_lengths <- c(3, 2, 5)

# Construct unmarked frame
umf <- unmarkedFrameGDR(yDistance=ydist, yRemoval=yrem, numPrimary=1,
                        siteCovs=site_covs, dist.breaks=db, unitsIn='m',
                        period.lengths=per_lengths)
head(umf)
numSites(umf)
# Note there are 825 'sites' - 55 survey points x 15 yearly surveys per point.


# Fit and compare models-------------------------------------------------------

# Fit a set of candidate distance/removal models
# All models include a random intercept on lambda by Point
# Using default half-normal key function for distance model
mod_null <- gdistremoval(lambdaformula=~(1|Point), removalformula=~1,
                         distanceformula=~1, data=umf, output="abund")

# Habitat effect
mod_hab <- gdistremoval(lambdaformula=~Habitat + (1|Point), removalformula=~1,
                        distanceformula=~1, data=umf, output="abund")

# Year effect
mod_year <- gdistremoval(lambdaformula=~Year + (1|Point), removalformula=~1,
                         distanceformula=~1, data=umf, output="abund")

# Habitat and year effects
mod_habyear <- gdistremoval(lambdaformula=~Habitat+Year + (1|Point),
                            removalformula=~1, distanceformula=~1,
                            data=umf, output="abund")

# Habitat and year w/interaction effects
mod_habxyear <- gdistremoval(lambdaformula=~Habitat*Year + (1|Point),
                            removalformula=~1, distanceformula=~1,
                            data=umf, output="abund")

mods <- list(null=mod_null, hab=mod_hab, year=mod_year, habyear=mod_habyear, habxyear=mod_habxyear)
mods <- fitList(fits=mods)

# Rank the models with AIC
modSel(mods)

#          nPars     AIC delta   AICwt cumltvWt
# habxyear     6 4322.14  0.00 9.7e-01     0.97
# habyear      5 4329.85  7.71 2.0e-02     0.99
# year         4 4330.65  8.52 1.4e-02     1.00
# hab          4 4366.48 44.35 2.3e-10     1.00
# null         3 4367.29 45.15 1.5e-10     1.00

# Check model goodness of fit--------------------------------------------------

# Plot residuals (separately by data type)
plot(mod_habxyear)

# Parametric bootstrap
set.seed(123)
pb <- parboot(mod_habxyear, nsim=30)
plot(pb)
# Model does not appear to fit the data well, but this is a crude test

# Inference from top model-----------------------------------------------------

# Summary of top model
mod_habxyear

# Abundance:
# Random effects:
#  Groups        Name Variance Std.Dev.
#   Point (Intercept)    0.035    0.187

# Fixed effects:
#                                 Estimate      SE     z   P(>|z|)
# (Intercept)                       1.8360 0.08391 21.88 4.06e-106
# HabitatHardwood Plantation        0.4393 0.12746  3.45  5.67e-04
# Year                             -0.0270 0.00773 -3.49  4.77e-04
# HabitatHardwood Plantation:Year  -0.0455 0.01476 -3.08  2.07e-03
#
# Distance:
#  Estimate     SE   z P(>|z|)
#      2.81 0.0222 126       0
#
# Removal:
#  Estimate     SE     z  P(>|z|)
#    -0.682 0.0515 -13.2 6.44e-40
#
# AIC: 4322.137

# The baseline abundance in year 1 (river levee) is exp(1.836) or about 6.27 birds.
# There are significant differences in abundance between the two habitats and over time

# Plot predicted abundance by habitat and year

nd <- data.frame(Habitat=factor(levels(umf@siteCovs$Habitat),
                                levels=levels(umf@siteCovs$Habitat)),
                Year=rep(0:17, each=2))
pr <- predict(mod_habxyear, 'lambda', newdata=nd, re.form=NA)
pr <- cbind(pr, nd)

# Point-level predictions
pr_point <- predict(mod_habxyear, 'lambda')
pr_point <- cbind(pr_point, siteCovs(umf))

tiff("Figure_5.tiff", height=5, width=7, units='in', res=300, compression='lzw')
ggplot(data=pr, aes(x=Year+2005, y=Predicted)) +
  geom_point(data=pr_point, aes(col=Habitat), alpha=0.2) +
  geom_ribbon(aes(ymin=lower, ymax=upper, fill=Habitat), alpha=0.2) +
  geom_line(aes(col=Habitat)) +
  labs(y="ACFL abundance and 95% CI", x="Year") +
  theme_bw(base_size=14) +
  theme(panel.grid=element_blank(), legend.pos=c(0.8,0.8),
        strip.background=element_rect("white"))
dev.off()

# Abundance estimates at each site based on empirical Bayes methods
r <- ranef(mod_habxyear)
bup(r)

# Compare latent abundance estimates among habitat types
hab_comp <- function(x){
  c(river = mean(x[umf@siteCovs$Habitat == "River Levee"]),
    hardwood = mean(x[umf@siteCovs$Habitat == "Hardwood Plantation"]))
}

out_mat <- predict(r, func=hab_comp)
t(apply(out_mat, 1, function(x) c(mean=mean(x), quantile(x, c(0.025,0.975)))))

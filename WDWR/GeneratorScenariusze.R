library("MASS")

limit <- function(vec, min, max)
{
  lt_min = which(vec < min);
  for(i in lt_min) {
    vec[i] = min;
  }
  gt_max = which(vec > max);
  for(i in gt_max) {
    vec[i] = max;
  }
  vec
}


n = 100

mu = c(55, 40, 50, 35, 45, 30)

covariance = c( 1,   1,   0,   2,  -1,  -1,
                1,  16,  -6,  -6,  -2,  12,
                0,  -6,   4,   2,  -2,  -5,
                2,  -6,   2,  25,   0, -17,
               -1,  -2,  -2,   0,   9,  -5,
               -1,  12,  -5, -17,  -5,  36) 

path = "C:\\Users\\Dominik\\Desktop\\WDWR\\projekt\\WDWR\\Scenariusze.dat"				


sigma = matrix(covariance, 6, 6)
Rvec = mvrnorm(n = n , mu = mu, Sigma = sigma)
Rvec = limit(Rvec, min = 20, max = 60)

lines = c(paste("N = ", toString(n), ";"), "CostProd = ", "[")

for(i in 1:n)
{
  line = "[\t["
  l = length(Rvec[i,])
  str = sapply(Rvec[i,], function(v) toString(v))  
  line = paste(line, str[1], sep="") 
  
  for(j in 2:l)
  {
    if(j==4L) { line = paste(line, str[j], sep="], \t\t [") }
    else { line = paste(line, str[j], sep=", \t") }
  }
  
  line = paste(line, "]\t]")
  lines = append(lines, line)
}

lines = append(lines, c("];"))

file<-file(path)
writeLines(lines, file)
close(file)

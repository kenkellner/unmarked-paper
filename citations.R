library(scholar)

# Get article ID
id <- "HdZX5qUAAAAJ"
art <- get_publications(id, cstart = 0, pagesize = 100, flush = FALSE)
pub <- as.character(art$pubid[1])

# Get citation stats
art_dat <- get_article_cite_history(id, pub)
art_dat$year <- format(as.Date(paste(art_dat$year, 1, 1, sep="-")), "%Y")
art_dat$year <- as.numeric(art_dat$year)
art_dat <- art_dat[art_dat$year %in% 2011:2022,]
stopifnot(nrow(art_dat) == 12)

# Calculated on 11-30-2022
total_cites <- sum(art_dat$cites)
total_cites # 2100
stopifnot(total_cites >= 2000)

mean_cites <- mean(art_dat$cites[8:12])
mean_cites # 266.4
stopifnot(mean_cites >= 250)

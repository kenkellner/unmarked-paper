library(scholar)
library(ggplot2)
library(cowplot)

id <- "HdZX5qUAAAAJ"

art <- get_publications(id, cstart = 0, pagesize = 100, flush = FALSE)
pub <- as.character(art$pubid[1])

art_dat <- get_article_cite_history(id, pub)
art_dat$year <- as.Date(paste(art_dat$year, 1, 1, sep="-"))

art_dat$cumcites <- cumsum(art_dat$cites)

bplot <- ggplot(data=art_dat, aes(x=year, y=cumcites)) +
  geom_bar(stat='identity') +
  theme_bw(base_size=14) +
  theme(panel.grid=element_blank()) +
  labs(y="Total citations", x="Year")



art_dat_line <- art_dat[-nrow(art_dat),]
lplot <- ggplot(data=art_dat_line, aes(x=year, y=cites)) +
  geom_line() +
  geom_point() +
  theme_bw(base_size=14) +
  theme(panel.grid=element_blank()) +
  labs(y="Citations per year", x="Year")




png("Fig1.png", height=7, width=7, units='in', res=300)
plot_grid(bplot, lplot, nrow=2)
dev.off()



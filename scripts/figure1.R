
# -----------------------------------------------------------------------------
# Figure 1. Cosing Similarity of Immigration to Key Terms by Decade
# -----------------------------------------------------------------------------

    years <- seq(1810, 2000, by=10)

    x.st <- c("immigration")
    y.st <- c("job", "school", "crime", "family")

    df.final <- data.frame()

    for(i in 1:length(years) ){

        wv   <- hi.wv[[i]]
        x.wv <- wv[x.st, , drop = FALSE]
        y.wv <- wv[y.st, , drop = FALSE]
        cos <- sim2(x = x.wv, y = y.wv, method = "cosine", norm = "l2")

        df.temp  <- cbind(melt(cos), years[i]) 
        df.final  <- rbind(df.final, df.temp) 
    }

    colnames(df.final) <- c("focal","term", "cosine", "year")

# -----------------------------------------------------------------------------
# PLOT
# -----------------------------------------------------------------------------

    p.cos <- df.final %>%
        filter(year >= 1880) %>%
        ggplot(aes(year, cosine, group = term) ) +
        geom_line(aes(color = term) ) +
        xlab("Decade") +
        ylab("Cosine Similarity to 'Immigration'") +
        scale_x_continuous(breaks = seq(1880, 2000, by = 20))

    png("fig1_immigr_cosine_plot.png", 
        width = 8, height = 5, units = 'in', res = 150)
    p.cos
    dev.off()

# -----------------------------------------------------------------------------
# The END
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Figure 1. Cosing Similarity of Immigration to Key Terms by Decade
# -----------------------------------------------------------------------------

years <- seq(1810, 2000, by = 10)

x_st <- c("immigration")
y_st <- c("job", "school", "crime", "family")

df_final <- data_frame()

for (i in seq_len(length(years))) {

    wv <- hi_wv[[i]]
    x_wv <- wv[x_st, , drop = FALSE]
    y_wv <- wv[y_st, , drop = FALSE]
    cos <- sim2(x_wv, y_wv, method = "cosine", norm = "l2")

    df_temp  <- cbind(melt(as.matrix(cos)), years[i])
    df_final <- rbind(df_final, df_temp)
}

colnames(df_final) <- c("focal", "term", "cosine", "year")

# -----------------------------------------------------------------------------
# PLOT
# -----------------------------------------------------------------------------

p_cos <- df_final %>%
    filter(year >= 1880) %>%
    ggplot(aes(year, cosine, group = term)) +
    geom_line(aes(color = term)) +
    xlab("Decade") +
    ylab("Cosine Similarity to 'Immigration'") +
    scale_x_continuous(breaks = seq(1880, 2000, by = 20))

png("fig1_immigr_cosine_plot.png",
    width = 8, height = 5, units = "in", res = 150
)
p_cos
dev.off()

# -----------------------------------------------------------------------------
# The END
# -----------------------------------------------------------------------------

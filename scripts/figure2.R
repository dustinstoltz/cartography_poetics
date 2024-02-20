# -----------------------------------------------------------------------------
# Figure 2. Immigrant and Citizen to Cultural Dimensions
# -----------------------------------------------------------------------------

years <- seq(1810, 2000, by = 10)

search_imm <- c("immigrants", "immigrant", "immigration")
search_cit <- c("citizens", "citizenship", "citizen")

# -------------------------------------------------------------------------
# CREATE RACE DIMENSION
dims <- df_anchors %>% filter(relation == "racial" & in_embeddings == TRUE)
# i = 1

df_a <- data.frame(matrix(nrow = length(years), ncol = 3))
colnames(df_a) <- c("Immigration", "Citizenship", "Year")

for (i in seq_len(length(years))) {
    wv <- hi_wv[[i]]
    s_wv_imm <- text2map::get_centroid(search_imm, wv)
    s_wv_cit <- text2map::get_centroid(search_cit, wv)
    s_wv <- rbind(s_wv_imm, s_wv_cit)
    d_wv <- text2map::get_direction(dims[, 1:2], wv)
    r_imm <- sim2(
        x = d_wv, y = s_wv,
        method = "cosine", norm = "l2"
    )
    df_a[i, ] <- cbind(r_imm, years[i])
}

df_a$Dimension <- "Race"

# -------------------------------------------------------------------------
# CREATE CLASS DIMENSION
dims <- df_anchors %>% filter(relation == "affluence" & in_embeddings == TRUE)

df_b <- data.frame(matrix(nrow = length(years), ncol = 3))
colnames(df_b) <- c("Immigration", "Citizenship", "Year")

for (i in seq_len(length(years))) {
    wv <- hi_wv[[i]]
    s_wv_imm <- text2map::get_centroid(search_imm, wv)
    s_wv_cit <- text2map::get_centroid(search_cit, wv)
    s_wv <- rbind(s_wv_imm, s_wv_cit)
    d_wv <- text2map::get_direction(dims[, 1:2], wv)
    r_imm <- sim2(
        x = d_wv, y = s_wv,
        method = "cosine", norm = "l2"
    )
    df_b[i, ] <- cbind(r_imm, years[i])
}

df_b$Dimension <- "Affluence"

# -------------------------------------------------------------------------
# CREATE MORALITY DIMENSION
dims <- df_anchors %>% filter(relation == "morality" & in_embeddings == TRUE)

df_c <- data.frame(matrix(nrow = length(years), ncol = 3))
colnames(df_c) <- c("Immigration", "Citizenship", "Year")

for (i in seq_len(length(years))) {
    wv <- hi_wv[[i]]
    s_wv_imm <- text2map::get_centroid(search_imm, wv)
    s_wv_cit <- text2map::get_centroid(search_cit, wv)
    s_wv <- rbind(s_wv_imm, s_wv_cit)
    d_wv <- text2map::get_direction(dims[, 1:2], wv)
    r_imm <- sim2(
        x = d_wv, y = s_wv,
        method = "cosine", norm = "l2"
    )
    df_c[i, ] <- cbind(r_imm, years[i])
}

df_c$Dimension <- "Morality"

# -----------------------------------------------------------------------------
# Merge Datasets
# -----------------------------------------------------------------------------

df_all <- bind_rows(
    melt(df_a, id.vars = c("Year", "Dimension")),
    melt(df_b, id.vars = c("Year", "Dimension")),
    melt(df_c, id.vars = c("Year", "Dimension"))
)

colnames(df_all) <- c("year", "dimension", "term", "similarity")
# colnames(df_all)

# -----------------------------------------------------------------------------
#  Semantic Direction PLOTS
# -----------------------------------------------------------------------------

p_imm_line <- df_all %>%
    filter(year >= 1880 & dimension == "Race" | dimension == "Affluence") %>%
    dcast(year + term ~ dimension, value.var = "similarity") %>%
    ggplot(aes(x = Affluence, y = Race, group = term)) +
    geom_point(aes(color = term, shape = term), size = 2.5) +
    geom_text_repel(aes(label = year, hjust = .002)) +
    ylab("Race Dimension ('White' to 'Black')") +
    xlab("Affluence Dimension ('Low Class' to 'High Class')") +
    labs(subtitle = "Race and Affluence Dimensions")

p_imm_mor_line <- df_all %>%
    filter(year >= 1880 & dimension == "Race" | dimension == "Morality") %>%
    dcast(year + term ~ dimension, value.var = "similarity") %>%
    ggplot(aes(x = Morality, y = Race, group = term)) +
    geom_point(aes(color = term, shape = term), size = 2.5) +
    geom_text_repel(aes(label = year, hjust = .002)) +
    ylab("Race Dimension ('White' to 'Black')") +
    xlab("Morality Dimension ('Bad' to 'Good')") +
    labs(subtitle = "Race and Morality Dimensions")

png("fig2_immigr_race_affluence_morals_dims_plot.png",
    width = 11, height = 5, units = "in", res = 200
)
ggarrange(p_imm_line, p_imm_mor_line)
dev.off()

# -----------------------------------------------------------------------------
# THE END
# -----------------------------------------------------------------------------

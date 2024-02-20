# -----------------------------------------------------------------------------
# Get Concept Mover's Distance for All The News articles
# -----------------------------------------------------------------------------

# get anchor lists and build directions
im_ant <- df_anchors %>%
    filter(relation == "immigration" & in_embeddings == TRUE) %>%
    select(add, subtract)

ra_ant <- df_anchors %>%
    filter(relation == "racial" & in_embeddings == TRUE) %>%
    select(add, subtract)

i_cd <- text2map::get_direction(im_ant, ft.wv)
r_cd <- text2map::get_direction(ra_ant, ft.wv)

cd <- rbind(i_cd, r_cd)


# run CMD
immigr_CMD <- text2map::CMDist(
    dtm = news_dtm_99,
    cw = c(
        "immigration", "immigration job",
        "immigration school", "immigration crime",
        "immigration family"
    ),
    cv = cd,
    wv = ft.wv,
    scale = TRUE
)


colnames(immigr_CMD) <- c(
    "docs", "cmd.immigration", "cmd.immigration.job",
    "cmd.immigration.school", "cmd.immigration.crime",
    "cmd.immigration.family", "cmd.immigrants.pole.1",
    "cmd.black.pole.2"
)

# join with metadata
df_news <- left_join(news_data, immigr_CMD, by = c("id" = "docs"))
df_news <- df_news[order(df_news$date), ]
df_news$date <- as.Date(df_news$date, "%Y-%m-%d")
df_news$month.yr <- lubridate::ceiling_date(as.Date(df_news$date), "month")
# dim(df_news)
# colnames(df_news)


# -----------------------------------------------------------------------------
# Figure 4. News Articles' Conceptual Engagement Over Time (with CMD)
# -----------------------------------------------------------------------------

df_plot_4 <- df_news %>%
    select(
        date, cmd.immigration,
        cmd.immigration.job, cmd.immigration.school,
        cmd.immigration.family, cmd.immigration.crime,
        month.yr
    ) %>%
    filter(month.yr >= "2012-01-01" & month.yr <= "2018-03-01") %>%
    na.omit() %>%
    arrange(month.yr) %>%
    group_by(month.yr) %>%
    summarize(
        Immigration = mean(cmd.immigration, na.rm = TRUE),
        `Immigration + Job` = mean(cmd.immigration.job, na.rm = TRUE),
        `Immigration + School` = mean(cmd.immigration.school, na.rm = TRUE),
        `Immigration + Family` = mean(cmd.immigration.family, na.rm = TRUE),
        `Immigration + Crime` = mean(cmd.immigration.crime, na.rm = TRUE)
    ) %>%
    melt(., id.vars = "month.yr")


plot4 <- df_plot_4 %>%
    ggplot(aes(x = month.yr, y = value, color = variable)) +
    geom_smooth(aes(linetype = variable),
        method = "loess", formula = "y ~ x", se = FALSE, span = .3
    ) +
    xlab("Date") +
    ylab("Closeness to Concept") +
    theme(
        legend.spacing.x = unit(.25, "cm"),
        axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
        legend.text.align = 0
    ) +
    scale_x_date(
        date_breaks = "3 months", date_labels = "%b - %Y",
        limits = c(as.Date("2012-01-01"), as.Date("2018-03-01"))
    ) +
    scale_linetype_manual(values = c(
        "dotted", "longdash", "twodash",
        "dotdash", "solid"
    ))

png("fig4_immigr_cmd_plot.png",
    width = 8, height = 5, units = "in", res = 400
)
plot4
dev.off()

# -----------------------------------------------------------------------------
# Figure 5. News Articles’ Conceptual Engagement and Key Events (with CMD)
# -----------------------------------------------------------------------------

df_plot_5 <- df_news %>%
    select(date, cmd.immigration, month.yr) %>%
    filter(month.yr >= "2012-01-01" &
        month.yr <= "2018-03-01") %>%
    na.omit() %>%
    arrange(month.yr) %>%
    group_by(month.yr) %>%
    summarize(immigr = mean(cmd.immigration, na.rm = TRUE))

# Immigration CMD over time
plot5 <- df_plot_5 %>%
    ggplot(aes(x = month.yr, y = immigr)) +
    geom_line(aes(x = month.yr, y = immigr), linewidth = 1.5) +
    xlab("Date") +
    ylab('Closeness to "Immigration" Concept') +
    theme(
        legend.spacing.x = unit(.25, "cm"),
        axis.text.x = element_text(angle = 45, hjust = 1, linewidth = 8),
        legend.text.align = 0
    ) +
    scale_x_date(
        date_breaks = "3 months", date_labels = "%b - %Y",
        limits = c(as.Date("2012-01-01"), as.Date("2018-03-01"))
    )

# add event lines
for (i in seq_len(nrow(df_events))) {
    plot5 <- plot5 +
        geom_vline(
            xintercept = as.Date(df_events$x[i]),
            linetype = 4, alpha = 0.8
        )
}

plot5 <- plot5 +
    ggrepel::geom_text_repel(
        data = df_events,
        aes(x = as.Date(x), y = y, label = label),
        box.padding = 0.8,
        size = 4
    )

png("fig5_immigr_only_plot.png",
    width = 10, height = 7, units = "in", res = 400
)
plot5
dev.off()

# -----------------------------------------------------------------------------
# Figure 6. News Articles’ Engagement with Key Cultural Dimensions (with CMD)
# -----------------------------------------------------------------------------

df_plot_6a <- df_news %>%
    select(
        date, cmd.immigrants.pole.1,
        cmd.black.pole.2, month.yr
    ) %>%
    filter(month.yr >= "2012-01-01" &
        month.yr <= "2018-03-01") %>%
    na.omit() %>%
    arrange(month.yr) %>%
    group_by(month.yr) %>%
    summarize(
        immigr = mean(cmd.immigrants.pole.1, na.rm = TRUE),
        race = mean(cmd.black.pole.2, na.rm = TRUE)
    ) %>%
    rename(
        `Immigration Dimension ("Citizen" to "Immigrant")` = immigr,
        `Race Dimension ("White" to "Black")` = race
    ) %>%
    melt(., id.vars = "month.yr")

# CD CMDs over time
plot6a <- df_plot_6a %>%
    ggplot(aes(x = month.yr, y = value, color = variable)) +
    geom_smooth(method = "loess", formula = "y ~ x", span = .3, se = TRUE) +
    xlab("Date") +
    ylab("Closeness to Poles of Cultural Dimension") +
    theme(
        legend.spacing.x = unit(.25, "cm"),
        axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
        legend.text.align = 0
    ) +
    scale_x_date(
        date_breaks = "6 months", date_labels = "%b - %Y",
        limits = c(as.Date("2012-01-01"), as.Date("2018-03-01"))
    )


df_plot_6b <- df_news %>%
    select(
        date, cmd.immigrants.pole.1,
        cmd.black.pole.2, month.yr
    ) %>%
    filter(month.yr >= "2012-01-01" & month.yr <= "2018-03-01") %>%
    na.omit() %>%
    arrange(month.yr) %>%
    group_by(month.yr) %>%
    summarize(
        immigr = mean(cmd.immigrants.pole.1, na.rm = TRUE),
        race = mean(cmd.black.pole.2, na.rm = TRUE)
    ) %>%
    mutate(
        immigr.diff = immigr - lag(immigr),
        race.diff = race - lag(race)
    ) %>%
    select(month.yr, immigr.diff, race.diff) %>%
    melt(., id.vars = "month.yr")


plot6b <- df_plot_6b %>%
    ggplot(aes(x = month.yr, y = value, color = variable)) +
    geom_smooth(method = "loess", formula = "y ~ x", span = .3, se = FALSE) +
    geom_line(aes(month.yr, 0), 
                  color = "#353535", 
                  linetype = 4, linewidth = 1) +
    xlab("Date") +
    ylab("Deviation from Previous Month-Year") +
    theme(
        legend.spacing.x = unit(.25, "cm"),
        axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
        legend.text.align = 0
    ) +
    scale_x_date(
        date_breaks = "6 months", date_labels = "%b - %Y",
        limits = c(as.Date("2012-01-01"), as.Date("2018-03-01"))
    )


png("fig6_cd_plot_combined.png",
    width = 6, height = 8, units = "in", res = 400
)
ggarrange(plot6a, plot6b,
    align = "hv",
    ncol = 1, nrow = 2, common.legend = TRUE
)
dev.off()

# -----------------------------------------------------------------------------
# THE END
# -----------------------------------------------------------------------------

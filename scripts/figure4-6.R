# -----------------------------------------------------------------------------
# Get Concept Mover's Distance for All The News articles
# -----------------------------------------------------------------------------

    # get anchor lists and build directions
    im.ant <- df.anchors %>% 
                filter(relation=="immigration" & in_embeddings==TRUE) %>%
                select(add, subtract)

    ra.ant <- df.anchors %>% 
                filter(relation=="racial" & in_embeddings==TRUE) %>%
                select(add, subtract)

    i.cd <- CMDist::get_direction(im.ant, ft.wv)
    r.cd <- CMDist::get_direction(ra.ant, ft.wv)

    cd <- rbind(i.cd, r.cd)


    # run CMD
    immigr.CMD <- CMDist::CMDist(dtm=news.dtm.99, 
                        cw = c("immigration", "immigration job",
                            "immigration school", "immigration crime",
                            "immigration family"),
                        cv = cd,
                        wv = ft.wv, 
                        scale = TRUE)


    colnames(immigr.CMD) <- c("docs", "cmd.immigration","cmd.immigration.job",
                            "cmd.immigration.school", "cmd.immigration.crime", 
                            "cmd.immigration.family", "cmd.immigrants.pole.1", 
                            "cmd.black.pole.2")

    # join with metadata
    df.news <- left_join(news.data, immigr.CMD, by = c("id" = "docs"))
    df.news <- df.news[order(df.news$date),]
    df.news$date <- as.Date(df.news$date, "%Y-%m-%d")
    df.news$month.yr <- lubridate::ceiling_date(as.Date(df.news$date), "month")
    # dim(df.news)
    # colnames(df.news)

  
# -----------------------------------------------------------------------------
# Figure 4. News Articles' Conceptual Engagement Over Time (with CMD)
# -----------------------------------------------------------------------------

    df.plot.4 <- df.news %>%
        select(date, cmd.immigration, 
            cmd.immigration.job, cmd.immigration.school, 
            cmd.immigration.family, cmd.immigration.crime,
            month.yr) %>% 
        filter(month.yr>="2012-01-01" & 
               month.yr<="2018-03-01") %>%
        na.omit() %>%
        arrange(month.yr) %>%
        group_by(month.yr) %>%
        summarize(Immigration = mean(cmd.immigration, na.rm=TRUE),
                `Immigration + Job` = mean(cmd.immigration.job, na.rm=TRUE),
                `Immigration + School` = mean(cmd.immigration.school, na.rm=TRUE),
                `Immigration + Family` = mean(cmd.immigration.family, na.rm=TRUE),
                `Immigration + Crime`  = mean(cmd.immigration.crime, na.rm=TRUE)) %>%
        melt(., id.vars = "month.yr") 
        

    plot4 <- df.plot.4 %>%
            ggplot(aes(x = month.yr, y = value, color = variable)) +
            geom_smooth(aes(linetype = variable),
                        method="loess", formula="y ~ x", se=F, span=.3) +
      xlab("Date") +
      ylab('Closeness to Concept') +
      theme(legend.spacing.x = unit(.25, 'cm'),
            axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
            legend.text.align = 0) +
      scale_x_date(date_breaks = "3 months", date_labels = "%b - %Y", 
                   limits = c(as.Date("2012-01-01"), as.Date("2018-03-01"))) +
      scale_linetype_manual(values = c("dotted","longdash","twodash",
                                       "dotdash","solid"))

    png("fig4_immigr_cmd_plot.png", 
        width = 8, height = 5, units = 'in', res = 400)
    plot4
    dev.off()

# -----------------------------------------------------------------------------
# Figure 5. News Articles’ Conceptual Engagement and Key Events (with CMD)
# -----------------------------------------------------------------------------

    df.plot.5 <- df.news %>%
        select(date, cmd.immigration, month.yr) %>% 
        filter(month.yr>="2012-01-01" & 
               month.yr<="2018-03-01") %>%
        na.omit() %>%
        arrange(month.yr) %>%
        group_by(month.yr) %>%
        summarize(immigr = mean(cmd.immigration, na.rm=TRUE))

    #Immigration CMD over time
    plot5 <- df.plot.5 %>%
      ggplot(aes(x = month.yr, y = immigr)) +
      geom_line(aes(x = month.yr, y = immigr), size=1.5) +
      xlab("Date") +
      ylab('Closeness to "Immigration" Concept') +
      theme(legend.spacing.x = unit(.25, 'cm'),
            axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
            legend.text.align = 0) +
      scale_x_date(date_breaks = "3 months", date_labels = "%b - %Y", 
                   limits = c(as.Date("2012-01-01"), as.Date("2018-03-01")))
    
    # add event lines
    for(i in 1:nrow(df.events)){
        plot5 <- plot5 +
        geom_vline(xintercept = as.Date(df.events$x[i]), linetype = 4, alpha=0.8)
        }

    plot5 <- plot5 +
        ggrepel::geom_text_repel(data=df.events, 
                                 aes(x = as.Date(x), y = y, label = label),
                                 box.padding = 0.8,
                                 size = 4)
  
    png("fig5_immigr_only_plot.png", 
        width = 10, height = 7, units = 'in', res = 400)
    plot5
    dev.off()
        
# -----------------------------------------------------------------------------
# Figure 6. News Articles’ Engagement with Key Cultural Dimensions (with CMD)
# -----------------------------------------------------------------------------

df.plot.6a <- df.news %>%
    select(date, cmd.immigrants.pole.1, 
            cmd.black.pole.2, month.yr) %>% 
    filter(month.yr>="2012-01-01" & 
            month.yr<="2018-03-01") %>%
    na.omit() %>%
    arrange(month.yr) %>%
    group_by(month.yr) %>%
    summarize(immigr = mean(cmd.immigrants.pole.1, na.rm=TRUE),
            race = mean(cmd.black.pole.2, na.rm=TRUE)) %>% 
    rename(`Immigration Dimension ("Citizen" to "Immigrant")` = immigr,
        `Race Dimension ("White" to "Black")` = race) %>%
    melt(., id.vars = "month.yr") 

    # CD CMDs over time
plot6a <- df.plot.6a %>%
      ggplot(aes(x = month.yr, y = value, color = variable)) +
      geom_smooth(method = "loess", formula = "y ~ x", span = .3, se = TRUE) +
      xlab("Date") +
      ylab("Closeness to Poles of Cultural Dimension") +
      theme(legend.spacing.x = unit(.25, 'cm'),
            axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
            legend.text.align = 0) +
      scale_x_date(date_breaks = "6 months", date_labels = "%b - %Y", 
                   limits = c(as.Date("2012-01-01"), as.Date("2018-03-01")))


df.plot.6b <- df.news %>%
    select(date, cmd.immigrants.pole.1, 
           cmd.black.pole.2, month.yr) %>% 
    filter(month.yr>="2012-01-01" & month.yr<="2018-03-01") %>%
    na.omit() %>%
    arrange(month.yr) %>%
    group_by(month.yr) %>%
    summarize(immigr = mean(cmd.immigrants.pole.1, na.rm=TRUE),
              race = mean(cmd.black.pole.2, na.rm=TRUE)) %>% 
    mutate(immigr.diff = immigr - lag(immigr),
            race.diff = race - lag(race)) %>%
    select(month.yr, immigr.diff, race.diff) %>%
    melt(., id.vars = "month.yr") 


plot6b <- df.plot.6b %>%
        ggplot(aes(x = month.yr, y = value, color = variable)) +
        geom_smooth(method = "loess", formula = "y ~ x", span = .3, se = FALSE) +
        geom_line(aes(x = month.yr, y = 0), color = "#353535", linetype=4, size=1) +
    xlab("Date") +
    ylab("Deviation from Previous Month-Year") +
      theme(legend.spacing.x = unit(.25, 'cm'),
            axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
            legend.text.align = 0) +
      scale_x_date(date_breaks = "6 months", date_labels = "%b - %Y", 
                   limits = c(as.Date("2012-01-01"), as.Date("2018-03-01")))


    png("fig6_cd_plot_combined.png", 
        width = 6, height = 8, units = 'in', res = 400)
    ggarrange(plot6a, plot6b, align = "hv", 
              ncol = 1, nrow = 2, common.legend = TRUE)
    dev.off()

# -----------------------------------------------------------------------------
# THE END
# -----------------------------------------------------------------------------

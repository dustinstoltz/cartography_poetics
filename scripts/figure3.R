# -----------------------------------------------------------------------------
# Figure 3. News Article's Similarity to Press Releases with WMD
# -----------------------------------------------------------------------------
  
   p.1 <- news.data  %>%
        filter(
               #immigration_rf > 0 & 
               !is.na(immigration_discourse) &
               (publication == "Breitbart" | 
               publication == "Fox News"  |
               publication == "National Review")) %>%               
        filter(month_yr >= "2016-01-01" & month_yr <= "2017-06-01") %>% 
    ggplot(aes(x=as.Date(month_yr) ) ) +
            geom_smooth(aes(y=avg_sim_right, color = "Right-Leaning")) +
            geom_smooth(aes(y=avg_sim_left, color = "Left-Leaning")) +
            geom_line(y=0.546, color = "black", linetype=2) +
            facet_wrap(.~immigration_discourse, ncol=1) +
            labs(title=NULL,
                 subtitle = "Breitbart, Fox News, National Review",
                 x = "Date of Publication",
                 y = "Average Similarity to Press Releases",
                 color = "Press Releases") +
                 coord_cartesian( ylim=c(.5, .665) ) +
            theme(plot.title = element_blank(),
                  plot.subtitle=element_text(face="italic"),
                  axis.text.x = element_text(angle = 45, hjust = 1),
                  legend.position = "none") +
        scale_x_date(date_breaks = "3 months", date_labels = "%b - %Y") +
        scale_color_manual(name = "Press Releases",
                          values = c("#003366", "#8B1A1A"),
                          labels = c( "Left-Leaning", "Right-Leaning") )

    p.2 <- news.data  %>%
        filter(
            #    immigration_rf > 0 & 
               !is.na(immigration_discourse) &
               (publication == "Talking Points Memo" | 
                publication == "New York Times" |
               publication == "Buzzfeed News")) %>%               
        filter(month_yr >= "2016-01-01" & month_yr <= "2017-06-01") %>%
    ggplot(aes(x=as.Date(month_yr) ) ) +
            geom_smooth(aes(y=avg_sim_right, color = "Right-Leaning") ) +
            geom_smooth(aes(y=avg_sim_left, color = "Left-Leaning" ) ) +
            geom_line(y=0.546, color = "black", linetype=2) +
            facet_wrap(.~immigration_discourse, ncol=1) +
            labs(title=NULL,
                 subtitle = "Talking Points Memo, New York Times, Buzzfeed News",
                 x = "Date of Publication", 
                 y = NULL) +
                 coord_cartesian( ylim=c(.5, .665) ) +
            theme(plot.title = element_blank(),
                  plot.subtitle=element_text(face="italic"),
                  legend.title = element_text(color = "black", size = 9),
                  legend.text = element_text(size = 9),
                  axis.text.x = element_text(angle = 45, hjust = 1),
                  legend.direction = "vertical",
                legend.position = c(.65, .15),
                legend.justification = c("left", "top"),
                legend.box.just = "left",
                legend.margin = margin(6, 6, 6, 6) ) +
        scale_x_date(date_breaks = "3 months", date_labels = "%b - %Y") +
        scale_color_manual(name = "Press Releases",
                          values = c("#003366", "#8B1A1A"),
                          labels = c( "Left-Leaning", "Right-Leaning") )

    png("fig3_immigr_wmd_press_releases.png", 
    width = 8.3, height = 6, units = 'in', res = 400)
    ggarrange(p.1, p.2, align="hv", nrow=1, common.legend = FALSE)
    dev.off()

# -----------------------------------------------------------------------------
# THE END
# -----------------------------------------------------------------------------
